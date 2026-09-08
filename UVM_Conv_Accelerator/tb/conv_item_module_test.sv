`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.09.2026 16:49:33
// Design Name: 
// Module Name: conv_item_module_test
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
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "conv_item_smoke_test.sv"

module conv_item_module_test;
        initial begin
        run_test("conv_item_smoke_test");
    end

endmodule
