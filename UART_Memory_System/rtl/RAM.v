`timescale 1ns / 1ps

module RAM
    #(
    parameter  ADDR_WIDTH = 8,//number of adress bits
               DATA_WIDTH = 8// number of bits
    )
    (
    input logic clk,mem_write_en,
    input logic [ADDR_WIDTH-1:0] mem_addr,
    input logic [DATA_WIDTH-1:0]mem_data_in,
    output logic [DATA_WIDTH-1:0] mem_data_out
    );
    
    // signal declaration
    logic [DATA_WIDTH-1:0] ram [0: 2** ADDR_WIDTH-1];// 256 positions of 8 bits each
    
    always_ff @(posedge clk)
        begin
            if(mem_write_en)
                ram[mem_addr]<=mem_data_in;
        end
    
    assign mem_data_out=ram[mem_addr];

endmodule
