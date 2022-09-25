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

 piano_widget_class_name byte "piano_widget_class", 0
 piano_rsrc byte "PIANO88", 0
 piano_midi_rsrc byte "PIANO88_MIDI", 0

 pwi piano_widget_infos <> ; une seule instance du widget à gérer
 
 
 ErrMsgGrave byte "Erreur grave, le programme va se fermer", 0
 ErrMsgMemoire byte "Erreur d'allocation de mémoire pour le piano virtuel !", 0
 ErrMsgBitmap byte "Impossible de charger les ressources graphique !", 0
 
.code



; **************************************************************************
piano_widget_class_register proc
  
 LOCAL wc:WNDCLASSEX
 LOCAL msg:MSG
 LOCAL hwnd:HWND 
 
 mov wc.cbSize, sizeof WNDCLASSEX
 mov wc.style, CS_HREDRAW or CS_VREDRAW
 mov wc.lpfnWndProc, offset piano_widget_proc
 mov wc.cbClsExtra, NULL
 mov wc.cbWndExtra, NULL
 
 invoke GetModuleHandle, NULL
 push eax 
 pop wc.hInstance
 
 mov wc.hbrBackground, COLOR_WINDOW
 mov wc.lpszMenuName, NULL
 mov wc.lpszClassName, offset piano_widget_class_name
 ;invoke LoadIcon, NULL, IDI_APPLICATION
 mov wc.hIcon, 0
 mov wc.hIconSm, 0
 invoke LoadCursor, NULL, IDC_ARROW
 mov wc.hCursor, eax
  
 ; on enregistre la classe de la fenêtre
 invoke RegisterClassEx, addr wc

 ; eax = 0 alors erreur
 
 ret

piano_widget_class_register endp






; ***************************************************************************
piano_widget_proc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
 
 .IF uMsg == WM_DESTROY
 
  ; libére les resources
  invoke DeleteObject, pwi.h_bitmap_piano 
  invoke GlobalFree, pwi.h_mem_piano

  invoke PostQuitMessage, NULL
  
  
 .ELSEIF uMsg == WM_CREATE
  
  mov eax, hWnd
  mov pwi.hwnd, eax
 
  
  invoke piano_widget_init
 
 ; ***********************
 .ELSEIF uMsg == WM_PAINT
 
  invoke piano_widget_dessine_piano
 
 
  ; ******************************************************
 .ELSEIF uMsg == WM_LBUTTONDOWN
 
   invoke piano_widget_click_gauche, MIDI_TOUCHE_APPUYEE, lParam
 
 .ELSEIF uMsg == WM_LBUTTONUP
   
   invoke piano_widget_click_gauche, MIDI_TOUCHE_RELACHEE, lParam
 
 .ELSE
 
  invoke DefWindowProc, hWnd, uMsg, wParam, lParam
  ret  
 .ENDIF 
  
 xor eax, eax
 ret
 
piano_widget_proc endp
 
 

; ******************************************************************************************************* 
piano_widget_click_gauche proc uMsg:UINT, lParam:LPARAM

 LOCAL pos_x:dword
 LOCAL pos_y:dword

 
 
 ; position du click sur le widget
 mov eax, lParam
 mov edx, eax
 and eax, 0FFFFh ; partie basse coordonnée x
 mov pos_x, eax
 shr edx, 16
 mov pos_y, edx ; partie haute coordonnée y
 
 ; vérifier la zone valide du click pour x
 mov eax, pwi.zoom_piano
 mov edx,  PIANO88_BMP_X_MAX
 mul edx ; eax = x max
 mov edx, pos_x
 
 .if edx >= eax
  ret
 .endif

 ; vérifier la zone valide du click pour y
 mov eax, pwi.zoom_piano
 mov edx,  PIANO88_BMP_Y_MAX
 mul edx ; eax = y max
 mov edx, pos_y
 
 .if edx >= eax
  ret
 .endif 
 ; ********************************************
 
 
 ; ajuster les coordonnées du click par rapport au bitmap d'origine
 mov ecx, pwi.zoom_piano
 mov eax, pos_y
 xor edx, edx
 div ecx
 mov pos_y, eax
 
 mov eax, pos_x
 xor edx, edx
 div ecx
 mov pos_x, eax
 
 
 mov eax, pos_y
 mov edx, PIANO88_BMP_X_MAX
 mul edx; eax = ligne
 add eax, pos_x
 

 mov edx, pwi.h_mem_piano
 mov al, byte ptr [eax+edx] ; al = code midi
 and eax, 0FFh
 
 ; envoyé le code midi
 invoke onaip_dlg_midi_out, eax, uMsg

 ret
 
piano_widget_click_gauche endp



; *************************************************************************************
piano_widget_dessine_piano proc 

 LOCAL hdc:dword
 LOCAL ps:PAINTSTRUCT
 ; LOCAL hbitmap:dword
 LOCAL hmem_dc:dword
 LOCAL rect1:RECT
 
 
 invoke BeginPaint, pwi.hwnd, addr ps
 mov hdc, eax
 
 invoke SetMapMode, hdc, MM_ANISOTROPIC
 ;invoke SetMapMode, hdc, MM_ISOTROPIC
 
 ;invoke GetClientRect, hWnd, addr rect1
 
 ;invoke SetWindowOrgEx, hdc, rect1.left, rect1.top, NULL
 ;invoke SetWindowExtEx, hdc, rect1.right, rect1.bottom, NULL
 
 invoke GetClientRect, pwi.hwnd, addr rect1
 ; invoke SetViewportOrgEx, hdc, rect1.left, rect1.top, NULL
 ; invoke SetViewportExtEx, hdc, rect1.right, rect1.bottom, NULL
 
 ;xor edx, edx
 ; mov eax, rect1.right
 ;mov ecx, PIANO88_BMP_X_MAX
 ;div ecx
 
 ; mov odc.zoom_piano, eax
 
 ;.if eax == 0
 ; inc eax
 ;.endif
 

 xor edx, edx
 mov eax, rect1.right
 mov ecx, PIANO88_BMP_X_MAX
 div ecx
 
 .if eax == 0
  inc eax
 .endif
  
 mov pwi.zoom_piano, eax
 
 xor edx, edx
 mov eax, rect1.bottom
 mov ecx, PIANO88_BMP_Y_MAX
 div ecx
  
 .if eax == 0
  inc eax
 .endif
  
 .if eax < pwi.zoom_piano
  mov pwi.zoom_piano, eax
 .endif

 invoke SetViewportExtEx, hdc, pwi.zoom_piano, pwi.zoom_piano, NULL 
 
 
 ; invoke SetViewportExtEx, hdc, 415, 33, NULL
 
 invoke CreateCompatibleDC, hdc
 mov hmem_dc, eax
 
 invoke SelectObject, hmem_dc, pwi.h_bitmap_piano 
  
 
  
 
 
 invoke BitBlt, hdc, 0, 0, PIANO88_BMP_X_MAX, PIANO88_BMP_Y_MAX, hmem_dc, 0, 0, SRCCOPY
 ; invoke StretchBlt, hdc, 10, 90, 830, 66, hmem_dc, 10, 90, 415, 33, SRCCOPY
  
 
 invoke DeleteDC, hmem_dc
 
 
 invoke EndPaint, pwi.hwnd, addr ps
 
 ret
 
piano_widget_dessine_piano endp
 
 

piano_widget_init proc
 
 LOCAL rect1:RECT
 LOCAL hdc:dword
 LOCAL hmem_dc:dword
 LOCAL pmem:dword
 LOCAL index_x:dword
 LOCAL index_y:dword
 LOCAL piano_x_max:dword
 LOCAL piano_y_max:dword
 LOCAL h_bitmap_piano_midi:dword
 ; LOCAL h_bitmap_piano:dword
 
 
 invoke GetDC, pwi.hwnd
 mov hdc, eax
 
 ; chargement de l'image du piano afficher à l'écran
 invoke GetModuleHandle, NULL
 invoke LoadImage, eax, addr piano_rsrc, IMAGE_BITMAP, PIANO88_BMP_X_MAX, PIANO88_BMP_Y_MAX, LR_CREATEDIBSECTION
 mov pwi.h_bitmap_piano, eax
 
 .if eax == 0
  invoke MessageBox, pwi.hwnd, addr ErrMsgBitmap, addr ErrMsgGrave, MB_ICONSTOP or MB_OK
  invoke ExitProcess, 1 
 .endif
  
 ; Chargement de l'image de repérage des touches midi
 invoke GetModuleHandle, NULL
 invoke LoadImage, eax, addr piano_midi_rsrc, IMAGE_BITMAP, PIANO88_BMP_X_MAX, PIANO88_BMP_Y_MAX, LR_CREATEDIBSECTION
 mov h_bitmap_piano_midi, eax
  
 .if eax == 0
  invoke MessageBox, pwi.hwnd, addr ErrMsgBitmap, addr ErrMsgGrave, MB_ICONSTOP or MB_OK
  invoke ExitProcess, 1 
 .endif
  

  
 invoke CreateCompatibleDC, hdc
 mov hmem_dc, eax
 
 invoke SelectObject, hmem_dc, h_bitmap_piano_midi
   
   
 invoke GlobalAlloc, GPTR, PIANO88_BMP_X_MAX * PIANO88_BMP_Y_MAX
 mov pwi.h_mem_piano, eax  
 mov pmem, eax
  
 .if eax == 0
  invoke MessageBox, pwi.hwnd, addr ErrMsgMemoire, addr ErrMsgGrave, MB_ICONSTOP or MB_OK
  invoke ExitProcess, 1 
 .endif 
  
  
 ; créer la table des couleurs (rouge) qui fait référence aux codes midi (piano 88 touches 15h -> 6Ch)
 mov index_y, 0  
   
 @table_y:
  mov index_x, 0
  
  @table_x:
   
  invoke GetPixel, hmem_dc, index_x, index_y
  mov edx, pmem   
  mov byte ptr [edx], al  ; on garde que la composante rouge
  inc pmem   
     
   inc index_x
  .if index_x < PIANO88_BMP_X_MAX
   jmp @table_x 
  .endif
   
   
  inc index_y
 .if index_y < PIANO88_BMP_Y_MAX
  jmp @table_y
 .endif  
 ; ******************************************* 
    
 
 ; invoke DeleteObject, pwi.h_bitmap_piano_midi
 invoke DeleteObject, h_bitmap_piano_midi
 invoke DeleteDC, hmem_dc
 invoke ReleaseDC, pwi.hwnd, hdc
 ; *************************************** 

 ret
 
piano_widget_init endp
 
 

 
END
