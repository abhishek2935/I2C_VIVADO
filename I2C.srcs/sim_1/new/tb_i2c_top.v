`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2026 17:40:48
// Design Name: 
// Module Name: tb_i2c_top
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


module tb_i2c_top(
    );
    reg clk ; 
    reg rst ;  
    
    wire scl ; 
    
    wire [15:0] debug_cnt ; 
    wire debug_sda_oe ; 
    
    wire [3:0] debug_bit_cnt;
    
    tri1 sda ; 
    
    i2c_top uut(
        .clk(clk) ,
        .rst(rst) , 
        .scl(scl),
        .debug_cnt(debug_cnt), 
        .sda(sda) , 
        .debug_sda_oe(debug_sda_oe), 
        .debug_bit_cnt(debug_bit_cnt) 
        ) ; 
    
    always #10 clk = ~clk ; 
    
    initial begin 
    clk = 0 ; 
    rst = 1 ; 
    
    #100 ; 
    rst = 0 ; 
    
    #25000 ; 
    
    $stop ; 
    end 
    
endmodule
