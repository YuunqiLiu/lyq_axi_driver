import AxiVipPkg::*;

class AxiSequenceMaster;


    AxiAgentMaster agent;



    task get_agent(input AxiAgentMaster agent);
        this.agent = agent;
    endtask

    task send_trans(input AxiTransaction trans);
        agent.send_trans(trans);
    endtask

    //task default_run();
    //    AxiTransaction transr,transw;
    //    fork
    //        forever agent.recv_read_trans(transr);
    //        forever agent.recv_write_trans(transw);
    //    join_none
    //endtask


    task run();
        fork 
            read_handler();
            write_handler();
        join_none
        //trans.resp[0] = 2'b01;
        //trans.display();
        //$display("send start");
    endtask


    task read_handler();
        AxiTransaction trans;
        int num = 5;
        for(int i=0;i<num;i=i+1) begin
            trans = agent.create_trans();
            trans.randomize() with {
                trans.addr          == 10;
                trans.size          == 2;
                trans.data.size()   == 7;
                trans.xact_type     == AxiTransaction::READ;
            };
            agent.send_trans(trans);
            agent.recv_read_trans(trans);
            $display("Seq Master:send read %d and recv resp done.",i);
            //trans.display();
        end
    endtask


    task write_handler();
        AxiTransaction trans;
        int num = 5;
        for(int i=0;i<num;i=i+1) begin
            trans = agent.create_trans();
            trans.randomize() with {
                trans.addr          == 10;
                trans.size          == 2;
                trans.data.size()   == 7;
                trans.xact_type     == AxiTransaction::WRITE;
            };
            agent.send_trans(trans);
            agent.recv_write_trans(trans);
            $display("Seq Master:send write %d and recv resp done.",i);
            //trans.display();
        end
    endtask

endclass:AxiSequenceMaster
