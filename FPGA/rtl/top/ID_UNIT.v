`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/15 16:55:51
// Design Name: 
// Module Name: ID_UNIT
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

// 译码单元
module ID_UNIT(

    input   wire                    clk            ,
    input   wire                    rst_n          ,
    
    input   wire                    hold_flag      ,
     
    //从IF模块传来的指令和指令地址
    input   wire[`INST_DATA_BUS]    ins_i          , 
    input   wire[`INST_ADDR_BUS]    ins_addr_i     , 
    
    // 传给RF模块的地址，用于读取数据
    output  wire[`INST_REG_ADDR]    reg1_rd_addr_o , 
    output  wire[`INST_REG_ADDR]    reg2_rd_addr_o ,
    
    // 根据传给RF模块地址读到的数据
    input   wire[`INST_REG_DATA]    reg1_rd_data_i , 
    input   wire[`INST_REG_DATA]    reg2_rd_data_i ,
    
    output  wire[`INST_DATA_BUS]    ins_o          , 
    output  wire[`INST_ADDR_BUS]    ins_addr_o     , 
    
    // 将读到的寄存器数据传给EX模块
    output  wire[`INST_REG_DATA]    reg1_rd_data_o , 
    output  wire[`INST_REG_DATA]    reg2_rd_data_o ,
    
    // 写寄存器地址
    output  wire[`INST_REG_ADDR]    reg_wr_addr_o  ,
    
    // 立即数
    output  wire[`INST_REG_DATA]    imm_o  
    );
    
    wire[`INST_REG_ADDR]    reg_wr_addr;
    wire[`INST_REG_DATA]    imm;
    
    // 指令译码模块例化
    id u_id(
        .clk            (clk),
        .rst_n          (rst_n),
        .ins_i          (ins_i), 
        .ins_addr_i     (ins_addr_i), 
        .reg1_rd_addr_o (reg1_rd_addr_o), 
        .reg2_rd_addr_o (reg2_rd_addr_o),
        .reg_wr_addr_o  (reg_wr_addr),
        .imm_o          (imm) 
    );
    
    // 将传给EX单元的内容打一拍
    id_ex u_id_ex(
        .clk            (clk),
        .rst_n          (rst_n),
        .hold_flag      (hold_flag),
        .ins_i          (ins_i), 
        .ins_addr_i     (ins_addr_i), 
        .reg1_rd_data_i (reg1_rd_data_i), 
        .reg2_rd_data_i (reg2_rd_data_i),
        .reg_wr_addr_i  (reg_wr_addr),
        .imm_i          (imm),
        .ins_o          (ins_o), 
        .ins_addr_o     (ins_addr_o), 
        .reg1_rd_data_o (reg1_rd_data_o), 
        .reg2_rd_data_o (reg2_rd_data_o),
        .reg_wr_addr_o  (reg_wr_addr_o),
        .imm_o          (imm_o)
    );
endmodule
