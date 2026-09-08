`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 21:31:23
// Design Name: 
// Module Name: test_random_images
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

`ifndef TEST_RANDOM_IMAGES_SV
`define TEST_RANDOM_IMAGES_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "conv_test.sv"
`include "all_zero_seq.sv"

class test_random_images extends conv_test;
    `uvm_component_utils(test_random_images)

    int num_images = 20;

    function new(string name = "test_random_images", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        conv_random_seq seq;
        all_zero_seq allzero;

        phase.raise_objection(this);

        for (int i = 0; i < num_images; i++) begin
            seq = conv_random_seq::type_id::create($sformatf("seq_%0d", i));
            seq.start(env.agent.sequencer);
        end

        allzero = all_zero_seq::type_id::create("allzero");
        allzero.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask
endclass
`endif