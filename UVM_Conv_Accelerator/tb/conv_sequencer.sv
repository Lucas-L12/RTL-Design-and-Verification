`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.09.2026 18:50:15
// Design Name: 
// Module Name: conv_sequencer
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


`ifndef CONV_SEQUENCER_SV
`define CONV_SEQUENCER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "conv_item.sv"

class conv_sequencer extends uvm_sequencer#(conv_item);
    `uvm_component_utils(conv_sequencer)
    function new(string name = "conv_sequencer", uvm_component parent = null);
    super.new(name, parent);
    endfunction
    

endclass
`endif