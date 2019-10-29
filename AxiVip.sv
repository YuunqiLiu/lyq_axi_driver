
`ifndef AXITRANSACTION
    `define AXITRANSACTION
    `include "AxiTransaction.sv"
`endif

`ifndef AXICONFIGDEFINE
    `define AXICONFIGDEFINE
    `include "AxiConfigDefine.sv"
`endif

`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
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



class AxiVip;

    AxiAgentMaster  mst[];
    AxiAgentMonitor mnt[];
    AxiAgentSlave   slv[];
    AxiConfig       cfg;

    //AxiInterface mst_if[`AXI_IF_MASTER_NUM] ();
    //AxiInterface slv_if[`AXI_IF_SLAVE_NUM]  ();
    //AxiInterface mnt_if[`AXI_IF_MONITOR_NUM]();

    virtual AxiInterface axi_if;

    function new(AxiConfig cfg);
        this.cfg = cfg;
    endfunction

    function create_trans();
        AxiTransaction trans;
        trans = new(cfg);
        create_trans = trans;
    endfunction


    function initialize();
        mst = new[cfg.master_num];
        mnt = new[cfg.monitor_num];
        slv = new[cfg.slave_num];

        for(int i=0;i<cfg.master_num;i++) begin
            mst[i] = new(cfg,axi_if.get_master(i));
        end

        for(int i=0;i<cfg.slave_num;i++) begin
            slv[i] = new(cfg,axi_if.get_slave(i));
        end

        for(int i=0;i<cfg.monitor_num;i++) begin
            mnt[i] = new(cfg,axi_if.get_monitor(i));
        end
        

    endfunction

    task run();
        for(int i=0;i<cfg.master_num;i++) begin
            mst[i].run();
        end

        for(int i=0;i<cfg.slave_num;i++) begin
            slv[i].run();
        end

        for(int i=0;i<cfg.monitor_num;i++) begin
            mnt[i].run();
        end
    endtask
    


endclass:AxiVip