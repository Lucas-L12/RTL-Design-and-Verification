`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2026 11:13:14
// Design Name: 
// Module Name: controller
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


module controller(
    input logic clk,rst,done_conv,ct_ready,
    input logic signed [31:0] ACCR,
    input  logic signed [7:0] img_pixel,
    output logic ready_conv,done_cont,
    output logic [9:0] img_addr,
    output logic [9:0] out_addr,
    output logic signed [31:0] out_data,
    output logic out_we,
    output logic signed [7:0] ventana_out [0:8]
    );
    
    
    //fsm state type 
  typedef enum logic [2:0]{
    IDLE,
    CLR,
    READ_ADDR,
    READ_DATA,
    SEND_READY,
    WAIT_D,
    DONE_CT
   } state_type;
   
   state_type state_reg, state_next;


   logic [1:0] j_reg, j_next, i_reg, i_next;
   logic [4:0] r_reg, r_next, c_reg, c_next;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            j_reg <= 0; i_reg <= 0; r_reg <= 0; c_reg <= 0;
            state_reg<=IDLE;
        end else begin
            j_reg <= j_next; i_reg <= i_next; r_reg <= r_next; c_reg <= c_next;
            state_reg<=state_next;
        end
    end
       
   always_comb
   
       begin
        state_next=state_reg;
        j_next=j_reg;
        i_next=i_reg;
        c_next=c_reg;
        r_next=r_reg;
        ready_conv=0;
        out_we=0;
        done_cont=0;
        out_addr=0;
        out_data=0;
        case(state_reg)
        
            IDLE:
                begin
                    c_next=0;
                    r_next=0;
                    if(ct_ready)
                        state_next=CLR;
                end         
            CLR:
                begin
                    j_next=0;
                    i_next=0;
                    state_next=READ_ADDR;
                end
            READ_ADDR:
                begin
                    
                    state_next=READ_DATA;
                end
            READ_DATA:
                begin
                   
                    if (j_reg == 2) begin
                        j_next = 0;
                        if (i_reg == 2) begin
                            state_next = SEND_READY;
                        end 
                        else begin
                            i_next=i_reg+1;
                            state_next=READ_ADDR;
                        end
                    end 
                    else begin
                        j_next=j_reg+1;
                        state_next=READ_ADDR;
                    end                            
                end            
            SEND_READY:
                begin
                    ready_conv=1;
                    state_next=WAIT_D;
                end                                        
            WAIT_D:
                begin
                    if(done_conv) begin
                        out_addr = r_reg*26 + c_reg;
                        out_data = ACCR;
                        out_we   = 1;                       
                        
                        if(c_reg==25) begin
                            c_next = 0;
                            if(r_reg==25) begin
                                state_next=DONE_CT;
                            end
                            else begin
                                r_next=r_reg+1;
                                state_next=CLR;
                            end
                        end
                        else begin
                            c_next=c_reg+1;
                            state_next=CLR;
                        end
                                                          
                    end                                       
                end
            DONE_CT:
                begin
                done_cont=1;
                state_next=IDLE;    
                end
        endcase
    
       
       
       end
       always_ff @(posedge clk) begin
            if (state_reg == READ_DATA)
                ventana_out[i_reg*3+j_reg] <= img_pixel;
            end
       
       assign img_addr = (r_reg+i_reg)*28 + (c_reg+j_reg);     
      


endmodule
