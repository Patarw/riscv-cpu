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
    
    input   wire                    erase_en    ,
    
    input   wire                    wr_en_i     , // write enable
    input   wire[`INST_ADDR_BUS]    wr_addr_i   , // address
    input   wire[`INST_DATA_BUS]    data_i      , // write data
    
    input   wire[`INST_ADDR_BUS]    rd_addr_i   , // address
    output  reg [`INST_DATA_BUS]    data_o        // read data
    
    );
    
    // 读取instructions.txt的指令到rom中
    initial begin
        $readmemb("../../../../../rtl/perips/instructions.txt", _rom);
    end
    
    integer i;
    reg[`INST_DATA_BUS] _rom[0:`ROM_NUM - 1];                               
    
    always @ (posedge clk) begin
        if(erase_en) begin
            for(i = 0; i < `ROM_NUM; i = i + 1) begin
                _rom[i] <= `ZERO_WORD;
            end
        end
        else if(wr_en_i == 1'b1) begin
            _rom[wr_addr_i[31:2]] <= data_i;
        end
    end
    
    always @ (*) begin
        if (!rst_n) begin
            data_o = `ZERO_WORD;
        end 
        else begin
            data_o = _rom[rd_addr_i[31:2]];
        end
    end
   
endmodule
