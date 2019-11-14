`timescale 1ns/1ps

`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
`endif

`ifndef AXITRANSACTION
    `define AXITRANSACTION
    `include "AxiTransaction.sv"
`endif

`ifndef AXITRANSFACTORY
    `define AXITRANSFACTORY
    `include "AxiTransFactory.sv"
`endif

class BaseClassWithTransFactory;

    AxiTransFactory trans_factory;
    AxiConfig       cfg;

    function new(AxiConfig cfg);
        this.cfg = cfg;
    endfunction

    function create();
        create = 


endclass