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

module rom(

    input   wire                    clk         ,
    input   wire                    rst_n       ,
    
    input   wire                    wr_en       , // write enable
    input   wire[`INST_ADDR_BUS]    addr        , // address
    input   wire[`INST_DATA_BUS]    data_i      , // write data
    
    output  reg [`INST_DATA_BUS]   data_o        // read data
    
    );
    
    initial begin
        $readmemb("D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/rtl/perips/instructions.txt", _rom);
    end
    
    reg[`INST_DATA_BUS] _rom[0:`ROM_NUM - 1];                               
       
    always @ (*) begin
        if (!rst_n) begin
            data_o = `ZERO_WORD;
        end 
        else begin
            data_o = _rom[addr[31:2]];
        end
    end
   
endmodule
