`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/14 17:24:01
// Design Name: 
// Module Name: rom
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

// rom
module rom(

    input   wire                    clk         ,
    input   wire                    rst_n       ,
    
    input   wire                    wr_en_i     , // write enable
    input   wire[`INST_ADDR_BUS]    wr_addr_i   , // write address
    input   wire[`INST_DATA_BUS]    wr_data_i   , // write data
    
    input   wire[`INST_ADDR_BUS]    rd_addr_i   , // read address
    output  reg [`INST_DATA_BUS]    rd_data_o   , // read data
    
    input   wire[`INST_ADDR_BUS]    pc_addr_i   , // instruction read address
    output  reg [`INST_DATA_BUS]    ins_o         // instruction
    
    );
    
    // 读取需要固化在rom里面的程序
    //initial begin
    //    $readmemb("D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/perips/instructions.txt", _rom);
    //end
    
    reg[`INST_DATA_BUS] _rom[0:`ROM_NUM - 1];                               
    
    // write before read
    always @ (posedge clk) begin
        if(wr_en_i == 1'b1) begin
            _rom[wr_addr_i[31:2]] = wr_data_i;
        end
        rd_data_o = _rom[rd_addr_i[31:2]];
        ins_o = _rom[pc_addr_i[31:2]];
    end
   
endmodule
