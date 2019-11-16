
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

    function new(input AxiConfigOtd cfg);
        limit_total         = cfg.total        ;
        limit_per_id_trans  = cfg.trans_per_id ;
        limit_id_num        = cfg.id_num       ;
        CntTotal            = 0;
        CntActiveID         = 0;
    endfunction

    function exists(input bit[`AXI_IF_ID_WIDTH-1:0] i);
        if(CntIBID.exists(i) && CntIBID[i] >0)  exists = 1;
        else                                    exists = 0;
    endfunction

    function full(input bit[`AXI_IF_ID_WIDTH-1:0] i);
        if(CntTotal < limit_total)
            if(exists(i))
                if(CntIBID[i] < limit_per_id_trans) full = 0;
                else                                full = 1;
            else if(CntActiveID < limit_id_num)     full = 0;
            else                                    full = 1;
        else                                        full = 1;
    endfunction


    task put(input bit[`AXI_IF_ID_WIDTH-1:0] i);

        wait((CntTotal < limit_total));

        if(CntIBID.exists(i)) begin
            wait(CntIBID[i] < limit_per_id_trans);
            CntIBID[i]   = CntIBID[i] + 1;
        end
        else begin
            wait(CntActiveID < limit_id_num);//< id limit
            CntIBID[i]  = 1;
            CntActiveID =CntActiveID + 1; 
        end
        CntTotal    = CntTotal   + 1;
        //$display("otdm put with id %d",i);
    endtask


    task get(input bit[`AXI_IF_ID_WIDTH-1:0] i);
        //$display("cnt total %d cntibid %d with get id",CntIBID[i],CntTotal,i);
        wait( (CntIBID[i] > 0) && (CntTotal > 0) );
        CntIBID[i] = CntIBID[i] - 1;
        CntTotal   = CntTotal   - 1;

        if(CntIBID[i] == 0) begin
            CntIBID.delete(i);
            CntActiveID = CntActiveID -1;
        end
    endtask


endclass