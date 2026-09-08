`timescale 1ns / 1ps



module Memory_out(
    input logic clk,
    input logic [9:0] addr,
    input logic signed [7:0] data_in,
    input logic we,
    input logic [9:0] read_addr,
    output logic signed [7:0] read_data
    );
    logic signed [7:0] mem [0:675];

    always_ff @(posedge clk) begin
        if (we)
            mem[addr] <= data_in;
        read_data <= mem[read_addr];
    end
endmodule
