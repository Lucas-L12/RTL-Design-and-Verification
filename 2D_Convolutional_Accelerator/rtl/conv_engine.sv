`timescale 1ns / 1ps



module conv_engine(
    input logic clk,rst,ready,
    input logic signed [7:0] ventana [8:0], kernel[8:0],
    output logic signed [31:0] ACCR,
    output logic done

    );

    logic enable, clr;
    logic signed [31:0] acc1,acc2,acc3,acc4,acc5,acc6,acc7,acc8,acc9;
    Mac_Unit mac1 (
        .clk    (clk),
        .rst    (rst),
        .clr    (clr),
        .enable (enable),
        .a      (ventana[0]),
        .b      (kernel[0]),
        .acc    (acc1)
    );

    Mac_Unit mac2 (
        .clk    (clk),
        .rst    (rst),
        .clr    (clr),
        .enable (enable),
        .a      (ventana[1]),
        .b      (kernel[1]),
        .acc    (acc2)
    );   


    Mac_Unit mac3 (
        .clk    (clk),
        .rst    (rst),
        .clr    (clr),
        .enable (enable),
        .a      (ventana[2]),
        .b      (kernel[2]),
        .acc    (acc3)
    );
 
     Mac_Unit mac4 (
        .clk    (clk),
        .rst    (rst),
        .clr    (clr),
        .enable (enable),
        .a      (ventana[3]),
        .b      (kernel[3]),
        .acc    (acc4)
    );
    Mac_Unit mac5 (
        .clk    (clk),
        .rst    (rst),
        .clr    (clr),
        .enable (enable),
        .a      (ventana[4]),
        .b      (kernel[4]),
        .acc    (acc5)
    );

    Mac_Unit mac6 (
        .clk    (clk),
        .rst    (rst),
        .clr    (clr),
        .enable (enable),
        .a      (ventana[5]),
        .b      (kernel[5]),
        .acc    (acc6)
    );
    Mac_Unit mac7 (
        .clk    (clk),
        .rst    (rst),
        .clr    (clr),
        .enable (enable),
        .a      (ventana[6]),
        .b      (kernel[6]),
        .acc    (acc7)
    );

    Mac_Unit mac8 (
        .clk    (clk),
        .rst    (rst),
        .clr    (clr),
        .enable (enable),
        .a      (ventana[7]),
        .b      (kernel[7]),
        .acc    (acc8)
    );

    Mac_Unit mac9 (
        .clk    (clk),
        .rst    (rst),
        .clr    (clr),
        .enable (enable),
        .a      (ventana[8]),
        .b      (kernel[8]),
        .acc    (acc9)
    );
 
 
   //fsm state type 
   typedef enum logic [1:0]{
    IDLE,
    CLEAR,
    COMPUTE,
    DONE  
   } state_type; 
   
   
    //signal declaration
    state_type state_reg, state_next;
    
    always_ff @(posedge clk or posedge rst) 
    begin
        if(rst)
        state_reg<=IDLE;
        else
        state_reg<=state_next;
    
    end
 
    always_comb
        begin
        state_next=state_reg;
        clr=0;
        enable=0;
        done=0;
        
        
        case(state_reg)
        
            IDLE:
            begin
                if(ready)

                    state_next=CLEAR;
                
            end
            
            CLEAR:
            begin
               clr=1;
               state_next=COMPUTE;
            end
            
            COMPUTE:
            begin
            enable=1;
            
        
         
            state_next=DONE;
            
            end

            
            DONE:
            begin
            done=1;
            state_next=IDLE;
            end
        endcase
    end
 
 
    assign ACCR=acc1+acc2+acc3+acc4+acc5+acc6+acc7+acc8+acc9;
 
 
 
    endmodule
