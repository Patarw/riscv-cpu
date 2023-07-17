`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/16 17:02:43
// Design Name: 
// Module Name: EX_UNIT
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

// 执行单元
module EX_UNIT(

    input   wire                    clk                 ,
    input   wire                    rst_n               ,
    
    input   wire[`INST_DATA_BUS]    ins_i               ,     
    input   wire[`INST_ADDR_BUS]    ins_addr_i          , 
    input   wire[6:0]               opcode_i            ,
    input   wire[2:0]               funct3_i            ,
    input   wire[6:0]               funct7_i            ,
    input   wire[`INST_REG_DATA]    imm_i               ,  
            
    input   wire[`INST_REG_DATA]    reg1_rd_data_i      , 
    input   wire[`INST_REG_DATA]    reg2_rd_data_i      ,
    input   wire[`INST_REG_ADDR]    reg_wr_addr_i       ,
     
    output  wire                    reg_wr_en_o         ,
    output  wire[`INST_REG_ADDR]    reg_wr_addr_o       ,
    output  wire[`INST_REG_DATA]    reg_wr_data_o       ,
    
    input   wire                    rib_hold_flag_i     ,
    output  wire                    jump_flag_o         ,
    output  wire[`INST_REG_DATA]    jump_addr_o         ,
    output  wire[2:0]               hold_flag_o         ,

    // 内存相关引脚（ram）
    input   wire[`INST_ADDR_BUS]    mem_rd_addr_i       ,
    input   wire[`INST_DATA_BUS]    mem_rd_data_i       ,
    output  wire                    mem_wr_rib_req_o    ,
    output  wire                    mem_wr_en_o         , 
    output  wire[`INST_ADDR_BUS]    mem_wr_addr_o       , 
    output  wire[`INST_DATA_BUS]    mem_wr_data_o       
    
    );
    
    wire[`INST_REG_DATA]     alu_data1;
    wire[`INST_REG_DATA]     alu_data2;
    wire[3:0]                alu_op_code;
    wire[`INST_REG_DATA]     alu_res;
    wire                     alu_zero_flag;
    wire                     alu_sign_flag;
    wire                     alu_overflow_flag;
    reg [`INST_ADDR_BUS]     mem_rd_addr;
    
    // 内存写地址 mem_wr_addr_o
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mem_rd_addr <= `ZERO_WORD;
        end
        else begin
            mem_rd_addr <= mem_rd_addr_i;
        end
    end
    
    // 控制单元例化
    cu u_cu(
        .clk                 (clk),
        .rst_n               (rst_n),
        .ins_addr_i          (ins_addr_i), 
        .opcode_i            (opcode_i),
        .funct3_i            (funct3_i),
        .funct7_i            (funct7_i),
        .imm_i               (imm_i),  
        .alu_res_i           (alu_res),
        .alu_zero_flag_i     (alu_zero_flag),
        .alu_sign_flag_i     (alu_sign_flag),
        .alu_overflow_flag_i (alu_overflow_flag),
        .alu_op_code_o       (alu_op_code),
        .alu_data1_o         (alu_data1), 
        .alu_data2_o         (alu_data2),
        .rib_hold_flag_i     (rib_hold_flag_i),          
        .jump_flag_o         (jump_flag_o),
        .jump_addr_o         (jump_addr_o),        
        .hold_flag_o         (hold_flag_o),
        .reg1_rd_data_i      (reg1_rd_data_i), 
        .reg2_rd_data_i      (reg2_rd_data_i),
        .reg_wr_addr_i       (reg_wr_addr_i),
        .reg_wr_en_o         (reg_wr_en_o),
        .reg_wr_addr_o       (reg_wr_addr_o),
        .reg_wr_data_o       (reg_wr_data_o),
        .mem_rd_addr_i       (mem_rd_addr),
        .mem_rd_data_i       (mem_rd_data_i),
        .mem_wr_rib_req_o    (mem_wr_rib_req_o),
        .mem_wr_en_o         (mem_wr_en_o), 
        .mem_wr_addr_o       (mem_wr_addr_o), 
        .mem_wr_data_o       (mem_wr_data_o)
    );
    
    // 运算单元例化
    alu u_alu(
        .alu_data1_i         (alu_data1), 
        .alu_data2_i         (alu_data2),
        .alu_op_code         (alu_op_code),
        .alu_res_o           (alu_res),
        .alu_zero_flag       (alu_zero_flag),
        .alu_sign_flag       (alu_sign_flag),
        .alu_overflow_flag   (alu_overflow_flag)
    );
    
endmodule
