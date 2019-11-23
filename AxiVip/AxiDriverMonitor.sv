`timescale 1ns/1ps

`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
`endif


`ifndef AXITRANSACTION
    `define AXITRANSACTION
    `include "AxiTransaction.sv"
`endif

class AxiDriverMonitor;

    Richmailbox                      mbx_aw,mbx_w,mbx_b,mbx_ar,mbx_r,mbx_write,mbx_read;
    bit                              recv_round;
    AxiConfig                        cfg;
    AxiTransaction                   trans;
    mailbox                          mbx;
    virtual AxiInterfaceUnit.monitor vif;

    function new(AxiConfig cfg,virtual AxiInterfaceUnit.monitor vif);
        this.mbx_aw    = new();
        this.mbx_w     = new();
        this.mbx_b     = new();
        this.mbx_ar    = new();
        this.mbx_r     = new();
        this.mbx_write = new();
        this.mbx_read  = new();

        this.cfg = cfg;
        this.vif = vif;
        this.mbx = new(1);
    endfunction

    function set_config(AxiConfig cfg);
        this.cfg = cfg;
    endfunction

    task initialize();
        recv_round = 0;
    endtask

    task recv_trans(output AxiTransaction trans);
        if(recv_round == 0) begin 
            recv_round = 1;
            recv_write_trans.get(trans);
        end
        else begin
            recv_round = 0;
            recv_read_trans.get(trans);
        end
    endtask

    task recv_write_trans(output AxiTransaction trans);
        mbx_write.get(trans);
    endtask

    task recv_read_trans(output AxiTransaction trans);
        mbx_read.get(trans);
    endtask

    task run();
        initialize();
        fork 
            recv_aw();
            recv_w();
            recv_b();
            recv_ar();
            recv_r();
            write_merge_handler();
            read_handler();
            write_resp_merge_handler();
            read_resp_merge_handler();
        join_none
    endtask


    task recv_aw();
        AxiTransaction trans;
        fork
        if(cfg.axi_driver_debug_enable) $display("AxiDriverMonitor: recv_aw run.");
        forever begin
            while(!(vif.awvalid && vif.awready)) @(posedge vif.aclk);
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
        end
        join_none
    endtask
 
    task recv_ar();
        AxiTransaction trans;
        fork
        if(cfg.axi_driver_debug_enable) $display("AxiDriverMonitor: recv_ar run.");
        forever begin
            while(!(vif.arvalid && vif.arready)) @(posedge vif.aclk);
            trans = new(cfg);
            trans.xact_type = AxiTransaction::READ;
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
        end
        join_none
    endtask

    task recv_w();
        AxiWChannelDataPack pack;
        bit [127:0][7:0]data_copy;
        bit [127:0]     strb_copy;
        bit [127:0]     user_copy[255:0];
        int             data_ptr,handshake_ptr;
        fork
        if(cfg.axi_driver_debug_enable) $display("AxiDriverSlave: recv_w run.");
        forever begin
            data_ptr        = 0;
            handshake_ptr   = 0;
            pack = new();
            do begin
                while(!(vif.wvalid && vif.wready)) @(posedge vif.aclk);
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
            byte_ptr = 0;
            hdsk_ptr = 0;
            pack = new();
            do begin
                while(!(vif.rvalid && vif.rready)) @(posedge vif.aclk);
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
            mbx_r.put(pack);
        end
        join_none
    endtask

    task recv_b();
        AxiBChannelDataPack pack;
        fork
        if(cfg.axi_driver_debug_enable) $display("AxiDriverMonitor: recv_b run.");
        forever begin
            while(!(vif.bvalid && vif.bready)) @(posedge vif.aclk);
            pack        = new;
            pack.resp   = vif.bresp;
            pack.user   = vif.buser;
            pack.id     = vif.bid;
            mbx_b.put(pack);
        end
        join_none
    endtask



endclass:AxiDriverMonitor

//function AxiTransaction create_trans();
//    AxiTransaction trans;
//    trans = new(cfg);
//    create_trans = trans;
//endfunction