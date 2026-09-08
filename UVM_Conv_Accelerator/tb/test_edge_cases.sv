`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 22:01:53
// Design Name: 
// Module Name: test_edge_cases
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`ifndef TEST_EDGE_CASES_SV
`define TEST_EDGE_CASES_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "conv_test.sv"
`include "all_zero_seq.sv"

class test_edge_cases extends conv_test;
    `uvm_component_utils(test_edge_cases)

    function new(string name = "test_edge_cases", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        all_zero_seq allzero;
        phase.raise_objection(this);
    
        allzero = all_zero_seq::type_id::create("allzer");
        allzero.start(env.agent.sequencer);
    
        phase.drop_objection(this);
    endtask
endclass
`endif