`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/25 17:24:01
// Design Name: 
// Module Name: csr
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

// control and status register，控制状态寄存器
module csr(

    input   wire                    clk               ,
    input   wire                    rst_n             ,
           
    // 读写信号    
    input   wire                    wr_en_i           , // write enable
    input   wire[`INST_ADDR_BUS]    wr_addr_i         , // write address
    input   wire[`INST_REG_DATA]    wr_data_i         , // write data
    input   wire[`INST_ADDR_BUS]    rd_addr_i         , // read address
    output  reg [`INST_REG_DATA]    rd_data_o         , // read data
    
    // clint (Core Local Interruptor) 读写信号
    input   wire                    clint_wr_en_i     , // clint_write enable
    input   wire[`INST_ADDR_BUS]    clint_wr_addr_i   , // clint_write address
    input   wire[`INST_REG_DATA]    clint_wr_data_i   , // clint_write data
    input   wire[`INST_ADDR_BUS]    clint_rd_addr_i   , // clint_read address
    output  reg [`INST_REG_DATA]    clint_rd_data_o   , // clint_read data
    
    // privilege_mode (特权模式) 读写信号
    input   wire                    wr_privilege_en_i , 
    input   wire[1:0]               wr_privilege_i    , 
    output  wire[1:0]               privileg_o        ,
    
    // to clint
    output  wire[`INST_REG_DATA]    clint_csr_mtvec   , // mtvec
    output  wire[`INST_REG_DATA]    clint_csr_mepc    , // mepc
    output  wire[`INST_REG_DATA]    clint_csr_mstatus   // mstatus
    
    );
    
    // 00:  User
    // 01:  Supervisor
    // 11:  Machine
    reg[1:0]                       privilege_mode;
    
    // csr寄存器定义
    reg[`INST_DB_REG_DATA]         cycle;
    reg[`INST_REG_DATA]            mtvec;
    reg[`INST_REG_DATA]            mcause;
    reg[`INST_REG_DATA]            mepc;
    reg[`INST_REG_DATA]            mie;
    reg[`INST_REG_DATA]            mstatus;
    reg[`INST_REG_DATA]            mscratch;
    
    assign clint_csr_mtvec = mtvec;
    assign clint_csr_mepc = mepc;
    assign clint_csr_mstatus = mstatus;
    
    // cycle counter
    // 复位撤销后就一直计数
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle <= `DB_ZERO_WORD;
        end else begin
            cycle <= cycle + 1'b1;
        end
    end
    
    // privilege_mode
    assign privileg_o = privilege_mode;
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            privilege_mode <= `PRIVILEG_MACHINE;
        end 
        else begin
            if(wr_privilege_en_i == 1'b1) begin
                privilege_mode <= wr_privilege_i;
            end
        end
    end
    
    // write reg
    // 写寄存器操作
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mtvec <= `ZERO_WORD;
            mcause <= `ZERO_WORD;
            mepc <= `ZERO_WORD;
            mie <= `ZERO_WORD;
            mstatus <= `ZERO_WORD;
            mscratch <= `ZERO_WORD;
        end 
        else begin
            // 优先响应ex模块的写操作
            if (wr_en_i == 1'b1) begin
                case (wr_addr_i[11:0])
                    `CSR_MTVEC: begin
                        mtvec <= wr_data_i;
                    end
                    `CSR_MCAUSE: begin
                        mcause <= wr_data_i;
                    end
                    `CSR_MEPC: begin
                        mepc <= wr_data_i;
                    end
                    `CSR_MIE: begin
                        mie <= wr_data_i;
                    end
                    `CSR_MSTATUS: begin
                        mstatus <= wr_data_i;
                    end
                    `CSR_MSCRATCH: begin
                        mscratch <= wr_data_i;
                    end
                    default: begin

                    end
                endcase
            // clint模块写操作
            end 
            else if (clint_wr_en_i == 1'b1) begin
                case (clint_wr_addr_i[11:0])
                    `CSR_MTVEC: begin
                        mtvec <= clint_wr_data_i;
                    end
                    `CSR_MCAUSE: begin
                        mcause <= clint_wr_data_i;
                    end
                    `CSR_MEPC: begin
                        mepc <= clint_wr_data_i;
                    end
                    `CSR_MIE: begin
                        mie <= clint_wr_data_i;
                    end
                    `CSR_MSTATUS: begin
                        mstatus <= clint_wr_data_i;
                    end
                    `CSR_MSCRATCH: begin
                        mscratch <= clint_wr_data_i;
                    end
                    default: begin

                    end
                endcase
            end
        end
    end

    // read reg
    // ex模块读CSR寄存器
    always @ (*) begin
        if ((wr_addr_i[11:0] == rd_addr_i[11:0]) && (wr_en_i == 1'b1)) begin
            rd_data_o = wr_data_i;
        end else begin
            case (rd_addr_i[11:0])
                `CSR_CYCLE: begin
                    rd_data_o = cycle[31:0];
                end
                `CSR_CYCLEH: begin
                    rd_data_o = cycle[63:32];
                end
                `CSR_MTVEC: begin
                    rd_data_o = mtvec;
                end
                `CSR_MCAUSE: begin
                    rd_data_o = mcause;
                end
                `CSR_MEPC: begin
                    rd_data_o = mepc;
                end
                `CSR_MIE: begin
                    rd_data_o = mie;
                end
                `CSR_MSTATUS: begin
                    rd_data_o = mstatus;
                end
                `CSR_MSCRATCH: begin
                    rd_data_o = mscratch;
                end
                default: begin
                    rd_data_o = `ZERO_WORD;
                end
            endcase
        end
    end

    // read reg
    // clint模块读CSR寄存器
    always @ (*) begin
        if ((clint_wr_addr_i[11:0] == clint_rd_addr_i[11:0]) && (clint_wr_en_i == 1'b1)) begin
            clint_rd_data_o = clint_wr_data_i;
        end else begin
            case (clint_rd_addr_i[11:0])
                `CSR_CYCLE: begin
                    clint_rd_data_o = cycle[31:0];
                end
                `CSR_CYCLEH: begin
                    clint_rd_data_o = cycle[63:32];
                end
                `CSR_MTVEC: begin
                    clint_rd_data_o = mtvec;
                end
                `CSR_MCAUSE: begin
                    clint_rd_data_o = mcause;
                end
                `CSR_MEPC: begin
                    clint_rd_data_o = mepc;
                end
                `CSR_MIE: begin
                    clint_rd_data_o = mie;
                end
                `CSR_MSTATUS: begin
                    clint_rd_data_o = mstatus;
                end
                `CSR_MSCRATCH: begin
                    clint_rd_data_o = mscratch;
                end
                default: begin
                    clint_rd_data_o = `ZERO_WORD;
                end
            endcase
        end
    end
    
endmodule