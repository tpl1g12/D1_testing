@ECHO off

:Start
SET filename=main
::ECHO. 
IF EXIST "%filename%.c" GOTO Run
GOTO NoFile

:Run
Echo File found.
ECHO Compile errors:
Echo.
avr-gcc -mmcu=atmega644p -DF_CPU=12000000 -Wall -Os -Wl,-u,vfprintf -lprintf_flt   %filename%.c -o %filename%.elf -lm -lc -lm
avr-objcopy -O ihex %filename%.elf %filename%.hex

ECHO.
::SET /P dl=Would you like to download the program to the I1 Matto (y/n)?
ECHO (if yes please check the board is in bootloader mode before continuing.)
GOTO download
::IF "%dl%"=="Y" GOTO download

ECHO Y | DEL %filename%.elf
ECHO Y | DEL %filename%.hex
EXIT

:download
avrdude -c usbasp -p m644p -U flash:w:%filename%.hex
ECHO Y | DEL %filename%.elf
ECHO Y | DEL %filename%.hex
PAUSE
EXIT

:NoFile
ECHO Cannot find file "%filename%.c", check file name and try again.
ECHO.
GOTO Start


