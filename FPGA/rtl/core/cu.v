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

    input   wire                    clk                 ,
    input   wire                    rst_n               ,
    
    // 指令译码相关参数
    input   wire[`INST_ADDR_BUS]    ins_addr_i          , 
    input   wire[6:0]               opcode_i            ,
    input   wire[2:0]               funct3_i            ,
    input   wire[6:0]               funct7_i            ,
    input   wire[`INST_REG_DATA]    imm_i               ,  
    
    // alu相关参数（alu）
    input   wire[`INST_REG_DATA]    alu_res_i           ,
    input   wire                    alu_zero_flag_i     ,
    input   wire                    alu_sign_flag_i     ,
    input   wire                    alu_overflow_flag_i ,
    output  reg [3:0]               alu_op_code_o       ,
    output  reg [`INST_REG_DATA]    alu_data1_o         , 
    output  reg [`INST_REG_DATA]    alu_data2_o         ,

    // 跳转和暂停流水线相关参数
    input   wire                    rib_hold_flag_i     ,          
    output  reg                     jump_flag_o         ,
    output  reg [`INST_ADDR_BUS]    jump_addr_o         ,        
    output  reg [2:0]               hold_flag_o         ,

    // 寄存器相关参数（register）
    input   wire[`INST_REG_DATA]    reg1_rd_data_i      , 
    input   wire[`INST_REG_DATA]    reg2_rd_data_i      ,
    input   wire[`INST_REG_ADDR]    reg_wr_addr_i       ,
    output  reg                     reg_wr_en_o         ,
    output  reg [`INST_REG_ADDR]    reg_wr_addr_o       ,
    output  reg [`INST_REG_DATA]    reg_wr_data_o       ,
    
    // 内存相关引脚（ram）
    input   wire[`INST_ADDR_BUS]    mem_rd_addr_i       ,
    input   wire[`INST_DATA_BUS]    mem_rd_data_i       ,
    output  reg                     mem_wr_rib_req_o    ,
    output  reg                     mem_wr_en_o         , 
    output  wire[`INST_ADDR_BUS]    mem_wr_addr_o       , 
    output  reg [`INST_DATA_BUS]    mem_wr_data_o       
    
    );
    
    reg                     hold_flag;
    
    assign mem_wr_addr_o = mem_rd_addr_i;

    
    // 暂停流水线控制信号 hold_flag_o
    always @ (*) begin
        // 暂停整个流水线
        if(hold_flag == 1'b1) begin
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
    
    // 根据不同指令类型发出不同的控制信号
    always @ (*) begin
        // alu计算相关
        alu_op_code_o = 4'd0;
        alu_data1_o = reg1_rd_data_i;
        alu_data2_o = reg2_rd_data_i;
        
        // 跳转相关
        jump_flag_o = 1'b0;
        jump_addr_o = `ZERO_WORD;
        hold_flag = 1'b0;
        
        // 寄存器相关
        reg_wr_en_o = 1'b0;
        reg_wr_addr_o = reg_wr_addr_i;
        reg_wr_data_o = alu_res_i;
        
        // 内存相关
        mem_wr_rib_req_o = 1'b0;
        mem_wr_en_o = 1'b0;
        mem_wr_data_o = `ZERO_WORD;
        
        case(opcode_i) 
            // I型指令
            `INS_TYPE_I: begin
                reg_wr_en_o = 1'b1;
                alu_data2_o = imm_i;
                case(funct3_i)
                    `INS_ADDI: begin
                        alu_op_code_o = `ALU_ADD;
                    end
                    `INS_SLTI: begin
                        alu_op_code_o = `ALU_SLT;
                    end
                    `INS_SLTIU: begin
                        alu_op_code_o = `ALU_SLTU;
                    end
                    `INS_XORI: begin
                        alu_op_code_o = `ALU_XOR;
                    end
                    `INS_ORI: begin
                        alu_op_code_o = `ALU_OR;
                    end
                    `INS_ANDI: begin
                        alu_op_code_o = `ALU_AND;
                    end
                    `INS_SLLI: begin
                        alu_op_code_o = `ALU_SLL;
                    end
                    `INS_SRLI_SRAI: begin
                        if(funct7_i == 7'b000_0000) begin
                            alu_op_code_o = `ALU_SRL;
                        end
                        else if(funct7_i == 7'b010_0000) begin
                            alu_op_code_o = `ALU_SRA;
                        end
                    end
                endcase
            end
            // R型指令
            `INS_TYPE_R: begin
                reg_wr_en_o = 1'b1;
                case({funct7_i,funct3_i}) 
                    `INS_ADD: begin
                        alu_op_code_o = `ALU_ADD;
                    end
                    `INS_SUB: begin
                        alu_op_code_o = `ALU_SUB;
                    end
                    `INS_SLL: begin
                        alu_op_code_o = `ALU_SLL;
                    end
                    `INS_SLT: begin
                        alu_op_code_o = `ALU_SLT;
                    end
                    `INS_SLTU: begin
                        alu_op_code_o = `ALU_SLTU;
                    end
                    `INS_XOR: begin
                        alu_op_code_o = `ALU_XOR;
                    end
                    `INS_SRL: begin
                        alu_op_code_o = `ALU_SRL;
                    end
                    `INS_SRA: begin
                        alu_op_code_o = `ALU_SRA;
                    end
                    `INS_OR: begin
                        alu_op_code_o = `ALU_OR;
                    end
                    `INS_AND: begin
                        alu_op_code_o = `ALU_AND;
                    end
                    default: begin 
                    end
                endcase
            end 
            `INS_LUI: begin
                reg_wr_en_o = 1'b1;
                alu_data2_o = imm_i;
                alu_op_code_o = `ALU_ADD;
            end
            `INS_AUIPC: begin
                reg_wr_en_o = 1'b1;
                alu_data1_o =ins_addr_i;
                alu_data2_o = imm_i;
                alu_op_code_o = `ALU_ADD;
            end
            // 无条件跳转指令
            `INS_JAL: begin
                reg_wr_en_o = 1'b1;
                reg_wr_data_o = ins_addr_i + 4'd4;
                alu_data1_o =ins_addr_i;
                alu_data2_o = imm_i;
                alu_op_code_o = `ALU_ADD;
                jump_flag_o = 1'b1;
                jump_addr_o = {alu_res_i[31:1], 1'b0};
                hold_flag = 1'b1;
            end
            `INS_JALR: begin
                reg_wr_en_o = 1'b1;
                reg_wr_data_o = ins_addr_i + 4'd4;
                alu_data2_o = imm_i;
                alu_op_code_o = `ALU_ADD;
                jump_flag_o = 1'b1;
                jump_addr_o = {alu_res_i[31:1], 1'b0};
                hold_flag = 1'b1;
            end
            `INS_TYPE_BRANCH: begin
                case(funct3_i)
                    `INS_BEQ: begin
                        alu_op_code_o = `ALU_SUB;
                        jump_flag_o = alu_zero_flag_i ? 1'b1 : 1'b0;
                        jump_addr_o = alu_zero_flag_i ? ($signed(ins_addr_i) + $signed(imm_i)) : {alu_res_i[31:1], 1'b0};
                        hold_flag = alu_zero_flag_i ? 1'b1 : 1'b0;
                    end
                    `INS_BNE: begin
                        alu_op_code_o = `ALU_SUB;
                        jump_flag_o = !alu_zero_flag_i ? 1'b1 : 1'b0;
                        jump_addr_o = !alu_zero_flag_i ? ($signed(ins_addr_i) + $signed(imm_i)) : {alu_res_i[31:1], 1'b0};
                        hold_flag = !alu_zero_flag_i ? 1'b1 : 1'b0;
                    end
                    `INS_BLT: begin
                        alu_op_code_o = `ALU_SUB;
                        jump_flag_o = alu_sign_flag_i ? 1'b1 : 1'b0;
                        jump_addr_o = alu_sign_flag_i ? ($signed(ins_addr_i) + $signed(imm_i)) : {alu_res_i[31:1], 1'b0};
                        hold_flag = alu_sign_flag_i ? 1'b1 : 1'b0;
                    end
                    `INS_BGE: begin
                        alu_op_code_o = `ALU_SUB;
                        jump_flag_o = !alu_sign_flag_i ? 1'b1 : 1'b0;
                        jump_addr_o = !alu_sign_flag_i ? ($signed(ins_addr_i) + $signed(imm_i)) : {alu_res_i[31:1], 1'b0};
                        hold_flag = !alu_sign_flag_i ? 1'b1 : 1'b0;
                    end
                    `INS_BLTU: begin
                        alu_op_code_o = `ALU_SLTU;
                        jump_flag_o = !alu_zero_flag_i ? 1'b1 : 1'b0;
                        jump_addr_o = !alu_zero_flag_i ? ($signed(ins_addr_i) + $signed(imm_i)) : {alu_res_i[31:1], 1'b0};
                        hold_flag = !alu_zero_flag_i ? 1'b1 : 1'b0;
                    end
                    `INS_BGEU: begin
                        alu_op_code_o = `ALU_SLTU;
                        jump_flag_o = alu_zero_flag_i ? 1'b1 : 1'b0;
                        jump_addr_o = alu_zero_flag_i ? ($signed(ins_addr_i) + $signed(imm_i)) : {alu_res_i[31:1], 1'b0};
                        hold_flag = alu_zero_flag_i ? 1'b1 : 1'b0;
                    end
                    default: begin
                    end
                endcase
            end
            `INS_TYPE_SAVE: begin
                mem_wr_rib_req_o = 1'b1;
                mem_wr_en_o = 1'b1;
                case(funct3_i)
                    `INS_SB: begin
                        case(mem_wr_addr_o[1:0])
                            2'b00: begin
                                mem_wr_data_o = {mem_rd_data_i[31:8],reg2_rd_data_i[7:0]};
                            end
                            2'b01: begin
                                mem_wr_data_o = {mem_rd_data_i[31:16],reg2_rd_data_i[7:0],mem_rd_data_i[7:0]};
                            end
                            2'b10: begin
                                mem_wr_data_o = {mem_rd_data_i[31:24],reg2_rd_data_i[7:0],mem_rd_data_i[15:0]};
                            end
                            2'b11: begin
                                mem_wr_data_o = {reg2_rd_data_i[7:0],mem_rd_data_i[23:0]};
                            end
                        endcase
                    end
                    `INS_SH: begin
                        if(mem_wr_addr_o[1:0] == 2'b00) begin
                            mem_wr_data_o = {mem_rd_data_i[31:16],reg2_rd_data_i[15:0]};
                        end
                        else begin
                            mem_wr_data_o = {reg2_rd_data_i[15:0],mem_rd_data_i[15:0]};
                        end
                    end
                    `INS_SW: begin
                        mem_wr_data_o = reg2_rd_data_i;
                    end
                    default: begin
                        mem_wr_data_o = reg2_rd_data_i;
                    end
                endcase
            end
            `INS_TYPE_LOAD: begin
                reg_wr_en_o = 1'b1;
                case(funct3_i)
                    `INS_LB: begin
                        case(mem_rd_addr_i[1:0])
                            2'b00: begin
                                reg_wr_data_o = {{24{mem_rd_data_i[7]}}, mem_rd_data_i[7:0]};
                            end
                            2'b01: begin
                                reg_wr_data_o = {{24{mem_rd_data_i[15]}}, mem_rd_data_i[15:8]};
                            end
                            2'b10: begin
                                reg_wr_data_o = {{24{mem_rd_data_i[23]}}, mem_rd_data_i[23:16]};
                            end
                            2'b11: begin
                                reg_wr_data_o = {{24{mem_rd_data_i[31]}}, mem_rd_data_i[31:24]};
                            end
                        endcase
                    end
                    `INS_LH: begin
                        if(mem_rd_addr_i[1:0] == 2'b00) begin
                            reg_wr_data_o = {{16{mem_rd_data_i[15]}}, mem_rd_data_i[15:0]};
                        end
                        else begin
                            reg_wr_data_o = {{16{mem_rd_data_i[31]}}, mem_rd_data_i[31:16]};
                        end
                    end
                    `INS_LW: begin
                        reg_wr_data_o = mem_rd_data_i;
                    end
                    `INS_LBU: begin
                        case(mem_rd_addr_i[1:0])
                            2'b00: begin
                                reg_wr_data_o = {{24{1'b0}}, mem_rd_data_i[7:0]};
                            end
                            2'b01: begin
                                reg_wr_data_o = {{24{1'b0}}, mem_rd_data_i[15:8]};
                            end
                            2'b10: begin
                                reg_wr_data_o = {{24{1'b0}}, mem_rd_data_i[23:16]};
                            end
                            2'b11: begin
                                reg_wr_data_o = {{24{1'b0}}, mem_rd_data_i[31:24]};
                            end
                        endcase
                    end
                    `INS_LHU: begin
                        if(mem_rd_addr_i[1:0] == 2'b00) begin
                            reg_wr_data_o = {{16{1'b0}}, mem_rd_data_i[15:0]};
                        end
                        else begin
                            reg_wr_data_o = {{16{1'b0}}, mem_rd_data_i[31:16]};
                        end
                    end
                    default: begin
                        reg_wr_data_o = mem_rd_data_i;
                    end
                endcase
            end
            default: begin
            end
        endcase
    end
    
endmodule
