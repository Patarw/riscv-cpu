CROSS_COMPILE = riscv-none-embed-

RISCV_GCC     := $(CROSS_COMPILE)gcc
RISCV_AS      := $(CROSS_COMPILE)as
RISCV_GXX     := $(CROSS_COMPILE)g++
RISCV_OBJDUMP := $(CROSS_COMPILE)objdump
RISCV_GDB     := $(CROSS_COMPILE)gdb
RISCV_AR      := $(CROSS_COMPILE)ar
RISCV_OBJCOPY := $(CROSS_COMPILE)objcopy
RISCV_READELF := $(CROSS_COMPILE)readelf

.PHONY: all
all: $(TARGET)

ASM_SRCS += $(COMMON_DIR)/start.S

C_SRCS += $(COMMON_DIR)/init.c 
C_SRCS += $(COMMON_DIR)/lib/uart.c 
C_SRCS += $(COMMON_DIR)/lib/printf.c
C_SRCS += $(COMMON_DIR)/lib/hw_timer.c


LINKER_SCRIPT := $(COMMON_DIR)/link.lds

INCLUDES += -I$(COMMON_DIR)

LDFLAGS += -T $(LINKER_SCRIPT) -nostartfiles -Wl,--gc-sections -Wl,--check-sections

ASM_OBJS := $(ASM_SRCS:.S=.o)
C_OBJS := $(C_SRCS:.c=.o)
LINK_OBJS += $(ASM_OBJS) $(C_OBJS)
LINK_DEPS += $(LINKER_SCRIPT)

CLEAN_OBJS += $(TARGET) $(LINK_OBJS) $(TARGET).dump $(TARGET).bin ../$(TARGET).inst

CFLAGS += -march=$(RISCV_ARCH)
CFLAGS += -mabi=$(RISCV_ABI)
CFLAGS += -mcmodel=$(RISCV_MCMODEL) -nostdlib -ffunction-sections -fdata-sections -fno-builtin-printf -fno-builtin-malloc -Wall

$(TARGET): $(LINK_OBJS) $(LINK_DEPS) Makefile
	$(RISCV_GCC) $(CFLAGS) $(INCLUDES) $(LINK_OBJS) -o $@ $(LDFLAGS)
	$(RISCV_OBJCOPY) -O binary $@ $@.bin
	$(RISCV_OBJDUMP) --disassemble-all $@ > $@.dump
	python ../../tools/bin_to_mem.py $@.bin ../$@.inst

$(ASM_OBJS): %.o: %.S
	$(RISCV_GCC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

$(C_OBJS): %.o: %.c
	$(RISCV_GCC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

.PHONY: clean
clean:
	rm -f $(CLEAN_OBJS)
