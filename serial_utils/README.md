# 串口调试相关工具

## serial_send.py

串口下载工具，用于下载二进制 .bin 文件到 rom 中：

```
python .\serial_send.py <串口号> <需要下载的 .bin 文件路径>
```

以 led_flow.bin 文件为例，**先按住 key1 不动**，然后执行如下命令，出现 send over 字样后即可松开 key1：

```
python .\serial_send.py COM3 .\binary\led_flow.bin

COM3 open success!
sending bin file
send over, the number of byte:  272
```

## led_flow.bin
流水灯程序，由 C 语言编译而来，在将 cpu 烧录到板子上后，为验证其是否能正常工作，可以使用本程序来验证：

```
python .\serial_send.py COM3 .\binary\led_flow.bin

COM3 open success!
sending bin file
send over, the number of byte:  272
```
使用脚本下载完流水灯程序后，若板子上的 led 交替闪烁，即为成功。 