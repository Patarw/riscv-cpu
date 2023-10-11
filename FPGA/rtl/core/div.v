`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/20 10:29:50
// Design Name: 
// Module Name: div
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

// 除法单元，33个时钟周期完成计算
module div(

    input      wire                    clk                 ,
    input      wire                    rst_n               ,

    input      wire[`INST_REG_DATA]    div_data1_i         , 
    input      wire[`INST_REG_DATA]    div_data2_i         ,
    input      wire[2:0]               div_op_code_i       ,
    input      wire                    div_req_i           , // 除法操作执行请求信号
    input      wire[`INST_REG_ADDR]    div_reg_wr_addr_i   , // 除法指令结果要写的寄存器地址
    
    output     reg [`INST_REG_ADDR]    div_reg_wr_addr_o   ,
    output     reg                     div_busy_o          , // 除法操作忙信号
    output     reg                     div_res_ready_o     , // div结果就绪信号
    output     reg [`INST_REG_DATA]    div_res_o             
    
    );
    
    localparam IDLE = 2'd0,
               BUSY = 2'd1;
    
    reg[`INST_DB_REG_DATA]    div_data1;
    reg[`INST_DB_REG_DATA]    div_data2; 
    reg                       div_data1_sign;
    reg                       div_data2_sign; 
    reg[2:0]                  div_op_code;
    reg[1:0]                  div_state; // 状态机
    reg[5:0]                  cnt;       // 计数器
    reg[`INST_REG_DATA]       div_data2_temp;
    
    // 除法操作忙信号 div_busy_o
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            div_busy_o <= 1'b0;
        end
        else if(div_req_i == 1'b1) begin
            div_busy_o <= 1'b1;
        end
        else if(div_state == IDLE) begin
            div_busy_o <= 1'b0;
        end
        else begin
            div_busy_o <= div_busy_o;
        end
    end 
    
    // 计数信号 cnt
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt <= 6'd0;
        end
        else if(div_state == BUSY) begin
            cnt <= cnt + 1'b1;
        end
        else begin
            cnt <= 6'd0;
        end
    end 
    
    // 状态机 div_state
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            div_state <= IDLE;
            div_res_ready_o <= 1'b0;
            div_res_o <= `ZERO_WORD;
        end
        else begin
            case(div_state)
                IDLE: begin
                    div_res_ready_o <= 1'b0;
                    div_res_o <= `ZERO_WORD;
                    if(div_req_i == 1'b1) begin
                        div_state <= BUSY;
                        div_op_code <= div_op_code_i;
                        div_reg_wr_addr_o <= div_reg_wr_addr_i;
                        div_data1_sign <= div_data1_i[31];
                        div_data2_sign <= div_data2_i[31];
                        div_data2_temp <= div_data2_i;
                        case(div_op_code_i)
                            `DIV, `REM: begin
                                div_data1 <= {32'h0, div_data1_i[31] ? (~div_data1_i + 1'b1) : div_data1_i};
                                div_data2 <= {div_data2_i[31] ? (~div_data2_i + 1'b1) : div_data2_i, 32'h0};
                            end
                            `DIVU, `REMU: begin
                                div_data1 <= {32'h0, div_data1_i};
                                div_data2 <= {div_data2_i, 32'h0};
                            end
                            default: begin
                                div_data1 <= {32'h0, div_data1_i};
                                div_data2 <= {div_data2_i, 32'h0};
                            end
                        endcase
                    end
                    else begin
                        div_state <= div_state;
                    end
                end
                // 开始div计算, 计算完毕后div_data1高32位为余数，低32位为商 
                BUSY: begin
                    if(cnt == 6'd32) begin
                        div_state <= IDLE;
                        div_res_ready_o <= 1'b1;
                        if (div_data2_temp == `ZERO_WORD && (div_op_code == `DIV || div_op_code == `DIVU)) begin
                            div_res_o <= 32'hffffffff;
                        end
                        else begin
                            case(div_op_code)
                                `DIV: begin
                                    if(div_data1_sign ^ div_data2_sign) begin
                                        div_res_o <= ~div_data1[31:0] + 1'b1;
                                    end
                                    else begin
                                        div_res_o <= div_data1[31:0];
                                    end
                                end
                                `DIVU: begin
                                    div_res_o <= div_data1[31:0];
                                end
                                `REM: begin
                                    div_res_o <= div_data1_sign ? (~div_data1[63:32] + 1'b1) : div_data1[63:32];
                                end
                                `REMU: begin
                                    div_res_o <= div_data1[63:32];
                                end
                                default: begin
                                    div_res_o <= `ZERO_WORD;
                                end
                            endcase
                        end
                    end
                    else begin
                        if({div_data1[62:0], 1'b0} >= div_data2) begin
                            div_data1 <= {div_data1[62:0], 1'b0} - div_data2 + 1'b1;
                        end
                        else begin
                            div_data1 <= {div_data1[62:0], 1'b0};
                        end
                    end
                end
            endcase
        end
    end 
    
endmodule