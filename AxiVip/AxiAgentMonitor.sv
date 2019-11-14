`timescale 1ns/1ps

`ifndef AXIDRIVERMONITOR
    `define AXIDRIVERMONITOR
    `include "AxiDriverMonitor.sv"
`endif

class AxiAgentMonitor;

    AxiConfig       cfg;
    AxiDriverMonitor monitor;
    //AxiTransFactory  factory;

    function new(AxiConfig cfg,virtual AxiInterfaceUnit vif);
        monitor = new(cfg,vif.monitor);
        this.cfg = cfg;
    //    factory = new(cfg);
    endfunction

    function AxiTransaction create_trans();
        AxiTransaction trans;
        trans = new(cfg);
        create_trans = trans;
    endfunction

    function set_config(AxiConfig cfg);
        monitor.set_config(cfg);
    endfunction

    task run();
        monitor.run();
    endtask

    //function AxiTransaction create();
    //    create = factory.create();
    //endfunction

endclass:AxiAgentMonitor

