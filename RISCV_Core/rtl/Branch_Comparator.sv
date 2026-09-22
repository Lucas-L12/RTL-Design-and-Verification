`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.09.2026 13:55:13
// Design Name: 
// Module Name: Branch_Comparator
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


module Branch_Comparator(
    input logic [31:0] rs1_data,rs2_data,
    input logic [31:0] instr,
    output logic comp_result
    );
    
    logic [2:0] funct3;
    
    always_comb begin
        comp_result=0;
        funct3 = instr[14:12]; 
        case(funct3)
        
            3'b000:     //beq
                begin
                    if(rs1_data == rs2_data) begin
                        comp_result=1;
                    end   
                end
                
            3'b001:      //bne
                begin
                    if(rs1_data != rs2_data) begin
                        comp_result=1;
                    end                   
                end   
                             
             3'b100:     //blt
                begin
                    if($signed(rs1_data) < $signed(rs2_data)) begin
                        comp_result=1;
                    end                
                end   
             3'b101:     //bge
                begin
                    if($signed(rs1_data) >= $signed(rs2_data)) begin
                        comp_result=1;
                end               
                end               
                            
            3'b110:      //bltu
                begin
                    if(rs1_data <  rs2_data) begin
                        comp_result=1;
                end                
                end            
            
            3'b111:      //bgeu
                begin
                    if(rs1_data >= rs2_data) begin
                        comp_result=1;
                    end                
                end                
               
            default: begin end
                      
        endcase
            
    
    end
    
    
    
    
endmodule
