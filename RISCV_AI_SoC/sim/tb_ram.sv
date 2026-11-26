`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2026 19:46:20
// Design Name: 
// Module Name: tb_ram
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


`timescale 1ns / 1ps

module tb_ram();

    logic clk = 0;
    logic mem_valid;
    logic [31:0] addr, wdata, rdata;
    logic [3:0]  wstrb;
    logic ready;

    logic [31:0] dato;

    // Direcciones de prueba (lejos de donde cargara el programa)
    localparam logic [31:0] A_CAS  = 32'h0000_3E80; // casilla 4000
    localparam logic [31:0] A_CAS2 = 32'h0000_3E84; // casilla 4001
    localparam logic [31:0] A_ULT  = 32'h0000_3FFC; // casilla 4095 (la ultima)

    ram dut (
        .clk(clk),
        .mem_valid(mem_valid),
        .addr(addr),
        .wdata(wdata),
        .wstrb(wstrb),
        .rdata(rdata),
        .ready(ready)
    );

    always #5 clk = ~clk;

    integer errores = 0;

    task automatic check(input logic [31:0] actual, input logic [31:0] esperado, input string nombre);
        if (actual !== esperado) begin
            $display("FALLO -> %s : esperado = 0x%08h, obtenido = 0x%08h", nombre, esperado, actual);
            errores = errores + 1;
        end else begin
            $display("OK    -> %s : valor = 0x%08h", nombre, actual);
        end
    endtask

    // La escritura se hace efectiva en el flanco de subida
    task automatic escribir(input logic [31:0] a, input logic [31:0] d, input logic [3:0] s);
        @(negedge clk);
        mem_valid = 1; addr = a; wdata = d; wstrb = s;
        @(posedge clk);
        #1;
        mem_valid = 0; wstrb = 4'b0000;
    endtask

    // La lectura es combinacional: basta esperar un instante
    task automatic leer(input logic [31:0] a, output logic [31:0] d);
        @(negedge clk);
        mem_valid = 1; addr = a; wdata = 32'h0; wstrb = 4'b0000;
        #1;
        d = rdata;
    endtask

    initial begin
        mem_valid = 0; addr = 0; wdata = 0; wstrb = 0;
        #1;
        check({31'b0, ready}, 32'd0, "ready = 0 sin valid");

        // 1. Una casilla que nadie escribio vale 0, no X
        leer(A_CAS, dato);
        check(dato, 32'h0000_0000, "casilla sin escribir = 0");
        check({31'b0, ready}, 32'd1, "ready = 1 con valid");

        // 2. Escritura de palabra completa (sw)
        escribir(A_CAS, 32'hAABBCCDD, 4'b1111);
        leer(A_CAS, dato);
        check(dato, 32'hAABBCCDD, "sw: casilla entera");

        // 3. Escrituras de byte y media palabra, con el dato replicado
        //    como lo manda PicoRV32
        escribir(A_CAS, 32'h77777777, 4'b0010);
        leer(A_CAS, dato);
        check(dato, 32'hAABB77DD, "sb en byte 1");

        escribir(A_CAS, 32'h12341234, 4'b1100);
        leer(A_CAS, dato);
        check(dato, 32'h123477DD, "sh mitad alta");

        escribir(A_CAS, 32'h56785678, 4'b0011);
        leer(A_CAS, dato);
        check(dato, 32'h12345678, "sh mitad baja");

        escribir(A_CAS, 32'hEEEEEEEE, 4'b0001);
        leer(A_CAS, dato);
        check(dato, 32'h123456EE, "sb en byte 0");

        escribir(A_CAS, 32'h99999999, 4'b0100);
        leer(A_CAS, dato);
        check(dato, 32'h129956EE, "sb en byte 2");

        escribir(A_CAS, 32'h44444444, 4'b1000);
        leer(A_CAS, dato);
        check(dato, 32'h449956EE, "sb en byte 3");

        // 4. wstrb = 0000 con valid = 1 no escribe
        escribir(A_CAS, 32'hFFFFFFFF, 4'b0000);
        leer(A_CAS, dato);
        check(dato, 32'h449956EE, "wstrb = 0000 no escribe");

        // 5. valid = 0 con wstrb = 1111 no escribe
        @(negedge clk);
        mem_valid = 0; addr = A_CAS; wdata = 32'hFFFFFFFF; wstrb = 4'b1111;
        @(posedge clk);
        #1;
        wstrb = 4'b0000;
        leer(A_CAS, dato);
        check(dato, 32'h449956EE, "valid = 0 no escribe");

        // 6. Los dos bits bajos de addr no cambian la casilla
        leer(A_CAS + 1, dato);
        check(dato, 32'h449956EE, "addr+1 misma casilla");
        leer(A_CAS + 2, dato);
        check(dato, 32'h449956EE, "addr+2 misma casilla");
        leer(A_CAS + 3, dato);
        check(dato, 32'h449956EE, "addr+3 misma casilla");

        // 7. Casillas independientes
        escribir(A_CAS2, 32'h11223344, 4'b1111);
        leer(A_CAS, dato);
        check(dato, 32'h449956EE, "casilla vecina no se altera");
        leer(A_CAS2, dato);
        check(dato, 32'h11223344, "casilla vecina guarda su dato");

        // 8. Ultima casilla (comprueba el rango completo del indice)
        escribir(A_ULT, 32'hDEADBEEF, 4'b1111);
        leer(A_ULT, dato);
        check(dato, 32'hDEADBEEF, "ultima casilla (4095)");

        @(negedge clk);
        mem_valid = 0;

        if (errores == 0)
            $display("\nTODOS LOS TESTS HAN PASADO CORRECTAMENTE");
        else
            $display("\nSE HAN ENCONTRADO %0d ERRORES", errores);

        $finish;
    end

endmodule