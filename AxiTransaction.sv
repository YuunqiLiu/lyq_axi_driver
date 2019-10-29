`timescale 1ns/1ps

`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
`endif


class AxiTransaction;

    AxiConfig       cfg;
    rand int        id;
    rand longint    addr;
    rand int        burst_length;
    rand int        burst_size;
    rand int        lock;//how to define
    rand bit [2:0]  prot;
    rand bit [3:0]  qos;
    rand bit []     region;
    rand int        user;
    rand bit [7:0]  data[];
    rand bit        strb[];

    function new(AxiConfig cfg);
        this.cfg = cfg;
    endfunction

    constraint id_cons {
        id >= 0;
        id <  2**cfg.id_width;
    }

    constraint addr_cons {
        addr >= 0;
        addr < 2**cfg.addr_width;
    }

    constraint data_cons {
        

    }


endclass:AxiTransaction



