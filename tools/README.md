# 通用工具脚本

## bin_to_mem.py

可以将二进制 .bin 文件转换成 16 进制的指令序列文件，以 led_flow.bin 为例：

```
python bin_to_mem.py ../serial_utils/binary/led_flow.bin led_flow.inst
```