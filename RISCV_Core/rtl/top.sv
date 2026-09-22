`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2026 13:56:15
// Design Name: 
// Module Name: top
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

module top(
    input logic clk,rst
    );
    
    logic RegWrite,ALUSrc,MemRead,MemWrite,Branch,Jump,comp_result;
    logic [2:0] ResultSrc;
    logic [31:0] instr,rs1_data,rs2_data,rd_data,PC,PC4,PCIMM,imm, alu_result,RData,Src_result,ALU_Src_Result;
    operation_type ALUControl;   
    format_type Format;
      
    PC pc (.clk(clk),.rst(rst),.Src_result(Src_result),.PC_reg(PC));
    
    InstructionMemory IM (.instr_adress(PC),.instr_data(instr));
    
    Immediate_Gen IMM (.instr(instr),.Format(Format),.imm(imm));
   
    Control_Unit CN (.instr(instr),.RegWrite(RegWrite),.ALUSrc(ALUSrc),.MemRead(MemRead),.MemWrite(MemWrite),.Branch(Branch),.Jump(Jump),
                     .ResultSrc(ResultSrc),.ALUControl(ALUControl),.Format(Format));

    RegisterFile RF (.clk(clk),.rst(rst),.RegWrite(RegWrite),.instr(instr),.rd_data(rd_data),.rs1_data(rs1_data),
                     .rs2_data(rs2_data));

    ADDER_PC4 ADDPC4 (.PC(PC),.ADD(PC4));
    
    ADDER_PCIMM ADDIMM (.PC(PC),.imm(imm),.ADD(PCIMM));

    ALU ALU_inst (.A(rs1_data),.B(ALU_Src_Result),.ALUControl(ALUControl),.alu_result(alu_result));

    DataMemory DM (.rs2_data(rs2_data),.alu_result(alu_result),.clk(clk),.MemWrite(MemWrite),.RData(RData));
    
    Branch_Comparator BC (.rs1_data(rs1_data),.rs2_data(rs2_data),.instr(instr),.comp_result(comp_result));
    
    PC_Src PCSRC (.alu_result(alu_result),.PC4(PC4),.PCIMM(PCIMM),.Jump(Jump),.AluSrc(ALUSrc),.branch(Branch),
                  .comp_result(comp_result),.PC_Src_result(Src_result));

        
    assign ALU_Src_Result = ALUSrc ? imm : rs2_data;
    always_comb begin
        case(ResultSrc)
        3'b000:
            begin
                rd_data=alu_result;  
            end
        3'b001:
            begin
                rd_data=RData; 
            end            
            
        3'b010:
            begin
                 rd_data=PC4;
            end            
            
         3'b011:
            begin
                rd_data=PCIMM;
            end           
            
         3'b100:
            begin
                rd_data=imm;
            end           

        default:
            begin
                rd_data=alu_result;
            end
            
                
       endcase 
    end
    

endmodule