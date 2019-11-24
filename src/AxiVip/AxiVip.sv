
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

    AxiAgentMaster  master[];
    AxiAgentMonitor monitor[];
    AxiAgentSlave   slave[];
    AxiConfig       cfg;

    //AxiInterface master_if[`AXI_IF_MASTER_NUM] ();
    //AxiInterface slave_if[`AXI_IF_SLAVE_NUM]  ();
    //AxiInterface monitor_if[`AXI_IF_monitor_NUM]();

    virtual AxiInterface axi_if;

    function new(AxiConfig cfg,virtual AxiInterface axi_if);
        this.axi_if = axi_if;
        this.cfg = cfg;
        initialize();
    endfunction

    function AxiTransaction create_trans();
        AxiTransaction trans;
        trans = new(cfg);
        create_trans = trans;
    endfunction


    function initialize();
        master = new[cfg.master_num];
        monitor = new[cfg.monitor_num];
        slave = new[cfg.slave_num];

        for(int i=0;i<cfg.master_num;i++) begin
            master[i] = new(cfg,axi_if.get_master(i));
        end

        for(int i=0;i<cfg.slave_num;i++) begin
            slave[i] = new(cfg,axi_if.get_slave(i));
        end

        for(int i=0;i<cfg.monitor_num;i++) begin
            monitor[i] = new(cfg,axi_if.get_monitor(i));
        end
        

    endfunction

    task run();
        for(int i=0;i<cfg.master_num;i++) begin
            master[i].run();
        end

        for(int i=0;i<cfg.slave_num;i++) begin
            slave[i].run();
        end

        for(int i=0;i<cfg.monitor_num;i++) begin
            monitor[i].run();
        end
    endtask
    


endclass:AxiVip