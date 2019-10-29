`timescale 1ns/1ps

`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
`endif

`ifndef AXITRANSACTION
    `define AXITRANSACTION
    `include "AxiTransaction.sv"
`endif

class AxiTransFactory;

    AxiConfig cfg;
    AxiTransaction trans;

    function new(AxiConfig cfg_in);
        cfg = cfg_in;
    endfunction

    function AxiTransaction create();
        create = new(cfg);
    endfunction

endclass:AxiTransFactory
