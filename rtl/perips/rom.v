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
    
    reg[`INST_DATA_BUS] _rom[0:`ROM_NUM - 1];
    
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            _rom[0]  <= 32'b11110000000100000000000010010011;
            _rom[1]  <= 32'b00000000010000000000000100010011;
            _rom[2]  <= 32'b11111110000100010000111000100011;
            _rom[3]  <= 32'b00000000000100010001000000100011;
            _rom[4]  <= 32'b00000000000100010010001000100011;
            _rom[5]  <= 32'b00000000000000000000000110000011;
            _rom[6]  <= 32'b00000000000000000100001000000011;
            _rom[7]  <= 32'b00000000010000000001001010000011;
            _rom[8]  <= 32'b00000000010000000101001100000011;
            _rom[9]  <= 32'b00000000100000000010001110000011;
           /* _rom[10] <= 32'b01000000000100001101010110010011; */
        end
    end          
                                        


       
    always @ (*) begin
        if (!rst_n) begin
            data_o = `ZERO_WORD;
        end 
        else begin
            data_o = _rom[addr[31:2]];
        end
    end
   
endmodule
