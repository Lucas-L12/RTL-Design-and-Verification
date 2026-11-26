`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.11.2026 18:38:53
// Design Name: 
// Module Name: ram
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


module ram(
    input logic clk,mem_valid,
    input logic  [31:0] addr,wdata,
    input  logic  [3:0] wstrb,
    output logic  [31:0] rdata,
    output logic ready
     );
     logic [31:0] memory [4095:0];
     logic  [11:0] adress;
    initial begin
            for (int i=0; i<4096; i++)
            memory[i]=32'b0;

        $readmemh("firmware.mem", memory);  
    end
     always_comb  begin
        ready=mem_valid;
        adress=addr[13:2];
        rdata=memory[adress];
     end
always_ff @(posedge clk ) begin

    if (mem_valid) begin
        if (wstrb[0]) memory[adress][7:0]   <= wdata[7:0];
        if (wstrb[1]) memory[adress][15:8]  <= wdata[15:8];
        if (wstrb[2]) memory[adress][23:16] <= wdata[23:16];
        if (wstrb[3]) memory[adress][31:24] <= wdata[31:24];
    end
end
     
endmodule
