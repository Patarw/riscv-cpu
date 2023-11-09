`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/27 11:25:02
// Design Name: 
// Module Name: RISCV_SOC_TOP
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

// SOC，系统时钟频率为50MHz
module RISCV_SOC_TOP(

    input   wire                        clk                 ,
    input   wire                        sys_rst_n           ,
    
    input   wire                        uart_debug_pin      , // uart_debug使能引脚
    input   wire                        uart_rx             , // uart接收引脚
    output  wire                        uart_tx             , // uart发送引脚
    
    output  wire[3:0]                   gpio_pins             // led引脚资源               
    
    );
    
    
    wire                     rib_hold_flag_o;
    
    // master0
    wire[`INST_DATA_BUS]     m0_rd_data_o;
    // master1
    wire[`INST_DATA_BUS]     m1_rd_data_o;  
    // master2
    wire[`INST_DATA_BUS]     m2_rd_data_o;
    
    // slave0
    wire                     s0_wr_en_o;  
    wire[`INST_ADDR_BUS]     s0_wr_addr_o;
    wire[`INST_DATA_BUS]     s0_wr_data_o;
    wire[`INST_ADDR_BUS]     s0_rd_addr_o;
    // slave1
    wire                     s1_wr_en_o;  
    wire[`INST_ADDR_BUS]     s1_wr_addr_o;
    wire[`INST_DATA_BUS]     s1_wr_data_o;
    wire[`INST_ADDR_BUS]     s1_rd_addr_o;
    // slave2
    wire                     s2_wr_en_o;  
    wire[`INST_ADDR_BUS]     s2_wr_addr_o;
    wire[`INST_DATA_BUS]     s2_wr_data_o;
    wire[`INST_ADDR_BUS]     s2_rd_addr_o;
    // slave3
    wire                     s3_wr_en_o;  
    wire[`INST_ADDR_BUS]     s3_wr_addr_o;
    wire[`INST_DATA_BUS]     s3_wr_data_o;
    wire[`INST_ADDR_BUS]     s3_rd_addr_o;
    // slave4
    wire                     s4_wr_en_o;  
    wire[`INST_ADDR_BUS]     s4_wr_addr_o;
    wire[`INST_DATA_BUS]     s4_wr_data_o;
    wire[`INST_ADDR_BUS]     s4_rd_addr_o;
    
    // RISCV模块输出信号
    wire[`INST_ADDR_BUS]     riscv_pc_o;
    wire                     riscv_mem_wr_rib_req_o;
    wire                     riscv_mem_wr_en_o;
    wire[`INST_ADDR_BUS]     riscv_mem_wr_addr_o;
    wire[`INST_DATA_BUS]     riscv_mem_wr_data_o;
    wire                     riscv_mem_rd_rib_req_o;
    wire[`INST_ADDR_BUS]     riscv_mem_rd_addr_o;
    
    // uart_debug模块输出信号
    wire                     uart_rib_wr_req_o;
    wire                     uart_mem_wr_en_o;  
    wire[`INST_ADDR_BUS]     uart_mem_wr_addr_o; 
    wire[`INST_DATA_BUS]     uart_mem_wr_data_o; 
    
    // rom模块输出信号
    wire[`INST_DATA_BUS]     rom_rd_data_o;
    wire[`INST_DATA_BUS]     rom_ins_o;
    
    // ram模块输出信号
    wire[`INST_DATA_BUS]     ram_rd_data_o;
    
    // uart模块输出信号
    wire[`INST_DATA_BUS]     uart_rd_data_o;
    wire                     uart_int_flag_o;
    
    // gpio模块输出信号
    wire[`INST_DATA_BUS]     gpio_rd_data_o;
    
    // timer模块输出信号
    wire[`INST_DATA_BUS]     timer_rd_data_o;
    wire                     timer_int_flag_o;
    
    // 中断信号
    wire[`INT_BUS]           int_flag;
    assign int_flag = {6'h0, uart_int_flag_o, timer_int_flag_o};
    
    // 同步后的复位信号
    wire rst_n;
    
    rst_ctrl u_rst_ctrl(
        .clk          (clk),
        .sys_rst_n    (sys_rst_n),  
        .rst_n        (rst_n)       
    );
    
    RISCV u_RISCV(
        .clk               (clk),
        .rst_n             (rst_n),
        .rib_hold_flag_i   (rib_hold_flag_o),
        .int_flag_i        (int_flag),
        .pc_o              (riscv_pc_o),
        .ins_i             (rom_ins_o),
        .mem_wr_rib_req_o  (riscv_mem_wr_rib_req_o),
        .mem_wr_en_o       (riscv_mem_wr_en_o),
        .mem_wr_addr_o     (riscv_mem_wr_addr_o),
        .mem_wr_data_o     (riscv_mem_wr_data_o),
        .mem_rd_rib_req_o  (riscv_mem_rd_rib_req_o),
        .mem_rd_addr_o     (riscv_mem_rd_addr_o),
        .mem_rd_data_i     (m0_rd_data_o)
    );
    
    uart_debug u_uart_debug(
        .clk               (clk),
        .rst_n             (rst_n),
        .debug_en_i        (!uart_debug_pin),
        .uart_rx           (uart_rx),
        .rib_wr_req_o      (uart_rib_wr_req_o),
        .mem_wr_en_o       (uart_mem_wr_en_o), 
        .mem_wr_addr_o     (uart_mem_wr_addr_o), 
        .mem_wr_data_o     (uart_mem_wr_data_o)  
    );
    
    rib u_rib(
        .clk            (clk),
        .rst_n          (rst_n),
        .m0_wr_req_i    (riscv_mem_wr_rib_req_o), 
        .m0_wr_en_i     (riscv_mem_wr_en_o), 
        .m0_wr_addr_i   (riscv_mem_wr_addr_o), 
        .m0_wr_data_i   (riscv_mem_wr_data_o), 
        .m0_rd_req_i    (riscv_mem_rd_rib_req_o), 
        .m0_rd_addr_i   (riscv_mem_rd_addr_o), 
        .m0_rd_data_o   (m0_rd_data_o), 
        .m1_wr_req_i    (uart_rib_wr_req_o), 
        .m1_wr_en_i     (uart_mem_wr_en_o), 
        .m1_wr_addr_i   (uart_mem_wr_addr_o), 
        .m1_wr_data_i   (uart_mem_wr_data_o), 
        .s0_wr_en_o     (s0_wr_en_o), 
        .s0_wr_addr_o   (s0_wr_addr_o), 
        .s0_wr_data_o   (s0_wr_data_o), 
        .s0_rd_addr_o   (s0_rd_addr_o), 
        .s0_rd_data_i   (rom_rd_data_o), 
        .s1_wr_en_o     (s1_wr_en_o), 
        .s1_wr_addr_o   (s1_wr_addr_o), 
        .s1_wr_data_o   (s1_wr_data_o), 
        .s1_rd_addr_o   (s1_rd_addr_o), 
        .s1_rd_data_i   (ram_rd_data_o), 
        .s2_wr_en_o     (s2_wr_en_o), 
        .s2_wr_addr_o   (s2_wr_addr_o), 
        .s2_wr_data_o   (s2_wr_data_o), 
        .s2_rd_addr_o   (s2_rd_addr_o), 
        .s2_rd_data_i   (uart_rd_data_o), 
        .s3_wr_en_o     (s3_wr_en_o), 
        .s3_wr_addr_o   (s3_wr_addr_o), 
        .s3_wr_data_o   (s3_wr_data_o), 
        .s3_rd_addr_o   (s3_rd_addr_o), 
        .s3_rd_data_i   (gpio_rd_data_o), 
        .s4_wr_en_o     (s4_wr_en_o), 
        .s4_wr_addr_o   (s4_wr_addr_o), 
        .s4_wr_data_o   (s4_wr_data_o), 
        .s4_rd_addr_o   (s4_rd_addr_o), 
        .s4_rd_data_i   (timer_rd_data_o), 
        .rib_hold_flag_o(rib_hold_flag_o) 
    );
    
    rom u_rom(
        .clk            (clk),
        .rst_n          (rst_n),
        .wr_en_i        (s0_wr_en_o), 
        .wr_addr_i      (s0_wr_addr_o), 
        .wr_data_i      (s0_wr_data_o), 
        .rd_addr_i      (s0_rd_addr_o), 
        .rd_data_o      (rom_rd_data_o),
        .pc_addr_i      (riscv_pc_o),
        .ins_o          (rom_ins_o)
    );
    
    ram u_ram(
        .clk            (clk),
        .rst_n          (rst_n),
        .wr_en_i        (s1_wr_en_o), 
        .wr_addr_i      (s1_wr_addr_o), 
        .wr_data_i      (s1_wr_data_o), 
        .rd_addr_i      (s1_rd_addr_o), 
        .rd_data_o      (ram_rd_data_o)
    );
    
    uart u_uart(
        .clk            (clk),
        .rst_n          (rst_n),
        .uart_rx        (uart_rx), 
        .uart_tx        (uart_tx), 
        .wr_en_i        (s2_wr_en_o), 
        .wr_addr_i      (s2_wr_addr_o), 
        .wr_data_i      (s2_wr_data_o), 
        .rd_addr_i      (s2_rd_addr_o), 
        .rd_data_o      (uart_rd_data_o),
        .uart_int_flag_o(uart_int_flag_o)
    );
    
    gpio u_gpio(
        .clk            (clk),
        .rst_n          (rst_n),
        .wr_en_i        (s3_wr_en_o),
        .wr_addr_i      (s3_wr_addr_o),
        .wr_data_i      (s3_wr_data_o),
        .rd_addr_i      (s3_rd_addr_o), 
        .rd_data_o      (gpio_rd_data_o),
        .gpio_pins      (gpio_pins) 
    );
    
    timer u_timer(
        .clk                (clk),
        .rst_n              (rst_n),
        .wr_en_i            (s4_wr_en_o), 
        .wr_addr_i          (s4_wr_addr_o), 
        .wr_data_i          (s4_wr_data_o), 
        .rd_addr_i          (s4_rd_addr_o), 
        .rd_data_o          (timer_rd_data_o), 
        .timer_int_flag_o   (timer_int_flag_o)
    );
    
endmodule
