`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 00:50:36
// Design Name: 
// Module Name: conv_test
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


`ifndef CONV_TEST_SV
`define CONV_TEST_SV

`include "uvm_macros.svh"
`include "conv_random_seq.sv"
import uvm_pkg::*;
`include "conv_env.sv"

class conv_test extends uvm_test;
    `uvm_component_utils(conv_test)
    conv_env env;
    
    function new(string name = "conv_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = conv_env::type_id::create("env", this);
    endfunction
    
    task run_phase(uvm_phase phase);
        conv_random_seq seq;
        phase.raise_objection(this);
    
        seq = conv_random_seq::type_id::create("seq");
        seq.start(env.agent.sequencer);
    
        phase.drop_objection(this);
    endtask
endclass

`endif