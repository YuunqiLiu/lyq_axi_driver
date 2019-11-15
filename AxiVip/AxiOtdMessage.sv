
`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
`endif

`ifndef AXICONFIGDEFINE
    `define AXICONFIGDEFINE
    `include "AxiConfigDefine.sv"
`endif

class AxiOtdMessage;

    int CntIBID[bit[`AXI_IF_ID_WIDTH-1:0]];
    int CntTotal;
    int CntActiveID;
    int limit_per_id_trans;
    int limit_total;
    int limit_id_num;

    function new(input AxiConfig cfg);
        limit_total         = cfg.driver_master_write_otd_total        ;
        limit_per_id_trans  = cfg.driver_master_write_otd_trans_per_id ;
        limit_id_num        = cfg.driver_master_write_otd_id_num       ;
    endfunction

    function exists(input bit[`AXI_IF_ID_WIDTH-1:0] i);
        if(CntIBID.exists(i) && CntIBID[i] >0)  exists = 1;
        else                                    exists = 0;
    endfunction


    task put(input bit[`AXI_IF_ID_WIDTH-1:0] i);
        if(CntIBID.exists(i)) begin
            wait( (CntIBID[i] < limit_per_id_trans) && (CntTotal < limit_total) );
            CntIBID[i]   = CntIBID[i] + 1;
        end
        else begin
            wait(CntActiveID < limit_id_num);//< id limit
            CntIBID[i]  = 1;
            CntActiveID =CntActiveID + 1; 
        end
        CntTotal    = CntTotal   + 1;
    endtask


    task get(input bit[`AXI_IF_ID_WIDTH-1:0] i);
        wait( (CntIBID[i] > 0) && (CntTotal > 0) );
        CntIBID[i] = CntIBID[i] - 1;
        CntTotal   = CntTotal   - 1;

        if(CntIBID[i] == 0) begin
            CntIBID.delete(i);
            CntTotal    = CntTotal - 1;
            CntActiveID = CntActiveID -1;
        end
    endtask


endclass