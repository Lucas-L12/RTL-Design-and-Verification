`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 20:10:15
// Design Name: 
// Module Name: conv_coverage
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


`ifndef CONV_COVERAGE_SV
`define CONV_COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "conv_item.sv"


class conv_coverage extends uvm_subscriber#(conv_item);
    `uvm_component_utils(conv_coverage)
    bit signed [7:0] max_pixel;
    bit signed [7:0] min_pixel;
    bit all_zero;


    function new(string name = "conv_coverage", uvm_component parent = null);
        super.new(name, parent);
        img_cg = new();
    endfunction
    
    function void write(conv_item t);
        max_pixel = t.pixels[0];
        min_pixel = t.pixels[0];
        all_zero  = 1;
    
        foreach (t.pixels[i]) begin
            if (t.pixels[i] > max_pixel) max_pixel = t.pixels[i];
            if (t.pixels[i] < min_pixel) min_pixel = t.pixels[i];
            if (t.pixels[i] != 0) all_zero = 0;
        end
    
        img_cg.sample();
    endfunction
    
    function void report_phase(uvm_phase phase);
        `uvm_info("COVERAGE", $sformatf("Cobertura funcional final: %0.2f%%", img_cg.get_coverage()), UVM_LOW)   
    
    
    
    endfunction
        
    covergroup img_cg;
        option.per_instance = 1;
        cp_max: coverpoint max_pixel {
            bins negative = {[-128:-1]};
            bins zero     = {0};
            bins positive = {[1:127]};
        }
        cp_min: coverpoint min_pixel {
            bins negative = {[-128:-1]};
            bins zero     = {0};
            bins positive = {[1:127]};
        }
        cp_all_zero: coverpoint all_zero {
            bins yes = {1};
            bins no  = {0};
        }
    endgroup
    
    
endclass

`endif