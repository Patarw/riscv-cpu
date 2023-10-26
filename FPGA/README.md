# FPGA 工程文件

目录结构：
1.  quartus_prj：quartus 工程文件；
2.  rtl：包含本项目所有的 verilog 源码；
3.  sim：本项目的仿真文件；

如果要修改 cpu 的 rom 和 ram 的大小，直接修改 ```rtl\core\defines.v``` 里面的 ROM_NUM 和 RAM_NUM 即可（注意一定要保证资源足够的情况下），计算公式为：
rom_size = ((ROM_NUM * 4) / 1024) KB