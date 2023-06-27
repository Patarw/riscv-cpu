`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/14 22:24:56
// Design Name: 
// Module Name: id
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

//指令译码模块
module id(

    input   wire                    clk            ,
    input   wire                    rst_n          ,
    
    //从IF模块传来的指令和指令地址
    input   wire[`INST_DATA_BUS]    ins_i          , 
    input   wire[`INST_ADDR_BUS]    ins_addr_i     , 
    
    // 传给RF模块的寄存器地址，用于取数据
    output  reg[`INST_REG_ADDR]     reg1_rd_addr_o , 
    output  reg[`INST_REG_ADDR]     reg2_rd_addr_o ,
    
    // 写寄存器地址
    output  reg[`INST_REG_ADDR]     reg_wr_addr_o  ,
    
    // 立即数
    output  reg[`INST_REG_DATA]     imm_o  
    
    );
    
    // R类指令可以根据下列三个参数确定
    wire[6:0]       opcode;
    wire[2:0]       funct3;
    wire[6:0]       funct7;
    assign opcode = ins_i[6:0];
    assign funct3 = ins_i[14:12];
    assign funct7 = ins_i[31:25];
    
    // R类指令涉及到的三个寄存器
    wire[4:0]       rs1;
    wire[4:0]       rs2;
    wire[4:0]       rd;
    assign rs1 = ins_i[19:15];
    assign rs2 = ins_i[24:20];
    assign rd = ins_i[11:7];
    
    
    // 开始译码
    always @ (*) begin
        case(opcode) 
            `INS_TYPE_I: begin
                case(funct3)
                    `INS_ADDI,`INS_SLTI: begin
                        reg1_rd_addr_o = rs1;
                        reg2_rd_addr_o = `ZERO_REG_ADDR;
                        reg_wr_addr_o = rd;
                        imm_o = {{20{ins_i[31]}}, ins_i[31:20]}; // 因为立即数是补码，所以需要符号位拓展
                    end
                    `INS_SLTIU,`INS_XORI,`INS_ORI,`INS_ANDI: begin
                        reg1_rd_addr_o = rs1;
                        reg2_rd_addr_o = `ZERO_REG_ADDR;
                        reg_wr_addr_o = rd;
                        imm_o = {{20{1'b0}}, ins_i[31:20]}; // 这里的立即数是无符号数，所以不能符号位拓展
                    end
                    `INS_SLLI,`INS_SRLI_SRAI: begin
                        reg1_rd_addr_o = rs1;
                        reg2_rd_addr_o = `ZERO_REG_ADDR;
                        reg_wr_addr_o = rd;
                        imm_o = {{27{1'b0}}, ins_i[24:20]};
                    end
                endcase
            end
            `INS_TYPE_R: begin
                case({funct7,funct3})
                    `INS_ADD,`INS_SUB,`INS_SLL,`INS_SLT,`INS_SLTU,`INS_XOR,`INS_SRL,`INS_SRA,`INS_OR,`INS_AND: begin
                        reg1_rd_addr_o = rs1;
                        reg2_rd_addr_o = rs2;
                        reg_wr_addr_o = rd;
                        imm_o = `ZERO_WORD;
                    end                    
                endcase
            end   
            `INS_LUI,`INS_AUIPC: begin
                reg1_rd_addr_o = `ZERO_REG_ADDR;
                reg2_rd_addr_o = `ZERO_REG_ADDR;
                reg_wr_addr_o = rd;
                imm_o = {ins_i[31:12], {12{1'b0}}};
            end
            `INS_JAL: begin
                reg1_rd_addr_o = `ZERO_REG_ADDR;
                reg2_rd_addr_o = `ZERO_REG_ADDR;
                reg_wr_addr_o = rd;
                imm_o = {{11{ins_i[31]}}, ins_i[31], ins_i[19:12], ins_i[20], ins_i[30:21], 1'b0};
            end
            `INS_JALR: begin
                reg1_rd_addr_o = rs1;
                reg2_rd_addr_o = `ZERO_REG_ADDR;
                reg_wr_addr_o = rd;
                imm_o = {{20{ins_i[31]}}, ins_i[31:20]}; // 因为立即数是补码，所以需要符号位拓展
            end
            `INS_TYPE_BRANCH: begin
                case(funct3)
                    `INS_BEQ,`INS_BNE,`INS_BLT,`INS_BGE,`INS_BLTU,`INS_BGEU: begin
                        reg1_rd_addr_o = rs1;
                        reg2_rd_addr_o = rs2;
                        reg_wr_addr_o = `ZERO_REG_ADDR;
                        imm_o = {{19{ins_i[31]}}, ins_i[31], ins_i[7], ins_i[30:25], ins_i[11:8], 1'b0}; // 因为立即数是补码，所以需要符号位拓展
                    end
                endcase
            end
            `INS_TYPE_SAVE: begin
                reg1_rd_addr_o = rs1;
                reg2_rd_addr_o = rs2;
                reg_wr_addr_o = `ZERO_REG_ADDR;
                imm_o = {{20{ins_i[31]}}, ins_i[31:25], ins_i[11:7]}; // 因为立即数是补码，所以需要符号位拓展
            end
            `INS_TYPE_LOAD: begin
                reg1_rd_addr_o = rs1;
                reg2_rd_addr_o = `ZERO_REG_ADDR;
                reg_wr_addr_o = rd;
                imm_o = {{20{ins_i[31]}}, ins_i[31:20]}; // 因为立即数是补码，所以需要符号位拓展
            end
            default: begin
                reg1_rd_addr_o = `ZERO_REG_ADDR;
                reg2_rd_addr_o = `ZERO_REG_ADDR;
                reg_wr_addr_o = `ZERO_REG_ADDR;
                imm_o = `ZERO_WORD;
            end
        endcase
    end
endmodule
