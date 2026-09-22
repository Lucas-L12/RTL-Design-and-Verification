`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.09.2026 13:03:07
// Design Name: 
// Module Name: tb_top
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

module tb_top();

    logic clk, rst;

    top dut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    integer errores = 0;

    task automatic check(input logic [31:0] actual, input logic [31:0] esperado, input string nombre);
        if (actual !== esperado) begin
            $display("FALLO -> %s : esperado = %0d, obtenido = %0d", nombre, esperado, actual);
            errores = errores + 1;
        end else begin
            $display("OK    -> %s : valor = %0d", nombre, actual);
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;

        @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Dejamos correr suficientes ciclos para ejecutar las 6 primeras
        // instrucciones y entrar en el bucle infinito final
        repeat (20) @(posedge clk);
        #1;

        check(dut.RF.registers[1], 32'd5,  "x1 = 5");
        check(dut.RF.registers[2], 32'd10, "x2 = 10");
        check(dut.RF.registers[3], 32'd15, "x3 = 15");
        check(dut.RF.registers[4], 32'd15, "x4 = 15 (leido de memoria)");
        check(dut.RF.registers[5], 32'd0,  "x5 = 0 (nunca escrito, el branch lo salta)");
        check(dut.DM.memory[0],    32'd15, "mem[0] = 15");

        if (errores == 0)
            $display("\nTODOS LOS TESTS HAN PASADO CORRECTAMENTE");
        else
            $display("\nSE HAN ENCONTRADO %0d ERRORES", errores);

        $finish;
    end

endmodule