`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.11.2026 12:31:03
// Design Name: 
// Module Name: tb_mmio_regs
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


`timescale 1ns/1ps

module tb_mmio_regs;

    logic        clk = 0, rstn = 0, mem_valid = 0;
    logic [31:0] addr = 0, wdata = 0;
    logic [3:0]  wstrb = 0;
    logic [31:0] rdata, data_out;
    logic        ready;

    int errors = 0, checks = 0;

    mmio_regs dut (.*);

    always #5 clk = ~clk;

    task automatic check(input string name, input logic [31:0] got, input logic [31:0] exp);
        checks++;
        if (got === exp) $display("OK   %-32s = %h", name, got);
        else begin
            errors++;
            $display("FAIL %-32s got %h expected %h", name, got, exp);
        end
    endtask

    // Escritura: se aplica en el flanco de subida, se suelta despues
    task automatic bus_write(input logic [31:0] a, input logic [31:0] d, input logic [3:0] s);
        @(negedge clk);
        addr = a; wdata = d; wstrb = s; mem_valid = 1;
        @(posedge clk); #1;
        mem_valid = 0; wstrb = 0;
    endtask

    // Lectura: rdata es combinacional, se mira con mem_valid=1 y wstrb=0
    task automatic bus_read(input logic [31:0] a, output logic [31:0] d);
        @(negedge clk);
        addr = a; wstrb = 0; mem_valid = 1;
        #1 d = rdata;
        @(posedge clk); #1;
        mem_valid = 0;
    endtask

    logic [31:0] r;

    initial begin
        // Reset inicial
        #12 rstn = 1;

        // 1. Valores tras reset
        bus_read(32'h1000_0000, r); check("DATA tras reset", r, 32'h0);
        bus_read(32'h1000_0004, r); check("ID", r, 32'hC0FFEE01);
        check("data_out tras reset", data_out, 32'h0);

        // 2. Escritura de palabra completa
        bus_write(32'h1000_0000, 32'hDEADBEEF, 4'b1111);
        bus_read (32'h1000_0000, r); check("DATA = DEADBEEF", r, 32'hDEADBEEF);
        check("data_out = DATA", data_out, 32'hDEADBEEF);

        // 3. Escritura de un solo byte (sb)
        bus_write(32'h1000_0000, 32'h1122_3344, 4'b0001);
        bus_read (32'h1000_0000, r); check("wstrb 0001", r, 32'hDEADBE44);

        // 4. Escritura de media palabra alta (sh)
        bus_write(32'h1000_0000, 32'hAABB_CCDD, 4'b1100);
        bus_read (32'h1000_0000, r); check("wstrb 1100", r, 32'hAABBBE44);

        // 5. Escribir en ID no lo cambia
        bus_write(32'h1000_0004, 32'hFFFF_FFFF, 4'b1111);
        bus_read (32'h1000_0004, r); check("ID tras escribir", r, 32'hC0FFEE01);
        bus_read (32'h1000_0000, r); check("DATA intacto", r, 32'hAABBBE44);

        // 6. Direcciones sin registro: leen 0 y no escriben
        bus_write(32'h1000_0008, 32'h1234_5678, 4'b1111);
        bus_write(32'h1000_000C, 32'h1234_5678, 4'b1111);
        bus_read (32'h1000_0008, r); check("offset 0x08", r, 32'h0);
        bus_read (32'h1000_000C, r); check("offset 0x0C", r, 32'h0);
        bus_read (32'h1000_0000, r); check("DATA intacto (0x08/0C)", r, 32'hAABBBE44);

        // 7. Con mem_valid = 0 no se escribe
        @(negedge clk);
        addr = 32'h1000_0000; wdata = 32'h0; wstrb = 4'b1111; mem_valid = 0;
        @(posedge clk); #1; wstrb = 0;
        bus_read(32'h1000_0000, r); check("sin mem_valid no escribe", r, 32'hAABBBE44);

        // 8. ready sigue a mem_valid
        @(negedge clk); mem_valid = 1; #1 check("ready con mem_valid=1", ready, 1'b1);
        mem_valid = 0;               #1 check("ready con mem_valid=0", ready, 1'b0);

        // 9. Reset asincrono borra DATA
        #3 rstn = 0; #1;
        check("data_out durante reset", data_out, 32'h0);

        // 10. Durante reset no se escribe (prioridad del reset)
        @(negedge clk);
        addr = 32'h1000_0000; wdata = 32'hFFFF_FFFF; wstrb = 4'b1111; mem_valid = 1;
        @(posedge clk); #1; mem_valid = 0; wstrb = 0;
        check("escritura en reset ignorada", data_out, 32'h0);
        @(negedge clk); rstn = 1;
        bus_read(32'h1000_0000, r); check("DATA tras salir de reset", r, 32'h0);

        $display("----------------------------------");
        if (errors == 0) $display("PASS: %0d/%0d checks", checks, checks);
        else             $display("FAIL: %0d errores de %0d checks", errors, checks);
        $finish;
    end

endmodule