`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 19:38:06
// Design Name: 
// Module Name: conv_scoreboard
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
`ifndef CONV_SCOREBOARD_SV
`define CONV_SCOREBOARD_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "conv_item.sv"
`include "conv_result.sv"
`uvm_analysis_imp_decl(_item)
`uvm_analysis_imp_decl(_result)
class conv_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(conv_scoreboard)
    uvm_analysis_imp_item#(conv_item, conv_scoreboard)     item_imp;
    uvm_analysis_imp_result#(conv_result, conv_scoreboard) result_imp;
    conv_item last_item;

    localparam bit signed [7:0] KERNEL [0:8] = '{-1, 0, 1, -2, 0, 2, -1, 0, 1};
    int pass_count = 0;
    int fail_count = 0;

    function new(string name = "conv_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void write_item(conv_item item);
        last_item = item;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_imp   = new("item_imp", this);
        result_imp = new("result_imp", this);
    endfunction

    function void write_result(conv_result result);
        int signed acc;
        bit signed [7:0] expected;
        int signed floor_val, rounded;
        bit [1:0] remainder;

        for (int r = 0; r < 26; r++) begin
            for (int c = 0; c < 26; c++) begin
                acc = 0;
                for (int i = 0; i < 3; i++) begin
                    for (int j = 0; j < 3; j++) begin
                        acc = acc + (last_item.pixels[(r+i)*28 + (c+j)] * KERNEL[i*3+j]);
                    end
                end

                floor_val = acc >>> 2;
                remainder = acc[1:0];

                if (remainder < 2)
                    rounded = floor_val;
                else if (remainder > 2)
                    rounded = floor_val + 1;
                else
                    rounded = (floor_val[0] == 1'b0) ? floor_val : floor_val + 1;

                if (rounded > 127)
                    expected = 127;
                else if (rounded < -128)
                    expected = -128;
                else
                    expected = rounded[7:0];

                if (expected !== result.pixels_out[r*26 + c]) begin
                    fail_count++;
                    `uvm_error("MISMATCH", $sformatf("r=%0d c=%0d esperado=%0d obtenido=%0d", r, c, expected, result.pixels_out[r*26+c]))
                end else begin
                    pass_count++;
                end

            end
        end
        `uvm_info("SCOREBOARD", $sformatf("%0d PASS, %0d FAIL de %0d posiciones", pass_count, fail_count, pass_count+fail_count), UVM_LOW)
    endfunction

endclass
`endif