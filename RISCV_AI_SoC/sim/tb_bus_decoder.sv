`timescale 1ns / 1ps

module tb_bus_decoder;

    logic        mem_valid = 0, ram_ready = 0, per_ready = 0, acc_ready = 0;
    logic [31:0] mem_addr = 0;
    logic [31:0] ram_rdata = 32'hAAAA_AAAA, per_rdata = 32'hBBBB_BBBB, acc_rdata = 32'hCCCC_CCCC;
    logic [31:0] mem_rdata;
    logic        ram_valid, per_valid, acc_valid, mem_ready, bus_error;

    int errors = 0, checks = 0;

    bus_decoder dut (.*);

    // rdy = {ram_ready, per_ready, acc_ready}   exp_v = {ram_valid, per_valid, acc_valid}
    task automatic test(
        input string       name,
        input logic [31:0] a,
        input logic        v,
        input logic [2:0]  rdy,
        input logic [2:0]  e_v,
        input logic [31:0] e_rdata,
        input logic        e_ready, e_err
    );
        mem_addr = a; mem_valid = v;
        {ram_ready, per_ready, acc_ready} = rdy;
        #1;
        checks++;
        if ({ram_valid, per_valid, acc_valid} === e_v && mem_rdata === e_rdata &&
            mem_ready === e_ready && bus_error === e_err)
            $display("OK   %-34s", name);
        else begin
            errors++;
            $display("FAIL %-34s", name);
            $display("     valid {ram,per,acc} %b (exp %b)", {ram_valid, per_valid, acc_valid}, e_v);
            $display("     mem_rdata %h (exp %h)", mem_rdata, e_rdata);
            $display("     mem_ready %b (exp %b) bus_error %b (exp %b)", mem_ready, e_ready, bus_error, e_err);
        end
    endtask

    initial begin
        //                                          addr          v  rdy(r,p,a) valid(r,p,a)  rdata         rdy err
        test("RAM, ready de la RAM = 1",          32'h0000_0010, 1, 3'b100,    3'b100, 32'hAAAA_AAAA, 1, 0);
        test("RAM, ready de la RAM = 0",          32'h0000_0010, 1, 3'b011,    3'b100, 32'hAAAA_AAAA, 0, 0);
        test("RAM, sin mem_valid",                32'h0000_0010, 0, 3'b000,    3'b000, 32'hAAAA_AAAA, 0, 0);
        test("RAM, ultima direccion",             32'h0FFF_FFFC, 1, 3'b100,    3'b100, 32'hAAAA_AAAA, 1, 0);

        test("Periferico, ready = 1",             32'h1000_0004, 1, 3'b010,    3'b010, 32'hBBBB_BBBB, 1, 0);
        test("Periferico, ready = 0",             32'h1000_0004, 1, 3'b101,    3'b010, 32'hBBBB_BBBB, 0, 0);
        test("Periferico, sin mem_valid",         32'h1000_0004, 0, 3'b000,    3'b000, 32'hBBBB_BBBB, 0, 0);
        test("Periferico, ultima direccion",      32'h1FFF_FFFC, 1, 3'b010,    3'b010, 32'hBBBB_BBBB, 1, 0);

        test("Acelerador, ready = 1",             32'h2000_0004, 1, 3'b001,    3'b001, 32'hCCCC_CCCC, 1, 0);
        test("Acelerador, ready = 0",             32'h2000_0004, 1, 3'b110,    3'b001, 32'hCCCC_CCCC, 0, 0);
        test("Acelerador, sin mem_valid",         32'h2000_0004, 0, 3'b000,    3'b000, 32'hCCCC_CCCC, 0, 0);
        test("Acelerador, region de salida",      32'h2000_0800, 1, 3'b001,    3'b001, 32'hCCCC_CCCC, 1, 0);
        test("Acelerador, ultima direccion",      32'h2FFF_FFFC, 1, 3'b001,    3'b001, 32'hCCCC_CCCC, 1, 0);

        test("Sin mapear 0x3",                    32'h3000_0000, 1, 3'b111,    3'b000, 32'hDEADDEAD, 1, 1);
        test("Sin mapear 0x8",                    32'h8000_0000, 1, 3'b111,    3'b000, 32'hDEADDEAD, 1, 1);
        test("Sin mapear 0xF",                    32'hF000_0000, 1, 3'b111,    3'b000, 32'hDEADDEAD, 1, 1);
        test("Sin mapear, sin mem_valid",         32'h8000_0000, 0, 3'b111,    3'b000, 32'hDEADDEAD, 0, 0);

        $display("----------------------------------");
        if (errors == 0) $display("PASS: %0d/%0d checks", checks, checks);
        else             $display("FAIL: %0d errores de %0d checks", errors, checks);
        $finish;
    end

endmodule
