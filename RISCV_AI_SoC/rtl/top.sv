`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.11.2026 18:53:30
// Design Name: 
// Module Name: top
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

module top(
    input  logic        clk, resetn,
    output logic        trap, bus_error,
    output logic [31:0] data_out
);

    // Bus del core
    logic        mem_valid, mem_ready;
    logic [31:0] mem_addr, mem_wdata, mem_rdata;
    logic [3:0]  mem_wstrb;

    // RAM
    logic        ram_valid, ram_ready;
    logic [31:0] ram_rdata;

    // Periferico
    logic        per_valid, per_ready;
    logic [31:0] per_rdata;

    // Acelerador
    logic        acc_valid, acc_ready;
    logic [31:0] acc_rdata;

    picorv32 #(
        .STACKADDR(32'h0000_4000)
    ) u_cpu (
        .clk        (clk),
        .resetn     (resetn),
        .trap       (trap),

        .mem_valid  (mem_valid),
        .mem_instr  (),
        .mem_ready  (mem_ready),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_wstrb  (mem_wstrb),
        .mem_rdata  (mem_rdata),

        .mem_la_read  (),
        .mem_la_write (),
        .mem_la_addr  (),
        .mem_la_wdata (),
        .mem_la_wstrb (),

        .pcpi_valid (),
        .pcpi_insn  (),
        .pcpi_rs1   (),
        .pcpi_rs2   (),
        .pcpi_wr    (1'b0),
        .pcpi_rd    (32'b0),
        .pcpi_wait  (1'b0),
        .pcpi_ready (1'b0),

        .irq        (32'b0),
        .eoi        (),

        .trace_valid(),
        .trace_data ()
    );

    bus_decoder u_decoder (
        .mem_valid (mem_valid),
        .mem_addr  (mem_addr),
        .ram_ready (ram_ready),
        .per_ready (per_ready),
        .acc_ready (acc_ready),
        .ram_rdata (ram_rdata),
        .per_rdata (per_rdata),
        .acc_rdata (acc_rdata),
        .mem_rdata (mem_rdata),
        .ram_valid (ram_valid),
        .per_valid (per_valid),
        .acc_valid (acc_valid),
        .mem_ready (mem_ready),
        .bus_error (bus_error)
    );

    ram u_ram (
        .clk       (clk),
        .mem_valid (ram_valid),
        .addr      (mem_addr),
        .wdata     (mem_wdata),
        .wstrb     (mem_wstrb),
        .rdata     (ram_rdata),
        .ready     (ram_ready)
    );

    mmio_regs u_mmio (
        .clk       (clk),
        .rstn      (resetn),
        .mem_valid (per_valid),
        .addr      (mem_addr),
        .wdata     (mem_wdata),
        .wstrb     (mem_wstrb),
        .rdata     (per_rdata),
        .data_out  (data_out),
        .ready     (per_ready)
    );

    Wrapper u_accel (
        .clk       (clk),
        .resetn    (resetn),
        .acc_valid (acc_valid),
        .addr      (mem_addr),
        .wdata     (mem_wdata),
        .wstrb     (mem_wstrb),
        .acc_rdata (acc_rdata),
        .acc_ready (acc_ready)
    );

endmodule