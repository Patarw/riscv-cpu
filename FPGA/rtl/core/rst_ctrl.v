`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/9 14:29:50
// Design Name: 
// Module Name: rst_ctrl
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

`include "defines.v"

// 复位信号同步模块（异步复位，同步释放）
module rst_ctrl(

    input    wire                    clk       ,
    input    wire                    sys_rst_n ,
    
    output   reg                     rst_n            

    );
    
    reg rst_reg;
    
    always @ (posedge clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            {rst_n, rst_reg} <= 2'b0;
        end
        else begin
            {rst_n, rst_reg} <= {rst_reg, 1'b1};
        end
    end
    
endmodule 