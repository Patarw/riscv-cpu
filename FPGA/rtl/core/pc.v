`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/14 10:39:16
// Design Name: 
// Module Name: pc_reg
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

// PC寄存器模块
module pc(

    input   wire                    clk         ,
    input   wire                    rst_n       ,
    
    input   wire                    jump_flag   ,
    input   wire[`INST_REG_DATA]    jump_addr   ,
    
    output  reg[`INST_ADDR_BUS]     pc_out  
    
    );
    
    always @ (posedge clk or negedge rst_n) begin
        // 复位
        if(!rst_n) begin
            pc_out <= `RESET_ADDR;
        end
        // 跳转
        else if(jump_flag == 1'b1) begin
            pc_out <= jump_addr;
        end
        // 地址加4
        else begin
            pc_out <= pc_out + 4'd4;
        end
    end
    
endmodule
