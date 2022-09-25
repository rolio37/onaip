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




.code


aproposde_dlg_proc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
 
 
 .IF uMsg == WM_CLOSE
 
  invoke EndDialog, hWnd, NULL
  
 .ELSE
 
  xor eax, eax
 
 .ENDIF
 
  ret
  
 aproposde_dlg_proc endp
 
 
 
 END
