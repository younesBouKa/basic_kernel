# Headers files
HEADERS = $(wildcard kernel/*.h drivers/*.h)
# Expanded list of all source files
C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
# List of object files by replacing .c in C_SOURCES to .o
OBJS = ${C_SOURCES:.c=.o}

# Default build target
all: os-image

# build image
os-image: boot/boot.bin kernel.bin
	cat $^ > os-image
	
# Run on qemu
run: all
	qemu-system-x86_64 -hda os-image

# Building kernel binary file
kernel.bin: kernel/kernel_entry.o ${OBJS}
	ld -o $@ -Ttext 0x1000 $^ --oformat binary

# Generic rule for building .o from .c
%.o: %.c ${HEADERS}
	gcc -ffreestanding -fno-pie -c $< -o $@

# Assemble kernel_entry
%.o: %.asm
	nasm $< -f elf -o $@
%.bin: %.asm
	nasm $< -f bin -I '../../16bit/' -o $@

clean: 
	rm -fr *.bin *.dis *.o os-image
	rm -fr kernel/*.o drivers/*.o boot/*.bin 
	#rm ${OBJS}
