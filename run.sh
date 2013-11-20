#!/bin/bash

rm ./intel_aes.o 
rm ./iaesx64.o
rm ./aes64

pushd .
asm="iaesx64"
./yasm -D__linux__ -g dwarf2 -f elf64 iaesx64.s -o iaesx64.o
gcc -maes -msse4 -m64 -O3 -g -m64 -c intel_aes.c -o intel_aes.o
ar -r intel_aes64.a *.o
popd

gcc -maes -msse4 -m64 -O3 -o aes64 aes.c intel_aes64.a


