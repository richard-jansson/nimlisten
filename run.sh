#!/bin/bash
rm -f nimlisten.exe
rm -f  /home/richard/.cache/nim/nimlisten_d/*.o
nim c --cpu:i386 --os:windows --gcc.exe:i686-w64-mingw32-gcc --gcc.linkerexe:i686-w64-mingw32-gcc nimlisten.nim && wine nimlisten.exe
