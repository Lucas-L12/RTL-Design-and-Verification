`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 14:26:00
// Design Name: 
// Module Name: mem_backdoor
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


interface mem_backdoor_if (ref logic signed [7:0] mem [0:783]);
    task write_pixel(input int addr, input logic signed [7:0] val);
        mem[addr] = val;
    endtask
endinterface

bind Memory_In mem_backdoor_if backdoor_if_inst(.*);