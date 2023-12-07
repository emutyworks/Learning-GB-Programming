#!/bin/sh

if [ -z "$2" ] 
then
	echo "Usage: ./a.sh <.asm filename> <.gb filename>"
fi

rgbasm -o $1.o $1.asm
rgblink -o $2.gb $1.o
rgbfix -v -p 0 $2.gb