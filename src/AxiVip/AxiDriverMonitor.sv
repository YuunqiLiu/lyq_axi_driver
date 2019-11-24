`timescale 1ns/1ps

`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
`endif

`ifndef RICHMAILBOX
    `define RICHMAILBOX
    `include "RichMailbox.sv"
`endif

`ifndef AXITRANSACTION
    `define AXITRANSACTION
    `include "AxiTransaction.sv"
`endif

`ifndef AXIWCHANNELDATAPACK
    `define AXIWCHANNELDATAPACK
    `include "AxiWChannelDataPack.sv"
`endif

`ifndef AXIDRIVERTOOL
    `define AXIDRIVERTOOL
    `include "AxiDriverTool.sv"
`endif

class AxiDriverMonitor;

    RichMailbox                      mbx_aw,mbx_w,mbx_b,mbx_ar,mbx_r,mbx_write,mbx_read;
    AxiTransMailboxIBK               mbxibid_waitr,mbxibid_waitb;
    AxiDriverTool                    tool;
    bit                              recv_round;
    AxiConfig                        cfg;
    AxiTransaction                   trans;
    virtual AxiInterfaceUnit.monitor vif;

    function new(AxiConfig cfg,virtual AxiInterfaceUnit.monitor vif);
        this.mbx_aw    = new();
        this.mbx_w     = new();
        this.mbx_b     = new();
        this.mbx_ar    = new();
        this.mbx_r     = new();
        this.mbx_write = new();
        this.mbx_read  = new();

        this.mbxibid_waitb = new;
        this.mbxibid_waitr = new;

        this.cfg = cfg;
        this.vif = vif;
        this.tool = new;
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
            this.recv_write_trans(trans);
        end
        else begin
            recv_round = 0;
            this.recv_read_trans(trans);
        end
    endtask

    task recv_write_trans(output AxiTransaction trans);
        mbx_write.get(trans);
    endtask

    task recv_read_trans(output AxiTransaction trans);
        mbx_read.get(trans);
    endtask

    task run();
        $display("MON RUN.");
        initialize();
        fork 
            recv_aw();
            recv_w();
            recv_b();
            recv_ar();
            recv_r();
            write_merge_handler();
            write_resp_merge_handler();
            read_resp_merge_handler();
        join_none
    endtask

    task recv_aw();
        AxiTransaction trans;
        fork
        if(cfg.axi_driver_debug_enable) $display("AxiDriverMonitor: recv_aw run.");
        forever begin
            while(!(vif.awvalid === 1 && vif.awready === 1)) @(posedge vif.aclk);
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
            @(posedge vif.aclk);
            //$display("MON AW DONE");
        end
        join_none
    endtask
 
    task recv_ar();
        AxiTransaction trans;
        fork
        if(cfg.axi_driver_debug_enable) $display("AxiDriverMonitor: recv_ar run.");
        forever begin
            while(!(vif.arvalid === 1 && vif.arready === 1)) @(posedge vif.aclk);
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
            tool.recv_trans_init(trans,cfg);
            mbxibid_waitr.put(trans,trans.id);
            @(posedge vif.aclk);
            //$display("MON AR DONE      23333");
        end
        join_none
    endtask

    task recv_w();
        AxiWChannelDataPack pack;
        bit [127:0][7:0]data_copy;
        bit [127:0]     strb_copy;
        int             data_ptr,handshake_ptr;
        fork
        if(cfg.axi_driver_debug_enable) $display("AxiDriverSlave: recv_w run.");
        forever begin
            data_ptr        = 0;
            handshake_ptr   = 0;
            pack = new();
            do begin
                while(!(vif.wvalid === 1 && vif.wready === 1)) @(posedge vif.aclk);
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
                @(posedge vif.aclk);
            end while(!(vif.wlast===1 && vif.wvalid===1 && vif.wready===1));
            mbx_w.put(pack);
            //$display("MON W DONE          2333");
        end
        join_none
    endtask

    task recv_r();
        AxiRChannelDataPack pack;
        bit [127:0][7:0]    data;
        int                 byte_ptr,hdsk_ptr;
        fork
        forever begin
            byte_ptr = 0;
            hdsk_ptr = 0;
            pack = new();
            do begin
                while(!(vif.rvalid === 1 && vif.rready === 1)) @(posedge vif.aclk);
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
                @(posedge vif.aclk);
            end while(!(vif.rlast===1 && vif.rvalid===1 && vif.rready===1));
            mbx_r.put(pack);
            //$display("MON R DONE  233333");
        end
        join_none
    endtask

    task recv_b();
        AxiBChannelDataPack pack;
        fork
        if(cfg.axi_driver_debug_enable) $display("AxiDriverMonitor: recv_b run.");
        forever begin
            while(!(vif.bvalid === 1 && vif.bready === 1)) @(posedge vif.aclk);
            pack        = new;
            pack.resp   = vif.bresp;
            pack.user   = vif.buser;
            pack.id     = vif.bid;
            mbx_b.put(pack);
            //$display("MON B DONE %d %d",vif.bvalid,vif.bready);
            @(posedge vif.aclk);
        end
        join_none
    endtask

    task write_merge_handler();
        AxiTransaction      trans_aw,trans;
        AxiWChannelDataPack pack;
        bit [7:0]           data[4095:0];
        int                 ptr,start_point,offset;
        int                 data_length;
        fork
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

            mbxibid_waitb.put(trans,trans.id);
            //$display("end to merge.");
        end
        join_none
    endtask

    task write_resp_merge_handler();
        AxiTransaction      trans;
        AxiBChannelDataPack pack;
        fork 
        forever begin
            //merge b
            mbx_b.get(pack);
            //$display("WDM!!!!!!!!!!!!!!!!!!!!!!");
            //$display("pack id %d",pack.id);
            if(mbxibid_waitb.empty(pack.id)) $finish;
            mbxibid_waitb.get(trans,pack.id);
            trans.buser   = pack.user;
            trans.resp[0] = pack.resp;
            mbx_write.put(trans);
        end
        join_none
    endtask

    task read_resp_merge_handler();
        AxiRChannelDataPack pack;
        AxiTransaction      trans;
        int                 start_point,offset;
        int                 data_length;
        
        fork
        forever begin
            //merge_r
            mbx_r.get(pack);
            //$display("RDM~~~~~~~~~~~~~~~~~~~");
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

            mbx_read.put(trans);
        end
        join_none
    endtask



endclass:AxiDriverMonitor

//function AxiTransaction create_trans();
//    AxiTransaction trans;
//    trans = new(cfg);
//    create_trans = trans;
//endfunction