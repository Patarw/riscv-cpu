`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/27 10:29:50
// Design Name: 
// Module Name: clint
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

// core local interruptor module，核心中断管理、仲裁模块
module clint(
    input    wire                    clk                 ,
    input    wire                    rst_n               ,
    
    input    wire[`INST_DATA_BUS]    ins_i               ,     
    input    wire[`INST_ADDR_BUS]    ins_addr_i          , 
    
    // from ex
    input    wire                    jump_flag_i         ,
    input    wire[`INST_ADDR_BUS]    jump_addr_i         ,
    input    wire                    div_req_i           , // 除法操作执行请求信号
    input    wire                    div_busy_i          , // 除法操作忙信号
    
    // csr读写信号
    output   reg                     wr_en_o             , // csr write enable
    output   reg [`INST_ADDR_BUS]    wr_addr_o           , // csr write address
    output   reg [`INST_REG_DATA]    wr_data_o           , // csr write data
    output   reg [`INST_ADDR_BUS]    rd_addr_o           , // csr read address
    input    wire[`INST_REG_DATA]    rd_data_i           , // csr read data
    
    // from csr 
    input    wire[`INST_REG_DATA]    csr_mtvec           , // mtvec寄存器
    input    wire[`INST_REG_DATA]    csr_mepc            , // mepc寄存器
    input    wire[`INST_REG_DATA]    csr_mstatus         , // mstatus寄存器
    input    wire[1:0]               privileg_i          ,
    output   reg                     wr_privilege_en_o   , 
    output   reg [1:0]               wr_privilege_o      , 
    
    input    wire[`INT_BUS]          int_flag_i          , // 异步中断信号
    output   wire                    clint_busy_o        , // 中断忙信号
    output   reg [`INST_ADDR_BUS]    int_addr_o          , // 中断入口地址
    output   reg                     int_assert_o          // 中断标志
    
    );
    
    // 中断状态定义
    localparam INT_IDLE            = 3'b001;
    localparam INT_SYNC_ASSERT     = 3'b010;
    localparam INT_ASYNC_ASSERT    = 3'b011;
    localparam INT_MRET            = 3'b100;

    // 写CSR寄存器状态定义
    localparam CSR_IDLE            = 3'b001;
    localparam CSR_MSTATUS         = 3'b010;
    localparam CSR_MEPC            = 3'b011;
    localparam CSR_MSTATUS_MRET    = 3'b100;
    localparam CSR_MCAUSE          = 3'b101;
    
    reg[2:0]                    int_state;
    reg[2:0]                    csr_state;
    reg[`INST_REG_DATA]         cause;
    reg[`INST_ADDR_BUS]         ins_addr;
    reg[`INST_ADDR_BUS]         div_ins_addr;
    
    // 如果是除法指令，则保存除法指令的地址
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            div_ins_addr <= `ZERO_WORD;
        end
        else if (ins_i == `INS_DIV || ins_i == `INS_DIVU || ins_i == `INS_REM || ins_i == `INS_REMU) begin
            div_ins_addr <= ins_addr_i;
        end
        else begin
            div_ins_addr <= div_ins_addr;
        end
    end
    
    assign clint_busy_o = ((int_state != INT_IDLE) | (csr_state != CSR_IDLE)) ? 1'b1 : 1'b0;
    
    // 中断仲裁逻辑
    always @ (*) begin
        if (!rst_n) begin
            int_state = INT_IDLE;
        end
        // 同步中断
        //if (ins_i == `INS_ECALL || ins_i == `INS_EBREAK || (ins_i[6:0] == `INS_TYPE_CSR && privileg_i < `PRIVILEG_MACHINE)) begin
        else begin
            if (ins_i == `INS_ECALL || ins_i == `INS_EBREAK) begin
                // 如果执行阶段的指令为除法指令或者跳转指令，则先不处理同步中断
                if (div_req_i != 1'b1 && jump_flag_i != 1'b1) begin
                    int_state = INT_SYNC_ASSERT;
                end 
                else begin
                    int_state = INT_IDLE;
                end
            end 
            // 异步中断
            else if (int_flag_i != `INT_NONE && csr_mstatus[3] == 1'b1) begin
                int_state = INT_ASYNC_ASSERT;
            end 
            else if (ins_i == `INS_MRET) begin
                int_state = INT_MRET;
            end 
            else begin
                int_state = INT_IDLE;
            end
        end
    end
    
    // 写CSR寄存器状态切换
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            csr_state <= CSR_IDLE;
            cause <= `ZERO_WORD;
            ins_addr <= `ZERO_WORD;
        end 
        else begin
            case (csr_state)
                CSR_IDLE: begin
                    // 同步中断
                    if (int_state == INT_SYNC_ASSERT) begin
                        csr_state <= CSR_MEPC;
                        // 在中断处理函数里会将中断返回地址加4
                        ins_addr <= ins_addr_i;
                        
                        // Environment call from M-mode
                        //if (ins_i == `INS_ECALL && privileg_i == `PRIVILEG_MACHINE) begin
                        if (ins_i == `INS_ECALL) begin
                            cause <= 32'd11;
                        end
                        // Environment call from U-mode
                        //else if (ins_i == `INS_ECALL && privileg_i == `PRIVILEG_USER) begin
                        //    cause <= 32'd8;
                        //end
                        // Breakpoint
                        else if (ins_i == `INS_EBREAK) begin
                            cause <= 32'd3;
                        end
                        // Illegal Instruction
                        //else if (ins_i[6:0] == `INS_TYPE_CSR && privileg_i < `PRIVILEG_MACHINE) begin
                        //    cause <= 32'd2;
                        //end
                        else begin
                            cause <= 32'd10;
                        end
                    end 
                    // 异步中断
                    else if (int_state == INT_ASYNC_ASSERT) begin
                        // 定时器中断    
                        if (int_flag_i & `INT_TIMER) begin
                            cause <= 32'h80000007;
                        end
                        // uart中断，目前这个只用于测试
                        else if (int_flag_i & `INT_UART_REV) begin
                            cause <= 32'h8000000b;
                        end
                        else begin
                            cause <= 32'h8000000a;
                        end
                        
                        csr_state <= CSR_MEPC;
                        if (jump_flag_i == 1'b1) begin
                            ins_addr <= jump_addr_i;
                        end
                        // 异步中断可以中断除法指令的执行，中断处理完再重新执行除法指令
                        else if (div_req_i == 1'b1 || div_busy_i == 1'b1) begin
                            ins_addr <= div_ins_addr;
                        end 
                        else begin
                            ins_addr <= ins_addr_i;
                        end
                    end 
                    // 中断返回
                    else if (int_state == INT_MRET) begin
                        csr_state <= CSR_MSTATUS_MRET;
                    end
                end
                CSR_MEPC: begin
                    csr_state <= CSR_MSTATUS;
                end
                CSR_MSTATUS: begin
                    csr_state <= CSR_MCAUSE;
                end
                CSR_MCAUSE: begin
                    csr_state <= CSR_IDLE;
                end
                CSR_MSTATUS_MRET: begin
                    csr_state <= CSR_IDLE;
                end
                default: begin
                    csr_state <= CSR_IDLE;
                end
            endcase
        end
    end
    
    // 发出中断信号前，先写几个CSR寄存器
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_en_o <= 1'b0;
            wr_addr_o <= `ZERO_WORD;
            wr_data_o <= `ZERO_WORD;
            wr_privilege_en_o <= 1'b0;
            wr_privilege_o <= `PRIVILEG_MACHINE;
        end 
        else begin
            case (csr_state)
                // 将mepc寄存器的值设为当前指令地址
                CSR_MEPC: begin
                    wr_en_o <= 1'b1;
                    wr_addr_o <= {20'h0, `CSR_MEPC};
                    wr_data_o <= ins_addr;
                end
                // 写中断产生的原因
                CSR_MCAUSE: begin
                    wr_en_o <= 1'b1;
                    wr_addr_o <= {20'h0, `CSR_MCAUSE};
                    wr_data_o <= cause;
                end
                // 关闭全局中断，修改特权级别为machine，并将当前特权级别存入MPP中
                CSR_MSTATUS: begin
                    wr_privilege_en_o <= 1'b1;
                    wr_privilege_o <= `PRIVILEG_MACHINE;
                    wr_en_o <= 1'b1;
                    wr_addr_o <= {20'h0, `CSR_MSTATUS};
                    wr_data_o <= {csr_mstatus[31:13], privileg_i, csr_mstatus[10:4], 1'b0, csr_mstatus[2:0]};
                    
                end
                // 中断返回，修改特权级别为MPP
                CSR_MSTATUS_MRET: begin
                    wr_privilege_en_o <= 1'b1;
                    wr_privilege_o <= csr_mstatus[12:11]; // MPP
                    wr_en_o <= 1'b1;
                    wr_addr_o <= {20'h0, `CSR_MSTATUS};
                    wr_data_o <= {csr_mstatus[31:4], csr_mstatus[7], csr_mstatus[2:0]};
                end
                default: begin
                    wr_privilege_en_o <= 1'b0;
                    wr_privilege_o <= `PRIVILEG_MACHINE;
                    wr_en_o <= 1'b0;
                    wr_addr_o <= `ZERO_WORD;
                    wr_data_o <= `ZERO_WORD;
                end
            endcase
        end
    end
    
    // 发出中断信号给cu模块
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            int_assert_o <= 1'b0;
            int_addr_o <= `ZERO_WORD;
        end 
        else begin
            case (csr_state)
                // 发出中断进入信号.写完mcause寄存器才能发
                CSR_MCAUSE: begin
                    int_assert_o <= 1'b1;
                    int_addr_o <= csr_mtvec;
                end
                // 发出中断返回信号
                CSR_MSTATUS_MRET: begin
                    int_assert_o <= 1'b1;
                    int_addr_o <= csr_mepc;
                end
                default: begin
                    int_assert_o <= 1'b0;
                    int_addr_o <= `ZERO_WORD;
                end
            endcase
        end
    end
    
endmodule

