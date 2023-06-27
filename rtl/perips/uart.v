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

// 串口模块，目前只用于下载程序到rom中，波特率为9600，系统时钟频率为50MHz，传输一位需要5208个时钟周期
module uart(

    input   wire                        clk                 ,
    input   wire                        rst_n               ,
    
    input   wire                        uart_rx             ,
    output  wire                        uart_tx             ,

    output  reg                         rom_erase_en_o      , // rom全擦除使能信号
    output  reg                         rom_wr_en_o         , // rom写使能信号
    output  reg[`INST_ADDR_BUS]         rom_wr_addr_o       , // rom写地址信号
    output  reg[`INST_DATA_BUS]         rom_wr_data_o         // rom写数据信号

    );
    
    parameter   BAUD_CNT_MAX = `CLK_FREQ / `UART_BPS;
    parameter   IDLE = 4'd0,
                BEGIN= 4'd1,
                BIT0 = 4'd2,
                BIT1 = 4'd3,
                BIT2 = 4'd4,
                BIT3 = 4'd5,
                BIT4 = 4'd6,
                BIT5 = 4'd7,
                BIT6 = 4'd8,
                BIT7 = 4'd9,
                END  = 4'd10;
    
    wire                        uart_rx_temp;
    reg                         uart_rx_delay; // 延迟后的rx输入
    reg[12:0]                   baud_cnt;      // 计数器
    reg[2:0]                    byte_cnt;      // 接收到的字节数
    reg[3:0]                    uart_state;    // 状态机
    reg[7:0]                    byte_data;     // 接收到的字节数据
    reg[`INST_DATA_BUS]         wr_data_reg;
    reg                         data_rd_flag;  // 数据就绪标志位
    
    // 将输入rx延迟4个时钟周期，减少亚稳态的影响
    delay_buffer #(
        .DEPTH(4),
        .DATA_WIDTH(1)
    ) u_delay_buffer(
        .clk           (clk),   //  Master Clock
        .data_i        (uart_rx),   //  Data Input
        .data_o        (uart_rx_temp)    //  Data Output
    );
    
    
    always @ (posedge clk) begin
        uart_rx_delay <= uart_rx_temp;
    end
    
    // baud_cnt计数
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
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
        else if(uart_state == END && byte_cnt != 3'd0 && baud_cnt == 13'd1) begin
            wr_data_reg <= {wr_data_reg[23:0], byte_data};
        end
        else begin
            wr_data_reg <= wr_data_reg;
        end            
    end
    
    // rom_wr_en_o，rom_wr_data_o
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            rom_wr_en_o <= 1'b0;
            rom_wr_data_o <= 32'd0;
        end
        else if(data_rd_flag == 1'b1) begin
            rom_wr_en_o <= 1'b1;
            rom_wr_data_o <= wr_data_reg;
        end
        else begin
            rom_wr_en_o <= 1'b0;
            rom_wr_data_o <= rom_wr_data_o;
        end            
    end
    
    // rom_wr_addr_o
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            rom_wr_addr_o <= 32'd0;
        end
        // 待数据写入后，地址+4
        else if(rom_wr_en_o == 1'b1) begin
            rom_wr_addr_o <= rom_wr_addr_o + 3'd4;
        end
        else begin
            rom_wr_addr_o <= rom_wr_addr_o;
        end            
    end
    
    // rom_erase_en_o
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin 
            rom_erase_en_o <= 1'b0;
        end
        else if(uart_state == BEGIN && baud_cnt == 13'd0 && byte_cnt == 3'd0 && rom_wr_addr_o == 32'd0) begin
            rom_erase_en_o <= 1'b1;
        end
        else begin
            rom_erase_en_o <= 1'b0;
        end            
    end
    
    // uart_state状态机
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            uart_state <= IDLE;
            byte_data <= 8'd0;
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
                        uart_state <= BIT0; 
                    end
                    else begin
                        uart_state <= uart_state;
                    end
                end
                BIT0: begin
                    if(baud_cnt == BAUD_CNT_MAX / 2 - 1) begin
                        byte_data <= {uart_rx_delay, byte_data[7:1]};
                    end
                    else if(baud_cnt == BAUD_CNT_MAX - 1) begin
                        uart_state <= BIT1; 
                    end
                    else begin
                        uart_state <= uart_state;
                    end
                end
                BIT1: begin
                    if(baud_cnt == BAUD_CNT_MAX / 2 - 1) begin
                        byte_data <= {uart_rx_delay, byte_data[7:1]};
                    end
                    else if(baud_cnt == BAUD_CNT_MAX - 1) begin
                        uart_state <= BIT2; 
                    end
                    else begin
                        uart_state <= uart_state;
                    end
                end
                BIT2: begin
                    if(baud_cnt == BAUD_CNT_MAX / 2 - 1) begin
                        byte_data <= {uart_rx_delay, byte_data[7:1]};
                    end
                    else if(baud_cnt == BAUD_CNT_MAX - 1) begin
                        uart_state <= BIT3; 
                    end
                    else begin
                        uart_state <= uart_state;
                    end
                end
                BIT3: begin
                    if(baud_cnt == BAUD_CNT_MAX / 2 - 1) begin
                        byte_data <= {uart_rx_delay, byte_data[7:1]};
                    end
                    else if(baud_cnt == BAUD_CNT_MAX - 1) begin
                        uart_state <= BIT4; 
                    end
                    else begin
                        uart_state <= uart_state;
                    end
                end
                BIT4: begin
                    if(baud_cnt == BAUD_CNT_MAX / 2 - 1) begin
                        byte_data <= {uart_rx_delay, byte_data[7:1]};
                    end
                    else if(baud_cnt == BAUD_CNT_MAX - 1) begin
                        uart_state <= BIT5; 
                    end
                    else begin
                        uart_state <= uart_state;
                    end
                end
                BIT5: begin
                    if(baud_cnt == BAUD_CNT_MAX / 2 - 1) begin
                        byte_data <= {uart_rx_delay, byte_data[7:1]};
                    end
                    else if(baud_cnt == BAUD_CNT_MAX - 1) begin
                        uart_state <= BIT6; 
                    end
                    else begin
                        uart_state <= uart_state;
                    end
                end
                BIT6: begin
                    if(baud_cnt == BAUD_CNT_MAX / 2 - 1) begin
                        byte_data <= {uart_rx_delay, byte_data[7:1]};
                    end
                    else if(baud_cnt == BAUD_CNT_MAX - 1) begin
                        uart_state <= BIT7; 
                    end
                    else begin
                        uart_state <= uart_state;
                    end
                end
                BIT7: begin
                    if(baud_cnt == BAUD_CNT_MAX / 2 - 1) begin
                        byte_data <= {uart_rx_delay, byte_data[7:1]};
                    end
                    else if(baud_cnt == BAUD_CNT_MAX - 1) begin
                        uart_state <= END; 
                    end
                    else begin
                        uart_state <= uart_state;
                    end
                end
                END: begin
                    if(baud_cnt == BAUD_CNT_MAX - 1) begin
                        uart_state <= IDLE; 
                    end
                    else begin
                        uart_state <= uart_state;
                    end
                end
                default: begin
                    byte_data <= 8'd0;
                    uart_state <= IDLE;
                end
            endcase
        end
    end
    
endmodule
