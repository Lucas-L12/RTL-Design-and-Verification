`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.11.2026 12:42:12
// Design Name: 
// Module Name: bus_decoder
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


module bus_decoder(
    input logic mem_valid,ram_ready,per_ready,acc_ready,
    input logic  [31:0] mem_addr,ram_rdata,per_rdata,acc_rdata,
    output logic [31:0] mem_rdata,
    output logic  ram_valid, per_valid, mem_ready, bus_error,acc_valid
    );
    
    logic [3:0] adress;
     
    always_comb begin
        adress= mem_addr [31:28];
        ram_valid = 1'b0;
        per_valid = 1'b0;
        bus_error=1'b0;
        acc_valid = 1'b0;
        case (adress)
        4'b0000:
            begin
            ram_valid=mem_valid;
            mem_rdata=ram_rdata;
            mem_ready=ram_ready; 
            end
        4'b0001:
            begin
            per_valid=mem_valid;
            mem_rdata=per_rdata;
            mem_ready=per_ready;     
            
            end    
        4'b0010:
            begin
            acc_valid=mem_valid;
            mem_rdata=acc_rdata;
            mem_ready=acc_ready;     
            
            end            
        default:
            begin
            mem_rdata = 32'hDEADDEAD;
            mem_ready = mem_valid;
            bus_error = mem_valid;
            end        
        endcase
    
    
    end
    
    
endmodule
