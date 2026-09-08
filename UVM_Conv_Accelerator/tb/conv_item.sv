`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.08.2026 20:20:51
// Design Name: 
// Module Name: conv_item
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

`ifndef CONV_ITEM_SV
`define CONV_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class conv_item extends uvm_sequence_item;
    rand bit signed [7:0] pixels [784];
    `uvm_object_utils_begin(conv_item)
        `uvm_field_sarray_int(pixels, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "conv_item");
        super.new(name);
    endfunction
endclass

`endif