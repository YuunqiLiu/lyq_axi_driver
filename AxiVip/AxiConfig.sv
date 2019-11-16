`timescale 1ns/1ps

class AxiConfigBuffer;

    int aw_depth  = 1000;
    int w_depth   = 1000;
    int b_depth   = 1000;
    int ar_depth  = 1000;
    int r_depth   = 1000;

endclass


class AxiConfigOtd;

    int total           = 10;
    int trans_per_id    = 10;
    int id_num          = 10;

endclass

class AxiConfig;



    typedef enum bit {READ,WRITE} xact_type_e;

    int axi_driver_debug_enable = 1;

    //instance num config
    int master_num  = 1;
    int slave_num   = 1;
    int monitor_num = 1;

    //AXI ip spec
    AxiConfigOtd    master_write_otd;
    AxiConfigOtd    master_read_otd;
    AxiConfigOtd    slave_write_otd;
    AxiConfigOtd    slave_read_otd;
    AxiConfigBuffer master_buffer;
    AxiConfigBuffer slave_buffer;


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
    int strb_width = data_width/8;
    int wstrb_width = wdata_width/8;

    function new();
        master_write_otd = new;
        master_read_otd  = new;
        slave_write_otd  = new;
        slave_read_otd   = new;
        master_buffer    = new;
        slave_buffer     = new;
        
        slave_write_otd.trans_per_id = 65535;
        slave_write_otd.id_num       = 65535;
        slave_read_otd.trans_per_id  = 65535;
        slave_read_otd.id_num        = 65535;
    endfunction
    
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

