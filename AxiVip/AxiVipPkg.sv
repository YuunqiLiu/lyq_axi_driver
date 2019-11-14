`timescale 1ns/1ps

package AxiVipPkg;


//`ifndef AXIDRIVER
//    `define AXIDRIVER
//    `include "AxiDriver.sv"
//`endif

`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
`endif

`ifndef AXITRANSACTION
    `define AXITRANSACTION
    `include "AxiTransaction.sv"
`endif

`ifndef AXIAGENTMASTER
    `define AXIAGENTMASTER
    `include "AxiAgentMaster.sv"
`endif

`ifndef AXIAGENTMONITOR
    `define AXIAGENTMONITOR
    `include "AxiAgentMonitor.sv"
`endif

`ifndef AXIAGENTSLAVE
    `define AXIAGENTSLAVE
    `include "AxiAgentSlave.sv"
`endif


`ifndef AXIVIP
    `define AXIVIP
    `include "AxiVip.sv"
`endif




endpackage:AxiVipPkg

//`ifndef AXIINTERFACE
//    `define AXIINTERFACE
//    `include "AxiInterface.sv"
//`endif