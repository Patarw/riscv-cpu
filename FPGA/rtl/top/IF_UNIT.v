`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/14 11:23:19
// Design Name: 
// Module Name: IF
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

// 取指单元
module IF_UNIT(

    input   wire                     clk          ,
    input   wire                     rst_n        ,
    
    input   wire                     hold_flag    ,
    input   wire                     jump_flag    ,
    input   wire[`INST_REG_DATA]     jump_addr    ,
        
    output  wire[`INST_DATA_BUS]     ins_o        , // 指令
    output  wire[`INST_ADDR_BUS]     ins_addr_o   , // 指令地址
    
    output  wire[`INST_ADDR_BUS]     pc_o         , // 传给rom的指令地址
    input   wire[`INST_DATA_BUS]     ins_i          // rom根据地址读出来指令
    
    );
    
    wire[`INST_ADDR_BUS]       pc;
    assign pc_o = pc;
    
    
    // PC寄存器模块例化
    pc u_pc(
        .clk         (clk)  ,
        .rst_n       (rst_n),
        .jump_flag   (jump_flag),
        .jump_addr   (jump_addr),
        .pc_out      (pc)
    );
    
    // 指令寄存器模块例化
    if_id u_if_id(
        .clk         (clk),
        .rst_n       (rst_n),
        .hold_flag   (hold_flag),
        .ins_i       (ins_i), 
        .ins_addr_i  (pc),
        .ins_o       (ins_o), 
        .ins_addr_o  (ins_addr_o) 
    );
    
endmodule
