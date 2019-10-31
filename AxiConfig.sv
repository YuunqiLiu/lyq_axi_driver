`timescale 1ns/1ps

class AxiConfig;

    //instance num config
    int master_num  = 1;
    int slave_num   = 1;
    int monitor_num = 1;

    //AXI ip spec
    int driver_master_fifo_num = 1;
    int driver_slave_fifo_num = 1;


    //AXI interface param config
    int strb_always_enable = 1;

    int id_width    = 4;
    int data_width  = 32;
    int addr_width  = 32;
    int burst_length_limit = 16;

    int arlen_width = 4;
    int awlen_width = 4;
    
    int awid_width  = id_width;
    int arid_width  = id_width;
    int bid_width   = id_width;

    int awaddr_width = addr_width;
    int araddr_width = addr_width;

    int wdata_width = data_width;
    int rdata_width = data_width;
    int wstrb_width = wdata_width/8;
    
    function cfg_expand();
        awid_width  = id_width;
        arid_width  = id_width;
        bid_width   = id_width;

        awaddr_width = addr_width;
        araddr_width = addr_width;
        
        wdata_width = data_width;
        rdata_width = data_width;
        wstrb_width = wdata_width/8;

        if (burst_length_limit > 256) begin
            $display("error");
            $finish; 
        end
        else if (burst_length_limit <= 16) begin
            arlen_width = 4;
            awlen_width = 4;
        end
        else begin
            arlen_width = 16;
            awlen_width = 16;
        end

    endfunction


    //int data_width;
    //int busrt_length;
    //int strb_randomize;

    //function new;
    //    id_width = 1;
    //    master_num = 1;
    //    slave_num = 1;
    //    monitor_num = 1;
    //    
    //endfunction

endclass:AxiConfig

