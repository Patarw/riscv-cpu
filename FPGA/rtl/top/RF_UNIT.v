`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/14 22:29:15
// Design Name: 
// Module Name: regs
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

`include "../core/defines.v"

// 通用寄存器模块，双端口，可同时读取两个寄存器数据
module RF_UNIT(

    input   wire                    clk          ,
    input   wire                    rst_n        ,
    
    input   wire                    wr_en        , // 写使能
    input   wire[`INST_REG_ADDR]    wr_addr      , // 写地址
    input   wire[`INST_REG_DATA]    wr_data      , // 写数据
    
    input   wire[`INST_REG_ADDR]    reg1_rd_addr , // R1寄存器读地址
    input   wire[`INST_REG_ADDR]    reg2_rd_addr , // R2寄存器读地址
    
    output  reg[`INST_REG_DATA]     reg1_rd_data , // R1寄存器读数据
    output  reg[`INST_REG_DATA]     reg2_rd_data   // R2寄存器读数据
    
    );
    
    // 32个通用寄存器定义
    reg[`INST_REG_DATA]     regs[0 : `REG_NUM - 1];
    
    // R1读
    always @ (*) begin
        if(reg1_rd_addr == `ZERO_REG_ADDR) begin
            reg1_rd_data = `ZERO_WORD;
        end
        // 写地址和读地址相同，直接返回要写的数据
        else if(reg1_rd_addr == wr_addr && wr_en == 1'b1) begin
            reg1_rd_data = wr_data;
        end
        else begin
            reg1_rd_data = regs[reg1_rd_addr];
        end
    end
    
    // R2读
    always @ (*) begin
        if(reg2_rd_addr == `ZERO_REG_ADDR) begin
            reg2_rd_data = `ZERO_WORD;
        end
        // 写地址和读地址相同，直接返回要写的数据
        else if(reg2_rd_addr == wr_addr && wr_en == 1'b1) begin
            reg2_rd_data = wr_data;
        end
        else begin
            reg2_rd_data = regs[reg2_rd_addr];
        end
    end
    
    // 写数据
    always @ (posedge clk) begin
        // 写使能有效并且写地址不为0
        if(wr_en == 1'b1 && wr_addr != `REG_ADDR_WIDTH'd0) begin
            regs[wr_addr] <= wr_data;
        end
    end
    
endmodule
