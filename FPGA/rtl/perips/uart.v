`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/27 12:02:53
// Design Name: 
// Module Name: uart
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

// 串口模块，默认波特率为19200
module uart(

    input   wire                        clk                 ,
    input   wire                        rst_n               ,
    
    input   wire                        uart_rx             , // uart接收引脚
    output  reg                         uart_tx             , // uart发送引脚
    
    input   wire                        wr_en_i             , // uart寄存器写使能信号
    input   wire[`INST_ADDR_BUS]        wr_addr_i           , // uart寄存器写地址
    input   wire[`INST_DATA_BUS]        wr_data_i           , // uart写数据
    input   wire[`INST_ADDR_BUS]        rd_addr_i           , // uart寄存器读地址
    output  reg [`INST_DATA_BUS]        rd_data_o           , // uart读数据
    
    // 中断信号
    output  wire                        uart_int_flag_o    

    );
    
    // 寄存器地址定义
    parameter   UART_CTRL = 4'd0,
                UART_TX_DATA_BUF= 4'd4,
                UART_RX_DATA_BUF= 4'd8;
    // addr: 0x0
    // 低两位（1:0）为TI和RI
    // [1]: TI，发送完成中断位，该位在数据发送完成时被设置为高电平
    // [0]: RI，接收完成中断位，该位在数据接收完成时被设置为高电平
    reg[31:0]   uart_ctrl;
    
    assign uart_int_flag_o = 1'b0;
    
    // addr: 0x4
    // 发送数据寄存器
    reg[31:0]   uart_tx_data_buf;
    
    // addr: 0x8
    // 接收数据寄存器
    reg[31:0]   uart_rx_data_buf;
    
    parameter   BAUD_CNT_MAX = `CLK_FREQ / `UART_BPS;
    parameter   IDLE = 4'd0,
                BEGIN= 4'd1,
                RX_BYTE = 4'd2,
                TX_BYTE = 4'd3,
                END  = 4'd4;
    
    wire                        uart_rx_temp;
    reg                         uart_rx_delay; // rx延迟后的输入
    reg[3:0]                    uart_rx_state; // rx状态机
    reg[12:0]                   rx_baud_cnt;   // rx计数器
    reg[3:0]                    rx_bit_cnt;    // rx比特计数
    
    reg[3:0]                    uart_tx_state; // rx状态机
    reg[12:0]                   tx_baud_cnt;   // rx计数器
    reg[4:0]                    tx_bit_cnt;    // rx比特计数
    reg                         tx_data_rd;    // 发送数据就绪信号
    reg[31:0]                   uart_rx_data_buf_temp;
    reg[`INST_ADDR_BUS]         rd_addr_reg;
    
    
    // 读写寄存器，write before read
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            uart_ctrl <= `ZERO_WORD;
            uart_tx_data_buf <= `ZERO_WORD;
        end
        else begin
            if(wr_en_i == 1'b1) begin
                case(wr_addr_i[3:0])
                    UART_CTRL: begin
                        // 软件只能将TI和RI置0，无法将其置1
                        uart_ctrl <= wr_data_i;
                    end
                    UART_TX_DATA_BUF: begin
                        uart_tx_data_buf <= wr_data_i;
                    end
                endcase
            end
            if(uart_tx_state == END && tx_baud_cnt == 1) begin
                uart_ctrl[1] <= 1'b1; // TI置1，代表发送完毕，需要软件置0
            end
            if(uart_rx_state == END && rx_baud_cnt == 1) begin
                uart_ctrl[0] <= 1'b1; // RI置1，代表接收完毕，需要软件置0
            end
            rd_addr_reg <= rd_addr_i;
        end
    end
    
    always @ (*) begin
        case(rd_addr_reg[3:0])
            UART_CTRL: begin
                rd_data_o = uart_ctrl;
            end
            UART_TX_DATA_BUF: begin
                rd_data_o = uart_tx_data_buf;
            end
            UART_RX_DATA_BUF: begin
                rd_data_o = uart_rx_data_buf;
            end
            default: begin
                rd_data_o = `ZERO_WORD;
            end
        endcase
    end
    
    /* TX发送模块 */
    
    // tx数据就绪信号 tx_data_rd
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tx_data_rd <= 1'b0;  
        end
        else if(wr_en_i == 1'b1 && wr_addr_i[3:0] == UART_TX_DATA_BUF) begin
            tx_data_rd <= 1'b1;
        end
        else if(uart_tx_state == END && tx_baud_cnt == 1) begin
            tx_data_rd <= 1'b0;
        end
        else begin
            tx_data_rd <= tx_data_rd;
        end
    end
    
    // tx_baud_cnt计数
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            tx_baud_cnt <= 13'd0;
        end
        else if(uart_tx_state == IDLE || tx_baud_cnt == BAUD_CNT_MAX - 1) begin
            tx_baud_cnt <= 13'd0;
        end
        else begin
            tx_baud_cnt <= tx_baud_cnt + 1'b1;
        end
    end
    
    // TX发送模块
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            uart_tx_state <= IDLE;
            tx_bit_cnt <= 5'd0;
            uart_tx <= 1'b1;
        end
        else begin
            case(uart_tx_state)
                IDLE: begin
                    uart_tx <= 1'b1;
                    if(tx_data_rd == 1'b1) begin
                        uart_tx_state <= BEGIN; 
                    end
                    else begin
                        uart_tx_state <= uart_tx_state;
                    end
                end
                BEGIN: begin
                    uart_tx <= 1'b0;
                    if(tx_baud_cnt == BAUD_CNT_MAX - 1) begin
                        uart_tx_state <= TX_BYTE; 
                    end
                    else begin
                        uart_tx_state <= uart_tx_state;
                    end
                end
                TX_BYTE: begin
                    if(tx_bit_cnt == 5'd7 && tx_baud_cnt == BAUD_CNT_MAX - 1) begin
                        tx_bit_cnt <= 5'd0;
                        uart_tx_state <= END; 
                    end
                    else if(tx_baud_cnt == BAUD_CNT_MAX - 1) begin
                        tx_bit_cnt <= tx_bit_cnt + 1'b1; 
                    end
                    else begin
                        uart_tx <= uart_tx_data_buf[tx_bit_cnt];
                    end
                end
                END: begin
                    uart_tx <= 1'b1;
                    if(tx_baud_cnt == BAUD_CNT_MAX - 1) begin
                        uart_tx_state <= IDLE; 
                    end
                    else begin
                        uart_tx_state <= uart_tx_state;
                    end
                end
                default: begin
                    uart_tx_state <= IDLE;
                    tx_bit_cnt <= 5'd0;
                    uart_tx <= 1'b1;
                end
            endcase
        end
    end
    
    
    /* RX接收模块 */
    
    // 将输入rx延迟4个时钟周期，减少亚稳态的影响
    delay_buffer #(
        .DEPTH(4),
        .DATA_WIDTH(1)
    ) u_delay_buffer(
        .clk           (clk),         // Master Clock
        .data_i        (uart_rx),     // Data Input
        .data_o        (uart_rx_temp) // Data Output
    );
    
    always @ (posedge clk) begin
        uart_rx_delay <= uart_rx_temp;
    end
    
    // rx_baud_cnt计数
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            rx_baud_cnt <= 13'd0;
        end
        else if(uart_rx_state == IDLE || rx_baud_cnt == BAUD_CNT_MAX - 1) begin
            rx_baud_cnt <= 13'd0;
        end
        else begin
            rx_baud_cnt <= rx_baud_cnt + 1'b1;
        end
    end
    
    // RX接收模块
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            uart_rx_state <= IDLE;
            rx_bit_cnt <= 4'd0;
            uart_rx_data_buf <= `ZERO_WORD;
            uart_rx_data_buf_temp <= `ZERO_WORD;
        end
        else begin
            case(uart_rx_state)
                IDLE: begin
                    if(uart_rx_temp == 1'b0 && uart_rx_delay == 1'b1) begin
                        uart_rx_state <= BEGIN; 
                    end
                    else begin
                        uart_rx_state <= uart_rx_state;
                    end
                end
                BEGIN: begin
                    if(rx_baud_cnt == BAUD_CNT_MAX - 1) begin
                        uart_rx_state <= RX_BYTE; 
                    end
                    else begin
                        uart_rx_state <= uart_rx_state;
                    end
                end
                RX_BYTE: begin
                    if(rx_bit_cnt == 4'd7 && rx_baud_cnt == BAUD_CNT_MAX - 1) begin
                        rx_bit_cnt <= 4'd0;
                        uart_rx_state <= END; 
                    end
                    else if(rx_baud_cnt == BAUD_CNT_MAX / 2 - 1) begin
                        uart_rx_data_buf_temp <= {24'h0, uart_rx_delay, uart_rx_data_buf_temp[7:1]};
                    end
                    else if(rx_baud_cnt == BAUD_CNT_MAX - 1) begin
                        rx_bit_cnt <= rx_bit_cnt + 1'b1; 
                    end
                    else begin
                        uart_rx_state <= uart_rx_state;
                    end
                end
                END: begin
                    if(rx_baud_cnt == 1) begin
                        uart_rx_state <= IDLE; 
                        uart_rx_data_buf <= uart_rx_data_buf_temp;
                    end
                    else begin
                        uart_rx_state <= uart_rx_state;
                    end
                end
                default: begin
                    uart_rx_state <= IDLE;
                    rx_bit_cnt <= 4'd0;
                end
            endcase
        end
    end
    
endmodule