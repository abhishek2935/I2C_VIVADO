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
    wire ack_received; 
    
    tri1 sda ; 
    
    reg sda_slave_drive; // slave drives sda for ack 
    assign sda = (sda_slave_drive) ? 1'b0 : 1'bz; // simulates open drain behaviour 

    
    i2c_top uut(
        .clk(clk) ,
        .rst(rst) , 
        .scl(scl),
        .debug_cnt(debug_cnt), 
        .sda(sda) , 
        .debug_sda_oe(debug_sda_oe), 
        .debug_bit_cnt(debug_bit_cnt),
        .ack_received(ack_received) 
        ); 
    
    always #10 clk = ~clk ; // clock of 50 MHz 
   
   // slave ack simulation 
   always @(posedge scl)begin
    if(debug_bit_cnt == 8)
        sda_slave_drive <=1 ;
    else 
        sda_slave_drive <= 0 ; 
   end
       
    initial begin 
    clk = 0 ; 
    rst = 1 ; 
    
    sda_slave_drive = 0 ; 
    
    #100 ; 
    rst = 0 ; 
    
    #40000 ; 
    
    $stop ; 
    end 
    
endmodule
