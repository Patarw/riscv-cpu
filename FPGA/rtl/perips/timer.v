`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/05 11:25:02
// Design Name: 
// Module Name: timer
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

// 32bit 定时器
module timer(

    input   wire                        clk                 ,
    input   wire                        rst_n               ,
    
    // 读写信号    
    input   wire                        wr_en_i             , // write enable
    input   wire[`INST_ADDR_BUS]        wr_addr_i           , // write address
    input   wire[`INST_REG_DATA]        wr_data_i           , // write data
    input   wire[`INST_ADDR_BUS]        rd_addr_i           , // read address
    output  reg [`INST_REG_DATA]        rd_data_o           , // read data
    
    // 中断信号
    output  wire                        timer_int_flag_o    
    
    );

    localparam TIMER_CTRL = 4'h0;
    localparam TIMER_COUNT = 4'h4;
    localparam TIMER_EVALUE = 4'h8;
    
    // [0]: timer enable
    // [1]: timer int enable
    // [2]: timer int pending, software write 0 to clear it
    // addr offset: 0x00
    reg[31:0] timer_ctrl;

    // timer current count, read only
    // addr offset: 0x04
    reg[31:0] timer_count;

    // timer expired value
    // addr offset: 0x08
    reg[31:0] timer_evalue;
    
    assign timer_int_flag_o = ((timer_ctrl[2] == 1'b1) && (timer_ctrl[1] == 1'b1))? 1'b1 : 1'b0;
    
    reg[`INST_ADDR_BUS]        rd_addr_reg;

    // 读写寄存器，write before read
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer_ctrl <= `ZERO_WORD;
            timer_evalue <= `ZERO_WORD;
        end
        else begin
            if (wr_en_i == 1'b1) begin
                case (wr_addr_i[3:0])
                    TIMER_CTRL: begin
                        // 这里代表软件只能把 timer_ctrl[2]置0，无法将其置1
                        timer_ctrl <= {wr_data_i[31:3], (timer_ctrl[2] & wr_data_i[2]), wr_data_i[1:0]};
                    end
                    TIMER_EVALUE: begin
                        timer_evalue <= wr_data_i;
                    end
                endcase
            end
            
            if(timer_ctrl[0] == 1'b1 && timer_count >= timer_evalue) begin
                timer_ctrl[0] <= 1'b0;
                timer_ctrl[2] <= 1'b1;
            end
            rd_addr_reg <= rd_addr_i;
        end
    end
    
    always @ (*) begin
        case (rd_addr_reg[3:0])
            TIMER_CTRL: begin
                rd_data_o = timer_ctrl;
            end
            TIMER_COUNT: begin
                rd_data_o = timer_count;
            end
            TIMER_EVALUE: begin
                rd_data_o = timer_evalue;
            end
            default: begin
                rd_data_o = `ZERO_WORD;
            end
        endcase
    end
    
    // 计数器 timer_count
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer_count <= `ZERO_WORD;
        end
        else begin
            if (timer_ctrl[0] != 1'b1 || timer_count >= timer_evalue) begin
                timer_count <= `ZERO_WORD;
            end
            else begin
                timer_count <= timer_count + 1'b1;
            end
        end
    end
    
    
endmodule