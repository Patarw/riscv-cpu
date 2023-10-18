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
    input   wire[`INST_ADDR_BUS]    wr_addr_i   , // write address
    input   wire[`INST_DATA_BUS]    wr_data_i   , // write data
    
    input   wire[`INST_ADDR_BUS]    rd_addr_i   , // read address
    output  wire[`INST_DATA_BUS]    rd_data_o     // read data
    
    );
    reg[`INST_ADDR_BUS]    rd_addr_reg;
    
    reg[`INST_DATA_BUS] _ram[0:`RAM_NUM - 1];
    
    // write before read
    always @ (posedge clk) begin
        if(wr_en_i == 1'b1) begin
            _ram[wr_addr_i[31:2]] <= wr_data_i;
        end
        rd_addr_reg <= rd_addr_i;
    end
    
    assign rd_data_o = _ram[rd_addr_reg[31:2]];
    
endmodule
