`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.09.2026 13:48:58
// Design Name: 
// Module Name: Immediate_Gen
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

module Immediate_Gen(

   input logic [31:0] instr,
   input format_type Format, 
   output logic [31:0] imm

    );
    
    always_comb begin
    
        case(Format)
            I:
                begin
                    imm= { {20{instr[31]}}, instr[31:20] };
                end
            
            S:
                begin
                    imm= { {20{instr[31]}}, instr[31:25], instr[11:7] };
                end
              
            B:
                begin
                    imm= { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
                end
                
            U:
            begin
                    imm= { instr[31:12], 12'b0 };
                end
                
            J:
                begin
                    imm= { {11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0 };
                end
            
            default: imm= 32'b0;
            
            
        endcase
        
        
    
    end
    
    
    
endmodule
