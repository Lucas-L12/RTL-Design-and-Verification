`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2026 18:10:14
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




module tb_top();

    logic clk, rst, ct_ready, done_cont;
    logic [9:0] read_addr;
    logic signed [7:0] read_data;

    top dut (
        .clk(clk), .rst(rst), .ct_ready(ct_ready), .done_cont(done_cont),
        .read_addr(read_addr), .read_data(read_data)
    );;
    
    initial clk = 0;
    always #5 clk = ~clk;

    logic signed [7:0] expected [0:675];
    int pass_count, fail_count;

    initial begin
        $readmemh("expected_output.mem", expected);
        read_addr = 0;
        pass_count = 0;
        fail_count = 0;

        rst = 1; ct_ready = 0;
        repeat (2) @(negedge clk);
        rst = 0;

        @(negedge clk);
        ct_ready = 1;
        @(negedge clk);
        ct_ready = 0;

        wait (done_cont == 1);
        @(negedge clk);

        for (int k = 0; k < 676; k++) begin
            if (dut.mem_write.mem[k] !== expected[k]) begin
                $display("FAIL: addr=%0d resultado=%0d esperado=%0d", k, dut.mem_write.mem[k], expected[k]);
                fail_count++;
            end else begin
                pass_count++;
            end
        end

        $display("\n%0d PASS, %0d FAIL de %0d posiciones", pass_count, fail_count, pass_count+fail_count);
        $stop;
    end

endmodule