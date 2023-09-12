import sys
import filecmp
import subprocess
import sys
import os

# 可以将二进制.bin文件转换成一行一行的指令格式，用于在rom中初始化
def bin_to_mem(infile, outfile):
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

# 找出path目录下的所有bin文件
def list_bin_files(path):
    files = []
    files_name = []
    list_dir = os.walk(path)
    for maindir, subdir, all_file in list_dir:
        for filename in all_file:
            apath = os.path.join(maindir, filename)
            if apath.endswith('.bin'):
                files.append(apath)
                files_name.append(filename)

    return files, files_name

def main():
    [files_rv32i, files_rv32i_filename] = list_bin_files(r'./riscv-compliance/work/rv32i/')
    [files_rv32im, files_rv32im_filename] = list_bin_files(r'./riscv-compliance/work/rv32im/')
    [files_rv32Zicsr, files_rv32Zicsr_filename] = list_bin_files(r'./riscv-compliance/work/rv32Zicsr/')

    print(len(files_rv32i))
    # 如果目录不存在则创建目录
    if not os.path.exists('./test_case/rv32i'):
        os.makedirs('./test_case/rv32i')
    # 将 ./riscv-compliance/work/rv32i/ 下的所有 .bin 二进制源码转换成 rom 能读取的形式
    for index in range(0, len(files_rv32i)) :
        bin_to_mem(files_rv32i[index], './test_case/rv32i/'+ str.replace(files_rv32i_filename[index], 'bin', 'data'))

    print(len(files_rv32im))
    if not os.path.exists('./test_case/rv32im'):
        os.makedirs('./test_case/rv32im')
    for index in range(0, len(files_rv32im)) :
        bin_to_mem(files_rv32im[index], './test_case/rv32im/'+ str.replace(files_rv32im_filename[index], 'bin', 'data'))

    print(len(files_rv32Zicsr))
    if not os.path.exists('./test_case/rv32Zicsr'):
        os.makedirs('./test_case/rv32Zicsr')
    for index in range(0, len(files_rv32Zicsr)) :
        bin_to_mem(files_rv32Zicsr[index], './test_case/rv32Zicsr/'+ str.replace(files_rv32Zicsr_filename[index], 'bin', 'data'))

if __name__ == '__main__':
    sys.exit(main())