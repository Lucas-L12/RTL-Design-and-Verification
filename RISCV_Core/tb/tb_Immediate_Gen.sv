`timescale 1ns / 1ps

import riscv_pkg::*;

module tb_Immediate_Gen();

    logic [31:0] instr;
    format_type Format;
    logic [31:0] imm;

    // Instancia del DUT
    Immediate_Gen dut (
        .instr(instr),
        .Format(Format),
        .imm(imm)
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

        // ---- Formato I, positivo: equivalente a addi con imm = 5 ----
        instr = {12'd5, 5'd0, 3'b000, 5'd1, 7'b0010011};
        Format = I; #1;
        check(imm, 32'd5, "I positivo: imm = 5");

        // ---- Formato I, negativo: equivalente a addi con imm = -8 ----
        instr = {12'b111111111000, 5'd0, 3'b000, 5'd1, 7'b0010011};
        Format = I; #1;
        check(imm, 32'hFFFFFFF8, "I negativo: imm = -8");

        // ---- Formato S, positivo: equivalente a sw con offset = 8 ----
        instr = {7'b0000000, 5'd2, 5'd1, 3'b010, 5'b01000, 7'b0100011};
        Format = S; #1;
        check(imm, 32'd8, "S positivo: imm = 8");

        // ---- Formato S, negativo: equivalente a sw con offset = -4 ----
        instr = {7'b1111111, 5'd2, 5'd1, 3'b010, 5'b11100, 7'b0100011};
        Format = S; #1;
        check(imm, 32'hFFFFFFFC, "S negativo: imm = -4");

        // ---- Formato B, positivo: equivalente a beq con offset = 8 ----
        instr = {1'b0, 6'b000000, 5'd2, 5'd1, 3'b000, 4'b0100, 1'b0, 7'b1100011};
        Format = B; #1;
        check(imm, 32'd8, "B positivo: imm = 8");

        // ---- Formato B, negativo: equivalente a beq con offset = -4 ----
        instr = {1'b1, 6'b111111, 5'd2, 5'd1, 3'b000, 4'b1110, 1'b1, 7'b1100011};
        Format = B; #1;
        check(imm, 32'hFFFFFFFC, "B negativo: imm = -4");

        // ---- Formato U: equivalente a lui con imm = 0x12345 ----
        instr = {20'h12345, 5'd1, 7'b0110111};
        Format = U; #1;
        check(imm, 32'h12345000, "U: imm = 0x12345000");

        // ---- Formato J, positivo: equivalente a jal con offset = 16 ----
        instr = {1'b0, 10'b0000001000, 1'b0, 8'b00000000, 5'd1, 7'b1101111};
        Format = J; #1;
        check(imm, 32'd16, "J positivo: imm = 16");
    
        // ---- Formato J, negativo: equivalente a jal con offset = -16 ----
        instr = {1'b1, 10'b1111111000, 1'b1, 8'b11111111, 5'd1, 7'b1101111};
        Format = J; #1;
        check(imm, 32'hFFFFFFF0, "J negativo: imm = -16");

        if (errores == 0)
            $display("\nTODOS LOS TESTS HAN PASADO CORRECTAMENTE");
        else
            $display("\nSE HAN ENCONTRADO %0d ERRORES", errores);

        $finish;
    end

endmodule