SHELL=/bin/bash
.DELETE_ON_ERROR:
# If the first argument is "run"...
ifeq (run,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
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

