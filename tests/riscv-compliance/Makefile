#
# Ensure the compiler and necessary executables are on the search PATH
#

#
# Ensure you have set the following Variables
#
#


export RISCV_TARGET       ?= my_riscv
export RISCV_PREFIX       ?= riscv64-unknown-elf-


export ROOTDIR    = $(shell pwd)
export WORK       = $(ROOTDIR)/work
export TARGETDIR ?= $(ROOTDIR)/riscv-target

default: all


all:
	$(MAKE) RISCV_TARGET=$(RISCV_TARGET) RISCV_DEVICE=rv32i RISCV_PREFIX=$(RISCV_PREFIX) RISCV_ISA=rv32i run -C $(ROOTDIR)/riscv-test-suite/rv32i
	$(MAKE) RISCV_TARGET=$(RISCV_TARGET) RISCV_DEVICE=rv32im RISCV_PREFIX=$(RISCV_PREFIX) RISCV_ISA=rv32im run -C $(ROOTDIR)/riscv-test-suite/rv32im
	$(MAKE) RISCV_TARGET=$(RISCV_TARGET) RISCV_DEVICE=rv32Zicsr RISCV_PREFIX=$(RISCV_PREFIX) RISCV_ISA=rv32Zicsr run -C $(ROOTDIR)/riscv-test-suite/rv32Zicsr

clean:
	$(MAKE) RISCV_DEVICE=rv32i clean -C $(ROOTDIR)/riscv-test-suite/rv32i
	$(MAKE) RISCV_DEVICE=rv32im clean -C $(ROOTDIR)/riscv-test-suite/rv32im
	$(MAKE) RISCV_DEVICE=rv32Zicsr clean -C $(ROOTDIR)/riscv-test-suite/rv32Zicsr
