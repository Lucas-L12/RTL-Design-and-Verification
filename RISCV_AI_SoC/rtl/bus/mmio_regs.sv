`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.11.2026 11:35:40
// Design Name: 
// Module Name: mmio_regs
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

module mmio_regs(
    input  logic        clk, rstn, mem_valid,
    input  logic [31:0] addr, wdata,
    input  logic [3:0]  wstrb,
    output logic [31:0] rdata, data_out,
    output logic        ready
);

    localparam logic [31:0] ID = 32'hC0FFEE01;

    logic [31:0] data;
    logic [1:0]  adress;

    assign ready    = mem_valid;
    assign adress   = addr[3:2];
    assign data_out = data;

    always_comb begin
        case (adress)
            2'b00:   rdata = data;
            2'b01:   rdata = ID;
            default: rdata = 32'b0;
        endcase
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            data <= 32'b0;
        end
        else if (mem_valid && adress == 2'b00) begin
            if (wstrb[0]) data[7:0]   <= wdata[7:0];
            if (wstrb[1]) data[15:8]  <= wdata[15:8];
            if (wstrb[2]) data[23:16] <= wdata[23:16];
            if (wstrb[3]) data[31:24] <= wdata[31:24];
        end
    end

endmodule
    
    

