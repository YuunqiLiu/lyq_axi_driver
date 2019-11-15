`timescale 1ns/1ps


`ifndef AXITRANSACTION
    `define AXITRANSACTION
    `include "AxiTransaction.sv"
`endif

`ifndef AXICONFIGDEFINE
    `define AXICONFIGDEFINE
    `include "AxiConfigDefine.sv"
`endif

class AxiTransMailboxIBK;

    typedef AxiTransaction TransQue[$];

    TransQue TransQueIBID[bit[`AXI_IF_ID_WIDTH-1:0]];

    int depth;


    function new(int depth=65535);
        this.depth = depth;
    endfunction


    task put(input AxiTransaction trans,input bit[`AXI_IF_ID_WIDTH-1:0] i);
        //$display("put %d",i);
        trans.id = trans.id;
        wait(TransQueIBID[i].size()<depth);
        TransQueIBID[i].push_back(trans);
    endtask


    task get(output AxiTransaction trans,input bit[`AXI_IF_ID_WIDTH-1:0] i);
        //$display("get %d",i);
        wait(TransQueIBID[i].size()>0);
        //$display("size %d",TransQueIBID[i].size());
        trans = TransQueIBID[i].pop_front();
        //$display("%d",trans.id);
    endtask


    function bit full(input bit[`AXI_IF_ID_WIDTH-1:0] i);
        //$display("full %d",i);
        full = (TransQueIBID[i].size() == depth)?1:0;
    endfunction


    function bit empty(input bit[`AXI_IF_ID_WIDTH-1:0] i);
        //$display("empty %d",i);
        empty = (TransQueIBID[i].size() == 0)?1:0;
    endfunction

endclass:AxiTransMailboxIBK