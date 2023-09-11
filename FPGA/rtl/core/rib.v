`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/17 14:43:50
// Design Name: 
// Module Name: rib
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

// rib总线
module rib(
    
    input   wire                    clk         ,
    input   wire                    rst_n       ,
    
    // 主设备0（访存）
    input   wire                    m0_wr_req_i , // 主设备0写请求访问标志
    input   wire                    m0_wr_en_i  , // 主设备0写使能
    input   wire[`INST_ADDR_BUS]    m0_wr_addr_i, // 主设备0写地址
    input   wire[`INST_DATA_BUS]    m0_wr_data_i, // 主设备0写数据
    input   wire                    m0_rd_req_i , // 主设备0读请求访问标志
    input   wire[`INST_ADDR_BUS]    m0_rd_addr_i, // 主设备0读地址
    output  reg [`INST_DATA_BUS]    m0_rd_data_o, // 主设备0读数据
    
    // 主设备1（uart_debug）
    input   wire                    m1_wr_req_i , // 主设备1写请求访问标志
    input   wire                    m1_wr_en_i  , // 主设备1写使能
    input   wire[`INST_ADDR_BUS]    m1_wr_addr_i, // 主设备1写地址
    input   wire[`INST_DATA_BUS]    m1_wr_data_i, // 主设备1写数据
    input   wire                    m1_rd_req_i , // 主设备1读请求访问标志
    input   wire[`INST_ADDR_BUS]    m1_rd_addr_i, // 主设备1读地址
    output  reg [`INST_DATA_BUS]    m1_rd_data_o, // 主设备1读数据
    
    // 主设备2（暂留）
    input   wire                    m2_wr_req_i , // 主设备2写请求访问标志
    input   wire                    m2_wr_en_i  , // 主设备2写使能
    input   wire[`INST_ADDR_BUS]    m2_wr_addr_i, // 主设备2写地址
    input   wire[`INST_DATA_BUS]    m2_wr_data_i, // 主设备2写数据
    input   wire                    m2_rd_req_i , // 主设备2读请求访问标志
    input   wire[`INST_ADDR_BUS]    m2_rd_addr_i, // 主设备2读地址
    output  reg [`INST_DATA_BUS]    m2_rd_data_o, // 主设备2读数据
    
    // 从设备0（rom）
    output  reg                     s0_wr_en_o  , // 从设备0写使能
    output  reg [`INST_ADDR_BUS]    s0_wr_addr_o, // 从设备0写地址
    output  reg [`INST_DATA_BUS]    s0_wr_data_o, // 从设备0写数据
    output  reg [`INST_ADDR_BUS]    s0_rd_addr_o, // 从设备0读地址
    input   wire[`INST_DATA_BUS]    s0_rd_data_i, // 从设备0读数据
    
    // 从设备1（ram）
    output  reg                     s1_wr_en_o  , // 从设备1写使能
    output  reg [`INST_ADDR_BUS]    s1_wr_addr_o, // 从设备1写地址
    output  reg [`INST_DATA_BUS]    s1_wr_data_o, // 从设备1写数据
    output  reg [`INST_ADDR_BUS]    s1_rd_addr_o, // 从设备1读地址
    input   wire[`INST_DATA_BUS]    s1_rd_data_i, // 从设备1读数据
    
    // 从设备2（uart）
    output  reg                     s2_wr_en_o  , // 从设备2写使能
    output  reg [`INST_ADDR_BUS]    s2_wr_addr_o, // 从设备2写地址
    output  reg [`INST_DATA_BUS]    s2_wr_data_o, // 从设备2写数据
    output  reg [`INST_ADDR_BUS]    s2_rd_addr_o, // 从设备2读地址
    input   wire[`INST_DATA_BUS]    s2_rd_data_i, // 从设备2读数据
    
    // 从设备3（gpio）
    output  reg                     s3_wr_en_o  , // 从设备3写使能
    output  reg [`INST_ADDR_BUS]    s3_wr_addr_o, // 从设备3写地址
    output  reg [`INST_DATA_BUS]    s3_wr_data_o, // 从设备3写数据
    output  reg [`INST_ADDR_BUS]    s3_rd_addr_o, // 从设备3读地址
    input   wire[`INST_DATA_BUS]    s3_rd_data_i, // 从设备3读数据
    
    // 从设备4（timer）
    output  reg                     s4_wr_en_o  , // 从设备4写使能
    output  reg [`INST_ADDR_BUS]    s4_wr_addr_o, // 从设备4写地址
    output  reg [`INST_DATA_BUS]    s4_wr_data_o, // 从设备4写数据
    output  reg [`INST_ADDR_BUS]    s4_rd_addr_o, // 从设备4读地址
    input   wire[`INST_DATA_BUS]    s4_rd_data_i, // 从设备4读数据
    
    output  reg                     rib_hold_flag_o  // 暂停流水线标志
    
    );
    
    // 访问地址的最高四位决定要访问的是哪一个设备
    parameter[3:0]  slave_0 = 4'b0000; // 0x0000_0000 ~ 0x0fff_ffff [rom]
    parameter[3:0]  slave_1 = 4'b0001; // 0x1000_0000 ~ 0x1fff_ffff [ram]
    parameter[3:0]  slave_2 = 4'b0010; // 0x2000_0000 ~ 0x2fff_ffff [uart]
    parameter[3:0]  slave_3 = 4'b0011; // 0x3000_0000 ~ 0x3fff_ffff [gpio]
    parameter[3:0]  slave_4 = 4'b0100; // 0x4000_0000 ~ 0x4fff_ffff [timer]
    
    // 主设备授权访问
    parameter[1:0]  grant_master_0 = 2'b00; // 访存
    parameter[1:0]  grant_master_1 = 2'b01; // uart_debug
    parameter[1:0]  grant_master_2 = 2'b10; // 暂留
    
    reg[1:0]                      grant_wr;
    reg[1:0]                      grant_rd;
    reg[`INST_ADDR_BUS]           m0_rd_addr_i_reg;
    reg[`INST_ADDR_BUS]           m1_rd_addr_i_reg;
    reg[`INST_ADDR_BUS]           m2_rd_addr_i_reg;
    
    // 仲裁逻辑，写优先级，优先级从高到低：主设备1，主设备0
    always @ (*) begin
        if(m1_wr_req_i == 1'b1) begin
            grant_wr = grant_master_1;
            rib_hold_flag_o = 1'b1;
        end
        else if(m0_wr_req_i == 1'b1) begin
            grant_wr = grant_master_0;
            rib_hold_flag_o = 1'b0;
        end
        else begin
            grant_wr = grant_master_0;
            rib_hold_flag_o = 1'b0;
        end
    end
    
    // 仲裁逻辑，读优先级，优先级从高到低：主设备0
    always @ (*) begin
        if(m0_rd_req_i == 1'b1) begin
            grant_rd = grant_master_0;
        end
        else begin
            grant_rd = grant_master_0;
        end
    end
    
    // 根据仲裁结果，写对应的从设备
    always @ (*) begin
        s0_wr_en_o = 1'b0;  
        s0_wr_addr_o = `ZERO_WORD;
        s0_wr_data_o = `ZERO_WORD;
        
        s1_wr_en_o = 1'b0;  
        s1_wr_addr_o = `ZERO_WORD;
        s1_wr_data_o = `ZERO_WORD;
        
        s2_wr_en_o = 1'b0;  
        s2_wr_addr_o = `ZERO_WORD;
        s2_wr_data_o = `ZERO_WORD;
        
        s3_wr_en_o = 1'b0;  
        s3_wr_addr_o = `ZERO_WORD;
        s3_wr_data_o = `ZERO_WORD;
        
        s4_wr_en_o = 1'b0;  
        s4_wr_addr_o = `ZERO_WORD;
        s4_wr_data_o = `ZERO_WORD;
        
        // 写相关
        case(grant_wr)
            grant_master_0: begin
                case(m0_wr_addr_i[31:28])
                    slave_0: begin
                        s0_wr_en_o = m0_wr_en_i;  
                        s0_wr_addr_o = {{4'd0}, m0_wr_addr_i[27:0]};
                        s0_wr_data_o = m0_wr_data_i;
                    end
                    slave_1: begin
                        s1_wr_en_o = m0_wr_en_i;  
                        s1_wr_addr_o = {{4'd0}, m0_wr_addr_i[27:0]};
                        s1_wr_data_o = m0_wr_data_i;
                    end
                    slave_2: begin
                        s2_wr_en_o = m0_wr_en_i;  
                        s2_wr_addr_o = {{4'd0}, m0_wr_addr_i[27:0]};
                        s2_wr_data_o = m0_wr_data_i;
                    end
                    slave_3: begin
                        s3_wr_en_o = m0_wr_en_i;  
                        s3_wr_addr_o = {{4'd0}, m0_wr_addr_i[27:0]};
                        s3_wr_data_o = m0_wr_data_i;
                    end
                    slave_4: begin
                        s4_wr_en_o = m0_wr_en_i;  
                        s4_wr_addr_o = {{4'd0}, m0_wr_addr_i[27:0]};
                        s4_wr_data_o = m0_wr_data_i;
                    end
                    default: begin
                    end
                endcase
            end
            grant_master_1: begin
                case(m1_wr_addr_i[31:28])
                    slave_0: begin
                        s0_wr_en_o = m1_wr_en_i;  
                        s0_wr_addr_o = {{4'd0}, m1_wr_addr_i[27:0]};
                        s0_wr_data_o = m1_wr_data_i;
                    end
                    slave_1: begin
                        s1_wr_en_o = m1_wr_en_i;  
                        s1_wr_addr_o = {{4'd0}, m1_wr_addr_i[27:0]};
                        s1_wr_data_o = m1_wr_data_i;
                    end
                    slave_2: begin
                        s2_wr_en_o = m1_wr_en_i;  
                        s2_wr_addr_o = {{4'd0}, m1_wr_addr_i[27:0]};
                        s2_wr_data_o = m1_wr_data_i;
                    end
                    slave_3: begin
                        s3_wr_en_o = m1_wr_en_i;  
                        s3_wr_addr_o = {{4'd0}, m1_wr_addr_i[27:0]};
                        s3_wr_data_o = m1_wr_data_i;
                    end
                    slave_4: begin
                        s4_wr_en_o = m1_wr_en_i;  
                        s4_wr_addr_o = {{4'd0}, m1_wr_addr_i[27:0]};
                        s4_wr_data_o = m1_wr_data_i;
                    end
                    default: begin
                    end
                endcase
            end
            grant_master_2: begin
                case(m2_wr_addr_i[31:28])
                    slave_0: begin
                        s0_wr_en_o = m2_wr_en_i;  
                        s0_wr_addr_o = {{4'd0}, m2_wr_addr_i[27:0]};
                        s0_wr_data_o = m2_wr_data_i;
                    end
                    slave_1: begin
                        s1_wr_en_o = m2_wr_en_i;  
                        s1_wr_addr_o = {{4'd0}, m2_wr_addr_i[27:0]};
                        s1_wr_data_o = m2_wr_data_i;
                    end
                    slave_2: begin
                        s2_wr_en_o = m2_wr_en_i;  
                        s2_wr_addr_o = {{4'd0}, m2_wr_addr_i[27:0]};
                        s2_wr_data_o = m2_wr_data_i;
                    end
                    slave_3: begin
                        s3_wr_en_o = m2_wr_en_i;  
                        s3_wr_addr_o = {{4'd0}, m2_wr_addr_i[27:0]};
                        s3_wr_data_o = m2_wr_data_i;
                    end
                    slave_4: begin
                        s4_wr_en_o = m2_wr_en_i;  
                        s4_wr_addr_o = {{4'd0}, m2_wr_addr_i[27:0]};
                        s4_wr_data_o = m2_wr_data_i;
                    end
                    default: begin
                    end
                endcase
            end
            default: begin
            end
        endcase
    end
    
    always @ (posedge clk) begin
        m0_rd_addr_i_reg <= m0_rd_addr_i;
        m1_rd_addr_i_reg <= m1_rd_addr_i;
        m2_rd_addr_i_reg <= m2_rd_addr_i;
    end
    
    always @ (*) begin
        m0_rd_data_o = `ZERO_WORD;
        m1_rd_data_o = `ZERO_WORD;
        m2_rd_data_o = `ZERO_WORD;
        case(grant_rd)
            grant_master_0: begin
                case(m0_rd_addr_i_reg[31:28])
                    slave_0: begin
                        m0_rd_data_o = s0_rd_data_i;
                    end
                    slave_1: begin
                        m0_rd_data_o = s1_rd_data_i;
                    end
                    slave_2: begin
                        m0_rd_data_o = s2_rd_data_i;
                    end
                    slave_3: begin
                        m0_rd_data_o = s3_rd_data_i;
                    end
                    slave_4: begin
                        m0_rd_data_o = s4_rd_data_i;
                    end
                    default: begin
                    end
                endcase
            end
            grant_master_1: begin
                case(m1_rd_addr_i_reg[31:28])
                    slave_0: begin
                        m1_rd_data_o = s0_rd_data_i;
                    end
                    slave_1: begin
                        m1_rd_data_o = s1_rd_data_i;
                    end
                    slave_2: begin
                        m1_rd_data_o = s2_rd_data_i;
                    end
                    slave_3: begin
                        m1_rd_data_o = s3_rd_data_i;
                    end
                    slave_4: begin
                        m1_rd_data_o = s4_rd_data_i;
                    end
                    default: begin
                    end
                endcase
            end
            grant_master_2: begin
                case(m2_rd_addr_i_reg[31:28])
                    slave_0: begin
                        m2_rd_data_o = s0_rd_data_i;
                    end
                    slave_1: begin
                        m2_rd_data_o = s1_rd_data_i;
                    end
                    slave_2: begin
                        m2_rd_data_o = s2_rd_data_i;
                    end
                    slave_3: begin
                        m2_rd_data_o = s3_rd_data_i;
                    end
                    slave_4: begin
                        m2_rd_data_o = s4_rd_data_i;
                    end
                    default: begin
                    end
                endcase
            end
            default: begin
            end
        endcase
    end
    
    // 根据仲裁结果，读对应的从设备
    always @ (*) begin
        s0_rd_addr_o = `ZERO_WORD;
        s1_rd_addr_o = `ZERO_WORD;
        s2_rd_addr_o = `ZERO_WORD;
        s3_rd_addr_o = `ZERO_WORD;
        s4_rd_addr_o = `ZERO_WORD;
        case(grant_rd)
            grant_master_0: begin
                case(m0_rd_addr_i[31:28])
                    slave_0: begin
                        s0_rd_addr_o = {{4'd0}, m0_rd_addr_i[27:0]};
                    end
                    slave_1: begin
                        s1_rd_addr_o = {{4'd0}, m0_rd_addr_i[27:0]};
                    end
                    slave_2: begin
                        s2_rd_addr_o = {{4'd0}, m0_rd_addr_i[27:0]};
                    end
                    slave_3: begin
                        s3_rd_addr_o = {{4'd0}, m0_rd_addr_i[27:0]};
                    end
                    slave_4: begin
                        s4_rd_addr_o = {{4'd0}, m0_rd_addr_i[27:0]};
                    end
                    default: begin
                    end
                endcase
            end
            grant_master_1: begin
                case(m1_rd_addr_i[31:28])
                    slave_0: begin
                        s0_rd_addr_o = {{4'd0}, m1_rd_addr_i[27:0]};
                    end
                    slave_1: begin
                        s1_rd_addr_o = {{4'd0}, m1_rd_addr_i[27:0]};
                    end
                    slave_2: begin
                        s2_rd_addr_o = {{4'd0}, m1_rd_addr_i[27:0]};
                    end
                    slave_3: begin
                        s3_rd_addr_o = {{4'd0}, m1_rd_addr_i[27:0]};
                    end
                    slave_4: begin
                        s4_rd_addr_o = {{4'd0}, m1_rd_addr_i[27:0]};
                    end
                    default: begin
                    end
                endcase
            end
            grant_master_2: begin
                case(m2_rd_addr_i[31:28])
                    slave_0: begin
                        s0_rd_addr_o = {{4'd0}, m2_rd_addr_i[27:0]};
                    end
                    slave_1: begin
                        s1_rd_addr_o = {{4'd0}, m2_rd_addr_i[27:0]};
                    end
                    slave_2: begin
                        s2_rd_addr_o = {{4'd0}, m2_rd_addr_i[27:0]};
                    end
                    slave_3: begin
                        s3_rd_addr_o = {{4'd0}, m2_rd_addr_i[27:0]};
                    end
                    slave_4: begin
                        s4_rd_addr_o = {{4'd0}, m2_rd_addr_i[27:0]};
                    end
                    default: begin
                    end
                endcase
            end
            default: begin
            end
        endcase
    end
    
endmodule
