`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.09.2026 19:18:34
// Design Name: 
// Module Name: conv_monitor
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
`ifndef CONV_MONITOR_SV
`define CONV_MONITOR_SV
`include "uvm_macros.svh"
`include "conv_result.sv"
import uvm_pkg::*;
class conv_monitor extends uvm_monitor;
    `uvm_component_utils(conv_monitor)

    virtual conv_inf vif;
    uvm_analysis_port#(conv_result) ap;
    uvm_event mon_done;

    function new(string name = "conv_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual conv_inf)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "No se encontro la virtual interface en el config_db")
        ap = new("ap", this);
        mon_done = new("mon_done");
                 

        
    endfunction

    task run_phase(uvm_phase phase);
        conv_result result;
        forever begin
            @(negedge vif.clk);
            wait (vif.done_cont == 1);
            phase.raise_objection(this);
            @(negedge vif.clk);   // alinea al flanco de bajada antes de empezar a leer
    
            result = conv_result::type_id::create("result");
            for (int i = 0; i < 676; i++) begin
                vif.read_addr = i;
                @(negedge vif.clk);
                result.pixels_out[i] = vif.read_data;
            end

            ap.write(result);
            mon_done.trigger();
            phase.drop_objection(this);
        end
    endtask

endclass
`endif