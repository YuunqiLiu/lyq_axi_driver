`timescale 1ns/1ps

`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
`endif

`ifndef AXITRANSACTION
    `define AXITRANSACTION
    `include "AxiTransaction.sv"
`endif

`ifndef AXIDRIVERMASTER
    `define AXIDRIVERMASTER
    `include "AxiDriverMaster.sv"
`endif

`ifndef AXIDRIVERMONITOR
    `define AXIDRIVERMONITOR
    `include "AxiDriverMonitor.sv"
`endif

class AxiAgentMaster;

    AxiDriverMaster  master;
    AxiDriverMonitor monitor;
    virtual AxiInterfaceUnit vif;

    function new(AxiConfig cfg,virtual AxiInterfaceUnit vif);
        master = new (cfg,vif.master);
        monitor = new(cfg,vif.monitor);
    endfunction

    function set_config(AxiConfig cfg);
        master.set_config(cfg);
        monitor.set_config(cfg);
    endfunction

    task run();
        master.run();
        monitor.run();
    endtask

    //function AxiTransaction create();
    //    create = factory.create();
    //endfunction


endclass:AxiAgentMaster
    //AxiTransFactory  factory;   
        //factory = new(cfg);