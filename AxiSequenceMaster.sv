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
            write_recv_handler();
            read_recv_handler();
            read_send_handler();
            write_send_handler();
        join_none
        //trans.resp[0] = 2'b01;
        //trans.display();
        //$display("send start");
    endtask


    task read_send_handler();
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
            $display("Seq Master:send read trans with id %d.",trans.id);
            //trans.display();
        end
    endtask


    task write_send_handler();
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
            $display("Seq Master:send write trans with id %d.",trans.id);
            //trans.display();
        end
    endtask

    task read_recv_handler();
        AxiTransaction trans;
        fork
        forever begin
            agent.recv_read_trans(trans);
            $display("Seq Master:recv read resp with id %d.",trans.id);
        end
        join_none
    endtask


    task write_recv_handler();
        AxiTransaction trans;
        fork
        forever begin
            agent.recv_write_trans(trans);
            $display("Seq Master:recv write resp with id %d.",trans.id);
        end
        join_none
    endtask

endclass:AxiSequenceMaster
