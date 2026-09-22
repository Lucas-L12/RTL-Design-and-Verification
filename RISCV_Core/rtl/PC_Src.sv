`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2026 13:35:57
// Design Name: 
// Module Name: PC_Src
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


module PC_Src(
    input logic [31:0] alu_result,PC4,PCIMM,
    input logic Jump,AluSrc, branch, comp_result,
    output logic [31:0] PC_Src_result

    );
    
    always_comb begin
        PC_Src_result = PC4;

        if (branch && comp_result) begin
            PC_Src_result = PCIMM;
        end

        if (Jump) begin
            if (AluSrc) begin
                PC_Src_result = alu_result;
            end
            else begin
                PC_Src_result = PCIMM;
            end
        end
    end

endmodule