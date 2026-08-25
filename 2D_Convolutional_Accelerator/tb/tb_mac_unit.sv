`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.08.2026 19:37:43
// Design Name: 
// Module Name: tb_mac_unit
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


module tb_mac_unit;   
 
    logic clk;
    logic rst;
    logic clr;
    logic enable;
    logic signed [7:0]  a, b;
    logic signed [31:0] acc;

    // Instancia del DUT (Device Under Test)
    Mac_Unit dut (
        .clk    (clk),
        .rst    (rst),
        .clr    (clr),
        .enable (enable),
        .a      (a),
        .b      (b),
        .acc    (acc)
    );

    // Generador de reloj: periodo de 10ns
    always #5 clk = ~clk;

    // Contadores para el resumen final
    int pass_count = 0;
    int fail_count = 0;

    // Modelo de referencia, calculado en paralelo dentro del propio testbench
    logic signed [31:0] expected_acc;

    // Aplica un ciclo de MAC y compara acc contra el modelo de referencia
    task automatic do_mac_step(input logic do_clr, input logic do_enable,
                                input logic signed [7:0] in_a, input logic signed [7:0] in_b);
        begin
            clr    = do_clr;
            enable = do_enable;
            a      = in_a;
            b      = in_b;

            @(posedge clk);
            #1; // pequeño margen para que acc se estabilice tras el flanco

            if (do_clr)
                expected_acc = 0;
            else if (do_enable)
                expected_acc = expected_acc + (in_a * in_b);
            // si no hay clr ni enable, expected_acc se mantiene igual

            if (acc === expected_acc) begin
                pass_count++;
            end else begin
                fail_count++;
                $display("FAIL: a=%0d b=%0d clr=%0d enable=%0d -> acc=%0d, esperado=%0d",
                          in_a, in_b, do_clr, do_enable, acc, expected_acc);
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        clr = 0;
        enable = 0;
        a = 0;
        b = 0;
        expected_acc = 0;

        @(posedge clk);
        #1;
        if (acc !== 32'sd0) begin
            fail_count++;
            $display("FAIL: rst no puso acc a 0");
        end else pass_count++;
        rst = 0;

        // --- Caso 1: ventana 3x3 completa, ya verificada a mano (resultado = 8) ---
        // imagen: 1,2,3,4,5,6,7,8,9   kernel: -1,0,1,-2,0,2,-1,0,1
        do_mac_step(1, 0, 8'sd1, -8'sd1);
        do_mac_step(0, 1, 8'sd2,  8'sd0);
        do_mac_step(0, 1, 8'sd3,  8'sd1);
        do_mac_step(0, 1, 8'sd4, -8'sd2);
        do_mac_step(0, 1, 8'sd5,  8'sd0);
        do_mac_step(0, 1, 8'sd6,  8'sd2);
        do_mac_step(0, 1, 8'sd7, -8'sd1);
        do_mac_step(0, 1, 8'sd8,  8'sd0);
        do_mac_step(0, 1, 8'sd9,  8'sd1);

        // --- Caso 2: enable=0 debe mantener el valor (hold) ---
        do_mac_step(0, 0, 8'sd50, 8'sd50);

        // --- Caso 3: clr debe ganar aunque enable tambien este activo ---
        clr = 1; enable = 1; a = 8'sd10; b = 8'sd10;
        @(posedge clk); #1;
        expected_acc = 0;
        if (acc === expected_acc) pass_count++;
        else begin
            fail_count++;
            $display("FAIL: prioridad clr sobre enable no se respeta");
        end

        // --- Caso 4: 100 vectores aleatorios (clr + un solo paso de MAC) ---
        for (int i = 0; i < 100; i++) begin
            logic signed [7:0] ra, rb;
            ra = $random;
            rb = $random;
            do_mac_step(1, 0, 8'sd0, 8'sd0);  // clr: acc -> 0
            do_mac_step(0, 1, ra, rb);        // enable: acc -> ra*rb
        end

        $display("--------------------------------------------------");
        $display("%0d PASS, %0d FAIL de %0d tests", pass_count, fail_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TODOS LOS TESTS PASARON");
        else
            $display("HAY TESTS FALLANDO - revisa mac_unit.sv");
        $display("--------------------------------------------------");

        $finish;
    end

endmodule

