`timescale 1ns / 1ps


module receiver
#(
    parameter DBIT=8,            //#data bits
              SB_TICK=16        // #ticks for stop bits
)


(
    input wire clk,reset,
    input wire rx,s_tick,
    output reg rx_done_tick,
    output wire [7:0] dout
 );
   // symbolic state declaration
   localparam   [1:0]
        idle=2'b00,
        start=2'b01,
        data=2'b10,
        stop=2'b11;
   reg [1:0] state_reg,state_next;
   reg [2:0] n_reg,n_next;
   reg [3:0] s_reg, s_next;
   reg [7:0] b_reg,b_next;
  
         
   always @(posedge clk,posedge reset)
    if(reset)
        begin
            state_reg<=idle;
            n_reg<=0;
            s_reg<=0;
            b_reg<=0;
        end
    else
        begin
        state_reg<=state_next;
        n_reg<=n_next;
        s_reg<=s_next;
        b_reg<=b_next;
        end
   
   //FSMD state & data registers
   always @*
    begin
        state_next=state_reg;
        n_next=n_reg;
        s_next=s_reg;
        b_next=b_reg;
        rx_done_tick=1'b0;
        case(state_reg)
            idle:
                begin
                    if(rx==0)
                    begin
                        s_next=0;
                        state_next=start;
                    end    
                end
            start:
                begin
                    if(s_tick)
                        if(s_reg==7)
                            begin 
                                s_next=0;
                                n_next=0;
                                state_next=data;
                            end
                        else s_next=s_reg+1; 
                
                end
        
            data:
                begin
                    if(s_tick)
                        if(s_reg==15)
                            begin
                                s_next=0;
                                b_next={rx,b_reg[7:1]};
                            
                                if(n_reg== DBIT-1)
                                    state_next=stop;
                                else n_next=n_reg+1; 
                            end    
                         else s_next=s_reg+1;
                           
                end
            
            stop:  
                begin
                    if(s_tick)
                        if(s_reg==SB_TICK-1)
                            begin
                                rx_done_tick=1'b1;
                                state_next=idle;
                                s_next=0;

                                
                            end
                        else s_next=s_reg+1;    
            
                end 
        endcase 
                    
    end 
    assign dout=b_reg;
            
  
endmodule

