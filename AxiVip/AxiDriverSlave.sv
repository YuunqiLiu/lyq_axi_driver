`timescale 1ns/1ps

`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
`endif

`ifndef AXITRANSACTION
    `define AXITRANSACTION
    `include "AxiTransaction.sv"
`endif

`ifndef RICHMAILBOX
    `define RICHMAILBOX
    `include "RichMailbox.sv"
`endif

class AxiWChannelDataPack;

    bit [7:0]       data[4095:0];
    bit             strb[4095:0];
    bit [127:0]     user[255:0];

endclass

class AxiDriverSlave;

    AxiConfig                       cfg;
    AxiTransaction                  trans;
    RichMailbox                     mbx_aw,mbx_ar,mbx_w,mbx_b,mbx_r,mbx_otdw,mbx_otdr;
    RichMailbox                     mbx_write;
    virtual AxiInterfaceUnit.slave  vif;

    function new(AxiConfig cfg,virtual AxiInterfaceUnit.slave vif);
        this.vif = vif;
        set_config(cfg);
    endfunction

    function AxiTransaction create_trans();
        AxiTransaction trans;
        trans = new(cfg);
        create_trans = trans;
    endfunction

    function set_config(AxiConfig cfg);
        this.cfg = cfg;

        this.mbx_aw = new(cfg.driver_slave_send_fifo_depth);
        this.mbx_ar = new(cfg.driver_slave_send_fifo_depth);
        this.mbx_w  = new(cfg.driver_slave_send_fifo_depth);
        this.mbx_r  = new(cfg.driver_slave_recv_fifo_depth);
        this.mbx_b  = new(cfg.driver_slave_recv_fifo_depth);
        this.mbx_otdr = new(cfg.driver_slave_read_otd_depth);
        this.mbx_otdw = new(cfg.driver_slave_write_otd_depth);
        this.mbx_write = new();
    endfunction

    task initialize();
        //mbx = new(1);
    endtask
    
    task run();
        initialize();
        fork
            recv_aw();
            recv_ar();
            recv_w();
            send_b();
            send_r();
            write_merge_handler();

        join_none
    endtask


    task recv_write_trans(output AxiTransaction trans);
        mbx_write.get(trans);
    endtask

    task recv_read_trans(output AxiTransaction trans);
        mbx_ar.get(trans);
    endtask

    task send_trans(input AxiTransaction trans);
        automatic AxiTransaction trans_c;
        trans_c = new trans;
        if(trans_c.xact_type == AxiTransaction::WRITE)  mbx_b.put(trans_c);
        else                                            mbx_r.put(trans_c);
    endtask

    task write_merge_handler();
        AxiTransaction      trans_aw,trans;
        AxiWChannelDataPack pack;
        bit [7:0]           data[4095:0];
        int                 ptr,start_point,offset;
        int                 data_length;
        forever begin
            mbx_aw.get(trans_aw);
            mbx_w.get(pack);
            trans = new trans_aw;
            //$display("start to merge.");
            offset = trans.addr % (2**trans.size);
            ptr = 0;
            start_point = offset;
            data_length = (trans.len+1)*cfg.strb_width-offset;

            trans.data_length = data_length;
            trans.data = new[data_length];
            trans.strb = new[data_length];
            trans.user = new[trans.len+1];
            for(int i=0;i<data_length;i=i+1) begin
                trans.data[i] = pack.data[offset+i];
                trans.strb[i] = pack.strb[offset+i];
                //$display("ptr %d and s+j %d with data %h",i,offset+i,pack.data[offset+i]);
            end
            for(int i=0;i<=trans.len;i+=1) begin
                trans.user[i] = pack.user[i];
            end


            mbx_write.put(trans);
            //$display("end to merge.");
        end
    endtask

    function recv_trans_init(input AxiTransaction trans);
        int offset;
        offset = trans.addr % (2**trans.size);
        trans.data_length = (trans.len+1)*cfg.strb_width-offset;
        trans.data = new[trans.data_length];
        trans.strb = new[trans.data_length];
        trans.user = new[trans.len+1];
    endfunction

    task recv_aw();
        AxiTransaction trans;
        fork
        if(cfg.axi_driver_debug_enable) $display("AxiDriverSlave: recv_aw run.");
        forever begin
            if(!mbx_aw.full()) begin
                vif.awready <= 1;
                do @vif.aclk; while(!(vif.awvalid && vif.awready));
                trans = new(cfg);
                trans.xact_type = AxiTransaction::WRITE;
                trans.id        = vif.awid;
                trans.addr      = vif.awaddr;
                trans.len       = vif.awlen;
                trans.size      = vif.awsize;
                trans.burst     = vif.awburst;
                trans.lock      = vif.awlock;
                trans.cache     = vif.awcache;
                trans.prot      = vif.awprot;
                trans.region    = vif.awregion;
                trans.auser     = vif.awuser;
                trans.resp      = new[1];
                mbx_aw.put(trans);
                //trans.display();
            end
            else begin
                vif.awready <= 0;
                @vif.aclk;
            end
        end
        join_none
    endtask

    task recv_ar();
        AxiTransaction trans;
        fork
        if(cfg.axi_driver_debug_enable) $display("AxiDriverSlave: recv_ar run.");
        forever begin
            if(!mbx_ar.full()) begin
                //if(cfg.axi_driver_debug_enable) $display("AxiDriverSlave: Start to recv a READ transaction from interface.");
                vif.arready <= 1;
                do begin
                    @vif.aclk; 
                    //if(cfg.axi_driver_debug_enable) $display("AxiDriverSlave: wait handshake valid/ready %d/%d.",vif.arvalid,vif.arready);
                end while(!(vif.arvalid && vif.arready));
                trans = new(cfg);
                trans.xact_type = AxiTransaction::READ;
                //trans.xact_type <= 
                trans.id        = vif.arid;
                trans.addr      = vif.araddr;
                trans.len       = vif.arlen;
                trans.size      = vif.arsize;
                trans.burst     = vif.arburst;
                trans.lock      = vif.arlock;
                trans.cache     = vif.arcache;
                trans.prot      = vif.arprot;
                trans.region    = vif.arregion;
                trans.auser     = vif.aruser;
                trans.resp      = new[trans.len+1];

                trans.size_num  = 2**trans.size;
                recv_trans_init(trans);
                mbx_ar.put(trans);
                //if(cfg.axi_driver_debug_enable) $display("AxiDriverSlave: send_ar run.");
            end
            else begin
                //if(cfg.axi_driver_debug_enable) $display("AxiDriverSlave: send_ar run.");
                vif.arready <= 0;
                @vif.aclk; 
            end
        end
        join_none
    endtask

    task recv_w();
        AxiWChannelDataPack pack;
        //bit [7:0]       data[4095:0];
        bit [127:0][7:0]data_copy;
        bit [127:0]     strb_copy;
        bit [127:0]     user_copy[255:0];
        int             data_ptr,handshake_ptr;
        fork
        if(cfg.axi_driver_debug_enable) $display("AxiDriverSlave: recv_w run.");
        forever begin
            if(!mbx_w.full()) begin
                data_ptr = 0;
                handshake_ptr = 0;
                pack = new();
                do begin
                    vif.wready <= 1;
                    do @vif.aclk; while(!(vif.wvalid && vif.wready));
                    data_copy = vif.wdata;
                    strb_copy = vif.wstrb;
                    //$display("data_cp_all %h",data_copy);
                    for(int i=0;i<cfg.strb_width;i=i+1) begin
                        pack.data[data_ptr] = data_copy[i];
                        pack.strb[data_ptr] = strb_copy[i];
                        //$display("data_cp:%d",data_copy[i]);
                        data_ptr += 1;
                    end
                    pack.user[handshake_ptr] = vif.wuser;
                    //$display("get data:%d",data_copy); 
                    handshake_ptr +=1;
                end while(!(vif.wlast && vif.wvalid && vif.wready));
                mbx_w.put(pack);
                //$display("ptr:%d",data_ptr);
            end
            else begin
                vif.wready <= 0;
                @vif.aclk; 
            end
        end
        join_none
    endtask

    task send_b();
    AxiTransaction trans;
    fork
    if(cfg.axi_driver_debug_enable) $display("AxiDriverSlave: send_b run.");
    forever begin
        if(!mbx_b.empty()) begin
            //$display("start to resp!!!!!");
            mbx_b.peek(trans);
            vif.bvalid <= 1'b1;
            vif.bresp  <= trans.resp[0];
            vif.bid    <= trans.id;
            vif.buser  <= trans.buser;
            //$display("transresp0 %b",trans.resp[0]);
            do @vif.aclk; while(!(vif.bvalid && vif.bready));
            mbx_b.get(trans);
        end
        else begin
            vif.bvalid <= 1'b0;
            @vif.aclk;
        end
    end
    join_none
    endtask

    task send_r();
        AxiTransaction trans;
        bit [63:0] current_addr,up_boundary;
        int len_ptr,current_num,sel_byte,current_ptr;
        bit [127:0][7:0] data;

        fork
        forever begin
            if(!mbx_r.empty()) begin
                mbx_r.peek(trans);

                current_ptr     = 0;
                current_addr    = trans.addr;
                for(int i=0;i<=trans.len;i=i+1) begin
                    //Data prepare
                    up_boundary = (current_addr/trans.size_num + 1) * trans.size_num;
                    current_num = up_boundary-current_addr;
                    data        = 0;
                    //$display("current addr %d",current_addr);
                    //$display("current num %d",current_num);
                    for(int i=0;i<current_num;i=i+1) begin
                    //$display("runing");
                        sel_byte        = (current_addr+i) % cfg.wstrb_width;
                        data[sel_byte]  = trans.data[current_ptr];
                    //$display("data %d",trans.data[current_ptr]);
                        current_ptr     +=1;
                    end
                    current_addr += current_num;

                    //One handshake
                    vif.rvalid  <= 1'b1;
                    vif.rid     <= trans.id;
                    vif.rdata   <= data;
                    vif.ruser   <= trans.user[i];
                    vif.rresp   <= trans.resp[i];
                    vif.rlast   <= (i == trans.len) ? 1'b1 : 1'b0;
                    do @vif.aclk; while(!(vif.rvalid && vif.rready));
                end

                mbx_r.get(trans);
            end
            else begin
                vif.rvalid <= 1'b0;
                @vif.aclk;
            end
        end
        join_none
    endtask





endclass:AxiDriverSlave



            //for(int i=0;i<=trans.len;i=i+1) begin
            //    //if(i==0) start_point = offset;
            //    //else     start_point = 0;
            //    for(int j=0;start_point+j<cfg.strb_width;j=j+1) begin
            //        
            //        trans_aw.data[ptr] = pack.data[start_point+ptr];
            //        $display("ptr %d and s+j %d with data %h",ptr,start_point+ptr,pack.data[start_point+ptr]);
            //        ptr += 1;
            //    end
            //end