`timescale 1ns/1ps

`ifndef AXIINTERFACEUNIT
    `define AXIINTERFACEUNIT
    `include "AxiInterfaceUnit.sv"
`endif


`ifndef AXICONFIGDEFINE
    `define AXICONFIGDEFINE
    `include "AxiConfigDefine.sv"
`endif


interface AxiInterface();

    AxiInterfaceUnit master[`AXI_IF_MASTER_NUM-1:0]();
    AxiInterfaceUnit slave[`AXI_IF_SLAVE_NUM-1:0]();
    AxiInterfaceUnit monitor[`AXI_IF_MONITOR_NUM-1:0]();

    function virtual AxiInterfaceUnit get_master(int idx);
        case(idx)
        0:get_master = AxiInterface.master[0];
        1:get_master = AxiInterface.master[1];
        default: begin
                $display("AxiInterface::get_master();Master index %0d not supported.",idx);
                $finish;
            end 
        endcase
        //get_master = AxiInterface.master[idx];
    endfunction

    function virtual AxiInterfaceUnit get_slave(int idx);
        case(idx)
        0:get_slave = AxiInterface.slave[0];
        1:get_slave = AxiInterface.slave[1];
        default: begin
                $display("AxiInterface::get_slave();Slave index %0d not supported.",idx);
                $finish;
            end 
        endcase
        //get_master = AxiInterface.master[idx];
    endfunction

    function virtual AxiInterfaceUnit get_monitor(int idx);
        case(idx)
        0:get_monitor = AxiInterface.monitor[0];
        1:get_monitor = AxiInterface.monitor[1];
        default: begin
                $display("AxiInterface::get_monitor();Monitor index %0d not supported.",idx);
                $finish;
            end 
        endcase
        //get_master = AxiInterface.master[idx];
    endfunction    

endinterface:AxiInterface