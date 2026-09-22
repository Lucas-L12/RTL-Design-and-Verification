`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.09.2026 14:19:48
// Design Name: 
// Module Name: DataMemory
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


module DataMemory(
    input logic [31:0] rs2_data,alu_result,
    input logic clk,MemWrite,
    output logic [31:0] RData
    );


    logic [31:0] memory [255:0];
    logic  [7:0] adress_alu;
    
    always_comb begin
        adress_alu= alu_result [9:2];
        RData= memory[adress_alu];
            
    
    
    end
    always_ff @(posedge clk) begin
        if (MemWrite)
            memory[adress_alu] <= rs2_data;
    end
endmodule