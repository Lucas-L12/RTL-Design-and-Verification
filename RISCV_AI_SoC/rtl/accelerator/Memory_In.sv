`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2026 14:35:58
// Design Name: 
// Module Name: Memory_In
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



module Memory_In(
    input  logic        clk,
    // lado bus (escritura)
    input  logic        we,
    input  logic [7:0]  widx,
    input  logic [31:0] wdata,
    input  logic [3:0]  wstrb,
    
    // lado controlador (lectura)
    input  logic [9:0]  addr,
    output logic signed [7:0] pixel_out
);
    logic [31:0] mem [0:195];     

    initial begin
        for (int i = 0; i < 196; i++)
            mem[i] = 32'b0;
    end

    always_ff @(posedge clk) begin
        pixel_out <= mem[addr[9:2]][addr[1:0]*8 +: 8];

        if (we) begin
            if (wstrb[0]) mem[widx][7:0]   <= wdata[7:0];
            if (wstrb[1]) mem[widx][15:8]  <= wdata[15:8];
            if (wstrb[2]) mem[widx][23:16] <= wdata[23:16];
            if (wstrb[3]) mem[widx][31:24] <= wdata[31:24];
        end
    end
endmodule