#!/bin/bash
rm -f nimlisten.exe
nim c --cpu:i386 --os:windows --gcc.exe:i686-w64-mingw32-gcc --gcc.linkerexe:i686-w64-mingw32-gcc nimlisten.nim && wine nimlisten.exe
