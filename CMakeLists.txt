cmake_minimum_required(VERSION 3.10)
project(MINT64)

set(CMAKE_CXX_STANDARD 14)

include_directories(.)
include_directories(00.BootLoader)
include_directories(01.Kernel32)
include_directories(02.Kernel64)
include_directories(03.Application)
include_directories(04.Utility)

add_executable(MINT64
        00.BootLoader/BootLoader.asm
        00.BootLoader/BootLoader.bin
        00.BootLoader/BootLoader_backup.asm
        00.BootLoader/disk_read.asm
        00.BootLoader/disk_read.c
        00.BootLoader/Makefile
        Disk.img
        main.c
        Makefile
        qemu.sh)
