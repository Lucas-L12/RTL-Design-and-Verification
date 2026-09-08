`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.09.2026 17:03:24
// Design Name: 
// Module Name: conv_inf
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

interface  conv_inf(input logic clk);
    logic rst,ct_ready, done_cont;
    logic [9:0] read_addr;
    logic signed [7:0] read_data;
endinterface