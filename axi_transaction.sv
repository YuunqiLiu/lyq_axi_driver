
class AXI4Config;

    
    
    int id_width;
    //int data_width;
    //int busrt_length;
    //int strb_randomize;

    function new;
        id_width = 1;
    endfunction



endclass:AXI4_config


class axi_transaction;

    AXI4Config     cfg;
    rand int        id;
    //rand longint    addr;
    //rand int        burst_length;
    //rand int        burst_size;
    //rand int        lock;//how to define
    //rand bit [2:0]  prot;
    //rand bit [3:0]  qos;
    //rand bit []     region;
    //rand int        user;
    //rand bit [7:0]  data[];
    //rand bit        strb[];

    function new(AXI4_config cfg_in);
        cfg = cfg_in;
    endfunction

    constraint id_cons {
        id >= 0;
        id <  2**cfg.id_width;
    }

endclass:axi_transaction