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

    AxiConfig                        cfg;
    AxiTransaction                   trans;
    mailbox                          mbx;
    virtual AxiInterfaceUnit.monitor vif;

    function new(AxiConfig cfg,virtual AxiInterfaceUnit.monitor vif);
        this.cfg = cfg;
        this.vif = vif;
        this.mbx = new(1);
    endfunction

    function AxiTransaction create_trans();
        AxiTransaction trans;
        trans = new(cfg);
        create_trans = trans;
    endfunction

    function set_config(AxiConfig cfg);
        this.cfg = cfg;
    endfunction

    task run();
        fork 
            forever begin
                @vif.aclk;

            end
        join_none
    endtask

endclass:AxiDriverMonitor