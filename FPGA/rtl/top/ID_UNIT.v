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

    input   wire                    clk               ,
    input   wire                    rst_n             ,
                                                      
    input   wire[2:0]               hold_flag_i       ,
     
    // 从IF模块传来的指令和指令地址
    input   wire[`INST_DATA_BUS]    ins_i             , 
    input   wire[`INST_ADDR_BUS]    ins_addr_i        , 
    
    // gpr寄存器相关参数                 
    input   wire[`INST_REG_DATA]    reg1_rd_data_i    , 
    input   wire[`INST_REG_DATA]    reg2_rd_data_i    ,   
    output  wire[`INST_REG_ADDR]    reg1_rd_addr_o    , 
    output  wire[`INST_REG_ADDR]    reg2_rd_addr_o    ,         
    output  wire[`INST_REG_DATA]    reg1_rd_data_o    , 
    output  wire[`INST_REG_DATA]    reg2_rd_data_o    ,                         
    output  wire[`INST_REG_ADDR]    reg_wr_addr_o     ,
    
    // 传给EX模块的指令地址和译码参数        
    output  wire[`INST_DATA_BUS]    ins_o             ,     
    output  wire[`INST_ADDR_BUS]    ins_addr_o        , 
    output  wire[6:0]               opcode_o          ,
    output  wire[2:0]               funct3_o          ,
    output  wire[6:0]               funct7_o          ,                                       
    output  wire[`INST_REG_DATA]    imm_o             ,
    
    // csr寄存器相关参数
    input   wire[`INST_REG_DATA]    csr_rd_data_i     ,
    output  wire[`INST_ADDR_BUS]    csr_rd_addr_o     ,
    output  wire[`INST_ADDR_BUS]    csr_rw_addr_o     ,
    output  wire[`INST_REG_DATA]    csr_zimm_o        ,
    output  wire[`INST_REG_DATA]    csr_rd_data_o     ,
    
    // 访存
    output  wire                    mem_rd_rib_req_o  ,
    output  wire[`INST_ADDR_BUS]    mem_rd_addr_o       
    
    );
    
    wire[`INST_DATA_BUS]    ins;
    wire[6:0]               opcode;
    wire[2:0]               funct3;
    wire[6:0]               funct7;
    wire[`INST_REG_ADDR]    reg_wr_addr;
    wire[`INST_REG_DATA]    imm;
    wire                    mem_rd_flag;
    wire[`INST_ADDR_BUS]    csr_rw_addr;
    wire[`INST_REG_DATA]    csr_zimm;
    
    assign csr_rd_addr_o = csr_rw_addr;
    
    // 指令译码模块例化
    id u_id(
        .clk                (clk),
        .rst_n              (rst_n),
        .ins_i              (ins_i), 
        .ins_addr_i         (ins_addr_i),
        .ins_o              (ins), 
        .opcode_o           (opcode),
        .funct3_o           (funct3),
        .funct7_o           (funct7),
        .reg1_rd_addr_o     (reg1_rd_addr_o), 
        .reg2_rd_addr_o     (reg2_rd_addr_o),
        .reg_wr_addr_o      (reg_wr_addr),
        .imm_o              (imm),
        .mem_rd_flag_o      (mem_rd_flag),
        .csr_rw_addr_o      (csr_rw_addr),
        .csr_zimm_o         (csr_zimm)
    );
    
    // 将传给EX单元的内容打一拍
    id_ex u_id_ex(
        .clk                (clk),
        .rst_n              (rst_n),
        .hold_flag_i        (hold_flag_i),
        .mem_rd_flag_i      (mem_rd_flag),
        .ins_i              (ins), 
        .ins_addr_i         (ins_addr_i),
        .ins_o              (ins_o), 
        .opcode_i           (opcode),
        .funct3_i           (funct3),
        .funct7_i           (funct7),
        .reg1_rd_data_i     (reg1_rd_data_i), 
        .reg2_rd_data_i     (reg2_rd_data_i),
        .reg_wr_addr_i      (reg_wr_addr),
        .imm_i              (imm),
        .csr_rd_data_i      (csr_rd_data_i),
        .csr_rw_addr_i      (csr_rw_addr),
        .csr_zimm_i         (csr_zimm),
        .ins_addr_o         (ins_addr_o), 
        .opcode_o           (opcode_o),
        .funct3_o           (funct3_o),
        .funct7_o           (funct7_o),
        .reg1_rd_data_o     (reg1_rd_data_o), 
        .reg2_rd_data_o     (reg2_rd_data_o),
        .reg_wr_addr_o      (reg_wr_addr_o),
        .imm_o              (imm_o),
        .csr_rd_data_o      (csr_rd_data_o),
        .csr_rw_addr_o      (csr_rw_addr_o),
        .csr_zimm_o         (csr_zimm_o),
        .mem_rd_rib_req_o   (mem_rd_rib_req_o),
        .mem_rd_addr_o      (mem_rd_addr_o)
    );
    
endmodule
