`timescale 1ns/1ps

`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
`endif


`ifndef AXITRANSACTION
    `define AXITRANSACTION
    `include "AxiTransaction.sv"
`endif

class AxiDriverMaster;

    AxiConfig                       cfg;
    AxiTransaction                  trans;
    mailbox                         mbx_aw,mbx_w,mbx_ar,mbx_r,mbx_b,mbx_otdw,mbx_otdr;
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
            $cast(trans_aw,trans.clone());
            $cast(trans_w,trans.clone());
            mbx_aw.put(trans_aw);
            mbx_w.put(trans_w);
            mbx_otdw.put(trans_otdw);
        end
        else begin
            $cast(trans_ar,trans.clone());
            mbx_ar.put(trans_ar);
            mbx_otdr.put(trans_otdr);
        end
    endtask

    task initialize();
        //mbx = new(1);
    endtask
    
    task run();

        initialize();
        fork
            send_aw();
            send_w();
            send_ar();
            recv_b();
            recv_r();
            //forever begin
            //    mbx.get(trans);

            //end
            //$display("!!");
        join_none
    endtask

    task recv_b();
        AxiTransaction trans;
        fork
        forever begin
            if(mbx_otdw.num()!=0) begin
                vif.bready <= 1;
                do @vif.aclk; while(!(vif.bvalid && vif.bready));
                mbx_otdw.get(trans);
                trans.resp = vif.bresp;
                mbx_b.put(trans);
            end
            else begin
                vif.bready <= 0;
                @vif.aclk;
            end
        end
        join_none
    endtask

    task recv_r();
        int driver_master_write_otd_depth = 1;
    int driver_master_read_otd_depth = 1;
    
    endtask


    task send_aw();
        AxiTransaction trans;
        fork
        forever begin
            if(mbx_aw.num()!=0) begin
                mbx_aw.peek(trans);
                vif.awvalid <= 1'b1;
                vif.awaddr  <= trans.addr;
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
        forever begin 
            if(mbx_ar.num()!=0) begin
                mbx_ar.peek(trans);
                vif.arvalid <= 1'b1;
                vif.araddr  <= trans.addr;
                do @vif.aclk; while(!(vif.arvalid && arready));
                mbx_aw.get(trans);
            end
            else begin
                vif.arvalid <= 1'b0;
                @vif.aclk;
            end
        end
        join_none

    task send_w(AxiTransaction trans);
        
        fork
        forever begin
            if(mbx_w.num()!=0) begin
                current_ptr = 0;   
                up_boundary = 2**trans.burst_size;
                do begin
                    up_boundary     = (current_addr/(2**trans.burst_size) + 1) * (2**trans.burst_size);
                    current_num     = up_boundary - current_addr;
                    current_addr    += current_num;
                

                
                end while(current_addr < trans.addr +trans.data.size());
            end
            else begin

            end
        end
        join_none

        end while(!(vif.wvalid && vif.wready));
        vif.wvalid <= 1'b0;
    endtask



endclass:AxiDriverMaster





    //task send_write(AxiTransaction trans);
    //    fork 
    //        send_aw(trans);
    //        send_w(trans);
    //    join
    //endtask