for %%f in (objpos\*.bin) do objpos "%%f" "..\Object Placement\%%~nf.asm"
for %%f in (objpos\Original\*.bin) do objpos "%%f" "..\Object Placement\Original\%%~nf.asm"
for %%f in (objpos\Easy\*.bin) do objpos "%%f" "..\Object Placement\Easy\%%~nf.asm"
for %%f in (objpos\Normal\*.bin) do objpos "%%f" "..\Object Placement\Normal\%%~nf.asm"