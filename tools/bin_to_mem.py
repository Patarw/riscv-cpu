import sys
import sys
import os

# 可以将二进制.bin文件转换成一行一行的指令格式，用于在rom中初始化

def main():
    infile = sys.argv[1]
    outfile = sys.argv[2]
    binfile = open(infile, 'rb')
    binfile_content = binfile.read(os.path.getsize(infile))
    datafile = open(outfile, 'w+')

    index = 0
    b0 = 0
    b1 = 0
    b2 = 0
    b3 = 0

    for b in  binfile_content:
        # 四个字节倒序填充
        if index == 0:
            b0 = b
            index = index + 1
        elif index == 1:
            b1 = b
            index = index + 1
        elif index == 2:
            b2 = b
            index = index + 1
        elif index == 3:
            b3 = b
            index = 0
            array = []
            array.append(b3)
            array.append(b2)
            array.append(b1)
            array.append(b0)
            datafile.write(bytearray(array).hex() + '\n')

    binfile.close()
    datafile.close()

if __name__ == '__main__':
    sys.exit(main())