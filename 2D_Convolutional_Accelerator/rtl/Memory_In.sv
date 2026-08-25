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
    input  logic clk,
    input  logic [9:0] addr,          // 784 posiciones necesitan 10 bits (2^10=1024)
    output logic signed [7:0] pixel_out
);
    logic signed [7:0] mem [0:783];   // el almacenamiento real: 28x28 = 784 píxeles

    initial begin
        $readmemh("image.mem", mem);  // el mismo .mem  ya exportado en Fase 1
    end

    always_ff @(posedge clk) begin
        pixel_out <= mem[addr];
    end
endmodule
