`timescale 1ns/1ps

`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
`endif

class AxiTransaction;

    AxiConfig        cfg;
    rand int         id;
    rand bit [63:0]  addr;
    rand bit [63:0]  up_boundary;
    rand bit [7:0]   burst_length;
    rand bit [2:0]   burst_size;
    rand bit         lock;
    rand bit [2:0]   prot;
    rand bit [3:0]   qos;
    rand bit [3:0]   region;
    //rand bit [127:0] auser;

    rand bit [11:0]  data_length;
    rand bit [7:0]   data[];
    rand bit         strb[];
    //rand bit [127:0] user;
 
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
        //4K Boundary limit
        up_boundary == {addr[63:13],12'b0} + 13'b1_0000_0000_0000;
        data_length + addr <= up_boundary;
        data_length > 0;
        
        //AXI SIZE/LENGTH limit
        if (data_length % (2**burst_size) ==0)  burst_length == data_length/(2**burst_size);
        else                                    burst_length == data_length/(2**burst_size)+1;
        burst_length < cfg.burst_length_limit;
        burst_length > 0;

        data.size() == data_length;
        strb.size() == data_length;

        if(cfg.strb_always_enable)
            foreach(strb[i]) strb[i] == 1'b1;
    }


endclass:AxiTransaction



