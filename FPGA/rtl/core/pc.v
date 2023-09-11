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
    
    input   wire[2:0]               hold_flag_i ,
    input   wire                    jump_flag_i ,
    input   wire[`INST_REG_DATA]    jump_addr_i ,
    
    output  reg[`INST_ADDR_BUS]     pc_o  
    
    );
    
    always @ (posedge clk or negedge rst_n) begin
        // 复位
        if(!rst_n) begin
            pc_o <= `RESET_ADDR;
        end
        // 跳转
        else if(jump_flag_i == 1'b1) begin
            pc_o <= jump_addr_i;
        end
        // 暂停
        else if(hold_flag_i >= `HOLD_PC) begin
            pc_o <= pc_o;
        end
        // 地址加4
        else begin
            pc_o <= pc_o + 4'd4;
        end
    end
    
endmodule
