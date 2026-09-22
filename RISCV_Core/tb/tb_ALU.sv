`timescale 1ns / 1ps

import riscv_pkg::*;

module tb_ALU();

    logic [31:0] A, B;
    operation_type ALUControl;
    logic [31:0] alu_result;

    // Instancia del DUT
    ALU dut (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .alu_result(alu_result)
    );

    integer errores = 0;

    task automatic check(input logic [31:0] actual, input logic [31:0] esperado, input string nombre);
        if (actual !== esperado) begin
            $display("FALLO -> %s : esperado = 0x%0h, obtenido = 0x%0h", nombre, esperado, actual);
            errores = errores + 1;
        end else begin
            $display("OK    -> %s : valor = 0x%0h", nombre, actual);
        end
    endtask

    initial begin

        // ADD: 10 + 5 = 15
        A = 32'd10; B = 32'd5; ALUControl = ADD; #1;
        check(alu_result, 32'd15, "ADD: 10 + 5");

        // SUB: 10 - 5 = 5
        A = 32'd10; B = 32'd5; ALUControl = SUB; #1;
        check(alu_result, 32'd5, "SUB: 10 - 5");

        // SUB con resultado negativo: 5 - 10 = -5 -> 0xFFFFFFFB en complemento a 2
        A = 32'd5; B = 32'd10; ALUControl = SUB; #1;
        check(alu_result, 32'hFFFFFFFB, "SUB: 5 - 10 (negativo)");

        // AND
        A = 32'hFF00FF00; B = 32'h0F0F0F0F; ALUControl = L_AND; #1;
        check(alu_result, 32'h0F000F00, "AND");

        // OR
        A = 32'hFF00FF00; B = 32'h0F0F0F0F; ALUControl = L_OR; #1;
        check(alu_result, 32'hFF0FFF0F, "OR");

        // XOR
        A = 32'hFF00FF00; B = 32'h0F0F0F0F; ALUControl = L_XOR; #1;
        check(alu_result, 32'hF00FF00F, "XOR");

        // SLL: 1 << 4 = 16
        A = 32'd1; B = 32'd4; ALUControl = SLL; #1;
        check(alu_result, 32'd16, "SLL: 1 << 4");

        // SRL: 0x80000000 >> 4, rellena con 0 (logico)
        A = 32'h80000000; B = 32'd4; ALUControl = SRL; #1;
        check(alu_result, 32'h08000000, "SRL: 0x80000000 >> 4");

        // SRA: 0x80000000 >>> 4, rellena con el bit de signo (aritmetico)
        A = 32'h80000000; B = 32'd4; ALUControl = SRA; #1;
        check(alu_result, 32'hF8000000, "SRA: 0x80000000 >>> 4");

        // SLT: -1 < 1 con signo -> verdadero (1)
        A = 32'hFFFFFFFF; B = 32'd1; ALUControl = SLT; #1;
        check(alu_result, 32'd1, "SLT: -1 < 1 (con signo)");

        // SLTU: 0xFFFFFFFF sin signo es un numero enorme, no es menor que 1 -> falso (0)
        A = 32'hFFFFFFFF; B = 32'd1; ALUControl = SLTU; #1;
        check(alu_result, 32'd0, "SLTU: 0xFFFFFFFF < 1 (sin signo)");

        if (errores == 0)
            $display("\nTODOS LOS TESTS HAN PASADO CORRECTAMENTE");
        else
            $display("\nSE HAN ENCONTRADO %0d ERRORES", errores);

        $finish;
    end

endmodule