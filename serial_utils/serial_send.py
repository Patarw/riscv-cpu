import sys
import os
# 烧录方法为，按住板子上的key1，执行 python .\serial_send.py <串口号> <下载的文件path>，出现send over后即可松开按钮

import serial
 
try:
    ser = serial.Serial(sys.argv[1], 19200, timeout=0.5)
    if ser.is_open:
        print(sys.argv[1] + " open success!")
        with open(sys.argv[2], 'rb') as f:
            a = f.read()
        print("sending bin file")
        count = ser.write(a)
        print("send over, the number of byte: ", count)
 
except Exception as e:
    print("---error---: ", e)

# 如果报错ModuleNotFoundError: No module named 'serial'，则执行 pip install pyserial