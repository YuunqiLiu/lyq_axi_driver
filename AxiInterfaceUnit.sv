`timescale 1ns/1ps

`ifndef AXICONFIGDEFINE
    `define AXICONFIGDEFINE
    `include "AxiConfigDefine.sv"
`endif


interface AxiInterfaceUnit();

    logic aclk;
    logic aresetn;

    logic [`AXI_IF_AWID_WIDTH-1:0]      awid;
    logic [`AXI_IF_AWADDR_WIDTH-1:0]    awaddr;
    logic [`AXI_IF_AWLEN_WIDTH-1:0]     awlen;
    logic [2:0]                         awsize;
    logic [1:0]                         awburst;
    logic [1:0]                         awlock;
    logic [3:0]                         awcache;
    logic [2:0]                         awprot;
    logic                               awvalid;
    logic                               awready;

    logic [`AXI_IF_WID_WIDTH-1:0]       wid;
    logic [`AXI_IF_WDATA_WIDTH-1:0]     wdata;
    logic [`AXI_IF_WSTRB_WIDTH-1:0]     wstrb;
    logic                               wlast;
    logic                               wvalid;
    logic                               wready;

    logic [`AXI_IF_BID_WIDTH-1:0]       bid;
    logic [1:0]                         bresp;
    logic                               bvalid;
    logic                               bready;

    logic [`AXI_IF_ARID_WIDTH-1:0]      arid;
    logic [`AXI_IF_ARADDR_WIDTH-1:0]    araddr;
    logic [`AXI_IF_ARLEN_WIDTH-1:0]     arlen;
    logic [2:0]                         arsize;
    logic [1:0]                         arburst;
    logic [1:0]                         arlock;
    logic [3:0]                         arcache;
    logic [2:0]                         arprot;
    logic                               arvalid;
    logic                               arready;

    logic [`AXI_IF_RID_WIDTH-1:0]       rid;
    logic [`AXI_IF_RDATA_WIDTH-1:0]     rdata;
    logic [1:0]                         rresp;
    logic                               rlast;
    logic                               rvalid;
    logic                               rready;



    modport master(
        input  aclk,
        input  aresetn,

        output awid,
        output awaddr,
        output awlen,
        output awsize,
        output awburst,
        output awlock,
        output awcache,
        output awprot,
        output awvalid,
        input  awready,

        output wid,
        output wdata,
        output wstrb,
        output wlast,
        output wvalid,
        input  wready,

        input  bid,
        input  bresp,
        input  bvalid,
        output bready,

        output arid,
        output araddr,
        output arlen,
        output arsize,
        output arburst,
        output arlock,
        output arcache,
        output arprot,
        output arvalid,
        input  arready,

        input  rid,
        input  rdata,
        input  rresp,
        input  rlast,
        input  rvalid,
        output rready
    );

    modport slave(
        input  aclk,
        input  aresetn,

        input  awid,
        input  awaddr,
        input  awlen,
        input  awsize,
        input  awburst,
        input  awlock,
        input  awcache,
        input  awprot,
        input  awvalid,
        output awready,

        input  wid,
        input  wdata,
        input  wstrb,
        input  wlast,
        input  wvalid,
        output wready,

        output bid,
        output bresp,
        output bvalid,
        input  bready,

        input  arid,
        input  araddr,
        input  arlen,
        input  arsize,
        input  arburst,
        input  arlock,
        input  arcache,
        input  arprot,
        input  arvalid,
        output arready,

        output rid,
        output rdata,
        output rresp,
        output rlast,
        output rvalid,
        input  rready
    );

    modport monitor(
        input aclk,
        input aresetn,

        input awid,
        input awaddr,
        input awlen,
        input awsize,
        input awburst,
        input awlock,
        input awcache,
        input awprot,
        input awvalid,
        input awready,

        input wid,
        input wdata,
        input wstrb,
        input wlast,
        input wvalid,
        input wready,

        input bid,
        input bresp,
        input bvalid,
        input bready,

        input arid,
        input araddr,
        input arlen,
        input arsize,
        input arburst,
        input arlock,
        input arcache,
        input arprot,
        input arvalid,
        input arready,

        input rid,
        input rdata,
        input rresp,
        input rlast,
        input rvalid,
        input rready
    );



endinterface:AxiInterfaceUnit