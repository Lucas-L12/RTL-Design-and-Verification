`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2026 19:08:55
// Design Name: 
// Module Name: ALU
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

import riscv_pkg::*;

module ALU(
    input logic [31:0] A,B,
    input operation_type ALUControl,
    output logic [31:0] alu_result
    );
    
    
     always_comb begin 
        case(ALUControl)
        
        ADD:
            begin
                alu_result= A + B;
            
            end
        SUB:
            begin
                alu_result= A - B;
            
            end           
        L_AND:
            begin
                alu_result= A & B;
            
            end        
        L_OR:
            begin
                alu_result= A | B;
            
            end        
        L_XOR:
            begin
                alu_result= A ^ B;
            end        
        SLL:
            begin
                alu_result = A << B[4:0];
            end       
        SRL:
            begin
                alu_result = A >> B[4:0];
            
            end       
        SRA:
            begin
                alu_result = $signed(A) >>> B[4:0];
            end        
        SLT:
            begin
            alu_result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            
            end        
        SLTU:
             begin
                alu_result = (A < B) ? 32'd1 : 32'd0;
            
             end       
        default: alu_result= 32'b0;
     
        
        endcase
        

     
     end
     
    
    
    
endmodule
