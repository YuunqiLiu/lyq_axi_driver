

import AxiVipPkg::*;

class AxiSequenceSlave;


    AxiAgentSlave agent;

    task get_agent(input AxiAgentSlave agent);
        this.agent = agent;
    endtask

    task recv_write_trans(output AxiTransaction trans);
        agent.recv_write_trans(trans);
    endtask

    task recv_read_trans(output AxiTransaction trans);
        agent.recv_read_trans(trans);
    endtask


    task send_trans(input AxiTransaction trans);
        agent.send_trans(trans);
    endtask



    task run();
        write_handler();
        read_handler();
    endtask

    task write_handler();
        AxiTransaction trans;
        fork
        forever begin
            agent.recv_write_trans(trans);
            trans.resp[0] = 2'b11;
            agent.send_trans(trans);
            $display("Seq Slave:receive write and send resp done.");
            //trans.display();
        end
        join_none
    endtask



    task read_handler();
        AxiTransaction trans;
        fork
        forever begin
            agent.recv_read_trans(trans);
            for(int i=0;i<trans.data_length;i=i+1) begin
                trans.data[i] = 255;
            end
            for(int i=0;i<=trans.len;i=i+1) begin
                trans.user[i] = 1;
                trans.resp[i] = 2'b11;
            end
            agent.send_trans(trans);
            $display("Seq Slave:receive read and send resp done.");
            //trans.display();
        end
        join_none
    endtask









endclass:AxiSequenceSlave



    //task default_run();
    //    AxiTransaction transr,transw;
    //    fork
    //        forever agent.recv_read_trans(transr);
    //        forever agent.recv_write_trans(transw);
    //    join_none
    //endtask