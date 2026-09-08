`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 00:39:56
// Design Name: 
// Module Name: conv_env
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


`ifndef CONV_ENV_SV
`define CONV_ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "conv_agent.sv"
`include "conv_scoreboard.sv"
`include "conv_coverage.sv"

class conv_env extends uvm_env;
    `uvm_component_utils(conv_env)
   conv_agent  agent;
   conv_scoreboard scoreboard;
   conv_coverage coverage;

    
    function new(string name = "conv_env", uvm_component parent = null);
    super.new(name, parent);
    endfunction
    

    function void build_phase(uvm_phase phase);
       super.build_phase(phase);
       agent    = conv_agent::type_id::create("agent", this);
       scoreboard    = conv_scoreboard::type_id::create("scoreboard", this);
       coverage = conv_coverage::type_id::create("coverage", this);

        

    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.driver.ap.connect(scoreboard.item_imp);
        agent.monitor.ap.connect(scoreboard.result_imp);
        agent.driver.ap.connect(coverage.analysis_export);
                 
    endfunction
            
        
  
endclass




`endif