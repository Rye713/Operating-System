#! /bin/sh

set SDL_VIDEODRIVER=windib
set QEMU_AUDIO_DRV=dsound

qemu-system-x86_64 -L . -m 64 -hda /usr/CLionProjects/Operating-System/MINT64/Disk.img -M pc
//localtime 명령어 작동 안함
