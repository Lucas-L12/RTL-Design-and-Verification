`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.09.2026 13:09:56
// Design Name: 
// Module Name: ADDER_PC4
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


module ADDER_PC4(
    input logic [31:0] PC,
    output logic [31:0] ADD
    );
    
    always_comb begin
    ADD= PC+4;
    
    end
    
    
endmodule
