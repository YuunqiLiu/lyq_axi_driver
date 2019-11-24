`timescale 1ns/1ps

`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
`endif

class AxiTransaction;

    //typedef enum bit {READ,WRITE} xact_type_e;
    
    static bit WRITE = 1'b1;
    static bit READ  = 1'b0;

    //Burst type define
    static bit [1:0] FIXED   = 2'b00;
    static bit [1:0] INCR    = 2'b01;
    static bit [1:0] WRAP    = 2'b10;   

    //Lock type define
    static bit NORMAL    = 1'b0;
    static bit EXCLUSIVE = 1'b1; 

    //Transaction Type
    rand bit            xact_type;

    //Address channel parameter
    rand int            id;
    rand bit [63:0]     addr;
    rand bit [7:0]      len;
    rand bit [2:0]      size;
    rand bit [1:0]      burst;
    rand bit            lock;
    rand bit [3:0]      cache;
    rand bit [2:0]      prot;
    rand bit [3:0]      qos;
    rand bit [3:0]      region;
    rand bit [127:0]    auser;
    rand bit [127:0]    buser;

    //Data channel parameter
    rand bit [7:0]      data[];
    rand bit            strb[];
    rand bit [127:0]    user[];

    //
    rand bit [1:0]      resp[];


    AxiConfig           cfg;
    rand bit [63:0]     up_boundary;
    rand bit [11:0]     data_length;
    rand int            size_num;
    rand bit            data_head_offset;
    rand bit            data_tail_offset;

    
 
    function new(AxiConfig cfg);
        this.cfg = cfg;
    endfunction

    constraint id_cons {
        id >= 0;
        id <  2**cfg.id_width;
    }

    constraint addr_cons {
        addr >= 0;
        addr < 2**cfg.addr_width;
    }

    constraint data_cons {
        //4K Boundary limit
        up_boundary == {addr[63:13],12'b0} + 13'b1_0000_0000_0000;
        data_length + addr <= up_boundary;
        data_length > 0;
        
        //AXI SIZE/LENGTH limit
        if(addr % (2**size)==0)                 data_head_offset == 0;
        else                                    data_head_offset == 1;

        if((addr+data_length) % (2**size)==0)   data_tail_offset ==0;
        else                                    data_tail_offset ==1;

        len + 1 == data_length/(2**size) + data_head_offset + data_tail_offset;

        //if ((addr+data_length) % (2**size) ==0)  len+1 == (addr+data_length)/(2**size);
        //else                              len+1 == data_length/(2**size)+1;
        len < cfg.burst_length_limit;
        len > 0;

        data.size() == data_length;
        strb.size() == data_length;

        if(cfg.strb_always_enable || (xact_type == READ ))
            foreach(strb[i]) strb[i] == 1'b1;

        2**size <= cfg.data_width;
    }

    constraint resp_cons {
        if(xact_type == WRITE)  resp.size() == 1;
        else                    resp.size() == len+1;
    }

    constraint user_cons {
        user.size() == len+1;
    }

    //function get_data_length();
    //    int size_num;
    //    size_num = 2**size;
    //    if((addr % size_num) == 0) get_data_length = size_num * (len + 1);
    //    else                       get_data_length = size_num * (len + 1) + size_num - addr % size_num;
    //endfunction

    //constraint support_cons {
    //    size_num == 2**size;
    //}




    function display();
        $display("Display transaction message.");
        $display("    xact_type :%b",xact_type);
        $display("    id    :%h",id    );
        $display("    addr  :%h",addr  );
        $display("    len   :%h",len   );
        $display("    size  :%h",size  );
        $display("    burst :%h",burst );
        $display("    lock  :%h",lock  );
        $display("    cache :%h",cache );
        $display("    prot  :%h",prot  );
        $display("    qos   :%h",qos   );
        $display("    region:%h",region);
        $display("    auser :%h",auser );
        $display("    resp  :%b",resp[0]);


        $display("    data.size  :%d",data.size()  );
        $display("    strb.size  :%d",strb.size()  );
        $display("    user.size  :%d",user.size()  );
        $display("    data  :%h",data.sum()  );
        $display("    strb  :%h",strb.sum()  );
        $display("    user  :%h",user.sum()  );
        for(int i=0;i<data_length;i+=1) begin
            $display("    data %d:%h with strb %d",i,data[i],strb[i]  );
        end
    endfunction

    function set_support_value();
        size_num = 2**size;

    endfunction

    function copy_to(output AxiTransaction trans);
        trans = new this;
    endfunction

endclass:AxiTransaction



