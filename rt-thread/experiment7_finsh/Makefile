RISCV_ARCH := rv32im
RISCV_ABI := ilp32
RISCV_MCMODEL := medlow

TARGET = rtthread

ASM_SRCS := ./rtthread-nano/libcpu/risc-v/context_gcc.S \
			./rtthread-nano/libcpu/risc-v/trap_entry.S \

C_SRCS := \
	./user/main.c \
	./rtthread-nano/libcpu/risc-v/stack.c \
	./rtthread-nano/libcpu/risc-v/trap.c \
	./rtthread-nano/src/scheduler.c \
	./rtthread-nano/src/thread.c \
	./rtthread-nano/src/object.c \
	./rtthread-nano/src/kservice.c \
	./rtthread-nano/src/idle.c \
	./rtthread-nano/src/clock.c \
	./rtthread-nano/src/irq.c \
	./rtthread-nano/src/timer.c \
    ./rtthread-nano/components/finsh/shell.c \
	./rtthread-nano/components/finsh/msh.c \
	./rtthread-nano/components/finsh/cmd.c \

INCLUDES += -I. -I./user -I./rtthread-nano/include -I./rtthread-nano/libcpu/risc-v -I./rtthread-nano/components/finsh -I../include


COMMON_DIR = ..
include ../common.mk
