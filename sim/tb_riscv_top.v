`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/16 21:23:51
// Design Name: 
// Module Name: tb_riscv_top
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


module tb_riscv_top(); 

    reg     clk;
    reg     rst_n;
    reg     data_bit;
    reg[31:0]   ins1;
    reg[31:0]   ins2;
    reg[31:0]   ins3;
    reg[31:0]   ins4;
    
    always # (10) clk <= ~clk;
    
    initial begin
        clk = 1'b1;
        rst_n <= 1'b0;
        data_bit <= 1'b1;
        // 四条指令
        ins1 <= 32'b00000000000100000000000010010011;
        ins2 <= 32'b00000000001000000000000100010011;
        ins3 <= 32'b00000000000100001000000010110011;
        ins4 <= 32'b11111110001000001000111011100011;
        #17
        rst_n <= 1'b1;
    end
    
    
    // 串口发送数据任务
    task rx_bit(
        input   [7:0]   data
    );
        integer i;
        for(i = 0;i < 10;i = i + 1) begin
            case(i)
                0:data_bit <= 1'b0;
                1:data_bit <= data[0];
                2:data_bit <= data[1];
                3:data_bit <= data[2];
                4:data_bit <= data[3];
                5:data_bit <= data[4];
                6:data_bit <= data[5];
                7:data_bit <= data[6];
                8:data_bit <= data[7];
                9:data_bit <= 1'b1;
            endcase
            #(5208*20);
        end
    endtask
    
    // 通过串口将四条指令ins1、ins2、ins3、ins4写到rom中
    /* initial begin
        // ins1
        #200
        rx_bit(ins1[31:24]);
        data_bit = 1'b1;
        #200
        rx_bit(ins1[23:16]);
        data_bit = 1'b1;
        #200
        rx_bit(ins1[15:8]);
        data_bit = 1'b1;
        #200
        rx_bit(ins1[7:0]);
        data_bit = 1'b1;
    
        // ins2
        #200
        rx_bit(ins2[31:24]);
        data_bit = 1'b1;
        #200
        rx_bit(ins2[23:16]);
        data_bit = 1'b1;
        #200
        rx_bit(ins2[15:8]);
        data_bit = 1'b1;
        #200
        rx_bit(ins2[7:0]);
        data_bit = 1'b1;
        
        // ins3
        #200
        rx_bit(ins3[31:24]);
        data_bit = 1'b1;
        #200
        rx_bit(ins3[23:16]);
        data_bit = 1'b1;
        #200
        rx_bit(ins3[15:8]);
        data_bit = 1'b1;
        #200
        rx_bit(ins3[7:0]);
        data_bit = 1'b1;
        
        // ins4
        #200
        rx_bit(ins4[31:24]);
        data_bit = 1'b1;
        #200
        rx_bit(ins4[23:16]);
        data_bit = 1'b1;
        #200
        rx_bit(ins4[15:8]);
        data_bit = 1'b1;
        #200
        rx_bit(ins4[7:0]);
        data_bit = 1'b1;
        
        #200
        rst_n <= 1'b0;
        #17
        rst_n <= 1'b1;
    end */


    RISCV_SOC_TOP tb_RISCV_SOC_TOP(
        .clk                 (clk),
        .rst_n               (rst_n),
        .uart_tx             (), // uart发送引脚
        .uart_rx             (data_bit) // uart接收引脚
    );

endmodule
// do {tb_riscv_top_simulate.do}