
class axi_transaction;

    rand int        id;
    rand longint    addr;
    rand int        burst_length;
    rand int        burst_size;
    rand int        lock;//how to define
    rand bit [2:0]  prot;
    rand bit [3:0]  qos;
    rand bit []     region;
    rand int        user;
    rand bit [7:0]  data[];
    rand bit        strb[];


endclass:axi_transaction