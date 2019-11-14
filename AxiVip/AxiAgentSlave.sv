`timescale 1ns/1ps

`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
`endif

`ifndef AXITRANSACTION
    `define AXITRANSACTION
    `include "AxiTransaction.sv"
`endif

`ifndef AXIDRIVERSLAVE
    `define AXIDRIVERSLAVE
    `include "AxiDriverSlave.sv"
`endif

`ifndef AXIDRIVERMONITOR
    `define AXIDRIVERMONITOR
    `include "AxiDriverMonitor.sv"
`endif




class AxiAgentSlave;

    AxiConfig cfg;
    AxiDriverSlave  slave;
    AxiDriverMonitor monitor;
    //AxiTransFactory  factory;   
  
    function new(AxiConfig cfg,virtual AxiInterfaceUnit vif);
        slave   = new(cfg,vif.slave);
        monitor = new(cfg,vif.monitor);
        this.cfg = cfg;
    //    factory = new(cfg);
    endfunction

    function AxiTransaction create_trans();
        AxiTransaction trans;
        trans = new(cfg);
        create_trans = trans;
    endfunction

    task send_trans(input AxiTransaction trans);
        slave.send_trans(trans);
    endtask

    task recv_write_trans(output AxiTransaction trans);
        slave.recv_write_trans(trans);
    endtask

    task recv_read_trans(output AxiTransaction trans);
        slave.recv_read_trans(trans);
    endtask

    function set_config(AxiConfig cfg);
        slave.set_config(cfg);
        monitor.set_config(cfg);
    endfunction

    task run();
        slave.run();
        monitor.run();
    endtask

    //function AxiTransaction create();
    //    create = factory.create();
    //endfunction

endclass:AxiAgentSlave

   // function new(AXIConfig cfg_in,AXIInterface axi_if);
   //     factory = new(cfg_in);
   //     //slave   = new(axi_if);
   // endfunction