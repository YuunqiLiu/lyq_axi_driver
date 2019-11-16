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

`ifndef AXITRANSMAILBOXIBK
    `define AXITRANSMAILBOXIBK
    `include "AxiTransMailboxIBK.sv"
`endif

`ifndef AXICONFIGDEFINE
    `define AXICONFIGDEFINE
    `include "AxiConfigDefine.sv"
`endif

`ifndef AXIOTDMESSAGE
    `define AXIOTDMESSAGE
    `include "AxiOtdMessage.sv"
`endif

class AxiRChannelDataPack;

    bit [`AXI_IF_ID_WIDTH-1:0]      id;
    bit [7:0]                       data[4095:0];
    bit [`AXI_IF_USER_WIDTH-1:0]    user[255:0];

endclass

class AxiBChannelDataPack;

    bit [`AXI_IF_ID_WIDTH-1:0]      id;
    bit [1:0]                       resp;
    bit [`AXI_IF_USER_WIDTH-1:0]    user;

endclass

class AxiDriverMaster;

    AxiConfig                       cfg;
    AxiTransaction                  trans;
    AxiOtdMessage                   otdmsg_w,otdmsg_r;
    AxiTransMailboxIBK              mbxibid_waitb,mbxibid_waitr;
    RichMailbox                     mbx_p1b;//Type AxiBChannelDataPack
    RichMailbox                     mbx_p1r;//Type AxiRChannelDataPack
    RichMailbox                     mbx_aw,mbx_w,mbx_ar,mbx_r,mbx_b,mbx_otdw,mbx_otdr;//Type AxiTransaction
    virtual AxiInterfaceUnit.master vif;

    function new(input AxiConfig cfg,virtual AxiInterfaceUnit.master vif);
        this.vif = vif;
        set_config(cfg);
    endfunction

    function set_config(input AxiConfig cfg);
        this.cfg = cfg;
        this.mbx_aw = new(cfg.driver_master_send_fifo_depth);
        this.mbx_ar = new(cfg.driver_master_send_fifo_depth);
        this.mbx_w  = new(cfg.driver_master_send_fifo_depth);
        this.mbx_r  = new(cfg.driver_master_recv_fifo_depth);
        this.mbx_b  = new(cfg.driver_master_recv_fifo_depth);
        this.mbx_otdr = new(cfg.driver_master_read_otd_depth);
        this.mbx_otdw = new(cfg.driver_master_write_otd_depth);
        this.mbx_p1b = new(1);
        this.mbx_p1r = new(1);
        this.otdmsg_r = new(cfg);
        this.otdmsg_w = new(cfg);
        this.mbxibid_waitb = new;
        this.mbxibid_waitr = new;
    endfunction

    task initialize();
        //mbx = new(1);
    endtask

    task send_trans(input AxiTransaction trans);
        if(trans.xact_type == AxiTransaction::WRITE) send_write_trans(trans);
        else                                         send_read_trans(trans);
    endtask
    
    task send_read_trans(input AxiTransaction trans);
        AxiTransaction trans_ar,trans_waitr;
        if(trans.xact_type != AxiTransaction::READ) $finish;
        trans.copy_to(trans_ar);
        trans.copy_to(trans_waitr);
        otdmsg_r.put(trans.id);
        mbx_ar.put(trans_ar);
        mbxibid_waitr.put(trans_waitr,trans_waitr.id);
    endtask

    task send_write_trans(input AxiTransaction trans);
        AxiTransaction trans_aw,trans_w,trans_waitb;
        if(trans.xact_type != AxiTransaction::WRITE) $finish;
        trans.copy_to(trans_aw);
        trans.copy_to(trans_w);
        trans.copy_to(trans_waitb);
        otdmsg_w.put(trans.id);
        mbx_aw.put(trans_aw);
        mbx_w.put(trans_w);
        mbxibid_waitb.put(trans_waitb,trans_waitb.id);
    endtask

    task recv_read_trans(output AxiTransaction trans);
        mbx_r.get(trans);
        if(!otdmsg_r.exists(trans.id)) $finish;
        otdmsg_r.get(trans.id);

        //$display("recv read trans run");
    endtask

    task recv_write_trans(output AxiTransaction trans);
        mbx_b.get(trans);
        if(!otdmsg_w.exists(trans.id)) $finish;
        otdmsg_w.get(trans.id);
    endtask
    
    task run();
        if(cfg.axi_driver_debug_enable) $display("AxiDriverMaster: run.");
            
        initialize();
        fork
            send_aw();
            send_w();
            send_ar();
            recv_b();
            recv_r();
            process_b();
            process_r();
        join_none
    endtask

    task send_aw();
        AxiTransaction trans;
        fork
        if(cfg.axi_driver_debug_enable) $display("AxiDriverMaster: send_aw run.");
        forever begin
            if(!mbx_aw.empty()) begin
                mbx_aw.peek(trans);
                vif.awvalid <= 1'b1;
                vif.awid    <= trans.id;
                vif.awaddr  <= trans.addr;
                vif.awlen   <= trans.len;
                vif.awsize  <= trans.size;
                vif.awburst <= trans.burst;
                vif.awlock  <= trans.lock;
                vif.awcache <= trans.cache;
                vif.awprot  <= trans.prot;
                vif.awqos   <= trans.qos;
                vif.awregion<= trans.region;
                vif.awuser  <= trans.auser;
                do @vif.aclk; while(!(vif.awvalid && vif.awready));
                mbx_aw.get(trans);
            end
            else begin
                vif.awvalid <= 1'b0;
                @vif.aclk;
            end
        end
        join_none
    endtask

    task send_ar();
        AxiTransaction trans;
        fork 
        if(cfg.axi_driver_debug_enable) $display("AxiDriverMaster: send_ar run.");
        forever begin 
            if(!mbx_ar.empty()) begin
                //if(cfg.axi_driver_debug_enable) $display("AxiDriverMaster: Start to send a READ transaction to interface.");
                mbx_ar.peek(trans);
                vif.arvalid <= 1'b1;
                vif.arid    <= trans.id;
                vif.araddr  <= trans.addr;
                vif.arlen   <= trans.len;
                vif.arsize  <= trans.size;
                vif.arburst <= trans.burst;
                vif.arlock  <= trans.lock;
                vif.arcache <= trans.cache;
                vif.arprot  <= trans.prot;
                vif.arqos   <= trans.qos;
                vif.arregion<= trans.region;
                vif.aruser  <= trans.auser;
                do begin
                    @vif.aclk;
                    //if(cfg.axi_driver_debug_enable) $display("AxiDriverMaster: wait handshake valid/ready %d/%d.",vif.arvalid,vif.arready);
                end while(!(vif.arvalid && vif.arready));
                mbx_ar.get(trans);
                //if(cfg.axi_driver_debug_enable) $display("AxiDriverMaster: END to send a READ transaction to interface.");
            end
            else begin
                vif.arvalid <= 1'b0;
                @vif.aclk;
            end
        end
        join_none
    endtask

    task send_w();
        AxiTransaction      trans;
        int                 current_ptr;
        bit [63:0]          current_addr;
        int                 up_boundary;
        int                 current_num;
        int                 size;
        int                 sel_byte;
        bit [127:0][7:0]    data;
        bit [127:0]         strb;
        int                 handshake_cnt;

        fork
        if(cfg.axi_driver_debug_enable) $display("AxiDriverMaster: send_w run.");
        forever begin
            if(!mbx_w.empty()) begin
                mbx_w.peek(trans);

                current_ptr     = 0;   
                current_addr    = trans.addr;
                size = 2**trans.size;
                handshake_cnt = 0;
                do begin
                    up_boundary     = (current_addr/size + 1) * size;
                    current_num     = up_boundary - current_addr;
                    data = 0;
                    strb = 0;
                    for(int i=0;i<current_num;i=i+1) begin
                        sel_byte = (current_addr+i) % cfg.wstrb_width;
                        //$display("sel_byte %d",sel_byte);
                        data[sel_byte] = trans.data[current_ptr];
                        strb[sel_byte] = trans.strb[current_ptr];
                        current_ptr +=1 ;
                    end

                    //$display("handshake %d with addr %d and num %d",handshake_cnt,current_addr,current_num);
                    if(handshake_cnt ==trans.len) begin
                        vif.wlast <= 1'b1;
                        //$display("wlast send when handshake %d",handshake_cnt);
                    end
                    else                            vif.wlast <= 0;
                    vif.wvalid <= 1'b1;
                    vif.wdata  <= data;
                    vif.wstrb  <= strb;
                    vif.wuser  <= trans.user[handshake_cnt];
                    //$display("send wdata:%h",data);
                    
                    //current_ptr     += current_num;
                    current_addr    += current_num;
                    handshake_cnt   += 1;
                    do @vif.aclk; while(!(vif.wvalid && vif.wready));

                end while(current_addr < trans.addr +trans.data.size());
                mbx_w.get(trans);
            end
            else begin
                vif.wvalid <= 1'b0;
                vif.wlast <= 1'b0;
                @vif.aclk;
            end
        end
        join_none
    endtask

    task recv_b();
        AxiBChannelDataPack pack;
        fork
        if(cfg.axi_driver_debug_enable) $display("AxiDriverMaster: recv_b run.");
        forever begin
            if(!mbx_p1b.full()) begin
                pack = new;
                vif.bready <= 1'b1;
                do @vif.aclk; while(!(vif.bvalid && vif.bready));
                pack.resp = vif.bresp;
                pack.user = vif.buser;
                pack.id   = vif.bid;
                mbx_p1b.put(pack);
            end
            else begin
                vif.bready <= 1'b0;
                @vif.aclk;
            end
        end
        join_none
    endtask

    task recv_r();
        AxiRChannelDataPack pack;
        bit [127:0][7:0]    data;
        bit [127:0]         user_copy[255:0];
        int                 byte_ptr,hdsk_ptr;
        fork
        forever begin
            if( (!mbx_p1r.full())) begin
                byte_ptr = 0;
                hdsk_ptr = 0;
                pack = new();
                do begin
                    vif.rready <= 1'b1;
                    do @vif.aclk; while(!(vif.rvalid && vif.rready));
                    //Data read
                    data = vif.rdata;
                    for(int i=0;i<cfg.strb_width;i=i+1) begin
                        pack.data[byte_ptr] = data[i];
                        //$display("%d",data[i]);
                        byte_ptr += 1;
                    end
                    pack.user[hdsk_ptr] = vif.ruser;
                    pack.id             = vif.rid;

                    hdsk_ptr += 1;
                end while(!(vif.rlast && vif.rvalid && vif.rready));
                //$display("recv_r put result to mbx");
                //read_merge(trans_recv,pack,trans_send);
                mbx_p1r.put(pack);
                //$display("receive a read pack.");
            end
            else begin
                vif.rready <= 0;
                @vif.aclk;
            end
        end
        join_none

        //AxiTransaction trans;
        //for
        //forever begin
        //    if(mbx_otdr.num()!=0) begin
        //        vif.rready <= 1;
        //        do @vif.aclk; while(!(vif.rvalid && vif.rready));
        //        mbx_otdr.get(trans);
        //        trans.resp = vif.rresp;
        //    end 
        //    else begin
        //        vif.rready <= 0;
        //        @vif.aclk;
        //    end
        //end
        //join_none
    endtask

    task process_b();
        AxiTransaction trans;
        AxiBChannelDataPack pack;
        fork 
        forever begin
            //merge b
            mbx_p1b.peek(pack);
            if(mbxibid_waitb.empty(pack.id)) $finish;
            mbxibid_waitb.get(trans,pack.id);
            trans.buser   = pack.user;
            trans.resp[0] = pack.resp;

            //repo b
            mbx_b.put(trans);
            //otdmsg_w.get(trans.id);
            mbx_p1b.get(pack);
        end
        join_none
    endtask

    task process_r();
        AxiRChannelDataPack pack;
        AxiTransaction      trans;
        int                 start_point,offset;
        int                 data_length;
        
        fork
        forever begin
            //merge_r
            mbx_p1r.peek(pack);

            if(mbxibid_waitr.empty(pack.id)) $finish;
            mbxibid_waitr.get(trans,pack.id);

            offset = trans.addr % (2**trans.size);
            start_point = offset;
            data_length = (trans.len+1)*cfg.strb_width-offset;

            trans.data_length = data_length;
            trans.data = new[data_length];
            trans.strb = new[data_length];
            trans.user = new[trans.len+1];
            for(int i=0;i<data_length;i=i+1) begin
                trans.data[i] = pack.data[offset+i];
                trans.strb[i] = 1'b1;
                //$display("ptr %d and s+j %d with data %h",i,offset+i,pack.data[offset+i]);
            end
            for(int i=0;i<=trans.len;i+=1) begin
                trans.user[i] = pack.user[i];
            end

            //repo b
            mbx_r.put(trans);
            //$display("process a read pack.");
            
            
            //ostmsg_r.get(trans.id);
            mbx_p1r.get(pack);
        end
        join_none
    endtask


endclass:AxiDriverMaster

