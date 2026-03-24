`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2026 17:19:49
// Design Name: 
// Module Name: i2c_top
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


module i2c_top(
    //ports 
    input clk,
    input rst ,
    output scl,
    inout sda ,
    
    output [15:0] debug_cnt,
    output debug_sda_oe,
    
    output [3:0] debug_bit_cnt,
    
    output ack_received
    );
    
// ==========================
// PARAMETERS
// ==========================
parameter CLK_FREQ = 50000000;
parameter I2C_FREQ = 400000;

localparam DIVIDER = CLK_FREQ / (2 * I2C_FREQ);

// ==========================
// SIGNAL DECLARATIONS
// ==========================

reg [15:0] clk_cnt = 0;
reg scl_reg = 1;
reg scl_prev = 1;

// sda control 
reg sda_oe ; 
//reg [31:0] test_cnt ; // test counter for sda behaviour 

// bit engine 
reg [7:0] data_byte = 8'b01010101; // test pattern
reg [7:0] shift_reg;
reg [3:0] bit_cnt;
reg sending;

reg ack_reg ;

// ==========================
// CLOCK GENERATION (SCL)
// ==========================

/*
initial begin 
        $display("DIVIDER = %d" ,DIVIDER) ; // temp for debugging , to check if SCL switches after reaching the DIVIDER
    end 
*/

always @(posedge clk or posedge rst) begin
    if (rst) begin
        clk_cnt <= 0;
        scl_reg <= 1;
    end else begin
        if (clk_cnt == DIVIDER-1) begin
            clk_cnt <= 0;
            scl_reg <= ~scl_reg;
        end else begin
            clk_cnt <= clk_cnt + 1;
        end
    end
end

always @(posedge clk) begin
    scl_prev <= scl_reg;
end

wire scl_rising  = (scl_reg == 1 && scl_prev == 0);
wire scl_falling = (scl_reg == 0 && scl_prev == 1);

assign scl = scl_reg;

// ==========================
// SDA/SCL CONTROL (OPEN DRAIN)
// ==========================
assign sda = (sda_oe) ? 1'b0 : 1'bz;


// ==========================
// START/STOP LOGIC
// ==========================

// bit engine initialization 
always @(posedge clk or posedge rst) begin
    if (rst) begin
        sending <= 0;
        shift_reg <= 0;
        bit_cnt <= 0;
        ack_reg <= 0 ; 
    end else begin
        if (!sending) begin
            sending <= 1;
            shift_reg <= data_byte;
            bit_cnt <= 0;
        end
    end
end

// transmission (8databits + 1ack bit)
always @(posedge clk or posedge rst) begin
    if (rst) begin
        sda_oe <= 0;
    end else if (sending) begin
        if (scl_falling) begin
            if (bit_cnt < 8) begin
                // Send MSB first
                if (shift_reg[7] == 1)
                    sda_oe <= 0;  // release → HIGH
                else
                    sda_oe <= 1;  // drive LOW

                shift_reg <= shift_reg << 1;
                bit_cnt <= bit_cnt + 1;
            end else if (bit_cnt == 8)  begin  
                sda_oe <= 0; // release after byte
                bit_cnt <= bit_cnt+1 ; 
            end
        end
    end
end

// ack detection 

always @(posedge clk or posedge rst) begin 
    if(rst)begin
        ack_reg <= 0 ; 
    end 
    else if(sending && scl_rising && bit_cnt == 8)begin
        if(sda == 0) 
            ack_reg <= 1;
        else 
            ack_reg <=0 ; 
    end
end

// ==========================
// BYTE ENGINE
// ==========================

// ==========================
// FSM (MASTER)
// ==========================

// ==========================
// DEBUG LINES
// ==========================
assign debug_cnt = clk_cnt;   // debugg line for scl
assign debug_sda_oe = sda_oe ; 
assign debug_bit_cnt = bit_cnt; 
assign ack_received = ack_reg ; 
// ==========================
// OUTPUT LOGIC
// ==========================
    
endmodule