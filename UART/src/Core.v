`timescale 1ns / 1ps


module Core
#(
    parameter DBIT=8,
              SB_TICK=16,
              DVSR=27,
              DVSR_BIT=8,
              W=8
)
(
    input wire clk, reset,
    input wire rd_uart, wr_uart, rx,
    input wire [7:0] w_data,
    output wire tx_full, rx_empty, tx,
    output wire tx_done,
    output wire [7:0] r_data
);

    //signal declaration
    wire tick, rx_done_tick, tx_done_tick;
    wire [7:0] rx_data;
    wire rx_ready;

    wire [7:0] tx_data;
    wire tx_start;
    wire tx_start_pulse;
    reg tx_start_d;
    
    always @(posedge clk or posedge reset)
    if (reset)
        tx_start_d <= 0;
    else
        tx_start_d <= tx_start;
        

    baud_rate_generator #(.M(DVSR), .N(DVSR_BIT)) baud_gen (
        .clk(clk),.reset(reset),.q(),.max_tick(tick));


    receiver #(.DBIT(DBIT), .SB_TICK(SB_TICK)) receiver_unit (
        .clk(clk), .reset(reset),.rx(rx),.s_tick(tick),.rx_done_tick(rx_done_tick),.dout(rx_data));

    
    interface #(.W(W)) rx_interface (
        .clk(clk),
        .reset(reset),
        .set_flag(rx_done_tick),
        .clr_flag(rd_uart),
        .din(rx_data),
        .flag(rx_ready),
        .dout(r_data)
    );


    interface #(.W(W)) tx_interface (
    .clk(clk),.reset(reset),.set_flag(wr_uart),.clr_flag(tx_done_tick),.din(w_data),.flag(tx_start),.dout(tx_data));

 
    transmitter #(.DBIT(DBIT), .SB_TICK(SB_TICK)) trans (
        .clk(clk),.reset(reset),.tx_start(tx_start_pulse),.s_tick(tick), .din(tx_data),.tx_done_tick(tx_done_tick),.tx(tx));
                                //.tx_start(tx_start)

   
    // Output logic
    assign rx_empty = ~rx_ready;

    assign tx_start_pulse = tx_start & ~tx_start_d;
    assign tx_done = tx_done_tick;

endmodule
