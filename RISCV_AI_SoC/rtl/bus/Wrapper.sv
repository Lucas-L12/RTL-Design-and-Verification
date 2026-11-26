`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2026 20:55:10
// Design Name: 
// Module Name: Wrapper
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

module Wrapper(
    input  logic clk, resetn, acc_valid,
    input  logic [31:0] addr, wdata,
    input  logic [3:0]  wstrb,
    output logic [31:0] acc_rdata,
    output logic        acc_ready
    );

    logic Busy_reg, Busy_next, Done_reg, Done_next, Error_reg, Error_next;
    logic arranque_aceptado, we, acceso_ilegal, ct_ready, done_cont;
    logic espera, lectura_salida;
    logic [7:0]  idx;
    logic [31:0] rdata_mem;

    assign idx            = addr[9:2];
    assign lectura_salida = acc_valid && (addr[11:10] == 2'b10) && (wstrb == 0);
    assign acc_ready      = acc_valid && (!lectura_salida || espera);

    conv_accel u_acc (
        .clk       (clk),
        .rst       (~resetn),
        .ct_ready  (ct_ready),
        .we        (we),
        .widx      (idx),
        .wdata     (wdata),
        .wstrb     (wstrb),
        .ridx      (idx),
        .done_cont (done_cont),
        .rdata     (rdata_mem)
    );

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            Busy_reg  <= 0;
            Done_reg  <= 0;
            Error_reg <= 0;
            ct_ready  <= 0;
            espera    <= 0;
        end
        else begin
            Busy_reg  <= Busy_next;
            Done_reg  <= Done_next;
            Error_reg <= Error_next;
            ct_ready  <= arranque_aceptado;
            espera    <= lectura_salida && !espera;
        end
    end

    always_comb begin
        Busy_next         = Busy_reg;
        Done_next         = Done_reg;
        arranque_aceptado = 0;
        we                = 0;
        acceso_ilegal     = 0;
        acc_rdata         = 0;

        if (acc_valid) begin
            case (addr[11:10])

                2'b00:
                    begin
                        if (addr[3:2] == 2'b00) begin
                            if (wstrb != 0) begin
                                if (Busy_reg == 0)
                                    arranque_aceptado = 1;
                                else
                                    acceso_ilegal = 1;
                            end
                        end
                        else if (addr[3:2] == 2'b01) begin
                            if (wstrb == 0)
                                acc_rdata = {29'b0, Error_reg, Busy_reg, Done_reg};
                        end
                    end

                2'b01:
                    begin
                        if (wstrb != 0) begin
                            if (Busy_reg == 0)
                                we = 1;
                            else
                                acceso_ilegal = 1;
                        end
                    end

                2'b10:
                    begin
                        if (idx < 169)
                            acc_rdata = rdata_mem;
                        if (wstrb == 0 && Busy_reg == 1)
                            acceso_ilegal = 1;
                    end

                default:
                    begin
                    end
            endcase
        end

        if (arranque_aceptado) begin
            Busy_next = 1;
            Done_next = 0;
        end
        else if (done_cont) begin
            Busy_next = 0;
            Done_next = 1;
        end
    end

    // START limpia ERROR; un acceso ilegal lo activa; si no, se mantiene
    assign Error_next = arranque_aceptado ? 1'b0 : (Error_reg | acceso_ilegal);

endmodule