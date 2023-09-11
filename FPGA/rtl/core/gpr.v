`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/26 17:24:01
// Design Name: 
// Module Name: gpr
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

// general-purpose registers，通用寄存器模块
module gpr(

    input   wire                    clk            ,
    input   wire                    rst_n          ,
    
    input   wire                    wr_en_i        , // 写使能
    input   wire[`INST_REG_ADDR]    wr_addr_i      , // 写地址
    input   wire[`INST_REG_DATA]    wr_data_i      , // 写数据
    
    input   wire[`INST_REG_ADDR]    reg1_rd_addr_i , // R1寄存器读地址
    input   wire[`INST_REG_ADDR]    reg2_rd_addr_i , // R2寄存器读地址
    
    output  reg [`INST_REG_DATA]    reg1_rd_data_o , // R1寄存器读数据
    output  reg [`INST_REG_DATA]    reg2_rd_data_o   // R2寄存器读数据
    
    );
    
    // 32个通用寄存器定义
    reg[`INST_REG_DATA]     regs[0 : `REG_NUM - 1];
    
    // R1读
    always @ (*) begin
        if(reg1_rd_addr_i == `ZERO_REG_ADDR) begin
            reg1_rd_data_o = `ZERO_WORD;
        end
        // 写地址和读地址相同，直接返回要写的数据
        else if(reg1_rd_addr_i == wr_addr_i && wr_en_i == 1'b1) begin
            reg1_rd_data_o = wr_data_i;
        end
        else begin
            reg1_rd_data_o = regs[reg1_rd_addr_i];
        end
    end
    
    // R2读
    always @ (*) begin
        if(reg2_rd_addr_i == `ZERO_REG_ADDR) begin
            reg2_rd_data_o = `ZERO_WORD;
        end
        // 写地址和读地址相同，直接返回要写的数据
        else if(reg2_rd_addr_i == wr_addr_i && wr_en_i == 1'b1) begin
            reg2_rd_data_o = wr_data_i;
        end
        else begin
            reg2_rd_data_o = regs[reg2_rd_addr_i];
        end
    end
    
    // 写数据
    always @ (posedge clk) begin
        // 写使能有效并且写地址不为0
        if(wr_en_i == 1'b1 && wr_addr_i != `REG_ADDR_WIDTH'd0) begin
            regs[wr_addr_i] <= wr_data_i;
        end
    end
    
endmodule
