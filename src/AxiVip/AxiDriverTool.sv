`ifndef AXITRANSACTION
    `define AXITRANSACTION
    `include "AxiTransaction.sv"
`endif

`ifndef AXICONFIG
    `define  AXICONFIG
    `include "AxiConfig.sv"
`endif

class AxiDriverTool;

    function recv_trans_init(input AxiTransaction trans,input AxiConfig cfg);
        int offset;
        offset = trans.addr % (2**trans.size);
        trans.data_length = (trans.len+1)*cfg.strb_width-offset;
        trans.data = new[trans.data_length];
        trans.strb = new[trans.data_length];
        trans.user = new[trans.len+1];
    endfunction

endclass:AxiDriverTool;