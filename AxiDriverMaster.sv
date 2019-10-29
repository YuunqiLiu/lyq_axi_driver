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
    mailbox                         mbx;
    virtual AxiInterfaceUnit.master vif;

    function new(AxiConfig cfg,virtual AxiInterfaceUnit.master vif);
        this.vif = vif;
        set_config(cfg);
    endfunction

    function set_config(AxiConfig cfg);
        this.cfg = cfg;
        this.mbx = new(cfg.driver_master_fifo_num);
    endfunction

    task initialize();
        //mbx = new(1);
    endtask
    
    task run();

        initialize();
        $display("!");
        fork
            forever begin
                mbx.get(trans);
                $display("get a trans with id %d",trans.id);
            end
            $display("!!");
        join_none
    endtask

endclass:AxiDriverMaster




