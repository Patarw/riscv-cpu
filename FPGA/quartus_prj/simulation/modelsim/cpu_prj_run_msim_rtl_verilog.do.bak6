transcript on
if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

vlib verilog_libs/altera_ver
vmap altera_ver ./verilog_libs/altera_ver
vlog -vlog01compat -work altera_ver {d:/software/quartus/quartus/eda/sim_lib/altera_primitives.v}

vlib verilog_libs/lpm_ver
vmap lpm_ver ./verilog_libs/lpm_ver
vlog -vlog01compat -work lpm_ver {d:/software/quartus/quartus/eda/sim_lib/220model.v}

vlib verilog_libs/sgate_ver
vmap sgate_ver ./verilog_libs/sgate_ver
vlog -vlog01compat -work sgate_ver {d:/software/quartus/quartus/eda/sim_lib/sgate.v}

vlib verilog_libs/altera_mf_ver
vmap altera_mf_ver ./verilog_libs/altera_mf_ver
vlog -vlog01compat -work altera_mf_ver {d:/software/quartus/quartus/eda/sim_lib/altera_mf.v}

vlib verilog_libs/altera_lnsim_ver
vmap altera_lnsim_ver ./verilog_libs/altera_lnsim_ver
vlog -sv -work altera_lnsim_ver {d:/software/quartus/quartus/eda/sim_lib/altera_lnsim.sv}

vlib verilog_libs/cycloneive_ver
vmap cycloneive_ver ./verilog_libs/cycloneive_ver
vlog -vlog01compat -work cycloneive_ver {d:/software/quartus/quartus/eda/sim_lib/cycloneive_atoms.v}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/utils {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/utils/delay_buffer.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core/defines.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/perips {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/perips/timer.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core/clint.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core/gpr.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core/csr.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/perips {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/perips/gpio.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core/div.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core/mul.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/debug {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/debug/uart_debug.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core/rib.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/top {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/top/RISCV_SOC_TOP.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/top {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/top/RISCV.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/top {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/top/RF_UNIT.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/top {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/top/IF_UNIT.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/top {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/top/ID_UNIT.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/top {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/top/EX_UNIT.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/perips {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/perips/uart.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/perips {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/perips/rom.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/perips {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/perips/ram.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core/pc.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core/if_id.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core/id_ex.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core/id.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core/cu.v}
vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/rtl/core/alu.v}

vlog -vlog01compat -work work +incdir+D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/quartus_prj/../sim {D:/Users/Desktop/FPGA/tinyriscv_cpu/cpu_prj/FPGA/quartus_prj/../sim/tb_riscv_top.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_riscv_top

add wave *
view structure
view signals
run -all
