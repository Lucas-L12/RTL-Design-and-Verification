`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.08.2026 20:49:27
// Design Name: 
// Module Name: conv_item_smoke_test
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

`ifndef CONV_ITEM_SMOKE_TEST_SV
`define CONV_ITEM_SMOKE_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "conv_item.sv"

class conv_item_smoke_test extends uvm_test;
    `uvm_component_utils(conv_item_smoke_test)
    conv_item item;
    function new(string name = "conv_item_smoke_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        item = conv_item::type_id::create("item");
        item.randomize();
        
        item.print();

        phase.drop_objection(this);
    endtask
endclass

`endif