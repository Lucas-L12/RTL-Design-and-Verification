`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.09.2026 12:56:22
// Design Name: 
// Module Name: PC
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


module PC(
    input logic clk, rst,
    input logic [31:0] Src_result,
    output logic [31:0] PC_reg

    );
    
    logic [31:0] PC_next;

    always_ff @(posedge clk or posedge rst) begin
        if ( rst) begin
            PC_reg <= 32'b0;
                 
        end
        else begin
        PC_reg <= PC_next;
        end
    end
    
   
    assign PC_next=Src_result;
    

    
    
    
    
    
endmodule
