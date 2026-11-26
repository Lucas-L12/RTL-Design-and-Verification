`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2026 20:42:55
// Design Name: 
// Module Name: tb_top
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

module tb_top;

    logic        clk = 0, resetn = 0;
    logic        trap, bus_error;
    logic [31:0] data_out;

    localparam logic [31:0] PASS_CODE = 32'h0000600D;
    localparam int          TIMEOUT   = 500000;   // ciclos

    top dut (.*);

    always #5 clk = ~clk;

    // trap y bus_error no deben activarse nunca una vez fuera del reset
    logic trap_seen = 0, buserr_seen = 0;
    always @(posedge clk) if (resetn) begin
        if (trap      === 1'b1) trap_seen   <= 1'b1;
        if (bus_error === 1'b1) buserr_seen <= 1'b1;
    end

    int cycles = 0;
    int errors = 0;
        // 1. Contenido inicial de la RAM
    initial begin
        #1 $display("RAM[0]=%h RAM[1]=%h RAM[2]=%h",
                    dut.u_ram.memory[0], dut.u_ram.memory[1], dut.u_ram.memory[2]);
    end

    
    initial begin
        repeat (10) @(posedge clk);
        resetn = 1;

        // Esperar a un codigo final: exito, o fallo (0xBAD0 + errores)
        while (data_out !== PASS_CODE &&
               data_out[31:4] !== 28'h0000BAD &&
               cycles < TIMEOUT) begin
            @(posedge clk);
            cycles++;
        end
        repeat (5) @(posedge clk);   // margen para ver trap/bus_error tardios

        if (data_out === PASS_CODE) $display("OK   programa termino con exito (%0d ciclos)", cycles);
        else if (cycles >= TIMEOUT) begin errors++; $display("FAIL timeout, data_out = %h", data_out); end
        else begin errors++; $display("FAIL el programa reporta fallo, data_out = %h", data_out); end

        if (trap_seen)   begin errors++; $display("FAIL trap se activo");      end
        else                              $display("OK   trap nunca se activo");
        if (buserr_seen) begin errors++; $display("FAIL bus_error se activo"); end
        else                              $display("OK   bus_error nunca se activo");
        if (dut.u_accel.Error_reg) begin errors++; $display("FAIL el acelerador marco ERROR"); end
        else                                $display("OK   el acelerador no marco ERROR");
        $display("----------------------------------");
        if (errors == 0) $display("PASS");
        else             $display("FAIL: %0d errores", errors);
        $finish;
    end

endmodule