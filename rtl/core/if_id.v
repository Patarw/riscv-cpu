`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/14 20:49:15
// Design Name: 
// Module Name: ir_reg
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

// 将指令打一拍输出到译码模块
module if_id(

    input   wire                    clk         ,
    input   wire                    rst_n       ,
    
    input   wire                    hold_flag   ,
    
    input   wire[`INST_DATA_BUS]    ins_i       , 
    input   wire[`INST_ADDR_BUS]    ins_addr_i  ,
    
    output  reg[`INST_DATA_BUS]     ins_o       , 
    output  reg[`INST_ADDR_BUS]     ins_addr_o   
    
    );
    
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ins_o <= `INS_NOP;
            ins_addr_o <= `RESET_ADDR;
        end
        else if(hold_flag == 1'b1) begin
            ins_o <= `INS_NOP;
            ins_addr_o <= `RESET_ADDR;
        end
        else begin
            ins_o <= ins_i;
            ins_addr_o <= ins_addr_i;
        end
    end
    
endmodule
