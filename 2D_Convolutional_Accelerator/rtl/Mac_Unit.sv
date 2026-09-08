`timescale 1ns / 1ps


module Mac_Unit(
    input logic clk,rst,clr,enable,
    input logic signed [7:0] a,b,
    output logic signed [31:0]acc

    );
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            acc<=0;
        else if (clr)
            acc<=0;
        else if (enable)
            acc<= acc+(a*b);
    
    end
    
    
endmodule
