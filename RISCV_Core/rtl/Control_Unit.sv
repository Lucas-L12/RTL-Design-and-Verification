`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.09.2026 19:25:56
// Design Name: 
// Module Name: Control_Unit
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

module Control_Unit(
     input logic [31:0] instr,
     output logic RegWrite,ALUSrc,MemRead,MemWrite,Branch,Jump,
     output logic [2:0] ResultSrc,
     output operation_type ALUControl,
     output format_type Format
    );
    
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic funct7;
    
    always_comb begin
        opcode = instr[6:0];
        funct3 = instr[14:12]; 
        funct7 = instr[30];
       
        RegWrite=0;
        ALUSrc=0;
        MemRead=0;
        MemWrite=0;
        ResultSrc=3'b000;   // por defecto, resultado de la ALU
        Branch=0;
        ALUControl=ADD;
        Format=I;
        Jump=0;
        
        case(opcode)  
            
            7'b0110011:   //R
                begin
                    RegWrite=1;
                    case (funct3)
                        3'b000: begin if (funct7) ALUControl=SUB; else ALUControl=ADD; end
                        3'b001: ALUControl=SLL;
                        3'b010: ALUControl=SLT;
                        3'b011: ALUControl=SLTU;
                        3'b100: ALUControl=L_XOR;
                        3'b101: begin if(funct7) ALUControl=SRA; else ALUControl=SRL; end
                        3'b110: ALUControl=L_OR;
                        3'b111: ALUControl=L_AND;
                    endcase
                end
            
            7'b0010011:   //I aritmetico
                begin
                    Format=I;
                    RegWrite=1;
                    ALUSrc=1;
                    case (funct3)
                        3'b000: ALUControl=ADD;
                        3'b010: ALUControl=SLT;
                        3'b011: ALUControl=SLTU;
                        3'b100: ALUControl=L_XOR;
                        3'b110: ALUControl=L_OR;
                        3'b111: ALUControl=L_AND;
                        3'b001: ALUControl=SLL;
                        3'b101: begin if(funct7) ALUControl=SRA; else ALUControl=SRL; end
                    endcase
                end
                
            7'b0000011:   //I carga (lw)
                begin
                    Format=I;
                    RegWrite=1;
                    if (funct3==3'b010) begin
                        MemRead=1;
                        ALUSrc=1;
                        ResultSrc=3'b001; // dato de memoria
                    end
                end
                
            7'b1100111: //I especial (jalr)
                begin
                    Format=I;
                    RegWrite=1;
                    ALUSrc=1;
                    ResultSrc=3'b010; // PC+4
                    Jump=1;
                end
                
            7'b0100011:   //S (sw)
                begin
                    Format=S;
                    if (funct3==3'b010) begin
                        MemWrite=1;
                        ALUSrc=1;
                    end
                end
                
            7'b1100011:  //B (branches)
                begin
                    Format=B;
                    Branch=1;
                end
                
            7'b0110111:    //U (lui)
                begin
                    Format=U;
                    RegWrite=1;
                    ResultSrc=3'b100; // inmediato directo, sin pasar por la ALU
                end
                
            7'b0010111:    //U (auipc)
                begin
                    Format=U;
                    RegWrite=1;
                    ResultSrc=3'b011; // PC + inmediato
                end
                
            7'b1101111:    //J (jal)
                begin
                    Format=J;
                    RegWrite=1;
                    ResultSrc=3'b010; // PC+4
                    Jump=1;
                end
                                                 
            default: begin end
        
        endcase
    
    end
    
endmodule
