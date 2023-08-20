@echo off

rem assemble Z80 sound driver
axm68k /m /k /p "sound\DAC Driver.asm", "sound\DAC Driver.unc" >"sound\errors.txt", , "sound\DAC Driver.lst"
type "sound\errors.txt"
IF NOT EXIST "sound\DAC Driver.unc" PAUSE & EXIT 2

rem compress kosinski files
for %%f in ("256x256 Mappings\*.unc") do kosinski_compress "%%f" "256x256 Mappings\%%~nf.kos"
kosinski_compress "Graphics - Compressed\Ending Flowers.unc" "Graphics - Compressed\Ending Flowers.kos"
kosinski_compress "sound\DAC Driver.unc" "sound\DAC Driver.kos"

rem assemble final rom
IF EXIST sjbuilt.gen move /Y sjbuilt.gen sjbuilt.prev.gen >NUL
axm68k /m /k /p sonic.asm, sjbuilt.gen >errors.txt, , sonic.lst
type errors.txt

rem check for success and fix header
IF NOT EXIST sjbuilt.gen PAUSE & EXIT 2
fixheadr.exe sjbuilt.gen
exit 0
