`timescale 1ns/1ps
`ifndef AXIINTERFACE
    `define AXIINTERFACE
    `include "AxiInterface.sv"
`endif

`include "AxiVipPkg.sv"
`include "AxiSequenceMaster.sv"
`include "AxiSequenceSlave.sv"

module top();

    import AxiVipPkg::*;

    AxiTransaction trans,transr,transw;
    AxiInterface axi_if();
    AxiConfig   cfg;
    AxiVip      vip;

    AxiSequenceMaster mstseq;
    AxiSequenceSlave  slvseq;

    reg clk;

    assign axi_if.master[0].aclk = clk;
    assign axi_if.slave[0].aclk = clk;

    //W
    assign axi_if.slave[0].wdata    = axi_if.master[0].wdata    ;
    assign axi_if.slave[0].wstrb    = axi_if.master[0].wstrb    ;
    assign axi_if.slave[0].wlast    = axi_if.master[0].wlast    ;
    assign axi_if.slave[0].wuser    = axi_if.master[0].wuser    ;
    
    assign axi_if.slave[0].wvalid   = axi_if.master[0].wvalid   ;
    assign axi_if.master[0].wready  = axi_if.slave[0].wready   ;


    //AW
    assign axi_if.slave[0].awid     = axi_if.master[0].awid     ;
    assign axi_if.slave[0].awaddr   = axi_if.master[0].awaddr   ;
    assign axi_if.slave[0].awlen    = axi_if.master[0].awlen    ;
    assign axi_if.slave[0].awsize   = axi_if.master[0].awsize   ;
    assign axi_if.slave[0].awburst  = axi_if.master[0].awburst  ;
    assign axi_if.slave[0].awlock   = axi_if.master[0].awlock   ;
    assign axi_if.slave[0].awcache  = axi_if.master[0].awcache  ;
    assign axi_if.slave[0].awprot   = axi_if.master[0].awprot   ;
    assign axi_if.slave[0].awqos    = axi_if.master[0].awqos    ;
    assign axi_if.slave[0].awregion = axi_if.master[0].awregion ;
    assign axi_if.slave[0].awuser   = axi_if.master[0].awuser   ;
    
    assign axi_if.slave[0].awvalid  = axi_if.master[0].awvalid  ;
    assign axi_if.master[0].awready = axi_if.slave[0].awready   ;


    //AR
    assign axi_if.slave[0].arid     = axi_if.master[0].arid     ;
    assign axi_if.slave[0].araddr   = axi_if.master[0].araddr   ;
    assign axi_if.slave[0].arlen    = axi_if.master[0].arlen    ;
    assign axi_if.slave[0].arsize   = axi_if.master[0].arsize   ;
    assign axi_if.slave[0].arburst  = axi_if.master[0].arburst  ;
    assign axi_if.slave[0].arlock   = axi_if.master[0].arlock   ;
    assign axi_if.slave[0].arcache  = axi_if.master[0].arcache  ;
    assign axi_if.slave[0].arprot   = axi_if.master[0].arprot   ;
    assign axi_if.slave[0].arqos    = axi_if.master[0].arqos    ;
    assign axi_if.slave[0].arregion = axi_if.master[0].arregion ;
    assign axi_if.slave[0].aruser   = axi_if.master[0].aruser   ;
    
    assign axi_if.slave[0].arvalid  = axi_if.master[0].arvalid  ;
    assign axi_if.master[0].arready = axi_if.slave[0].arready   ;


    //B
    assign axi_if.master[0].bid     = axi_if.slave[0].bid       ;
    assign axi_if.master[0].bresp   = axi_if.slave[0].bresp     ;
    assign axi_if.master[0].buser   = axi_if.slave[0].buser     ;

    assign axi_if.master[0].bvalid  = axi_if.slave[0].bvalid    ;
    assign axi_if.slave[0].bready   = axi_if.master[0].bready   ;


    //R
    assign axi_if.master[0].rid     = axi_if.slave[0].rid       ;
    assign axi_if.master[0].rdata   = axi_if.slave[0].rdata     ;
    assign axi_if.master[0].rresp   = axi_if.slave[0].rresp     ;
    assign axi_if.master[0].ruser   = axi_if.slave[0].ruser     ;
    assign axi_if.master[0].rlast   = axi_if.slave[0].rlast     ;

    assign axi_if.master[0].rvalid  = axi_if.slave[0].rvalid    ;
    assign axi_if.slave[0].rready   = axi_if.master[0].rready   ;

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    initial begin
        cfg = new();
        vip = new(cfg,axi_if);
        mstseq = new;
        slvseq = new;
        
        mstseq.get_agent(vip.master[0]);
        slvseq.get_agent(vip.slave[0]);

        vip.run();
        mstseq.run();
        slvseq.run();


    end

    initial begin
        #20000;
        $finish;
    end



endmodule




        //vip.master[0].create_trans();
        //trans = new(cfg);
        //trans = vip.master[0].create_trans();
        //trans.randomize() with {
        //    trans.addr == 10;
        //    trans.size == 2;
        //    trans.data.size() == 7;
        //    trans.xact_type == AxiTransaction::WRITE;
        //};
        //trans.resp[0] = 2'b01;
//
        //trans.display();
//
        //$display("send start");
        //vip.master[0].master.send_trans(trans);

        //$display("send end");
        //vip.slave[0].slave.recv_read_trans(transr);
        //vip.slave[0].slave.recv_write_trans(transr);
        //transr.resp[0] = 2'b11;
        //$display("transrresp0 %b",transr.resp[0]);
        //transr.display();
        //vip.slave[0].slave.send_trans(transr);
//
        //$display("slave give response");
        //vip.master[0].master.recv_write_trans(transw);
//
        //transw.display();