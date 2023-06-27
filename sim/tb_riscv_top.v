`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/16 21:23:51
// Design Name: 
// Module Name: tb_riscv_top
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


module tb_riscv_top(); 

    reg     clk;
    reg     rst_n;
    
    always # (10) clk <= ~clk;
    
    initial begin
        clk = 1'b1;
        rst_n <= 1'b0;
        #17
        rst_n <= 1'b1;
        #1000
        $stop;
    end

    RISCV_TOP u_RISCV_TOP(
        .clk                 (clk),
        .rst_n               (rst_n),
        .rom_addr            ()
    );

endmodule
// do {tb_riscv_top_simulate.do}