`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2026 20:50:54
// Design Name: 
// Module Name: tb_controller
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

module tb_controller();

    logic clk, rst, ct_ready;
    logic ready_conv, done_conv, done_cont;
    logic [9:0] img_addr;
    logic signed [7:0] img_pixel;
    logic signed [31:0] ACCR;
    logic [9:0] out_addr;
    logic signed [31:0] out_data;
    logic out_we;
    logic signed [7:0] ventana_out [0:8];

    // memoria de imagen simulada (28x28 = 784 valores), lectura sincrona (1 ciclo)
    logic signed [7:0] image_mem [0:783];

    always_ff @(posedge clk) begin
        img_pixel <= image_mem[img_addr];
    end

    controller dut (
        .clk(clk), .rst(rst), .done_conv(done_conv), .ct_ready(ct_ready),
        .ACCR(ACCR), .img_pixel(img_pixel),
        .ready_conv(ready_conv), .done_cont(done_cont),
        .img_addr(img_addr),
        .out_addr(out_addr), .out_data(out_data), .out_we(out_we),
        .ventana_out(ventana_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // stub de conv_engine: simula ready->done con retraso fijo.
    // ACCR = suma de ventana_out (no hace falta kernel, solo probamos el controller)
    logic [2:0] delay_cnt;
    logic counting;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            done_conv <= 0; counting <= 0; delay_cnt <= 0;
        end else begin
            done_conv <= 0;
            if (ready_conv) begin
                counting  <= 1;
                delay_cnt <= 2;
            end else if (counting) begin
                if (delay_cnt == 0) begin
                    done_conv <= 1;
                    counting  <= 0;
                end else begin
                    delay_cnt <= delay_cnt - 1;
                end
            end
        end
    end

    assign ACCR = ventana_out[0] + ventana_out[1] + ventana_out[2] +
                  ventana_out[3] + ventana_out[4] + ventana_out[5] +
                  ventana_out[6] + ventana_out[7] + ventana_out[8];

    // captura de resultados (emula la BRAM de salida)
    logic signed [31:0] results [0:675];
    logic hit [0:675];

    always_ff @(posedge clk) begin
        if (out_we) begin
            results[out_addr] <= out_data;
            hit[out_addr]     <= 1;
        end
    end

    // modelo de referencia: misma formula de ventana, calculada directamente sobre image_mem
    function automatic signed [31:0] expected_sum(input int r, input int c);
        logic signed [31:0] s;
        s = 0;
        for (int i = 0; i < 3; i++)
            for (int j = 0; j < 3; j++)
                s = s + image_mem[(r+i)*28 + (c+j)];
        return s;
    endfunction

    int pass_count, fail_count;
    int addr;
    logic signed [31:0] exp;

    initial begin
        pass_count = 0;
        fail_count = 0;

        for (int k = 0; k < 784; k++)
            image_mem[k] = (k % 200) - 100;

        for (int a = 0; a < 676; a++)
            hit[a] = 0;

        rst = 1; ct_ready = 0;
        repeat (2) @(negedge clk);
        rst = 0;

        @(negedge clk);
        ct_ready = 1;
        @(negedge clk);
        ct_ready = 0;

        wait (done_cont == 1);
        @(negedge clk);

        for (int r = 0; r < 26; r++) begin
            for (int c = 0; c < 26; c++) begin
                addr = r*26 + c;
                exp  = expected_sum(r, c);
                if (!hit[addr]) begin
                    $display("FAIL: direccion %0d nunca escrita (r=%0d,c=%0d)", addr, r, c);
                    fail_count++;
                end else if (results[addr] !== exp) begin
                    $display("FAIL: addr=%0d resultado=%0d esperado=%0d (r=%0d,c=%0d)", addr, results[addr], exp, r, c);
                    fail_count++;
                end else begin
                    pass_count++;
                end
            end
        end

        $display("\n%0d PASS, %0d FAIL de %0d posiciones", pass_count, fail_count, pass_count+fail_count);
        $stop;
    end

endmodule