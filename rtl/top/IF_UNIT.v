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
    output  wire[`INST_ADDR_BUS]     ins_addr_o     // 指令地址
    
    );
    
    wire[`INST_DATA_BUS]       ins;
    wire[`INST_ADDR_BUS]       pc;
    
    // PC寄存器模块例化
    pc u_pc(
        .clk         (clk)  ,
        .rst_n       (rst_n),
        .jump_flag   (jump_flag),
        .jump_addr   (jump_addr),
        .pc_out      (pc)
    );
    
    // 这里先直接连接，后面再加上总线
    rom u_rom(
        .clk         (clk),
        .rst_n       (rst_n),
        .wr_en       (), // write enable
        .addr        (pc), // address
        .data_i      (), // write data
        .data_o      (ins)  // read data
    );
    
    // 指令寄存器模块例化
    ir u_ir(
        .clk         (clk),
        .rst_n       (rst_n),
        .hold_flag   (hold_flag),
        .ins_i       (ins), 
        .ins_addr_i  (pc),
        .ins_o       (ins_o), 
        .ins_addr_o  (ins_addr_o) 
    );
    
endmodule
