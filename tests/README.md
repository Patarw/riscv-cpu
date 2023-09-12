# 指令兼容性(riscv-compliance)测试项

github源码：https://github.com/syntacore/riscv-compliance

目录结构：
1.  output：指令兼容性程序仿真结果，会与 ```riscv-compliance\riscv-test-suite\rv32*\references``` 中的参考文件进行对比；
2.  riscv-compliance：RISC-V 指令兼容性测试程序源码；
3.  test_case：可以直接被 rom 读取的二进制指令兼容性测试程序；

## bin_to_mem.py

对 ```riscv-compliance\work\rv32*``` 下所有的 .bin 二进制文件转换成 rom 能读取的形式（在 ```test_case\rv32*``` 目录下的 .data 文件）。直接执行即可：

```
python .\bin_to_mem.py
```

## compare.py
将 ```output\rv32*``` 目录下的仿真结果与 ```riscv-compliance\riscv-test-suite\rv32*\references``` 下的对应的 .reference_output 参考结果文件进行对比，若输出 PASS，则代表对应指令通过测试。

```
# eg: python .\compare.py rv32i
python .\compare.py <rv32i or rv32im or rv32Zicsr>
```