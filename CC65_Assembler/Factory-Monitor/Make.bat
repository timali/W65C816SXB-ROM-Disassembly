set CC65_PATH=C:\code_projects\65x_C\6502\CC65\bin

%CC65_PATH%\ca65.exe -l listing.txt W65c816SXB-ROM.s
%CC65_PATH%\ld65.exe -C W65c816SXB-ROM.cfg W65c816SXB-ROM.o -o W65c816SXB-ROM.bin

pause