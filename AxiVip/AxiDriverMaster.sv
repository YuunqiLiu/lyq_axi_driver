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

class AxiRChannelDataPack;

    bit [7:0]       data[4095:0];
    bit [127:0]     user[255:0];

endclass


class AxiDriverMaster;

    AxiConfig                       cfg;
    AxiTransaction                  trans;
    RichMailbox                     mbx_aw,mbx_w,mbx_ar,mbx_r,mbx_b,mbx_otdw,mbx_otdr;
    virtual AxiInterfaceUnit.master vif;

    function new(AxiConfig cfg,virtual AxiInterfaceUnit.master vif);
        this.vif = vif;
        set_config(cfg);
    endfunction



    function set_config(AxiConfig cfg);
        this.cfg = cfg;
        this.mbx_aw = new(cfg.driver_master_send_fifo_depth);
        this.mbx_ar = new(cfg.driver_master_send_fifo_depth);
        this.mbx_w  = new(cfg.driver_master_send_fifo_depth);
        this.mbx_r  = new(cfg.driver_master_recv_fifo_depth);
        this.mbx_b  = new(cfg.driver_master_recv_fifo_depth);
        this.mbx_otdr = new(cfg.driver_master_read_otd_depth);
        this.mbx_otdw = new(cfg.driver_master_write_otd_depth);
    endfunction

    task send_trans(AxiTransaction trans);
        AxiTransaction trans_aw,trans_w,trans_ar,trans_otdw,trans_otdr;
        if(trans.xact_type == AxiTransaction::WRITE) begin
            //if(cfg.axi_driver_debug_enable) $display("AxiDriverMaster: get a WRITE transaction.");
            trans_aw    = new trans;
            trans_w     = new trans;
            trans_otdw  = new trans;
            //$cast(trans_aw,trans.clone());
            //$cast(trans_w,trans.clone());
            //$cast(trans_otdw,trans.clone());
            mbx_aw.put(trans_aw);
            mbx_w.put(trans_w);
            mbx_otdw.put(trans_otdw);
        end
        else begin
            //if(cfg.axi_driver_debug_enable) $display("AxiDriverMaster: get a READ transaction.");
            trans_ar    = new trans;
            trans_otdr  = new trans;
            //trans_r  = new trans;
            //$cast(trans_ar,trans.clone());
            //$cast(trans_otdr,trans.clone());
            mbx_ar.put(trans_ar);
            mbx_otdr.put(trans_otdr);
            //if(cfg.axi_driver_debug_enable) $display("AxiDriverMaster: mbx_ar get a new trans with num %d.",mbx_ar.num());
            
        end
    endtask

    task read_merge(input AxiTransaction trans_in,input AxiRChannelDataPack pack,output AxiTransaction trans_out);
        int                 start_point,offset;
        int                 data_length;
        
        
        trans_out = trans_in;

        offset = trans_out.addr % (2**trans_out.size);
        start_point = offset;
        data_length = (trans_out.len+1)*cfg.strb_width-offset;

        trans_out.data_length = data_length;
        trans_out.data = new[data_length];
        trans_out.strb = new[data_length];
        trans_out.user = new[trans_out.len+1];
        for(int i=0;i<data_length;i=i+1) begin
            trans_out.data[i] = pack.data[offset+i];
            trans_out.strb[i] = 1'b1;
            //$display("ptr %d and s+j %d with data %h",i,offset+i,pack.data[offset+i]);
        end
        for(int i=0;i<=trans_out.len;i+=1) begin
            trans_out.user[i] = pack.user[i];
        end

    endtask



    task recv_read_trans(output AxiTransaction trans);
        mbx_r.get(trans);
    endtask

    task recv_write_trans(output AxiTransaction trans);
        mbx_b.get(trans);
    endtask


    task initialize();
        //mbx = new(1);
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
        join_none
    endtask

    task recv_b();
        AxiTransaction trans;
        bit tmp;
        fork
        if(cfg.axi_driver_debug_enable) $display("AxiDriverMaster: recv_b run.");
        forever begin
            if(!mbx_otdw.empty()) begin
                vif.bready <= 1'b1;
                tmp = vif.bvalid;
                do @vif.aclk; while(!(vif.bvalid && vif.bready));
                mbx_otdw.get(trans);
                trans.resp[0] = vif.bresp;
                mbx_b.put(trans);
            end
            else begin
                vif.bready <= 1'b0;
                @vif.aclk;
            end
        end
        join_none
    endtask

    task recv_r();
        AxiTransaction      trans_recv,trans_send;
        AxiRChannelDataPack pack;
        bit [127:0][7:0]    data;
        bit [127:0]         user_copy[255:0];
        int                 byte_ptr,hdsk_ptr;
        fork
        forever begin
            if( (!mbx_r.full()) && (!mbx_otdr.empty()) ) begin
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

                    hdsk_ptr += 1;
                end while(!(vif.rlast && vif.rvalid && vif.rready));
                //$display("recv_r put result to mbx");
                
                mbx_otdr.get(trans_recv);
                read_merge(trans_recv,pack,trans_send);
                mbx_r.put(trans_send);
                //mbx_r.put(pack);
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
        //        mbx_r.put(trans);
        //    end 
        //    else begin
        //        vif.rready <= 0;
        //        @vif.aclk;
        //    end
        //end
        //join_none
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
        AxiTransaction trans;
        int             current_ptr;
        bit [63:0]      current_addr;
        int             up_boundary;
        int             current_num;
        int             size;
        int             sel_byte;
        bit [127:0][7:0] data;
        bit [127:0]     strb;
        int            handshake_cnt;

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



endclass:AxiDriverMaster





    //task send_write(AxiTransaction trans);
    //    fork 
    //        send_aw(trans);
    //        send_w(trans);
    //    join
    //endtask