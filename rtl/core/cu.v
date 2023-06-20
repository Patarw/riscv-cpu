`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/16 16:05:52
// Design Name: 
// Module Name: cu
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

// 控制单元
module cu(

    input   wire[`INST_DATA_BUS]    ins_i               , 
    input   wire[`INST_ADDR_BUS]    ins_addr_i          , 
            
    input   wire                    alu_zero_flag       ,
    input   wire                    alu_sign_flag       ,
    input   wire                    alu_overflow_flag   ,
    
    output  reg[3:0]                alu_op_code         ,
    // 立即数标志位，为1则输入立即数
    output  reg                     imm_flag            ,
    // pc标志位，为1则输入pc值       
    output  reg                     pc_flag             ,
    // pc+4标志位，为1则输出pc+4值       
    output  reg                     pc_4_flag           ,
    // pc+imm标志位，为1则输出pc+imm值       
    output  reg                     pc_imm_flag         ,
            
    output  reg                     jump_flag           ,
            
    output  reg                     hold_flag           ,
    
    // LOAD访存指令标志位
    output  reg                     load_ins_flag       ,         
    // 写寄存器相关参数，EX阶段执行完毕后写入结果
    output  reg                     reg_wr_en_o         ,
    
    output  reg                     mem_wr_en_o         
    
    );
    wire[6:0]       opcode;
    wire[2:0]       funct3;
    wire[6:0]       funct7;
    assign opcode = ins_i[6:0];
    assign funct3 = ins_i[14:12];
    assign funct7 = ins_i[31:25];
    
    
    always @ (*) begin
        case(opcode) 
            // I型指令
            `INS_TYPE_I: begin
                reg_wr_en_o = 1'b1;
                imm_flag = 1'b1;
                pc_flag = 1'b0;
                pc_4_flag = 1'b0;
                jump_flag = 1'b0;
                hold_flag = 1'b0;
                pc_imm_flag = 1'b0;
                mem_wr_en_o = 1'b0;
                load_ins_flag = 1'b0;
                case(funct3)
                    `INS_ADDI: begin
                        alu_op_code = `ALU_ADD;
                    end
                    `INS_SLTI: begin
                        alu_op_code = `ALU_SLT;
                    end
                    `INS_SLTIU: begin
                        alu_op_code = `ALU_SLTU;
                    end
                    `INS_XORI: begin
                        alu_op_code = `ALU_XOR;
                    end
                    `INS_ORI: begin
                        alu_op_code = `ALU_OR;
                    end
                    `INS_ANDI: begin
                        alu_op_code = `ALU_AND;
                    end
                    `INS_SLLI: begin
                        alu_op_code = `ALU_SLL;
                    end
                    `INS_SRLI_SRAI: begin
                        if(funct7 == 7'b000_0000) begin
                            alu_op_code = `ALU_SRL;
                        end
                        else if(funct7 == 7'b010_0000) begin
                            alu_op_code = `ALU_SRA;
                        end
                    end
                endcase
            end
            // R型指令
            `INS_TYPE_R: begin
                reg_wr_en_o = 1'b1;
                imm_flag = 1'b0;
                pc_flag = 1'b0;
                pc_4_flag = 1'b0;
                jump_flag = 1'b0;
                hold_flag = 1'b0;
                pc_imm_flag = 1'b0;
                mem_wr_en_o = 1'b0;
                load_ins_flag = 1'b0;
                case({funct7,funct3}) 
                    `INS_ADD: begin
                        alu_op_code = `ALU_ADD;
                    end
                    `INS_SUB: begin
                        alu_op_code = `ALU_SUB;
                    end
                    `INS_SLL: begin
                        alu_op_code = `ALU_SLL;
                    end
                    `INS_SLT: begin
                        alu_op_code = `ALU_SLT;
                    end
                    `INS_SLTU: begin
                        alu_op_code = `ALU_SLTU;
                    end
                    `INS_XOR: begin
                        alu_op_code = `ALU_XOR;
                    end
                    `INS_SRL: begin
                        alu_op_code = `ALU_SRL;
                    end
                    `INS_SRA: begin
                        alu_op_code = `ALU_SRA;
                    end
                    `INS_OR: begin
                        alu_op_code = `ALU_OR;
                    end
                    `INS_AND: begin
                        alu_op_code = `ALU_AND;
                    end
                endcase
            end 
            `INS_LUI: begin
                reg_wr_en_o = 1'b1;
                imm_flag = 1'b1;
                alu_op_code = `ALU_ADD;
                pc_flag = 1'b0;
                pc_4_flag = 1'b0;
                jump_flag = 1'b0;
                hold_flag = 1'b0;
                pc_imm_flag = 1'b0;
                mem_wr_en_o = 1'b0;
                load_ins_flag = 1'b0;
            end
            `INS_AUIPC: begin
                reg_wr_en_o = 1'b1;
                imm_flag = 1'b1;
                alu_op_code = `ALU_ADD;
                pc_flag = 1'b1;
                pc_4_flag = 1'b0;
                jump_flag = 1'b0;
                hold_flag = 1'b0;
                pc_imm_flag = 1'b0;
                mem_wr_en_o = 1'b0;
                load_ins_flag = 1'b0;
            end
            // 无条件跳转指令
            `INS_JAL: begin
                reg_wr_en_o = 1'b1;
                imm_flag = 1'b1;
                alu_op_code = `ALU_ADD;
                pc_flag = 1'b1;
                pc_4_flag = 1'b1;
                jump_flag = 1'b1;
                hold_flag = 1'b1;
                pc_imm_flag = 1'b0;
                mem_wr_en_o = 1'b0;
                load_ins_flag = 1'b0;
            end
            `INS_JALR: begin
                reg_wr_en_o = 1'b1;
                imm_flag = 1'b1;
                alu_op_code = `ALU_ADD;
                pc_flag = 1'b0;
                pc_4_flag = 1'b1;
                jump_flag = 1'b1;
                hold_flag = 1'b1;
                pc_imm_flag = 1'b0;
                mem_wr_en_o = 1'b0;
                load_ins_flag = 1'b0;
            end
            `INS_TYPE_BRANCH: begin
                reg_wr_en_o = 1'b0;
                imm_flag = 1'b0;
                pc_flag = 1'b0;
                pc_4_flag = 1'b0;
                mem_wr_en_o = 1'b0;
                load_ins_flag = 1'b0;
                case(funct3)
                    `INS_BEQ: begin
                        alu_op_code = `ALU_SUB;
                        jump_flag = alu_zero_flag ? 1'b1 : 1'b0;
                        hold_flag = alu_zero_flag ? 1'b1 : 1'b0;
                        pc_imm_flag = alu_zero_flag ? 1'b1 : 1'b0;
                    end
                    `INS_BNE: begin
                        alu_op_code = `ALU_SUB;
                        jump_flag = !alu_zero_flag ? 1'b1 : 1'b0;
                        hold_flag = !alu_zero_flag ? 1'b1 : 1'b0;
                        pc_imm_flag = !alu_zero_flag ? 1'b1 : 1'b0;
                    end
                    `INS_BLT: begin
                        alu_op_code = `ALU_SUB;
                        jump_flag = alu_sign_flag ? 1'b1 : 1'b0;
                        hold_flag = alu_sign_flag ? 1'b1 : 1'b0;
                        pc_imm_flag = alu_sign_flag ? 1'b1 : 1'b0;
                    end
                    `INS_BGE: begin
                        alu_op_code = `ALU_SUB;
                        jump_flag = (!alu_sign_flag && !alu_zero_flag) ? 1'b1 : 1'b0;
                        hold_flag = (!alu_sign_flag && !alu_zero_flag) ? 1'b1 : 1'b0;
                        pc_imm_flag = (!alu_sign_flag && !alu_zero_flag) ? 1'b1 : 1'b0;
                    end
                    `INS_BLTU,`INS_BGEU: begin
                        alu_op_code = `ALU_SLTU;
                        jump_flag = !alu_zero_flag ? 1'b1 : 1'b0;
                        hold_flag = !alu_zero_flag ? 1'b1 : 1'b0;
                        pc_imm_flag = !alu_zero_flag ? 1'b1 : 1'b0;
                    end
                endcase
            end
            `INS_TYPE_SAVE: begin
                reg_wr_en_o = 1'b0;
                imm_flag = 1'b1;
                alu_op_code = `ALU_ADD;
                pc_flag = 1'b0;
                pc_4_flag = 1'b0;
                jump_flag = 1'b0;
                hold_flag = 1'b0;
                pc_imm_flag = 1'b0;
                mem_wr_en_o = 1'b1;
                load_ins_flag = 1'b0;
            end
            `INS_TYPE_LOAD: begin
                reg_wr_en_o = 1'b1;
                imm_flag = 1'b1;
                alu_op_code = `ALU_ADD;
                pc_flag = 1'b0;
                pc_4_flag = 1'b0;
                jump_flag = 1'b0;
                hold_flag = 1'b0;
                pc_imm_flag = 1'b0;
                mem_wr_en_o = 1'b0;
                load_ins_flag = 1'b1;
            end
            default: begin
                reg_wr_en_o = 1'b0;
                imm_flag = 1'b0;
                alu_op_code = 4'd0;
                pc_flag = 1'b0;
                pc_4_flag = 1'b0;
                jump_flag = 1'b0;
                hold_flag = 1'b0;
                pc_imm_flag = 1'b0;
                mem_wr_en_o = 1'b0;
                load_ins_flag = 1'b0;
            end
        endcase
    end
    
endmodule
