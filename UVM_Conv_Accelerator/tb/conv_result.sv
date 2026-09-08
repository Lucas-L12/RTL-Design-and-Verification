`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.09.2026 19:04:38
// Design Name: 
// Module Name: conv_result
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

`ifndef CONV_RESULT_SV
`define CONV_RESULT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class conv_result extends uvm_object;

      bit signed [7:0] pixels_out [676];
     
    `uvm_object_utils_begin(conv_result)
        `uvm_field_sarray_int(pixels_out, UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "conv_result");
        super.new(name);
    endfunction


endclass


`endif