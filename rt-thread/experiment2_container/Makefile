RISCV_ARCH := rv32im
RISCV_ABI := ilp32
RISCV_MCMODEL := medlow

TARGET = rtthread

ASM_SRCS := ./rtthread-nano/libcpu/risc-v/context_gcc.S

C_SRCS := \
	./user/main.c \
	./rtthread-nano/libcpu/risc-v/stack.c \
	./rtthread-nano/src/scheduler.c \
	./rtthread-nano/src/thread.c \
	./rtthread-nano/src/object.c \
	./rtthread-nano/src/kservice.c \

INCLUDES += -I. -I./user/include -I./rtthread-nano/include -I./rtthread-nano/libcpu/risc-v -I../include


COMMON_DIR = ..
include ../common.mk
