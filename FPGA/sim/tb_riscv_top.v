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


module tb_riscv_top; 

    reg     clk;
    reg     rst_n;
    
    always #10 clk <= ~clk; // 50MHz
    
    wire[31:0] ex_end_flag = riscv_soc_top_0.u_ram._ram[4];
    wire[31:0] begin_signature = riscv_soc_top_0.u_ram._ram[2];
    wire[31:0] end_signature = riscv_soc_top_0.u_ram._ram[3];
    
    integer r;
    integer fd;
    
    initial begin
        clk = 1'b1;
        rst_n <= 1'b0;
        #17
        rst_n <= 1'b1;
        
        wait(ex_end_flag == 32'h1); //wait sim end
    
        fd = $fopen("../../../../tests/output/rv32i/I-ADD-01.elf.out");
        for (r = begin_signature; r < end_signature; r = r + 4) begin
            $fdisplay(fd, "%x", riscv_soc_top_0.u_rom._rom[r[31:2]]);
        end
        $fclose(fd);
    end
    
    // sim timeout
    initial begin
        #500000
        $display("Time out...");
        $finish;
    end
    
    // read mem data
    initial begin
        $readmemh("../../../../tests/test_case/rv32i/I-ADD-01.elf.data", riscv_soc_top_0.u_rom._rom);
    end

    RISCV_SOC_TOP riscv_soc_top_0(
        .clk                 (clk),
        .rst_n               (rst_n)
    );

endmodule
// do {tb_riscv_top_simulate.do}