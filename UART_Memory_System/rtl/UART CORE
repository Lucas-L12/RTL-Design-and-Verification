`timescale 1ns / 1ps

module Top_Level
#(
    parameter DBIT       = 8,
              SB_TICK    = 16,
              DVSR       = 27,
              DVSR_BIT   = 8,
              W          = 8,
              ADDR_WIDTH = 8,
              DATA_WIDTH = 8
)
(
    input  logic clk,
    input  logic reset,

    input  logic Rx,
    output logic Tx
);
 
    // Internal signals
    logic [DATA_WIDTH-1:0] r_data;
    logic [DATA_WIDTH-1:0] w_data;

    logic [DATA_WIDTH-1:0] mem_data_in;
    logic [DATA_WIDTH-1:0] mem_data_out;

    logic [ADDR_WIDTH-1:0] mem_addr;

    logic rx_ready;
    logic rx_empty;

    logic tx_done;
    logic wr_uart;
    logic rd_uart;

    logic access_valid;
    logic mem_write_en;

    logic tx_full;

    // UART Core
    Core #(
        .DBIT(DBIT),
        .SB_TICK(SB_TICK),
        .DVSR(DVSR),
        .DVSR_BIT(DVSR_BIT),
        .W(W)
    )
    I_Core (

        .clk(clk),
        .reset(reset),

        .rd_uart(rd_uart),
        .wr_uart(wr_uart),

        .rx(Rx),
        .tx(Tx),

        .w_data(w_data),
        .r_data(r_data),

        .rx_empty(rx_empty),
        .tx_full(tx_full),

        .tx_done(tx_done)
    );

    // Controller
    Controller #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    )
    I_Controller (

        .clk(clk),
        .reset(reset),

        .r_data(r_data),
        .mem_data_out(mem_data_out),

        .rx_ready(rx_ready),
        .tx_done(tx_done),
        .access_valid(access_valid),

        .rd_uart(rd_uart),
        .wr_uart(wr_uart),
        .mem_write_en(mem_write_en),

        .w_data(w_data),
        .mem_addr(mem_addr),
        .mem_data_in(mem_data_in)
    );

    // MPU
    MPU I_MPU (

        .addr(mem_addr),
        .access_valid(access_valid)
    );

    // RAM
    RAM #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    )
    I_RAM (

        .clk(clk),

        .mem_write_en(mem_write_en),

        .mem_addr(mem_addr),
        .mem_data_in(mem_data_in),

        .mem_data_out(mem_data_out)
    );

    // UART status conversion
    assign rx_ready = ~rx_empty;

endmodule
