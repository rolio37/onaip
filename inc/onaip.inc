COMMENT &

    onaip -- piano software

    Copyright (C) 2015-2022  Chédotal Julien

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; see the file COPYING . If not, write to the
    Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

    Please send bugreports with examples or suggestions to rjdi@wanadoo.fr

&


.586  ; pour l'instruction rstdc
.model flat, stdcall
option casemap:none
assume fs:nothing

IFNDEF INC_RECURSIF
 
 include \masm32\include\windows.inc
 include \masm32\include\comdlg32.inc
 include \masm32\include\kernel32.inc
 include \masm32\include\user32.inc
 include \masm32\include\shell32.inc
 include \masm32\include\comctl32.inc
 include \masm32\include\gdi32.inc
 include \masm32\include\winmm.inc


 includelib \masm32\lib\kernel32.lib
 includelib \masm32\lib\user32.lib
 includelib \masm32\lib\comdlg32.lib
 includelib \masm32\lib\shell32.lib
 includelib \masm32\lib\comctl32.lib
 includelib \masm32\lib\gdi32.lib
 includelib \masm32\lib\winmm.lib


 include inc\_piano_widget.inc
 include inc\_onaip_dlg.inc
 include inc\_midi.inc
 include inc\_aproposde_dlg.inc
 include inc\_partition_dlg.inc
 include inc\_partition_widget.inc
 include inc\_exercice_notes_dlg.inc
 include inc\_exercice_oreille_dlg.inc


 INC_RECURSIF = 1
 
ENDIF






