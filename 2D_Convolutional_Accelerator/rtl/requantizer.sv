`timescale 1ns / 1ps


module requantizer(
    input  logic signed [31:0] accr_in,
    output logic signed [7:0]  q_out
);
    logic signed [31:0] floor_val;
    logic [1:0] remainder;
    logic signed [31:0] rounded;

    always_comb begin
        floor_val = accr_in >>> 2;      // division hacia -infinito
        remainder = accr_in[1:0];       // resto de esa division, 0..3

        if (remainder < 2)
            rounded = floor_val;
        else if (remainder > 2)
            rounded = floor_val + 1;
        else begin // remainder == 2, empate exacto -> redondeo al par mas cercano
            if (floor_val[0] == 1'b0)
                rounded = floor_val;      // ya es par
            else
                rounded = floor_val + 1;  // era impar, sube a par
        end

        if (rounded > 127)
            q_out = 127;
        else if (rounded < -128)
            q_out = -128;
        else
            q_out = rounded[7:0];
    end
endmodule
