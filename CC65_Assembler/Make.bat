set CC65_PATH=C:\code_projects\65x_C\6502\CC65\bin

%CC65_PATH%\ca65.exe -l listing.txt WDC65c816SXB_ROM.s
%CC65_PATH%\ld65.exe -C WDC-SBX-ROM.cfg WDC65c816SXB_ROM.o -o W65C816SXB-ROM.bin

pause