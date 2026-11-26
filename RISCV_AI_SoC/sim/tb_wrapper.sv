`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2026 21:18:30
// Design Name: 
// Module Name: tb_wrapper
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

module tb_wrapper;

    localparam logic [31:0] START_A  = 32'h2000_0000;
    localparam logic [31:0] STATUS_A = 32'h2000_0004;
    localparam logic [31:0] IN_BASE  = 32'h2000_0400;
    localparam logic [31:0] OUT_BASE = 32'h2000_0800;

    logic        clk = 0, resetn = 0, acc_valid = 0;
    logic [31:0] addr = 0, wdata = 0;
    logic [3:0]  wstrb = 0;
    logic [31:0] acc_rdata;
    logic        acc_ready;

    logic [7:0]  img_mem [0:783];
    logic [7:0]  exp_mem [0:675];

    logic [31:0] v;
    int cyc, timeout, bad;
    int errors = 0, checks = 0;

    Wrapper dut (.*);
    always #5 clk = ~clk;

    task automatic check(input string name, input logic [31:0] got, input logic [31:0] exp);
        checks++;
        if (got === exp) $display("OK   %-44s = %h", name, got);
        else begin
            errors++;
            $display("FAIL %-44s got %h expected %h", name, got, exp);
        end
    endtask

    // Un acceso al bus: se mantiene valid hasta que llega ready
    task automatic bus(input logic [31:0] a, input logic [31:0] d, input logic [3:0] s);
        @(negedge clk);
        addr = a; wdata = d; wstrb = s; acc_valid = 1;
        cyc = 0;
        do begin
            @(posedge clk);
            cyc++;
        end while (!acc_ready && cyc < 50);
        v = acc_rdata;
        #1;
        acc_valid = 0; wstrb = 0;
    endtask

    task automatic wr(input logic [31:0] a, input logic [31:0] d, input logic [3:0] s);
        bus(a, d, s);
    endtask

    task automatic rd(input logic [31:0] a);
        bus(a, 32'b0, 4'b0000);
    endtask

    function automatic logic [31:0] img_word(input int w);
        return {img_mem[4*w+3], img_mem[4*w+2], img_mem[4*w+1], img_mem[4*w]};
    endfunction

    function automatic logic [31:0] exp_word(input int w);
        return {exp_mem[4*w+3], exp_mem[4*w+2], exp_mem[4*w+1], exp_mem[4*w]};
    endfunction

    task automatic esperar_done();
        timeout = 0;
        do begin
            rd(STATUS_A);
            timeout++;
        end while (!v[0] && timeout < 200000);
    endtask

    task automatic comparar_salida();
        bad = 0;
        for (int w = 0; w < 169; w++) begin
            rd(OUT_BASE + 4*w);
            if (w == 0) check("lectura de la salida tarda 2 ciclos", cyc, 2);
            if (v !== exp_word(w)) bad++;
        end
        check("casillas de salida distintas del esperado", bad, 0);
    endtask

    initial begin
        $readmemh("image.mem", img_mem);
        $readmemh("expected_output.mem", exp_mem);

        repeat (4) @(posedge clk);
        resetn = 1;
        repeat (2) @(posedge clk);

        // 1. Estado inicial y regiones sin lectura util
        rd(STATUS_A);          check("STATUS tras reset", v, 32'h0);
        check("leer STATUS tarda 1 ciclo", cyc, 1);
        rd(START_A);           check("leer START devuelve 0", v, 32'h0);
        rd(IN_BASE);           check("leer la entrada devuelve 0", v, 32'h0);
        rd(32'h2000_0C00);     check("region sin uso devuelve 0", v, 32'h0);

        // 2. Cargar la imagen: casilla 0 por bytes (sb), resto por palabras (sw)
        for (int k = 0; k < 4; k++)
            wr(IN_BASE, {4{img_mem[k]}}, 4'b0001 << k);
        for (int w = 1; w < 196; w++)
            wr(IN_BASE + 4*w, img_word(w), 4'b1111);
        check("escribir la entrada tarda 1 ciclo", cyc, 1);

        // 3. Arrancar
        wr(START_A, 32'h1, 4'b1111);
        check("escribir START tarda 1 ciclo", cyc, 1);
        rd(STATUS_A);          check("STATUS tras START: BUSY", v, 32'h2);

        // 4. Accesos ilegales mientras BUSY: se ignoran las escrituras y se marca ERROR
        wr(IN_BASE, 32'hFFFF_FFFF, 4'b1111);
        wr(START_A, 32'h1, 4'b1111);
        rd(OUT_BASE);
        rd(STATUS_A);          check("STATUS tras accesos ilegales: BUSY+ERROR", v, 32'h6);

        // 5. Esperar el fin
        esperar_done();
        check("el acelerador termina antes del timeout", timeout < 200000, 1);
        check("STATUS final: DONE+ERROR", v, 32'h5);

        // 6. Leer la salida y compararla con el resultado esperado
        comparar_salida();

        // 7. Indices fuera de la zona de salida
        rd(OUT_BASE + 169*4);  check("salida fuera de rango (casilla 169)", v, 32'h0);
        rd(OUT_BASE + 255*4);  check("salida fuera de rango (casilla 255)", v, 32'h0);

        // 8. Escrituras a STATUS y a la salida: ignoradas y sin error nuevo
        wr(STATUS_A, 32'hFFFF_FFFF, 4'b1111);
        wr(OUT_BASE, 32'hFFFF_FFFF, 4'b1111);
        rd(STATUS_A);          check("STATUS no cambia por escrituras ajenas", v, 32'h5);
        rd(OUT_BASE);          check("la salida no cambia por escribirla", v, exp_word(0));

        // 9. Segundo arranque limpio: START borra DONE y ERROR
        wr(START_A, 32'h1, 4'b1111);
        rd(STATUS_A);          check("STATUS tras 2o START: solo BUSY", v, 32'h2);
        esperar_done();
        check("2a ejecucion termina antes del timeout", timeout < 200000, 1);
        check("STATUS final limpio: solo DONE", v, 32'h1);
        comparar_salida();

        $display("----------------------------------");
        if (errors == 0) $display("PASS: %0d/%0d checks", checks, checks);
        else             $display("FAIL: %0d errores de %0d checks", errors, checks);
        $finish;
    end

endmodule