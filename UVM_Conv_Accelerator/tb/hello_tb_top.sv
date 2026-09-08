`include "uvm_macros.svh"
import uvm_pkg::*;
`include "hello_test.sv"

module hello_tb_top;
    initial begin
        run_test("hello_test");
    end
endmodule
