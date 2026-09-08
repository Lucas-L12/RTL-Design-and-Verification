`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 22:00:02
// Design Name: 
// Module Name: all_zero_seq
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


`ifndef ALL_ZERO_SEQ_SV
`define ALL_ZERO_SEQ_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "conv_item.sv"

class all_zero_seq extends uvm_sequence#(conv_item);
    `uvm_object_utils(all_zero_seq)

    function new(string name = "all_zero_seq");
        super.new(name);
    endfunction

    task body();
        conv_item req;
        req = conv_item::type_id::create("req");

        start_item(req);
        foreach (req.pixels[i]) begin
            req.pixels[i] = 0;
        end
        finish_item(req);
    endtask
endclass
`endif
