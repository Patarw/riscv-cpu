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
            
    input   wire[`INST_REG_DATA]    reg1_rd_data_i      , 
    input   wire[`INST_REG_DATA]    reg2_rd_data_i      ,
            
    input   wire[`INST_REG_ADDR]    reg_wr_addr_i       ,
    
    input   wire[`INST_REG_DATA]    imm_i               ,  
            
    output  wire                    reg_wr_en_o         ,
    output  wire[`INST_REG_ADDR]    reg_wr_addr_o       ,
    output  wire[`INST_REG_DATA]    reg_wr_data_o       ,
    output  wire                    jump_flag           ,
    output  wire[`INST_REG_DATA]    jump_addr           ,
    output  wire                    hold_flag           ,

    // 内存相关引脚
    input   wire[`INST_DATA_BUS]    mem_rd_data_i       ,
    output  wire                    mem_wr_en_o         , 
    output  wire[`INST_ADDR_BUS]    mem_wd_addr_o       , 
    output  reg[`INST_DATA_BUS]     mem_wr_data_o       
    
    );
    
    wire[`INST_REG_DATA]     alu_res;
    wire[3:0]                alu_op_code;
    wire                     pc_flag;
    wire                     pc_imm_flag;
    wire                     imm_flag;
    wire                     pc_4_flag;
    wire                     alu_zero_flag;
    wire                     alu_sign_flag;
    wire                     alu_overflow_flag;
    wire                     load_ins_flag;
    wire[`INST_REG_DATA]     alu_data1_i;
    wire[`INST_REG_DATA]     alu_data2_i;
    
    reg[`INST_DATA_BUS]      mem_rd_data;
    wire[2:0]       funct3;
    assign funct3 = ins_i[14:12];
    
    // 访存相关
    assign mem_wd_addr_o = alu_res;
    
    always @ (*) begin
        case(funct3)
            `INS_SB: begin
                case(mem_wd_addr_o[1:0])
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
                if(mem_wd_addr_o[1:0] == 2'b00) begin
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
    
    always @ (*) begin
        case(funct3)
            `INS_LB: begin
                case(mem_wd_addr_o[1:0])
                    2'b00: begin
                        mem_rd_data = {{24{mem_rd_data_i[7]}}, mem_rd_data_i[7:0]};
                    end
                    2'b01: begin
                        mem_rd_data = {{24{mem_rd_data_i[15]}}, mem_rd_data_i[15:8]};
                    end
                    2'b10: begin
                        mem_rd_data = {{24{mem_rd_data_i[23]}}, mem_rd_data_i[23:16]};
                    end
                    2'b11: begin
                        mem_rd_data = {{24{mem_rd_data_i[31]}}, mem_rd_data_i[31:24]};
                    end
                endcase
            end
            `INS_LH: begin
                if(mem_wd_addr_o[1:0] == 2'b00) begin
                    mem_rd_data = {{16{mem_rd_data_i[15]}}, mem_rd_data_i[15:0]};
                end
                else begin
                    mem_rd_data = {{16{mem_rd_data_i[31]}}, mem_rd_data_i[31:16]};
                end
            end
            `INS_LW: begin
                mem_rd_data = mem_rd_data_i;
            end
            `INS_LBU: begin
                case(mem_wd_addr_o[1:0])
                    2'b00: begin
                        mem_rd_data = {{24{1'b0}}, mem_rd_data_i[7:0]};
                    end
                    2'b01: begin
                        mem_rd_data = {{24{1'b0}}, mem_rd_data_i[15:8]};
                    end
                    2'b10: begin
                        mem_rd_data = {{24{1'b0}}, mem_rd_data_i[23:16]};
                    end
                    2'b11: begin
                        mem_rd_data = {{24{1'b0}}, mem_rd_data_i[31:24]};
                    end
                endcase
            end
            `INS_LHU: begin
                if(mem_wd_addr_o[1:0] == 2'b00) begin
                    mem_rd_data = {{16{1'b0}}, mem_rd_data_i[15:0]};
                end
                else begin
                    mem_rd_data = {{16{1'b0}}, mem_rd_data_i[31:16]};
                end
            end
            default: begin
                mem_rd_data = mem_rd_data_i;
            end
        endcase
    end
    
    //选择输入的是pc值还是寄存器数据
    assign alu_data1_i = (pc_flag) ? ins_addr_i : reg1_rd_data_i;
    
    //选择输入的是立即数还是寄存器数据
    assign alu_data2_i = (imm_flag) ? imm_i : reg2_rd_data_i;
    
    assign reg_wr_addr_o = reg_wr_addr_i;
    assign reg_wr_data_o = (load_ins_flag) ? mem_rd_data : ((pc_4_flag) ? (ins_addr_i + 4'd4) : alu_res);
    assign jump_addr = (pc_imm_flag) ? ($signed(ins_addr_i) + $signed(imm_i)) : alu_res;
    
    // 控制单元例化
    cu u_cu(
        .ins_i               (ins_i), 
        .ins_addr_i          (ins_addr_i), 
        .alu_zero_flag       (alu_zero_flag),
        .alu_sign_flag       (alu_sign_flag),
        .alu_overflow_flag   (alu_overflow_flag),
        .alu_op_code         (alu_op_code),
        .imm_flag            (imm_flag),
        .pc_flag             (pc_flag),
        .pc_4_flag           (pc_4_flag),
        .pc_imm_flag         (pc_imm_flag),
        .jump_flag           (jump_flag),
        .hold_flag           (hold_flag),
        .load_ins_flag       (load_ins_flag),
        .reg_wr_en_o         (reg_wr_en_o),
        .mem_wr_en_o         (mem_wr_en_o)
    );
    
    // 运算单元例化
    alu u_alu(
        .alu_data1_i         (alu_data1_i), 
        .alu_data2_i         (alu_data2_i),
        .alu_op_code         (alu_op_code),
        .alu_data_o          (alu_res),
        .alu_zero_flag       (alu_zero_flag),
        .alu_sign_flag       (alu_sign_flag),
        .alu_overflow_flag   (alu_overflow_flag)
    );
    
endmodule
