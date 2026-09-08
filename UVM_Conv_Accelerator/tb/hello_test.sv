`include "uvm_macros.svh"
import uvm_pkg::*;

class hello_test extends uvm_test;
    `uvm_component_utils(hello_test)

    function new(string name = "hello_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("HELLO", "Hola desde UVM, XSim funciona!", UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
