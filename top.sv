`timescale 1ns/1ps
`ifndef AXIINTERFACE
    `define AXIINTERFACE
    `include "AxiInterface.sv"
`endif

`include "AxiVipPkg.sv"

module top();

    import AxiVipPkg::*;
    //mailbox         mbx_mst_in,mbx_mst_out,mbx_slv_in,mbx_slv_out,mbx_mnt_in;
    //AxiConfig       cfg;
    //AxiTransaction  trans;
    //AxiAgentMaster  agent_mst;
    //AxiAgentSlave   agent_slv;
    //AxiAgentMonitor agent_mnt;
    //AxiDriverMaster driver_mst;

    AxiInterface axi_if();
    AxiConfig   cfg;
    AxiVip      vip;


    //AxiInterface    axi_if();



    initial begin
        cfg = new();
        vip = new(cfg);
        vip.axi_if = axi_if;

    end



endmodule


       //mbx_mst_in = new(1);
       //mbx_mst_out = new(1);
       //mbx_slv_in = new(1);
       //mbx_slv_out = new(1);
       //mbx_mnt_in = new(1);
       //
       //cfg = new();
       //trans = new(cfg);
    
       //agent_mst = new(cfg,axi_if,mbx_mst_in,mbx_mst_out);
       //agent_slv = new(cfg,axi_if,mbx_slv_in,mbx_slv_out);
       //agent_mnt = new(cfg,axi_if,mbx_mnt_in);

       //fork
       //$display("??");
       //
       //agent_mst.run();
       //agent_slv.run();
       //agent_mnt.run();
       //$display("???");
       //
       //join_none
       //#10;
       //mbx_mst_in.put(trans);
       //#10;