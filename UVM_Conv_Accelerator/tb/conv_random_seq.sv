`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 14:01:41
// Design Name: 
// Module Name: conv_random_seq
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
`ifndef CONV_RANDOM_SEQ_SV
`define CONV_RANDOM_SEQ_SV

`include "uvm_macros.svh"
`include "conv_item.sv"
import uvm_pkg::*;

class conv_random_seq extends uvm_sequence#(conv_item);
 
    `uvm_object_utils(conv_random_seq)


    function new(string name = "conv_random_seq");
        super.new(name);
    endfunction
    
    task body();
        conv_item item;
        item = conv_item::type_id::create("item");
        start_item(item);
        item.randomize();
        finish_item(item);
endtask
    endclass

`endif


