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
    input   wire                        rst_n               ,
    
    output  wire                        uart_tx             , // uart发送引脚
    input   wire                        uart_rx             , // uart接收引脚
    
    output  wire[3:0]                   led_ctl               
    
    );
    
    // RISCV模块输出信号
    wire[`INST_ADDR_BUS]     riscv_rom_rd_addr_o;
    wire                     riscv_mem_wr_en_o;
    wire[`INST_ADDR_BUS]     riscv_mem_wd_addr_o;
    wire[`INST_DATA_BUS]     riscv_mem_wr_data_o;
    
    // ram模块输出信号
    wire[`INST_DATA_BUS]     ram_rd_data_o;
    
    // rom模块输出信号
    wire[`INST_DATA_BUS]     rom_rd_data_o;
    
    // uart模块输出信号
    wire                     uart_rom_erase_en_o;
    wire                     uart_rom_wr_en_o;  
    wire[`INST_ADDR_BUS]     uart_rom_wr_addr_o; 
    wire[`INST_DATA_BUS]     uart_rom_wr_data_o; 
    
    RISCV u_RISCV(
        .clk            (clk),
        .rst_n          (rst_n),
        .rom_rd_addr_o  (riscv_rom_rd_addr_o),
        .rom_rd_data_i  (rom_rd_data_o),
        .mem_wr_en_o    (riscv_mem_wr_en_o),
        .mem_wd_addr_o  (riscv_mem_wd_addr_o),
        .mem_wr_data_o  (riscv_mem_wr_data_o),
        .mem_rd_data_i  (ram_rd_data_o)
    );
    
    rom u_rom(
        .clk            (clk),
        .rst_n          (rst_n),
        .erase_en       (uart_rom_erase_en_o),
        .wr_en_i        (uart_rom_wr_en_o), 
        .wr_addr_i      (uart_rom_wr_addr_o), 
        .data_i         (uart_rom_wr_data_o), 
        .rd_addr_i      (riscv_rom_rd_addr_o), 
        .data_o         (rom_rd_data_o) 
    );
    
    ram u_ram(
        .clk            (clk),
        .rst_n          (rst_n),
        .wr_en_i        (riscv_mem_wr_en_o), 
        .addr_i         (riscv_mem_wd_addr_o), 
        .data_i         (riscv_mem_wr_data_o), 
        .data_o         (ram_rd_data_o),
        .led_ctl        (led_ctl)
    );
    
    uart u_uart(
        .clk                 (clk),
        .rst_n               (rst_n),
        .uart_rx             (uart_rx),
        .uart_tx             (uart_tx),
        .rom_erase_en_o      (uart_rom_erase_en_o), 
        .rom_wr_en_o         (uart_rom_wr_en_o), 
        .rom_wr_addr_o       (uart_rom_wr_addr_o), 
        .rom_wr_data_o       (uart_rom_wr_data_o)  
    );
    
endmodule
