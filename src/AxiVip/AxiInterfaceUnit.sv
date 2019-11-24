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
    logic [3:0]                         awqos;
    logic [3:0]                         awregion;
    logic [`AXI_IF_AWUSER_WIDTH-1:0]    awuser;
    logic                               awvalid;
    logic                               awready;

    logic [`AXI_IF_WID_WIDTH-1:0]       wid;
    logic [`AXI_IF_WDATA_WIDTH-1:0]     wdata;
    logic [`AXI_IF_WSTRB_WIDTH-1:0]     wstrb;
    logic [`AXI_IF_WUSER_WIDTH-1:0]     wuser;
    logic                               wlast;
    logic                               wvalid;
    logic                               wready;

    logic [`AXI_IF_BID_WIDTH-1:0]       bid;
    logic [1:0]                         bresp;
    logic [`AXI_IF_BUSER_WIDTH-1:0]     buser;
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
    logic [3:0]                         arqos;
    logic [3:0]                         arregion;
    logic [`AXI_IF_ARUSER_WIDTH-1:0]    aruser;
    logic                               arvalid;
    logic                               arready;

    logic [`AXI_IF_RID_WIDTH-1:0]       rid;
    logic [`AXI_IF_RDATA_WIDTH-1:0]     rdata;
    logic [1:0]                         rresp;
    logic [`AXI_IF_RUSER_WIDTH-1:0]     ruser;
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
        output awqos,
        output awregion,
        output awuser,
        output awvalid,
        input  awready,

        output wid,
        output wdata,
        output wstrb,
        output wlast,
        output wuser,
        output wvalid,
        input  wready,

        input  bid,
        input  bresp,
        input  buser,
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
        output arqos,
        output arregion,
        output aruser,
        output arvalid,
        input  arready,

        input  rid,
        input  rdata,
        input  rresp,
        input  ruser,
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
        input  awqos,
        input  awregion,
        input  awuser,
        input  awvalid,
        output awready,

        input  wid,
        input  wdata,
        input  wstrb,
        input  wuser,
        input  wlast,
        input  wvalid,
        output wready,

        output bid,
        output bresp,
        output buser,
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
        input  arqos,
        input  arregion,
        input  aruser,
        input  arvalid,
        output arready,

        output rid,
        output rdata,
        output rresp,
        output ruser,
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
        input awqos,
        input awregion,
        input awuser,
        input awvalid,
        input awready,

        input wid,
        input wdata,
        input wstrb,
        input wuser,
        input wlast,
        input wvalid,
        input wready,

        input bid,
        input bresp,
        input buser,
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
        input arqos,
        input arregion,
        input aruser,
        input arvalid,
        input arready,

        input rid,
        input rdata,
        input rresp,
        input ruser,
        input rlast,
        input rvalid,
        input rready
    );



endinterface:AxiInterfaceUnit