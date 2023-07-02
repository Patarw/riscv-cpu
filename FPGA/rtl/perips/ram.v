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

    input   wire                    clk                 ,
    input   wire                    rst_n               ,
    
    input   wire                    wr_en_i             , // write enable
    input   wire[`INST_ADDR_BUS]    addr_i              , // write address, read address
    input   wire[`INST_DATA_BUS]    data_i              , // write data
    
    output  reg[`INST_DATA_BUS]     data_o              , // read data
    
    output  reg[3:0]                led_ctl
    
    );
    
    reg[`INST_DATA_BUS] _ram[0:`RAM_NUM - 1];
    
    always @ (posedge clk) begin
        if(wr_en_i == 1'b1) begin
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
    
    always @ (*) begin
        if (!rst_n) begin
            led_ctl = 4'd0;
        end 
        else begin
            led_ctl = ~_ram[0][3:0];
        end
    end
    
endmodule
