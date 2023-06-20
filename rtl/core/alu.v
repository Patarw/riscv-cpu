`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/16 14:43:50
// Design Name: 
// Module Name: alu
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

// 运算单元
module alu(

    input      wire[`INST_REG_DATA]    alu_data1_i         , 
    input      wire[`INST_REG_DATA]    alu_data2_i         ,
    input      wire[3:0]               alu_op_code         ,
    
    output     reg[`INST_REG_DATA]     alu_data_o          ,
    output     reg                     alu_zero_flag       , // 零标志位
    output     reg                     alu_sign_flag       , // 符号标志位，1为复数，0为正数或0
    output     reg                     alu_overflow_flag     // 溢出标志位
    
    );
    
    always @ (*) begin
        alu_zero_flag = !(|alu_data_o); 
        alu_sign_flag = alu_data_o[31];
        alu_overflow_flag = ((alu_op_code == `ALU_ADD & ~alu_data1_i[31] & ~alu_data2_i[31] & alu_data_o[31])
                                |(alu_op_code == `ALU_ADD & alu_data1_i[31] & alu_data2_i[31] & ~alu_data_o[31])
                                |(alu_op_code == `ALU_SUB & ~alu_data1_i[31] & alu_data2_i[31] & alu_data_o[31])
                                |(alu_op_code == `ALU_SUB & alu_data1_i[31] & ~alu_data2_i[31] & ~alu_data_o[31]));
    end
    always @ (*) begin
        case(alu_op_code)
            `ALU_ADD: begin
                alu_data_o = $signed(alu_data1_i) + $signed(alu_data2_i); // 和
            end
            `ALU_SUB: begin
                alu_data_o = $signed(alu_data1_i) - $signed(alu_data2_i); // 差
            end
            `ALU_AND: begin
                alu_data_o = alu_data1_i & alu_data2_i; // 与
            end
            `ALU_OR: begin
                alu_data_o = alu_data1_i | alu_data2_i; // 或
            end
            `ALU_XOR: begin
                alu_data_o = alu_data1_i ^ alu_data2_i; // 异或
            end
            `ALU_SLTU: begin
                alu_data_o = (alu_data1_i < alu_data2_i) ? 1 : 0; // 无符号数小于置1
            end
            `ALU_SLT: begin
                alu_data_o = ($signed(alu_data1_i) < $signed(alu_data2_i)) ? 1 : 0; // 有符号数小于置1
            end
            `ALU_SLL: begin
                alu_data_o = alu_data1_i << alu_data2_i; // 逻辑左移
            end
            `ALU_SRL: begin
                alu_data_o = alu_data1_i >> alu_data2_i; // 逻辑右移
            end
            `ALU_SRA: begin
                alu_data_o = $signed(alu_data1_i) >>> alu_data2_i; // 算术右移
            end  
            default: begin
                alu_data_o = alu_data1_i; 
            end            
        endcase
    end
    
endmodule


