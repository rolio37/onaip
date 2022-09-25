
\MASM32\BIN\rc.exe /v rsrc.rc

\MASM32\BIN\cvtres.exe /machine:ix86 rsrc.res

\MASM32\BIN\ml /c /coff onaip.asm _midi.asm _onaip_dlg.asm _piano_widget.asm _aproposde_dlg.asm _partition_dlg.asm _partition_widget.asm _exercice_notes_dlg.asm _exercice_oreille_dlg.asm

\MASM32\BIN\link /subsystem:windows /entry:debut onaip.obj _midi.obj _onaip_dlg.obj _piano_widget.obj _aproposde_dlg.obj _partition_dlg.obj _partition_widget.obj _exercice_notes_dlg.obj _exercice_oreille_dlg.obj rsrc.obj

pause
