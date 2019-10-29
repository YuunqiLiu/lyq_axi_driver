`timescale 1ns/1ps

`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
`endif


`ifndef AXITRANSACTION
    `define AXITRANSACTION
    `include "AxiTransaction.sv"
`endif

class AxiDriverSlave;

    AxiConfig                       cfg;
    AxiTransaction                  trans;
    mailbox                         mbx;
    virtual AxiInterfaceUnit.slave  vif;

    function new(AxiConfig cfg,virtual AxiInterfaceUnit.slave vif);
        this.vif = vif;
        set_config(cfg);
    endfunction

    function set_config(AxiConfig cfg);
        this.cfg = cfg;
        this.mbx = new(cfg.driver_slave_fifo_num);
    endfunction

    task initialize();
        //mbx = new(1);
    endtask
    
    task run();

        initialize();
        fork
            forever begin
            //mbx.get(trans);
            //$display("get a trans with id %d",trans.id);
            end
        join_none
    endtask

endclass:AxiDriverSlave
