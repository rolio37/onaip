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

.data?

 pdc partition_dlg_controls <>

.code


partition_dlg_proc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
 
 LOCAL rect1:RECT
 ; impossible de la fermer, lié à l'autre
 ;.IF uMsg == WM_CLOSE
 
 
 .IF uMsg == WM_INITDIALOG
 
  ; donne son hwnd à sa créatrice
  mov eax, lParam
  mov edx, hWnd
  mov [eax], edx
 
  mov eax, hWnd
  mov pdc.hwnd, eax
 
  invoke partition_dlg_init
  
 .ELSEIF uMsg == WM_SIZE
 
  invoke GetClientRect, hWnd, addr rect1
      
  invoke SetWindowPos, pdc.h_idw_partition, NULL, rect1.left, rect1.top, rect1.right, rect1.bottom, SWP_NOOWNERZORDER
   
 .ELSE
 
  xor eax, eax
 
 .ENDIF
 
  ret
  
 partition_dlg_proc endp
 
 
; ***********************************************
 partition_dlg_init proc
 
  invoke GetDlgItem, pdc.hwnd, IDW_PARTITION
  mov pdc.h_idw_partition, eax
  
  ret
  
 partition_dlg_init endp
  
  

 ; ***************************************************
 partition_dlg_titre_fenetre proc titre:dword
 
  ; changer le titre de la fenêtre
  invoke SetWindowText, pdc.hwnd, titre
 
  ret 
  
 partition_dlg_titre_fenetre endp

  
  END
