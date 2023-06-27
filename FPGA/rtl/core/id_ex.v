`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/15 14:15:46
// Design Name: 
// Module Name: id_ex
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

// 将译码结果打一拍后向EX模块传递
module id_ex(

    input   wire                     clk            ,
    input   wire                     rst_n          ,
    
    input   wire                     hold_flag      ,
    
    input   wire[`INST_DATA_BUS]     ins_i          , 
    input   wire[`INST_ADDR_BUS]     ins_addr_i     , 
    input   wire[`INST_REG_DATA]     reg1_rd_data_i , 
    input   wire[`INST_REG_DATA]     reg2_rd_data_i ,
    input   wire[`INST_REG_ADDR]     reg_wr_addr_i  ,
    input   wire[`INST_REG_DATA]     imm_i          ,  
    
    output  reg[`INST_DATA_BUS]      ins_o          , 
    output  reg[`INST_ADDR_BUS]      ins_addr_o     , 
    output  reg[`INST_REG_DATA]      reg1_rd_data_o , 
    output  reg[`INST_REG_DATA]      reg2_rd_data_o ,    
    output  reg[`INST_REG_ADDR]      reg_wr_addr_o  ,
    output  reg[`INST_REG_DATA]      imm_o  
    
    );
    
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ins_o <= `INS_NOP;
            ins_addr_o <= `RESET_ADDR;
            reg1_rd_data_o <= `ZERO_WORD;
            reg2_rd_data_o <= `ZERO_WORD;   
            reg_wr_addr_o <= `ZERO_WORD;   
            imm_o <= `ZERO_WORD;   
        end
        else if(hold_flag) begin
            ins_o <= `INS_NOP;
            ins_addr_o <= `RESET_ADDR;
            reg1_rd_data_o <= `ZERO_WORD;
            reg2_rd_data_o <= `ZERO_WORD;   
            reg_wr_addr_o <= `ZERO_WORD;   
            imm_o <= `ZERO_WORD;   
        end
        else begin
            ins_o <= ins_i;
            ins_addr_o <= ins_addr_i;
            reg1_rd_data_o <= reg1_rd_data_i;
            reg2_rd_data_o <= reg2_rd_data_i;
            reg_wr_addr_o <= reg_wr_addr_i;
            imm_o <= imm_i;
        end
    end
    
endmodule
