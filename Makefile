SHELL=/bin/bash
.DELETE_ON_ERROR:
ifeq (run,$(firstword $(MAKECMDGOALS)))
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif


all: out

bootloader:
	nasm -g bootloader.asm

clean:
	rm -rf bootloader out

run: bootloader $(RUN_ARGS)
	nasm $(RUN_ARGS).asm
	cat bootloader $(RUN_ARGS) >| out
	qemu-system-i386 -drive format=raw,file=out

