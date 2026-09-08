`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 00:26:55
// Design Name: 
// Module Name: conv_agent
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


`ifndef CONV_AGENT_SV
`define CONV_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "conv_driver.sv"
`include "conv_sequencer.sv"
`include "conv_monitor.sv"

class conv_agent extends uvm_agent;
    `uvm_component_utils(conv_agent)
   conv_driver    driver;
   conv_sequencer sequencer;
   conv_monitor   monitor;
    
    function new(string name = "conv_agent", uvm_component parent = null);
    super.new(name, parent);
    endfunction
    

    function void build_phase(uvm_phase phase);
       super.build_phase(phase);
       driver    = conv_driver::type_id::create("driver", this);
       sequencer = conv_sequencer::type_id::create("sequencer", this);
       monitor   = conv_monitor::type_id::create("monitor", this);
endfunction
        
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
        driver.mon_done = monitor.mon_done;
    endfunction
        
        
  
endclass




`endif