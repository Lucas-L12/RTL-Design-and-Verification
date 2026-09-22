`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.09.2026 13:29:41
// Design Name: 
// Module Name: InstructionMemory
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


module InstructionMemory(
    input logic [31:0] instr_adress,
    output logic [31:0] instr_data
    );



    logic [31:0] memory [255:0];
    logic [7:0] adress;

    initial begin
        $readmemh("instructions.mem", memory);  
    end
    always_comb begin
        adress=instr_adress[9:2];
        instr_data = memory[adress];
        
     
     end

endmodule