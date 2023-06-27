`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/16 17:17:03
// Design Name: 
// Module Name: RISCV_TOP
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

// riscv处理器核顶层模块
module RISCV_TOP(

    input   wire                    clk                 ,
    input   wire                    rst_n               ,
    
    output  wire                    rom_addr            
    );
    
    // IF单元输出信号
    wire[`INST_DATA_BUS]     if_ins_o;
    wire[`INST_ADDR_BUS]     if_ins_addr_o;
    wire[`INST_ADDR_BUS]     if_pc_o;
    
    // ID单元输出信号
    wire[`INST_DATA_BUS]     id_ins_o;
    wire[`INST_ADDR_BUS]     id_ins_addr_o;
    wire[`INST_REG_ADDR]     id_reg1_rd_addr_o;
    wire[`INST_REG_ADDR]     id_reg2_rd_addr_o;
    wire[`INST_REG_DATA]     id_reg1_rd_data_o;
    wire[`INST_REG_DATA]     id_reg2_rd_data_o;
    wire[`INST_REG_ADDR]     id_reg_wr_addr_o;
    wire[`INST_REG_DATA]     id_imm_o;
    
    // RF单元输出信号
    wire[`INST_REG_DATA]     rf_reg1_rd_data_o;
    wire[`INST_REG_DATA]     rf_reg2_rd_data_o;
    
    // EX单元输出信号
    wire                     ex_reg_wr_en_o  ;
    wire[`INST_REG_ADDR]     ex_reg_wr_addr_o;
    wire[`INST_REG_DATA]     ex_reg_wr_data_o;
    wire                     ex_jump_flag_o;
    wire[`INST_REG_DATA]     ex_jump_addr_o;
    wire                     ex_hold_flag_o;
    wire                     ex_mem_wr_en_o;  
    wire[`INST_ADDR_BUS]     ex_mem_wd_addr_o;
    wire[`INST_DATA_BUS]     ex_mem_wr_data_o;
    
    // ram rom输出信号
    wire[`INST_DATA_BUS]     ram_mem_rd_data_o;
    wire[`INST_DATA_BUS]     rom_ins_o;
    
    // 取指单元例化
    IF_UNIT INST_IF_UNIT(
        .clk          (clk),
        .rst_n        (rst_n),
        .hold_flag    (ex_hold_flag_o),
        .jump_flag    (ex_jump_flag_o),
        .jump_addr    (ex_jump_addr_o),
        .ins_o        (if_ins_o),      // 指令
        .ins_addr_o   (if_ins_addr_o), // 指令地址
        .pc_o         (if_pc_o),          
        .ins_i        (rom_ins_o)
    );
    
    // 译码单元例化
    ID_UNIT INST_ID_UNIT(
        .clk            (clk),
        .rst_n          (rst_n),
        .hold_flag      (ex_hold_flag_o),
        .ins_i          (if_ins_o), 
        .ins_addr_i     (if_ins_addr_o), 
        .reg1_rd_addr_o (id_reg1_rd_addr_o), 
        .reg2_rd_addr_o (id_reg2_rd_addr_o),
        .reg1_rd_data_i (rf_reg1_rd_data_o), 
        .reg2_rd_data_i (rf_reg2_rd_data_o),
        .ins_o          (id_ins_o), 
        .ins_addr_o     (id_ins_addr_o), 
        .reg1_rd_data_o (id_reg1_rd_data_o), 
        .reg2_rd_data_o (id_reg2_rd_data_o),
        .reg_wr_addr_o  (id_reg_wr_addr_o),
        .imm_o          (id_imm_o)
    );
    
    // 通用寄存器模块例化
    RF_UNIT INST_RF_UNIT(
        .clk          (clk),
        .rst_n        (rst_n),
        .wr_en        (ex_reg_wr_en_o), // 写使能
        .wr_addr      (ex_reg_wr_addr_o), // 写地址
        .wr_data      (ex_reg_wr_data_o), // 写数据
        .reg1_rd_addr (id_reg1_rd_addr_o), // R1寄存器读地址
        .reg2_rd_addr (id_reg2_rd_addr_o), // R2寄存器读地址
        .reg1_rd_data (rf_reg1_rd_data_o), // R1寄存器读数据
        .reg2_rd_data (rf_reg2_rd_data_o)  // R2寄存器读数据
    );
    
    // 执行单元例化
    EX_UNIT INST_EX_UNIT(
        .clk                 (clk),
        .rst_n               (rst_n),        
        .ins_i               (id_ins_o), 
        .ins_addr_i          (id_ins_addr_o),           
        .reg1_rd_data_i      (id_reg1_rd_data_o), 
        .reg2_rd_data_i      (id_reg2_rd_data_o),          
        .reg_wr_addr_i       (id_reg_wr_addr_o), 
        .imm_i               (id_imm_o),
        .reg_wr_en_o         (ex_reg_wr_en_o),
        .reg_wr_addr_o       (ex_reg_wr_addr_o),
        .reg_wr_data_o       (ex_reg_wr_data_o),
        .jump_flag           (ex_jump_flag_o),
        .jump_addr           (ex_jump_addr_o),
        .hold_flag           (ex_hold_flag_o),
        .mem_rd_data_i       (ram_mem_rd_data_o),   
        .mem_wr_en_o         (ex_mem_wr_en_o),
        .mem_wd_addr_o       (ex_mem_wd_addr_o),
        .mem_wr_data_o       (ex_mem_wr_data_o)
    );
    
    rom u_rom(
        .clk         (clk),
        .rst_n       (rst_n),
        .wr_en       (), // write enable
        .addr        (if_pc_o), // address
        .data_i      (), // write data
        .data_o      (rom_ins_o)  // read data
    );
    
    ram u_ram(
        .clk         (clk),
        .rst_n       (rst_n),
        .wr_en_i     (ex_mem_wr_en_o), // write enable
        .addr_i      (ex_mem_wd_addr_o), // address
        .data_i      (ex_mem_wr_data_o), // write data
        .data_o      (ram_mem_rd_data_o)  // read data
    );
    
endmodule
