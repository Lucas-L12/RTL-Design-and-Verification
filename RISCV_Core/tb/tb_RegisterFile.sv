`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench sencillo (no UVM) para el modulo RegisterFile
//
// Comprueba:
//   1) Reset: todos los registros deben leer 0 justo despues del reset
//   2) Escritura + lectura: escribir un valor en un registro y leerlo de vuelta
//   3) Doble lectura simultanea: rs1 y rs2 leyendo dos registros distintos a la vez
//   4) x0 (registro 0) nunca cambia, aunque se intente escribir en el
//   5) RegWrite = 0 no debe modificar ningun registro
//////////////////////////////////////////////////////////////////////////////////

module tb_RegisterFile();

    logic clk, rst, RegWrite;
    logic [31:0] instr, rd_data;
    logic [31:0] rs1_data, rs2_data;

    // Instancia del DUT (Device Under Test)
    RegisterFile dut (
        .clk(clk),
        .rst(rst),
        .RegWrite(RegWrite),
        .instr(instr),
        .rd_data(rd_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // Generacion de reloj: periodo de 10 ns
    always #5 clk = ~clk;

    // Construye una instruccion de 32 bits colocando rs1, rs2 y rd
    // en las mismas posiciones de bits que usa el DUT ([19:15], [24:20], [11:7]).
    // El resto de bits (opcode, funct3, funct7, etc.) se dejan a 0 porque
    // este modulo no los utiliza.
    function automatic logic [31:0] build_instr(
        input logic [4:0] rs1_f,
        input logic [4:0] rs2_f,
        input logic [4:0] rd_f
    );
        logic [31:0] i;
        i = 32'b0;
        i[19:15] = rs1_f;
        i[24:20] = rs2_f;
        i[11:7]  = rd_f;
        build_instr = i;
    endfunction

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
        RegWrite = 0;
        instr = 32'b0;
        rd_data = 32'b0;

        // ---- Test 1: tras el reset, cualquier registro debe leer 0 ----
        @(posedge clk);
        @(negedge clk);
        instr = build_instr(5'd1, 5'd2, 5'd0);
        #1;
        check(rs1_data, 32'd0, "Reset: x1 debe ser 0");
        check(rs2_data, 32'd0, "Reset: x2 debe ser 0");

        rst = 0;

        // ---- Test 2: escribir 42 en x5 y leerlo de vuelta por rs1 ----
        RegWrite = 1;
        instr    = build_instr(5'd0, 5'd0, 5'd5);   // rd = 5
        rd_data  = 32'd42;
        @(posedge clk);
        #1;
        RegWrite = 0;
        instr = build_instr(5'd5, 5'd0, 5'd0);      // rs1 = 5
        #1;
        check(rs1_data, 32'd42, "Escritura en x5, lectura por rs1");

        // ---- Test 3: escribir 100 en x10, leer x5 y x10 a la vez ----
        RegWrite = 1;
        instr    = build_instr(5'd0, 5'd0, 5'd10);  // rd = 10
        rd_data  = 32'd100;
        @(posedge clk);
        #1;
        RegWrite = 0;
        instr = build_instr(5'd5, 5'd10, 5'd0);     // rs1 = 5, rs2 = 10
        #1;
        check(rs1_data, 32'd42,  "Lectura doble: rs1 = x5");
        check(rs1_data, 32'd42,  "Lectura doble: rs1 = x5");
        check(rs2_data, 32'd100, "Lectura doble: rs2 = x10");

        // ---- Test 4: x0 nunca cambia, aunque se intente escribir ----
        RegWrite = 1;
        instr    = build_instr(5'd0, 5'd0, 5'd0);   // rd = 0
        rd_data  = 32'd999;
        @(posedge clk);
        #1;
        RegWrite = 0;
        instr = build_instr(5'd0, 5'd0, 5'd0);      // rs1 = 0
        #1;
        check(rs1_data, 32'd0, "x0 debe seguir siendo 0 tras intentar escribir");

        // ---- Test 5: RegWrite = 0 no debe escribir en ningun registro ----
        RegWrite = 0;
        instr    = build_instr(5'd0, 5'd0, 5'd7);   // rd = 7, pero RegWrite = 0
        rd_data  = 32'd555;
        @(posedge clk);
        #1;
        instr = build_instr(5'd7, 5'd0, 5'd0);      // rs1 = 7
        #1;
        check(rs1_data, 32'd0, "RegWrite=0 no debe escribir en x7");

        if (errores == 0)
            $display("\nTODOS LOS TESTS HAN PASADO CORRECTAMENTE");
        else
            $display("\nSE HAN ENCONTRADO %0d ERRORES", errores);

        $finish;
    end

endmodule