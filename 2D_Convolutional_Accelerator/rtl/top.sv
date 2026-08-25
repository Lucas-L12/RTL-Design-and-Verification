`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2026 14:41:15
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

module top
(
    input logic clk,rst,ct_ready,
    input logic [9:0] read_addr,
    output logic signed [7:0] read_data,
    output logic done_cont
    );
    logic  ready_conv,out_we, done;
    logic signed [7:0] ventana [8:0];
    logic signed [31:0] ACCR;
    logic signed [7:0] pixel_out_memory_in;   
    logic [9:0] addr_in,addr_out;
    logic signed [31:0] data_memory_out;
    logic signed [7:0] data_quantized;
    localparam logic signed [7:0] KERNEL [0:8] = '{-1, 0, 1, -2, 0, 2, -1, 0, 1};
    
    conv_engine conv    (.clk(clk), .rst(rst),.ready(ready_conv),.ventana(ventana),.kernel(KERNEL), .ACCR(ACCR),.done(done)   
    );
    
    controller cont     (.clk(clk),.rst(rst),.done_conv(done),.ct_ready(ct_ready),.ACCR(ACCR),.img_pixel(pixel_out_memory_in),
    .ready_conv(ready_conv),.done_cont(done_cont),.img_addr(addr_in),.out_addr(addr_out),.out_data(data_memory_out),
    .out_we(out_we), .ventana_out(ventana)
    
    );
    Memory_In mem_read  ( .clk(clk), .addr(addr_in),.pixel_out(pixel_out_memory_in)
    
    );

    requantizer requant ( .accr_in(data_memory_out), .q_out(data_quantized) );

    Memory_out mem_write ( .clk(clk),.addr(addr_out),.data_in(data_quantized), .we(out_we),
                           .read_addr(read_addr), .read_data(read_data)
    );
    
endmodule