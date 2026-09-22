`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.09.2026 21:37:29
// Design Name: 
// Module Name: tb_Control_Unit
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

module tb_Control_Unit();

    logic [31:0] instr;
    logic RegWrite, ALUSrc, MemRead, MemWrite, Branch;
    logic [2:0] ResultSrc;
    operation_type ALUControl;
    format_type Format;

    Control_Unit dut (
        .instr(instr),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ResultSrc(ResultSrc),
        .ALUControl(ALUControl),
        .Format(Format)
    );

    integer errores = 0;

    task automatic check_all(
        input string nombre,
        input logic e_RegWrite, e_ALUSrc, e_MemRead, e_MemWrite, e_Branch,
        input logic [2:0] e_ResultSrc,
        input operation_type e_ALUControl,
        input format_type e_Format
    );
        logic fallo;
        fallo = 0;
        if (RegWrite !== e_RegWrite)     begin $display("  FALLO RegWrite: esperado=%0d obtenido=%0d", e_RegWrite, RegWrite); fallo=1; end
        if (ALUSrc !== e_ALUSrc)         begin $display("  FALLO ALUSrc: esperado=%0d obtenido=%0d", e_ALUSrc, ALUSrc); fallo=1; end
        if (MemRead !== e_MemRead)       begin $display("  FALLO MemRead: esperado=%0d obtenido=%0d", e_MemRead, MemRead); fallo=1; end
        if (MemWrite !== e_MemWrite)     begin $display("  FALLO MemWrite: esperado=%0d obtenido=%0d", e_MemWrite, MemWrite); fallo=1; end
        if (Branch !== e_Branch)         begin $display("  FALLO Branch: esperado=%0d obtenido=%0d", e_Branch, Branch); fallo=1; end
        if (ResultSrc !== e_ResultSrc)   begin $display("  FALLO ResultSrc: esperado=%0d obtenido=%0d", e_ResultSrc, ResultSrc); fallo=1; end
        if (ALUControl !== e_ALUControl) begin $display("  FALLO ALUControl: esperado=%s obtenido=%s", e_ALUControl.name(), ALUControl.name()); fallo=1; end
        if (Format !== e_Format)         begin $display("  FALLO Format: esperado=%s obtenido=%s", e_Format.name(), Format.name()); fallo=1; end

        if (fallo) begin
            $display("FALLO -> %s", nombre);
            errores = errores + 1;
        end else begin
            $display("OK    -> %s", nombre);
        end
    endtask

    initial begin

        // add (R): funct3=000, funct7[5]=0
        instr = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011}; #1;
        check_all("add", 1,0,0,0,0, 3'b000, ADD, I);

        // sub (R): funct3=000, funct7[5]=1
        instr = {7'b0100000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011}; #1;
        check_all("sub", 1,0,0,0,0, 3'b000, SUB, I);

        // and (R): funct3=111
        instr = {7'b0000000, 5'd2, 5'd1, 3'b111, 5'd3, 7'b0110011}; #1;
        check_all("and", 1,0,0,0,0, 3'b000, L_AND, I);

        // addi (I aritmetico): funct3=000
        instr = {12'd0, 5'd1, 3'b000, 5'd3, 7'b0010011}; #1;
        check_all("addi", 1,1,0,0,0, 3'b000, ADD, I);

        // srai (I aritmetico): funct3=101, bit alto=1
        instr = {7'b0100000, 5'd0, 5'd1, 3'b101, 5'd3, 7'b0010011}; #1;
        check_all("srai", 1,1,0,0,0, 3'b000, SRA, I);

        // lw (I carga): funct3=010
        instr = {12'd0, 5'd1, 3'b010, 5'd3, 7'b0000011}; #1;
        check_all("lw", 1,1,1,0,0, 3'b001, ADD, I);

        // sw (S): funct3=010
        instr = {7'd0, 5'd2, 5'd1, 3'b010, 5'd0, 7'b0100011}; #1;
        check_all("sw", 0,1,0,1,0, 3'b000, ADD, S);

        // beq (B): funct3=000
        instr = {1'b0,6'd0,5'd2,5'd1,3'b000,4'd0,1'b0,7'b1100011}; #1;
        check_all("beq", 0,0,0,0,1, 3'b000, ADD, B);

        // jalr (I especial)
        instr = {12'd0, 5'd1, 3'b000, 5'd3, 7'b1100111}; #1;
        check_all("jalr", 1,1,0,0,0, 3'b010, ADD, I);

        // lui (U)
        instr = {20'd0, 5'd3, 7'b0110111}; #1;
        check_all("lui", 1,0,0,0,0, 3'b100, ADD, U);

        // auipc (U)
        instr = {20'd0, 5'd3, 7'b0010111}; #1;
        check_all("auipc", 1,0,0,0,0, 3'b011, ADD, U);

        // jal (J)
        instr = {1'b0,10'd0,1'b0,8'd0,5'd3,7'b1101111}; #1;
        check_all("jal", 1,0,0,0,0, 3'b010, ADD, J);

        if (errores == 0)
            $display("\nTODOS LOS TESTS HAN PASADO CORRECTAMENTE");
        else
            $display("\nSE HAN ENCONTRADO %0d ERRORES", errores);

        $finish;
    end

endmodule