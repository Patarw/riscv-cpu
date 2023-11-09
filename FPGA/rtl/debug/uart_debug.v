`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/27 12:02:53
// Design Name: 
// Module Name: uart_debug
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

// 串口下载模块，用于下载程序到memory中，波特率为19200
module uart_debug(

    input   wire                        clk                 ,
    input   wire                        rst_n               ,
    
    input   wire                        debug_en_i          , // 模块使能信号
    input   wire                        uart_rx             ,

    output  reg                         rib_wr_req_o        , // 总线请求信号
    output  reg                         mem_wr_en_o         , // mem写使能信号
    output  reg[`INST_ADDR_BUS]         mem_wr_addr_o       , // mem写地址信号
    output  reg[`INST_DATA_BUS]         mem_wr_data_o         // mem写数据信号

    );
    
    parameter   BAUD_CNT_MAX = `CLK_FREQ / `UART_BPS;
    parameter   IDLE = 4'd0,
                BEGIN= 4'd1,
                SEND_BYTE = 4'd2,
                END  = 4'd3;
    
    wire                        uart_rx_temp;
    reg                         uart_rx_delay; // 延迟后的rx输入
    reg[12:0]                   baud_cnt;      // 计数器
    reg[2:0]                    byte_cnt;      // 接收到的字节数
    reg[3:0]                    uart_state;    // 状态机
    reg[7:0]                    byte_data;     // 接收到的字节数据
    reg[`INST_DATA_BUS]         wr_data_reg;   // 字节数据拼接成的32位数据
    reg                         data_rd_flag;  // 数据就绪标志位
    reg[3:0]                    bit_cnt;       // 比特计数
    
    wire                        debug_en_i_delay; // 延迟后的按键输入
    
    // 延迟4个时钟周期，减少亚稳态的影响
    delay_buffer #(
        .DEPTH(4),
        .DATA_WIDTH(1)
    ) u_delay_buffer1(
        .clk           (clk),  
        .data_i        (uart_rx),  
        .data_o        (uart_rx_temp)   
    );
    
    delay_buffer #(
        .DEPTH(4),
        .DATA_WIDTH(1)
    ) u_delay_buffer2(
        .clk           (clk),   
        .data_i        (debug_en_i),   
        .data_o        (debug_en_i_delay)   
    );
    
    
    always @ (posedge clk) begin
        uart_rx_delay <= uart_rx_temp;
    end
    
    // rib_wr_req_o
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            rib_wr_req_o <= 1'b0;
        end
        else if(debug_en_i_delay == 1'b0) begin
            rib_wr_req_o <= 1'b0;
        end
        else begin
            rib_wr_req_o <= 1'b1;
        end
    end
    
    // baud_cnt计数
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            baud_cnt <= 13'd0;
        end
        else if(debug_en_i_delay == 1'b0) begin
            baud_cnt <= 13'd0;
        end
        else if(uart_state == IDLE || baud_cnt == BAUD_CNT_MAX - 1) begin
            baud_cnt <= 13'd0;
        end
        else begin
            baud_cnt <= baud_cnt + 1'b1;
        end
    end
    
    // byte_cnt计数
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            byte_cnt <= 3'd0;
        end
        else if(debug_en_i_delay == 1'b0) begin
            byte_cnt <= 3'd0;
        end
        else if(byte_cnt == 3'd4) begin
            byte_cnt <= 3'd0;
        end
        else if(uart_state == END && baud_cnt == 13'd0) begin
            byte_cnt <= byte_cnt + 1'b1;
        end
        else begin
            byte_cnt <= byte_cnt;
        end            
    end
    
    // data_rd_flag
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            data_rd_flag <= 1'b0;
        end
        else if(debug_en_i_delay == 1'b0) begin
            data_rd_flag <= 1'b0;
        end
        else if(byte_cnt == 3'd4) begin
            data_rd_flag <= 1'd1;
        end
        else begin
            data_rd_flag <= 1'b0;
        end            
    end
    
    // wr_data_reg
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            wr_data_reg <= 32'd0;
        end
        else if(debug_en_i_delay == 1'b0) begin
            wr_data_reg <= 32'd0;
        end
        else if(uart_state == END && byte_cnt != 3'd0 && baud_cnt == 13'd1) begin
            wr_data_reg <= {byte_data, wr_data_reg[31:8]};
        end
        else begin
            wr_data_reg <= wr_data_reg;
        end            
    end
    
    // mem_wr_en_o，mem_wr_data_o
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            mem_wr_en_o <= 1'b0;
            mem_wr_data_o <= 32'd0;
        end
        else if(debug_en_i_delay == 1'b0) begin
            mem_wr_en_o <= 1'b0;
            mem_wr_data_o <= 32'd0;
        end
        else if(data_rd_flag == 1'b1) begin
            mem_wr_en_o <= 1'b1;
            mem_wr_data_o <= wr_data_reg;
        end
        else begin
            mem_wr_en_o <= 1'b0;
            mem_wr_data_o <= mem_wr_data_o;
        end            
    end
    
    // mem_wr_addr_o
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            mem_wr_addr_o <= 32'd0;
        end
        else if(debug_en_i_delay == 1'b0) begin
            mem_wr_addr_o <= 32'd0;
        end
        // 待数据写入后，地址+4
        else if(mem_wr_en_o == 1'b1) begin
            mem_wr_addr_o <= mem_wr_addr_o + 3'd4;
        end
        else begin
            mem_wr_addr_o <= mem_wr_addr_o;
        end            
    end
    
    // uart_state状态机
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            uart_state <= IDLE;
            byte_data <= 8'd0;
            bit_cnt <= 4'd0;
        end
        else if(debug_en_i_delay == 1'b0) begin
            uart_state <= IDLE;
            byte_data <= 8'd0;
            bit_cnt <= 4'd0;
        end
        else begin
            case(uart_state)
                IDLE: begin
                    if(uart_rx_temp == 1'b0 && uart_rx_delay == 1'b1) begin
                        uart_state <= BEGIN; 
                    end
                    else begin
                        uart_state <= uart_state;
                    end
                end
                BEGIN: begin
                    if(baud_cnt == BAUD_CNT_MAX - 1) begin
                        uart_state <= SEND_BYTE; 
                    end
                    else begin
                        uart_state <= uart_state;
                    end
                end
                SEND_BYTE: begin
                    if(bit_cnt == 4'd7 && baud_cnt == BAUD_CNT_MAX - 1) begin
                        bit_cnt <= 4'd0;
                        uart_state <= END; 
                    end
                    else if(baud_cnt == BAUD_CNT_MAX / 2 - 1) begin
                        byte_data <= {uart_rx_delay, byte_data[7:1]};
                    end
                    else if(baud_cnt == BAUD_CNT_MAX - 1) begin
                        bit_cnt <= bit_cnt + 1'b1; 
                    end
                    else begin
                        uart_state <= uart_state;
                    end
                end
                END: begin
                    if(baud_cnt == 2) begin
                        uart_state <= IDLE; 
                    end
                    else begin
                        uart_state <= uart_state;
                    end
                end
                default: begin
                    bit_cnt <= 4'd0;
                    byte_data <= 8'd0;
                    uart_state <= IDLE;
                end
            endcase
        end
    end
    
endmodule
