#!/bin/sh

if [ -z "$2" ] 
then
  echo "Usage: ./a.sh <.asm filename> <.gb filename>"
fi 

rgbasm -o $1.o $1.asm
rgblink -t -o $2.gbc $1.o
rgbfix -v -p 255 -C $2.gbc
#rgbfix -m MBC1 -v -p 255 -C $2.gbc