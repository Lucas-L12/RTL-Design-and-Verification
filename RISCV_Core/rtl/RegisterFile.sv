`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2026 13:37:44
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile(
    input logic clk,rst,RegWrite,
    input logic [31:0] instr, rd_data,
    output logic [31:0] rs1_data,rs2_data

    );
    
    logic [31:0] registers [31:0];

    
    logic [4:0] rs1,rs2,rd;
    
    always_comb begin
    
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        rd  = instr[11:7];
        
        rs1_data = registers[rs1];
        rs2_data= registers[rs2];
    
    end
    
    always_ff  @ (posedge clk or posedge rst) begin
        if(rst)
            for (int i=0; i<32; i++)
                registers[i]<=32'b0;
        else
        
        if(RegWrite)
            if (rd != 5'b0) 
                registers [rd]<= rd_data;
                
            
            
    
    end
    
    
    
endmodule