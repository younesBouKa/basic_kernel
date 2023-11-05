echo "=> Clean directory ..."
rm -f ./kernel/*.bin ./kernel/*.o ./kernel/*.dis
rm -f ./boot/*.bin ./boot/*.o ./boot/*.dis
rm -f *.bin *.o *.dis

echo "=> Assemble boot sector ..."
nasm -f bin ./boot/boot.asm -o ./boot/boot.bin

echo "=> Disassembele boot code ..." 
ndisasm ./boot/boot.bin > ./boot/boot.dis
#head -n 20 ./boot/boot.dis


echo "=> Assembling kernel entry point ..."
# here kernel_entry.o object file can't be standalone executable so we mention elf format
nasm ./kernel/kernel_entry.asm -f elf -o ./kernel/kernel_entry.o

echo "=> Compiling kernel code ..."
gcc -ffreestanding -fno-pie -c ./kernel/kernel.c -o ./kernel/kernel.o

echo "=> Linking kernel code ..."
# order of files to pass to the linker is important here 
# we have kernel.o that depends on kernel_entry.o
# we link both files in one binary kernel file 
# the start point of code (kernel code) will be in address 0x10000
# this address is also mentioned in boot.asm (where to jump after protected mode switching) 
ld -o ./kernel/kernel.bin --Ttext 0x1000 --oformat binary ./kernel/kernel_entry.o ./kernel/kernel.o 

echo "=> Disassemling kernel code ..."
ndisasm -b 32 ./kernel/kernel.bin > ./kernel/kernel.dis
#head -n 20 ./kernel/kernel.dis
#head -n 10000 ./kernel/kernel.dis | grep -r10 1000

echo "=> Building image ..."
# Put the boot sector and kernel code in one binary file
cat ./boot/boot.bin ./kernel/kernel.bin > os_image.bin

echo "=> Disassemling image bin ..."
ndisasm -b 32 os_image.bin > os_image.dis
#head -n 100 os_image.dis

echo "=> Start VM with os image"
qemu-system-x86_64 -hda os_image.bin 
