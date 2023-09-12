import sys
import os

# Usage: python ./compare.py <rv32i or rv32im or rv32Zicsr>


# 找出path目录下的所有reference_output文件
def list_files(path, suffix):
    files = []
    list_dir = os.walk(path)
    for maindir, subdir, all_file in list_dir:
        for filename in all_file:
            apath = os.path.join(maindir, filename)
            if apath.endswith(suffix):
                files.append(apath)

    return files

def get_ref_files(prefix, files):
    for file in files:
            if (file.find(prefix) != -1):
                return file
    return None

# 将测试结果与标准测试参考文件对比
def main():
    # 标准参考测试结果
    reference_output_files = []
    # 测试结果文件
    output_files = []
    if (sys.argv[1] == 'rv32i'):
        reference_output_files = list_files(r'./riscv-compliance/riscv-test-suite/rv32i/references', '.reference_output')
        output_files = list_files(r'./output/rv32i', '.out')
    elif (sys.argv[1] == 'rv32im'):
        reference_output_files = list_files(r'./riscv-compliance/riscv-test-suite/rv32im/references', '.reference_output')
        output_files = list_files(r'./output/rv32im', '.out')
    elif (sys.argv[1] == 'rv32Zicsr'):
        reference_output_files = list_files(r'./riscv-compliance/riscv-test-suite/rv32Zicsr/references', '.reference_output')
        output_files = list_files(r'./output/rv32Zicsr', '.out')
    else:
        return None
    
    for index in range(0, len(output_files)):
        prefix = output_files[index].split('\\')[1].split('.')[0]
        ref_output_file = get_ref_files(prefix, reference_output_files)
        flag = 0

        f1 = open(output_files[index])
        f2 = open(ref_output_file)
        f1_lines = f1.readlines()
        f2_lines = f2.readlines()
        # 文件大小不一致直接fail
        if (len(f1_lines) != len(f2_lines)):
            flag = flag + 1;

        i = 0
        # 逐行比较
        for line in f2_lines:
            # 只要有一行内容不一致就fail
            if (f1_lines[i] != line):
                flag = flag + 2
                break
            i = i + 1
        
        if (flag == 1):
            print('Instruction %s size verify fail...'%prefix)
        elif (flag == 2):
            print('Instruction %s content verify fail... %s '%(prefix,ref_output_file))
        elif (flag == 3):
            print('Instruction %s size and content verify fail...'%prefix)
        elif (flag == 0):
            print('### Instruction %s PASS! ###'%prefix)
        else:
            print('%s error occured!'%prefix)

        f1.close()
        f2.close()

if __name__ == '__main__':
    sys.exit(main())
