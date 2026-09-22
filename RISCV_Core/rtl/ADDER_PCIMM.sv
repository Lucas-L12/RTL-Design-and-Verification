`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.09.2026 13:12:45
// Design Name: 
// Module Name: ADDER_PCIMM
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


module ADDER_PCIMM(
    input logic [31:0] PC,imm,
    output logic [31:0] ADD
    );
    
    always_comb begin
    ADD= PC+imm;
    
    end
    
    
endmodule
