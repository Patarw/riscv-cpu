`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/19 15:09:01
// Design Name: 
// Module Name: ram
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

// ram
module ram(

    input   wire                    clk         ,
    input   wire                    rst_n       ,
    
    input   wire                    wr_en_i     , // write enable
    input   wire[`INST_ADDR_BUS]    addr_i      , // address
    input   wire[`INST_DATA_BUS]    data_i      , // write data
    
    output  reg [`INST_DATA_BUS]    data_o      , // read data
    
    output  wire[3:0]               res_data      // 输出ram地址为0的数据的低四位
    
    );
    
    reg[`INST_DATA_BUS] _ram[0:`RAM_NUM - 1];
    integer     i;
    
    assign res_data = _ram[0][3:0];
    
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(i = 0; i < `RAM_NUM; i = i + 1) begin
                _ram[i] <= `ZERO_WORD;
            end
        end
        else if(wr_en_i == 1'b1) begin
            _ram[addr_i[31:2]] <= data_i;
        end
    end
    
    always @ (*) begin
        if (!rst_n) begin
            data_o = `ZERO_WORD;
        end 
        else begin
            data_o = _ram[addr_i[31:2]];
        end
    end
    
endmodule
