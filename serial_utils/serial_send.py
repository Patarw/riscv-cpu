import serial
 
try:
    ser = serial.Serial("COM3", 19200, timeout=0.5)
    if ser.is_open:
        print("COM3" + " open success!")
        with open('./final.bin', 'rb') as f:
            a = f.read()
        print("sending bin file")
        count = ser.write(a)
        print("send over, the number of byte: ", count)
 
except Exception as e:
    print("---error---: ", e)

# 如果报错ModuleNotFoundError: No module named 'serial'，则执行 pip install pyserial