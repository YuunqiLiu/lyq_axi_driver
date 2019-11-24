


class Scoreboard;

    AxiTransaction   trans_m,trans_s;
    AxiDriverMonitor mon_mst,mon_slv;

    task get_master_monitor(input AxiDriverMonitor mon_mst);
        this.mon_mst = mon_mst;
    endtask

    task get_slave_monitor(input AxiDriverMonitor mon_slv);
        this.mon_slv = mon_slv;
    endtask

    task run();
        fork
            write_handler();
            read_handler();
        join_none
    endtask

    task write_handler();
        //$display("SCB~~~~~~~~~~~~~~");
        fork
        forever begin
            mon_mst.recv_write_trans(trans_m);
            $display("recv master in SCB with id :%d",trans_m.id);
        end
        join_none
    endtask

    task read_handler();
        fork
        forever begin
            mon_slv.recv_write_trans(trans_s);
            $display("recv slave in SCB with id :%d",trans_s.id);
        end
        join_none
    endtask

endclass:Scoreboard