`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.09.2026 17:52:38
// Design Name: 
// Module Name: conv_driver
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
////////////////////////////////////////////////////////////////////////////////

`ifndef CONV_DRIVER_SV
`define CONV_DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "conv_item.sv"

class conv_driver extends uvm_driver#(conv_item);
    `uvm_component_utils(conv_driver)
    virtual conv_inf vif;
    uvm_event mon_done;
    virtual mem_backdoor_if backdoor;
    uvm_analysis_port#(conv_item) ap;
    conv_item req;
    function new(string name = "conv_driver", uvm_component parent = null);
    super.new(name, parent);
    endfunction
    

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual conv_inf)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "No se encontro la virtual interface en el config_db")
        if (!uvm_config_db#(virtual mem_backdoor_if)::get(this, "", "backdoor", backdoor))
            `uvm_fatal("NOBACKDOOR", "No se encontro la interface de backdoor en el config_db")
    endfunction
    
    
    task run_phase(uvm_phase phase);
    forever begin
       
        seq_item_port.get_next_item(req);
        ap.write(req);

    for (int i = 0; i < 784; i++) begin
        backdoor.write_pixel(i, req.pixels[i]);
    end
        
        vif.rst = 1;
        vif.ct_ready = 0;
        repeat (2) @(negedge vif.clk);
        vif.rst = 0;
        
        @(negedge vif.clk);
        vif.ct_ready = 1;
        @(negedge vif.clk);
        vif.ct_ready = 0;
        
        wait (vif.done_cont == 1);
        seq_item_port.item_done();
        mon_done.wait_trigger();
    end
endtask

endclass




`endif