`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.08.2026 00:57:32
// Design Name: 
// Module Name: tb_conv_engine
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

module tb_conv_engine();

    logic clk, rst, ready, done;
    logic signed [7:0] ventana [8:0];
    logic signed [7:0] kernel  [8:0];
    logic signed [31:0] ACCR;

    int pass_count = 0;
    int fail_count = 0;

    conv_engine dut (
        .clk    (clk),
        .rst    (rst),
        .ready  (ready),
        .ventana(ventana),
        .kernel (kernel),
        .ACCR   (ACCR),
        .done   (done)
    );

    // reloj: periodo 10ns
    initial clk = 0;
    always #5 clk = ~clk;

    // task: aplica una ventana+kernel, espera done, compara ACCR
    task automatic run_conv_test(
        input logic signed [7:0] vent [8:0],
        input logic signed [7:0] kern [8:0],
        input logic signed [31:0] expected,
        input string test_name
    );
        int i;
        begin
            for (i = 0; i < 9; i++) begin
                ventana[i] = vent[i];
                kernel[i]  = kern[i];
            end

            @(negedge clk);
            ready = 1;
            @(negedge clk);
            ready = 0;

            wait (done == 1);

            if (ACCR === expected) begin
                $display("PASS: %s | ACCR=%0d (esperado %0d)", test_name, ACCR, expected);
                pass_count++;
            end else begin
                $display("FAIL: %s | ACCR=%0d (esperado %0d)", test_name, ACCR, expected);
                fail_count++;
            end

            @(negedge clk); // deja que vuelva a IDLE antes del siguiente test
        end
    endtask

    initial begin
        logic signed [7:0] vent_test [8:0];
        logic signed [7:0] kern_test [8:0];
        logic signed [31:0] expected;
        int k;

        // reset
        rst = 1; ready = 0;
        repeat (2) @(negedge clk);
        rst = 0;

        // test 1: ventana 1-9, kernel sobel, resultado esperado = 8
        vent_test = '{1,2,3,4,5,6,7,8,9};
        kern_test = '{-1,0,1,-2,0,2,-1,0,1};
        run_conv_test(vent_test, kern_test, 32'sd8, "sobel_1_9");

        // test 2: todo ceros -> resultado 0
        vent_test = '{0,0,0,0,0,0,0,0,0};
        kern_test = '{-1,0,1,-2,0,2,-1,0,1};
        run_conv_test(vent_test, kern_test, 32'sd0, "todo_ceros");

        // test 3..102: 100 vectores aleatorios, verificados contra un modelo de referencia
        for (int t = 0; t < 100; t++) begin
            expected = 0;
            for (k = 0; k < 9; k++) begin
                vent_test[k] = $random % 128;
                kern_test[k] = $random % 128;
                expected = expected + (vent_test[k] * kern_test[k]);
            end
            run_conv_test(vent_test, kern_test, expected, $sformatf("random_%0d", t));
        end

        $display("\n%0d PASS, %0d FAIL de %0d tests", pass_count, fail_count, pass_count+fail_count);
        $stop;
    end

endmodule