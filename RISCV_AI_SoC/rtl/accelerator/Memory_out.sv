`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2026 14:40:10
// Design Name: 
// Module Name: Memory_out
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

`timescale 1ns / 1ps

module Memory_out(
    input  logic        clk,
    // lado controlador (escritura)
    input  logic [9:0]  addr,
    input  logic signed [7:0] data_in,
    input  logic        we,
    // lado bus (lectura)
    input  logic [7:0]  ridx,
    output logic [31:0] rdata
);
    logic [31:0] mem [0:168];       // 169 casillas de 32 bits = 676 bytes

    initial begin
        for (int i = 0; i < 169; i++)
            mem[i] = 32'b0;
    end

    always_ff @(posedge clk) begin
        if (we)
            mem[addr[9:2]][addr[1:0]*8 +: 8] <= data_in;

        rdata <= mem[ridx];
    end
endmodule