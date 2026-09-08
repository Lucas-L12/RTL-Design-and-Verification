`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.09.2026 17:32:50
// Design Name: 
// Module Name: uvm_conv_tb_top
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

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "test_random_images.sv"
module uvm_conv_tb_top();
    logic clk;
    conv_inf vif(.clk(clk));

    initial clk=0;
    always #5 clk=~clk;

    top  dut (.clk(clk), .rst(vif.rst),.ct_ready(vif.ct_ready),.done_cont(vif.done_cont),.read_addr(vif.read_addr),
    .read_data(vif.read_data));

    initial begin
        uvm_config_db#(virtual conv_inf)::set(null, "*", "vif", vif);
        uvm_config_db#(virtual mem_backdoor_if)::set(null, "*", "backdoor", dut.mem_read.backdoor_if_inst);
        run_test("test_random_images");
    end
endmodule