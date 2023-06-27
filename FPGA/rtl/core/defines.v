// 参数初始化
`define RESET_ADDR      32'h0
`define ZERO_WORD       32'h0
`define ZERO_REG_ADDR   5'h0

// 寄存器位宽初始化
`define INST_ADDR_BUS   31:0    // 地址总线
`define INST_DATA_BUS   31:0    // 数据总线
`define INST_REG_ADDR   4:0     // 通用寄存器地址位宽
`define INST_REG_DATA   31:0    // 通用寄存器数据位宽


// 常数定义
`define REG_NUM             32
`define ROM_NUM             512
`define RAM_NUM             4096
`define REG_ADDR_WIDTH      5

//ALU运算类型
`define ALU_ADD      4'b0001
`define ALU_SUB      4'b0011
`define ALU_AND      4'b0100
`define ALU_OR       4'b0101
`define ALU_XOR      4'b0110
`define ALU_SLTU     4'b1000  // 无符号小于置1
`define ALU_SLT      4'b1001  // 有符号小于置1
`define ALU_SLL      4'b1100  // 逻辑左移
`define ALU_SRL      4'b1101  // 逻辑右移
`define ALU_SRA      4'b1110  // 算术右移


/* 指令定义 */

// 空闲指令，NOP被编码为ADDI x0,x0,0
`define INS_NOP    32'h0000_0013


// R 类指令
`define INS_TYPE_R  7'b011_0011 // R类指令的opcode
// funct7+funct3组合成10位
`define INS_ADD     10'b00_0000_0000
`define INS_SUB     10'b01_0000_0000
`define INS_SLL     10'b00_0000_0001  // 逻辑左移
`define INS_SLT     10'b00_0000_0010  // 小于置1
`define INS_SLTU    10'b00_0000_0011  // 无符号数比较小于置1
`define INS_XOR     10'b00_0000_0100  // 异或
`define INS_SRL     10'b00_0000_0101  // 逻辑右移
`define INS_SRA     10'b01_0000_0101  // 算术右移
`define INS_OR      10'b00_0000_0110  // 或
`define INS_AND     10'b00_0000_0111  // 与

// I类指令
`define INS_TYPE_I  7'b001_0011
// funct3
`define INS_ADDI         3'b000
`define INS_SLTI         3'b010
`define INS_SLTIU        3'b011
`define INS_XORI         3'b100
`define INS_ORI          3'b110
`define INS_ANDI         3'b111
`define INS_SLLI         3'b001
`define INS_SRLI_SRAI    3'b101

// U类指令
`define INS_LUI         7'b011_0111  // 将立即数逻辑左移12位后存入寄存器rd
`define INS_AUIPC       7'b001_0111  // 将立即数逻辑左移12位后与PC当前值相加后存入寄存器rd

// 无条件跳转指令
`define INS_JAL         7'b110_1111  // 立即数+pc
`define INS_JALR        7'b110_0111  // 立即数+寄存器+pc

// 分支跳转指令
`define INS_TYPE_BRANCH         7'b110_0011  // opcode
// funct3
`define INS_BEQ         3'b000  // 相等跳转
`define INS_BNE         3'b001  // 不等跳转
`define INS_BLT         3'b100  // 小于跳转
`define INS_BGE         3'b101  // 大于跳转
`define INS_BLTU        3'b110  // 小于跳转（无符号数）
`define INS_BGEU        3'b111  // 大于跳转（无符号数）

// 访存指令SAVE
`define INS_TYPE_SAVE        7'b010_0011 
// funct3
`define INS_SB          3'b000  // 存8位
`define INS_SH          3'b001  // 存16位
`define INS_SW          3'b010  // 存32位

// 访存指令LOAD  
`define INS_TYPE_LOAD        7'b000_0011 
// funct3
`define INS_LB          3'b000  // 取8位
`define INS_LH          3'b001  // 取16位
`define INS_LW          3'b010  // 取32位
`define INS_LBU         3'b100  // 取8位，无符号拓展
`define INS_LHU         3'b101  // 取16位，无符号拓展