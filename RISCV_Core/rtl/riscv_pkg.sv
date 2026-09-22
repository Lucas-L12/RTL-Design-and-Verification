`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2026 19:30:08
// Design Name: 
// Module Name: riscv_pkg
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


package riscv_pkg;

    typedef enum logic [3:0] {
        ADD,
        SUB,
        L_AND,
        L_OR,
        L_XOR,
        SLL,
        SRL,
        SRA,
        SLT,
        SLTU
    } operation_type;
    
    
    
    typedef enum logic [2:0] {
            I,
            S,
            B,
            U,
            J
    } format_type;

endpackage