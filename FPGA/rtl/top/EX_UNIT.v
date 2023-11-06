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
    
    // from ID_UNIT
    input   wire[`INST_DATA_BUS]    ins_i               ,     
    input   wire[`INST_ADDR_BUS]    ins_addr_i          , 
    input   wire[`INST_REG_DATA]    imm_i               , 
    
    // from ID_UNIT
    input   wire[`INST_REG_DATA]    csr_rd_data_i       ,    
    input   wire[`INST_ADDR_BUS]    csr_rw_addr_i       ,
    input   wire[`INST_REG_DATA]    csr_zimm_i          ,
    // to RF_UNIT
    output  wire                    csr_wr_en_o         , 
    output  wire[`INST_ADDR_BUS]    csr_wr_addr_o       , 
    output  wire[`INST_REG_DATA]    csr_wr_data_o       , 
    
    // from ID_UNIT
    input   wire[`INST_REG_DATA]    reg1_rd_data_i      , 
    input   wire[`INST_REG_DATA]    reg2_rd_data_i      ,
    input   wire[`INST_REG_ADDR]    reg_wr_addr_i       ,
    // to RF_UNIT
    output  wire                    reg_wr_en_o         ,
    output  wire[`INST_REG_ADDR]    reg_wr_addr_o       ,
    output  wire[`INST_REG_DATA]    reg_wr_data_o       ,
    
    input   wire                    rib_hold_flag_i     ,
    // to IF_UNIT、clint
    output  wire                    jump_flag_o         ,
    output  wire[`INST_REG_DATA]    jump_addr_o         ,
    output  reg [2:0]               hold_flag_o         ,

    input   wire[`INST_ADDR_BUS]    mem_rd_addr_i       ,
    input   wire[`INST_DATA_BUS]    mem_rd_data_i       ,
    output  wire                    mem_wr_rib_req_o    ,
    output  wire                    mem_wr_en_o         , 
    output  wire[`INST_ADDR_BUS]    mem_wr_addr_o       , 
    output  wire[`INST_DATA_BUS]    mem_wr_data_o       ,
    
    // from clint
    input   wire                    clint_busy_i        , 
    input   wire[`INST_ADDR_BUS]    int_addr_i          , 
    input   wire                    int_assert_i        ,  
    // to clint
    output  wire                    div_busy_o          ,
    output  wire                    div_req_o           
    
    );
    
    wire[`INST_REG_DATA]     alu_data1;
    wire[`INST_REG_DATA]     alu_data2;
    wire[3:0]                alu_op_code;
    wire[`INST_REG_DATA]     alu_res;
    wire                     alu_zero_flag;
    wire                     alu_sign_flag;
    wire                     alu_overflow_flag;
    wire[2:0]                mul_op_code;
    wire[`INST_DB_REG_DATA]  mul_res;
    wire[2:0]                div_op_code;
    wire                     div_req;      
    wire                     div_busy;
    wire[`INST_REG_ADDR]     div_reg_wr_addr;
    wire                     div_res_ready;
    wire[`INST_REG_DATA]     div_res;
    wire                     jump_flag;
    wire[`INST_ADDR_BUS]     jump_addr;
    wire                     hold_flag;
    reg [`INST_ADDR_BUS]     mem_rd_addr;
    
    assign div_busy_o = div_busy;
    assign div_req_o = div_req;
    assign jump_flag_o = int_assert_i ? 1'b1 : jump_flag;
    assign jump_addr_o = int_assert_i ? int_addr_i : jump_addr;
    
    wire [6:0]      opcode;
    wire [2:0]      funct3;
    wire [6:0]      funct7;
    assign opcode = ins_i[6:0];
    assign funct3 = ins_i[14:12];
    assign funct7 = ins_i[31:25];
    
    // 读出的数据延后的一个时钟周期，所以内存读地址也需要延迟一个时钟周期
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mem_rd_addr <= `ZERO_WORD;
        end
        else begin
            mem_rd_addr <= mem_rd_addr_i;
        end
    end
    
    // 暂停流水线控制信号 hold_flag_o
    always @ (*) begin
        // 暂停整个流水线
        if(jump_flag_o == 1'b1 || hold_flag == 1'b1 || div_busy == 1'b1 || clint_busy_i == 1'b1) begin
            hold_flag_o = `HOLD_ID_EX;
        end
        // 暂停PC
        else if(rib_hold_flag_i == 1'b1) begin
            hold_flag_o = `HOLD_PC;
        end
        else begin
            hold_flag_o = `HOLD_NONE;
        end
    end
    
    // 控制模块例化
    cu u_cu(
        .clk                 (clk),
        .rst_n               (rst_n),
        .ins_addr_i          (ins_addr_i), 
        .opcode_i            (opcode),
        .funct3_i            (funct3),
        .funct7_i            (funct7),
        .imm_i               (imm_i),  
        .alu_res_i           (alu_res),
        .alu_zero_flag_i     (alu_zero_flag),
        .alu_sign_flag_i     (alu_sign_flag),
        .alu_overflow_flag_i (alu_overflow_flag),
        .alu_op_code_o       (alu_op_code),
        .alu_data1_o         (alu_data1), 
        .alu_data2_o         (alu_data2),
        .mul_res_i           (mul_res),
        .mul_op_code_o       (mul_op_code),
        .div_res_i           (div_res),
        .div_res_ready_i     (div_res_ready), 
        .div_reg_wr_addr_i   (div_reg_wr_addr),
        .div_req_o           (div_req), 
        .div_op_code_o       (div_op_code),        
        .jump_flag_o         (jump_flag),
        .jump_addr_o         (jump_addr),        
        .hold_flag_o         (hold_flag),
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
        .mem_wr_data_o       (mem_wr_data_o),
        .csr_rw_addr_i       (csr_rw_addr_i),
        .csr_zimm_i          (csr_zimm_i),
        .csr_rd_data_i       (csr_rd_data_i),
        .csr_wr_en_o         (csr_wr_en_o),
        .csr_wr_addr_o       (csr_wr_addr_o),
        .csr_wr_data_o       (csr_wr_data_o)
    );
    
    // alu运算模块例化
    alu u_alu(
        .alu_data1_i         (alu_data1), 
        .alu_data2_i         (alu_data2),
        .alu_op_code_i       (alu_op_code),
        .alu_res_o           (alu_res),
        .alu_zero_flag_o     (alu_zero_flag),
        .alu_sign_flag_o     (alu_sign_flag),
        .alu_overflow_flag_o (alu_overflow_flag)
    );
    
    // 乘法模块例化
    mul u_mul(
        .mul_data1_i         (reg1_rd_data_i), 
        .mul_data2_i         (reg2_rd_data_i),
        .mul_op_code_i       (mul_op_code),
        .mul_res_o           (mul_res)
    );
    
    // 除法模块例化
    div u_div(
        .clk                 (clk),
        .rst_n               (rst_n),
        .div_data1_i         (reg1_rd_data_i), 
        .div_data2_i         (reg2_rd_data_i),
        .div_op_code_i       (div_op_code),
        .div_req_i           (div_req), 
        .div_reg_wr_addr_i   (reg_wr_addr_i),
        .div_reg_wr_addr_o   (div_reg_wr_addr),
        .div_busy_o          (div_busy), 
        .div_res_ready_o     (div_res_ready), 
        .div_res_o           (div_res)  
    );
    
    
endmodule
