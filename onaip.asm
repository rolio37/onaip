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


INCLUDE inc\onaip.inc

  


.data

 NomDlgOnaip byte "ONAIP_DLG", 0
 
 ErrMsgGrave byte "Erreur grave, le programme va se fermer", 0
 ErrMsgWidget byte "Impossible de créer le widget personnalisé !" 
 
.data?

 ic INITCOMMONCONTROLSEX <>
 HandlePrincipal DWORD ? 
  
 
 
  
.code



debut:


 invoke GetModuleHandle, NULL
 mov HandlePrincipal, eax

 
 ; utile pour windows XP, sinon fenêtre ne s'affiche pas !  
 mov ic.dwSize, sizeof INITCOMMONCONTROLSEX
 mov ic.dwICC, ICC_COOL_CLASSES or ICC_BAR_CLASSES
 invoke InitCommonControlsEx, addr ic
 
 ; piano widget
 invoke piano_widget_class_register

 .if eax == 0
  invoke MessageBox, NULL, addr ErrMsgWidget, addr ErrMsgGrave, MB_ICONSTOP or MB_OK
  invoke ExitProcess, 1
 .endif

 ; partition widget
 invoke partition_widget_class_register 
  
 .if eax == 0
  invoke MessageBox, NULL, addr ErrMsgWidget, addr ErrMsgGrave, MB_ICONSTOP or MB_OK
  invoke ExitProcess, 1
 .endif


invoke DialogBoxParam, HandlePrincipal, ADDR NomDlgOnaip, NULL, ADDR onaip_dlg_proc, NULL

invoke ExitProcess, 0

ret



END debut
