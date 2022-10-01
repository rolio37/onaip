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

 partition_widget_class_name byte "partition_widget_class", 0
 
 scrollbar_widget_class_name byte "ScrollBar", 0
 
 
 
 clef_fa_rsrc byte "CLEF_FA", 0
 clef_sol_rsrc byte "CLEF_SOL", 0
 accolade_rsrc byte "ACCOLADE", 0
 diese_rsrc byte "DIESE", 0
 bemol_rsrc byte "BEMOL", 0
 
 
 ErrMsgGrave byte "Erreur grave, le programme va se fermer", 0
 ErrMsgPartition byte "Impossible d'allouer la mémoire pour l'affichage de la partition !", 0
 ErrMsgMemoire byte "Erreur d'allocation de mémoire pour les notes !", 0
 ErrMsgBitmap byte "Impossible de charger les ressources graphique !", 0
 
 ptwi partition_widget_infos <> ; une seule instance du widget à gérer
 
 
 ; tableau pour le traçage des lignes supplémentaires pour la clef de sol 
 ligne_sup_clef_sol_index_max dword 36
 ligne_sup_clef_sol dword   OUI,
                            NOTE_HORS_PORTEE, 
							OUI,
							NOTE_HORS_PORTEE,
							OUI,
							NOTE_HORS_PORTEE,
							OUI, 
							NOTE_HORS_PORTEE,
							OUI,
							NOTE_HORS_PORTEE,
							OUI,
							NOTE_HORS_PORTEE, 
							OUI, 
							NOTE_HORS_PORTEE,
							OUI, 
							NOTE_HORS_PORTEE, 
							OUI 
 ligne_sup_clef_sol_ dword	NON,
							NON, ; LIGNE 5 PORTEE
							NON, 
							NON, ; LIGNE 4 PORTEE
							NON, 
							NON, ; LIGNE 3 PORTEE
							NON,
							NON, ; LIGNE 2 PORTEE (SOL)
							NON,
							NON, ; LIGNE 1 PORTEE
							NON,
							OUI,
							NOTE_HORS_PORTEE,
							OUI,
							NOTE_HORS_PORTEE,
							OUI,
							NOTE_HORS_PORTEE,
							OUI,
							NOTE_HORS_PORTEE
							

 ; tableau pour le traçage des lignes supplémentaires pour la clef de fa
 ligne_sup_clef_fa_index_max dword 30
 ligne_sup_clef_fa dword    OUI,
                            NOTE_HORS_PORTEE, 
							OUI,
							NOTE_HORS_PORTEE,
							OUI,
							NOTE_HORS_PORTEE,
							OUI, 
							NON,
							NON, ; LIGNE 5 PORTEE
							NON,
							NON, ; LIGNE 4 PORTEE (FA)
							NON, 
							NON, ; LIGNE 3 PORTEE
							NON,
							NON, ; LIGNE 2 PORTEE
							NON, 
							NON  ; LIGNE 1 PORTEE
 ligne_sup_clef_fa_ dword	NON,
							OUI, 
							NOTE_HORS_PORTEE, 
							OUI, 
							NOTE_HORS_PORTEE, 
							OUI, 
							NOTE_HORS_PORTEE,
							OUI, 
							NOTE_HORS_PORTEE,
							OUI, 
							NOTE_HORS_PORTEE,
							OUI,
							NOTE_HORS_PORTEE

							
 .data?
 
 ; pointeur mémoire globalalloc
 notes_infos_portee_haute dword ?
 notes_infos_portee_basse dword ? 
 
 
 
.code



; **************************************************************************
partition_widget_class_register proc
  
 LOCAL wc:WNDCLASSEX
 LOCAL msg:MSG
 LOCAL hwnd:HWND 
 LOCAL lb:LOGBRUSH
 LOCAL hbrush:dword
 
 
 mov wc.cbSize, sizeof WNDCLASSEX
 mov wc.style, CS_HREDRAW or CS_VREDRAW ;or WS_VSCROLL or WS_HSCROLL
 mov wc.lpfnWndProc, offset partition_widget_proc
 mov wc.cbClsExtra, NULL
 mov wc.cbWndExtra, NULL
 
 invoke GetModuleHandle, NULL
 push eax 
 pop wc.hInstance
 
 ; créer un pinceau blanc
 mov lb.lbStyle, BS_SOLID
 mov lb.lbColor, 0FFFFFFh
 mov lb.lbHatch, HS_VERTICAL
 
 invoke CreateBrushIndirect, addr lb
 mov hbrush, eax
 mov wc.hbrBackground, eax
 
 
 
 mov wc.lpszMenuName, NULL
 mov wc.lpszClassName, offset partition_widget_class_name
 invoke LoadIcon, NULL, IDI_APPLICATION
 mov wc.hIcon, 0
 mov wc.hIconSm, 0
 invoke LoadCursor, NULL, IDC_ARROW
 mov wc.hCursor, eax
  
 ; on enregistre la classe de la fenêtre
 invoke RegisterClassEx, addr wc

 ; eax = 0 alors erreur
 push eax
 
 invoke DeleteObject, hbrush
 
 ; RegisterClassEx -> eax
 pop eax
 
 
 ret

partition_widget_class_register endp






; ***************************************************************************
partition_widget_proc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
 
 .IF uMsg == WM_DESTROY
 
  ; libére les resources
  invoke DeleteDC, ptwi.hdc_zoom_x1
  invoke DeleteObject, ptwi.hbitmap_zoom_x1
  
  
  
  invoke DeleteObject, ptwi.h_bitmap_clef_fa
  invoke DeleteObject, ptwi.h_bitmap_clef_sol
  invoke DeleteObject, ptwi.h_bitmap_accolade
  invoke DeleteObject, ptwi.h_bitmap_diese
  invoke DeleteObject, ptwi.h_bitmap_bemol
  
  
  invoke GlobalFree, notes_infos_portee_haute
  
  invoke PostQuitMessage, NULL 
 
 
 
 .ELSEIF uMsg == WM_CREATE
  
  mov eax, hWnd
  mov ptwi.hwnd, eax
 
  
  invoke partition_widget_init
 
 
 
 ; ***********************
 .ELSEIF uMsg == WM_PAINT
 
  invoke partition_widget_dessine_partition
 
 
 .ELSEIF uMsg == WM_SIZE
  
  invoke partition_widget_resize
  
 
 .ELSEIF uMsg == WM_HSCROLL || uMsg == WM_VSCROLL

  invoke partition_widget_scrollbar, wParam, lParam
 

 ; utile pour supprimer le son "bell" à l'appuie d'une touche quand la fenêtre à le focus 
 .ELSEIF uMsg == WM_GETDLGCODE 
  
  mov eax, DLGC_WANTALLKEYS
  ret  
 ; ********************************************
 
 
 ; la roulette de la souris pour le zoom -/+
 .ELSEIF uMsg == WM_MOUSEWHEEL
 
  
  invoke partition_widget_roulette_souris, wParam, lParam
  ret
 
 
 .ELSEIF uMsg == WM_KEYUP
 
  ; gestion du clavier
  mov eax, wParam
 
  
  ; touche +
  .if eax == VK_ADD
  
   ; augmenter de 10 % la taille de la partition
   invoke partition_widget_zoom, 10, ZOOM_PLUS
   ret 
    
  
  ; touche -
  .elseif eax == VK_SUBTRACT
  
  
   ; réduire de 10 % la taille de la partition
   invoke partition_widget_zoom, 10, ZOOM_MOINS
   ret
    
  .endif
  
  
  mov eax, 1
  ret
  
 
  ; ******************************************************
  .ELSEIF uMsg == WM_LBUTTONDOWN
 
   ; enregistre la position de départ de la souris lors du click gauche, pour le scrolling
   mov eax, lParam
   mov edx, eax
   and eax, 0FFFFh  ; x
   shr edx, 16      ; y   
   	  
   mov ptwi.click_gauche_souris_x, eax
   mov ptwi.click_gauche_souris_y, edx
    
   ret
 
  
  .ELSEIF uMsg == WM_MOUSEMOVE
  
   invoke partition_widget_souris_scrolling, wParam, lParam
   ret
 
 .ELSE
 
  invoke DefWindowProc, hWnd, uMsg, wParam, lParam
  ret  
 .ENDIF 
  
 xor eax, eax
 ret
 
partition_widget_proc endp
 
 




; *************************************************************************************
partition_widget_dessine_partition proc 

 LOCAL hdc:dword
 LOCAL ps:PAINTSTRUCT
 LOCAL s_info_hx:SCROLLINFO
 LOCAL s_info_vy:SCROLLINFO
 LOCAL hbrush:dword
 
 
 
 invoke BeginPaint, ptwi.hwnd, addr ps
 mov hdc, eax
 
 
 ; récupèration de la position des scrollbars
 mov s_info_hx.fMask, SIF_POS
 mov s_info_hx.cbSize, SIZEOF SCROLLINFO
 invoke GetScrollInfo, ptwi.h_scrollbar_h, SB_CTL, addr s_info_hx
 
 mov s_info_vy.fMask, SIF_POS
 mov s_info_vy.cbSize, SIZEOF SCROLLINFO
 invoke GetScrollInfo, ptwi.h_scrollbar_v, SB_CTL, addr s_info_vy
  
 
 invoke SetMapMode, hdc, MM_ANISOTROPIC
 
 invoke SetViewportExtEx, hdc, ptwi.rect_dessin.left, ptwi.rect_dessin.top, NULL 

  
 ; pas de modification de la partition, donc simple affichage/recadrage
 .if ptwi.flag_dessine_bitmap_zoom == 1
   
  ; fond du bitmap de reférence blanc
  invoke CreateSolidBrush, 0FFFFFFh
  mov hbrush, eax
  invoke FillRect, ptwi.hdc_zoom_x1, addr ptwi.rect_bitmap, eax; addr ptwi.rect_dessin, eax  
  invoke DeleteObject, hbrush
  ; ********************************************************
  
  ; déssine les portées
  invoke partition_widget_dessine_portees, hdc
 
  ; déssine les notes
  invoke partition_widget_dessine_notes
    
  mov ptwi.flag_dessine_bitmap_zoom, 0
  
 .endif
 
 
 
 
 ; dessin final de l'ensemble visible
 invoke BitBlt, hdc, 0, 0, ptwi.rect_dessin.right, ptwi.rect_dessin.bottom, ptwi.hdc_zoom_x1, s_info_hx.nPos, s_info_vy.nPos, SRCCOPY

 
 invoke EndPaint, ptwi.hwnd, addr ps
 
 ret
 
partition_widget_dessine_partition endp





; ****************************************************************************************************
partition_widget_init proc
 
 LOCAL rect1:RECT
 LOCAL hdc:dword
 LOCAL hdc_zoom_x1:dword
 
 
 ; allouer de la mémoire pour les notes pour la simple ou double portée
 ; PADDING de 5 pour aligner les octaves et faciliter les futurs calculs :) 
 invoke GlobalAlloc, GPTR, ((NOTES_TEMPS_MAX + DECALAGE_OCTAVE_0) * TEMPS_MAX * TYPE note) * 2 
 
 .if eax == 0
  invoke MessageBox, ptwi.hwnd, addr ErrMsgMemoire, addr ErrMsgGrave, MB_ICONSTOP or MB_OK
  invoke ExitProcess, 1
 .endif
 
 mov notes_infos_portee_haute, eax
 
 ; notes_infos_portee_basse pointe sur l'autre moitié de la mémoire
 add eax, ((NOTES_TEMPS_MAX + DECALAGE_OCTAVE_0) * TEMPS_MAX * TYPE note)
 mov notes_infos_portee_basse, eax
 
 
 ; création des deux scrollbars avec des tailles aléatoires, modifié dans la gestion du message WM_SIZE
 invoke GetModuleHandle, NULL
 invoke CreateWindowEx, NULL, addr scrollbar_widget_class_name, NULL, WS_CHILD or SBS_VERT, 0, 0, 120, 20, ptwi.hwnd, NULL, eax, NULL
 mov ptwi.h_scrollbar_v, eax

 
 invoke GetModuleHandle, NULL
 invoke CreateWindowEx, NULL, addr scrollbar_widget_class_name, NULL, WS_CHILD or SBS_HORZ, 250, 257, 120, 20, ptwi.hwnd, NULL, eax, NULL
 mov ptwi.h_scrollbar_h, eax
 
 
 
 ; chargé les bitmaps prédéfinies
 invoke GetModuleHandle, NULL
 invoke LoadImage, eax, addr clef_fa_rsrc, IMAGE_BITMAP, CLEF_FA_BMP_X_MAX, CLEF_FA_BMP_Y_MAX, LR_CREATEDIBSECTION
 mov ptwi.h_bitmap_clef_fa, eax
  
 .if eax == 0
  invoke MessageBox, ptwi.hwnd, addr ErrMsgBitmap, addr ErrMsgGrave, MB_ICONSTOP or MB_OK
  invoke ExitProcess, 1
 .endif
  
 invoke GetModuleHandle, NULL
 invoke LoadImage, eax, addr clef_sol_rsrc, IMAGE_BITMAP, CLEF_SOL_BMP_X_MAX, CLEF_SOL_BMP_Y_MAX, LR_CREATEDIBSECTION
 mov ptwi.h_bitmap_clef_sol, eax
  
 .if eax == 0
  invoke MessageBox, ptwi.hwnd, addr ErrMsgBitmap, addr ErrMsgGrave, MB_ICONSTOP or MB_OK
  invoke ExitProcess, 1
 .endif
 
 invoke GetModuleHandle, NULL
 invoke LoadImage, eax, addr accolade_rsrc, IMAGE_BITMAP, ACCOLADE_BMP_X_MAX, ACCOLADE_BMP_Y_MAX, LR_CREATEDIBSECTION
 mov ptwi.h_bitmap_accolade, eax
  
 .if eax == 0
  invoke MessageBox, ptwi.hwnd, addr ErrMsgBitmap, addr ErrMsgGrave, MB_ICONSTOP or MB_OK
  invoke ExitProcess, 1
 .endif
  
 invoke GetModuleHandle, NULL
 invoke LoadImage, eax, addr diese_rsrc, IMAGE_BITMAP, DIESE_BMP_X_MAX, DIESE_BMP_Y_MAX, LR_CREATEDIBSECTION
 mov ptwi.h_bitmap_diese, eax
  
 .if eax == 0
  invoke MessageBox, ptwi.hwnd, addr ErrMsgBitmap, addr ErrMsgGrave, MB_ICONSTOP or MB_OK
  invoke ExitProcess, 1
 .endif
 
 invoke GetModuleHandle, NULL
 invoke LoadImage, eax, addr bemol_rsrc, IMAGE_BITMAP, BEMOL_BMP_X_MAX, BEMOL_BMP_Y_MAX, LR_CREATEDIBSECTION
 mov ptwi.h_bitmap_bemol, eax
 
 .if eax == 0
  invoke MessageBox, ptwi.hwnd, addr ErrMsgBitmap, addr ErrMsgGrave, MB_ICONSTOP or MB_OK
  invoke ExitProcess, 1
 .endif
 
  
  
  
 ; ********** 
 invoke SetStretchBltMode, ptwi.hdc_zoom_x1, STRETCH_DELETESCANS
  
 
 
 ; zoom par défaut
 mov ptwi.zoom_min, 20
 mov ptwi.zoom_max, 200
 mov ptwi.zoom_partition, 60 ; 100 % -> taille réel
 mov ptwi.zoom_partition_precedent, 60
  
   
 ; les pointeurs mémoire des bitmaps et hdc pas encore alloués
 mov ptwi.hbitmap_zoom_x1, 0
 mov ptwi.hdc_zoom_x1, 0

 
 ; par défaut l'autoscrolling est activé
 invoke partition_widget_fixe_auto_scrolling, 1
 
 ; définir la portée de la partition et sa mise en page par défaut
 ; 25 notes par portée, 2 portées par défaut 
 invoke partition_widget_def, MODE_PORTEE_DOUBLE, CLEF_SOL, CLEF_FA, 25, 2
 
 
 ret
 
partition_widget_init endp
 
 
 
; ***************************************** 
partition_widget_def proc m_portee:dword, clef1:dword, clef2:dword, nb_notes_portee:dword, nb_portees:dword
 
 ; mode la portée simple ou double
 mov eax, m_portee
 mov ptwi.mode_portee, eax
 
 ; type clef de la portée 1 et 2
 mov eax, clef1
 mov ptwi.clef_simple, eax
 mov eax, clef2
 mov ptwi.clef_double, eax
 
 ; nombre de note par portée
 mov eax, nb_notes_portee
 mov ptwi.notes_par_portee, eax
 
 ; nombre total de portée
 mov eax, nb_portees
 mov ptwi.nb_portee_max, eax
 
 
 ; TMP PAS D'ARMATURE
 mov ptwi.armature_type, ARMATURE_NATURELLE
  
 invoke partition_widget_bitmap_zoom_x1_alloc
 
 ; rendre invalide toutes les notes 
 invoke partition_widget_notes_reset
  
  
 invoke partition_widget_resize	 
  
 ret
 
partition_widget_def endp 
 
 
 
 
; *************************************
partition_widget_bitmap_zoom_x1_alloc proc
 
 LOCAL hdc:dword
  
 invoke GetDC, ptwi.hwnd
 mov hdc, eax 
 
 
 
 @re_calcul_zoom:
 
 ; taille objet à 100%
 mov ptwi.marge_gauche, MARGE_GAUCHE
 mov ptwi.marge_droite, MARGE_DROITE 
 mov ptwi.ecart_portee, ECART_PORTEE
 mov ptwi.portee_simple, PORTEE_SIMPLE 
 mov ptwi.portee_double, PORTEE_DOUBLE
 mov ptwi.ecart_portee_double, ECART_PORTEE_DOUBLE
 mov ptwi.espace_mesure_note_noire, ESPACE_MESURE_NOTE_NOIRE
 mov ptwi.ecart_accolade_portee, ECART_ACCOLADE_PORTEE
 mov ptwi.ecart_accolade_clef_sol_x, ECART_ACCOLADE_CLEF_SOL_X
 mov ptwi.ecart_accolade_clef_sol_y, ECART_ACCOLADE_CLEF_SOL_Y 
 mov ptwi.ecart_accolade_clef_fa_x, ECART_ACCOLADE_CLEF_FA_X
 mov ptwi.ecart_accolade_clef_fa_y, ECART_ACCOLADE_CLEF_FA_Y
 mov ptwi.ecart_clef_sol, ECART_CLEF_SOL
 mov ptwi.ecart_clef_fa, ECART_CLEF_FA 
 mov ptwi.ecart_interligne, ECART_INTERLIGNE 
 mov ptwi.ecart_note_y, ECART_NOTE_Y 
 mov ptwi.ligne_sup_x, LIGNE_SUP_X 
 mov ptwi.hampe_taille, HAMPE_TAILLE
 mov ptwi.hampe_x, HAMPE_X 
 mov ptwi.hampe_y, HAMPE_Y
 mov ptwi.note_x, NOTE_X
 mov ptwi.note_y, NOTE_Y
 mov ptwi.note_correction_x, NOTE_CORRECTION_X
 
 
 ; taille des bitmaps à 100%
 mov ptwi.bitmap_clef_sol_x_max, CLEF_SOL_BMP_X_MAX
 mov ptwi.bitmap_clef_sol_y_max, CLEF_SOL_BMP_Y_MAX
 
 mov ptwi.bitmap_clef_fa_x_max, CLEF_FA_BMP_X_MAX
 mov ptwi.bitmap_clef_fa_y_max, CLEF_FA_BMP_Y_MAX

 mov ptwi.bitmap_accolade_x_max, ACCOLADE_BMP_X_MAX
 mov ptwi.bitmap_accolade_y_max, ACCOLADE_BMP_Y_MAX
 
 mov ptwi.bitmap_diese_x_max, DIESE_BMP_X_MAX
 mov ptwi.bitmap_diese_y_max, DIESE_BMP_Y_MAX
 
 mov ptwi.bitmap_bemol_x_max, BEMOL_BMP_X_MAX
 mov ptwi.bitmap_bemol_y_max, BEMOL_BMP_Y_MAX
 ; ************************************************
 
 
 invoke partition_widget_calcul_zoom
 
 
 
 ; calculer l'axe des x maximum
 ; marge gauche + marge droite + notes_par_portee 
 mov eax, ptwi.notes_par_portee
 
 ; ajouter un peu de place en fin de la portée
 add eax, 2
 
 mov ecx, ptwi.espace_mesure_note_noire
 mul ecx
  
    
 ; longueur d'une portee max
 mov ptwi.portee_x_max, eax
 
 add eax, ptwi.marge_gauche
 add eax, ptwi.marge_droite
 
 ; fixer x max
 mov ptwi.bitmap_x_max, eax
 
 
 ; calculer l'axe y maximum
 mov eax, ptwi.ecart_portee
 
 .if ptwi.mode_portee == MODE_PORTEE_SIMPLE
  add eax, ptwi.portee_simple
 .else
  ; MODE_PORTEE_DOUBLE 
  add eax, ptwi.portee_double
 .endif
 
 mov ecx, ptwi.nb_portee_max
 mul ecx
 add eax, ptwi.ecart_portee ; pour le dessous de la dernière portée
 
 ; fixer y max
 mov ptwi.bitmap_y_max, eax
 
 
 
 mov eax, ptwi.bitmap_x_max
 mov edx, ptwi.bitmap_y_max
 
 mov ptwi.rect_bitmap.left, 0
 mov ptwi.rect_bitmap.right, eax
 mov ptwi.rect_bitmap.top, 0
 mov ptwi.rect_bitmap.bottom, edx
 
 

 ; libérer la mémoire
 .if ptwi.hbitmap_zoom_x1 != 0
  invoke DeleteObject, ptwi.hbitmap_zoom_x1
 .endif
  
 .if ptwi.hdc_zoom_x1 != 0
  invoke DeleteDC, ptwi.hdc_zoom_x1
 .endif
  
 
 invoke CreateCompatibleBitmap, hdc, ptwi.bitmap_x_max, ptwi.bitmap_y_max
 mov ptwi.hbitmap_zoom_x1, eax
 
 .if eax == 0
  
  mov eax, ptwi.zoom_partition_precedent
  .if ptwi.zoom_partition != eax
   
   ; dernière chance :) , refixer l'ancien zoom et refaire les calculs
   mov ptwi.zoom_partition, eax
   jmp @re_calcul_zoom
  .endif
  
  
  ; ici l'ancien zoom correspond au nouveau
  ; donc plus rien à faire, quitter le programme :(
  invoke MessageBox, ptwi.hwnd, addr ErrMsgPartition, addr ErrMsgGrave, MB_ICONSTOP or MB_OK
  invoke ExitProcess, 1
  
 .endif ; erreur CreateCompatibleBitmap
 
 
 
 invoke CreateCompatibleDC, hdc
 mov ptwi.hdc_zoom_x1, eax
 
 invoke SelectObject, ptwi.hdc_zoom_x1, ptwi.hbitmap_zoom_x1
  
 invoke ReleaseDC, ptwi.hwnd, hdc

 
 ; nombre maximum de notes de cette partition
 mov eax, ptwi.nb_portee_max
 mov edx, ptwi.notes_par_portee
 mul edx 
 mov ptwi.nb_temps_max, eax
 
 
 ; nouveau bitmap d'affichage, redéssiner le bitmap
 mov ptwi.flag_dessine_bitmap_zoom, 1
 
 ret

partition_widget_bitmap_zoom_x1_alloc endp



; ****************************************
partition_widget_calcul_zoom proc

 
 ; recalculer la taille de tous les objets graphiques
 mov eax, ptwi.marge_gauche
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.marge_gauche, eax
   
 mov eax, ptwi.marge_droite
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.marge_droite, eax  
 
 mov eax, ptwi.ecart_portee
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.ecart_portee, eax 
 
 mov eax, ptwi.portee_simple
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.portee_simple, eax 
 
 mov eax, ptwi.portee_double
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.portee_double, eax
 
 mov eax, ptwi.ecart_portee_double
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.ecart_portee_double, eax
 
 mov eax, ptwi.espace_mesure_note_noire
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.espace_mesure_note_noire, eax
 
 mov eax, ptwi.ecart_accolade_portee
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.ecart_accolade_portee, eax

 mov eax, ptwi.ecart_accolade_clef_sol_x
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.ecart_accolade_clef_sol_x, eax
 
 mov eax, ptwi.ecart_accolade_clef_sol_y
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.ecart_accolade_clef_sol_y, eax
 
 mov eax, ptwi.ecart_accolade_clef_fa_x
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.ecart_accolade_clef_fa_x, eax
 
 mov eax, ptwi.ecart_accolade_clef_fa_y
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.ecart_accolade_clef_fa_y, eax
 
 mov eax, ptwi.ecart_clef_sol
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.ecart_clef_sol, eax
 
 mov eax, ptwi.ecart_clef_fa
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.ecart_clef_fa, eax
 
 mov eax, ptwi.ecart_interligne
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.ecart_interligne, eax
 
 mov eax, ptwi.ecart_note_y
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.ecart_note_y, eax
 
 mov eax, ptwi.ligne_sup_x
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.ligne_sup_x, eax
 
 mov eax, ptwi.hampe_taille
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.hampe_taille, eax
 
 mov eax, ptwi.hampe_x
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.hampe_x, eax
 
 mov eax, ptwi.hampe_y
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.hampe_y, eax
 
 mov eax, ptwi.note_x
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.note_x, eax
 
 mov eax, ptwi.note_y
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.note_y, eax
 
 
 ; les bitmaps
 mov eax, ptwi.bitmap_clef_sol_x_max
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.bitmap_clef_sol_x_max, eax

 mov eax, ptwi.bitmap_clef_sol_y_max
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.bitmap_clef_sol_y_max, eax
 
 mov eax, ptwi.bitmap_clef_fa_x_max
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.bitmap_clef_fa_x_max, eax
 
 mov eax, ptwi.bitmap_clef_fa_y_max
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.bitmap_clef_fa_y_max, eax
 
 mov eax, ptwi.bitmap_accolade_x_max
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.bitmap_accolade_x_max, eax
 
 mov eax, ptwi.bitmap_accolade_y_max
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.bitmap_accolade_y_max, eax

 mov eax, ptwi.bitmap_diese_x_max
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.bitmap_diese_x_max, eax
 
 mov eax, ptwi.bitmap_diese_y_max
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.bitmap_diese_y_max, eax
 
 mov eax, ptwi.bitmap_bemol_x_max
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.bitmap_bemol_x_max, eax
  
 mov eax, ptwi.bitmap_bemol_y_max
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.bitmap_bemol_y_max, eax
 
 mov eax, ptwi.note_correction_x
 mov edx, ptwi.zoom_partition
 mul edx
 xor edx, edx
 mov ecx, 100
 div ecx
 mov ptwi.note_correction_x, eax
 
 
 ret

partition_widget_calcul_zoom endp




; *******************************************
partition_widget_resize proc
 
 LOCAL rect_scroll_v:RECT
 LOCAL rect_scroll_h:RECT
 LOCAL s_info_hx:SCROLLINFO
 LOCAL s_info_vy:SCROLLINFO
 
 
 
 ; valeur de disparation de la barre horizontale
 mov s_info_hx.fMask, SIF_POS
 mov s_info_hx.cbSize, SIZEOF SCROLLINFO
 mov s_info_hx.nPos, 0
 
 ; valeur de disparation de la barre verticale
 mov s_info_vy.fMask, SIF_POS
 mov s_info_vy.cbSize, SIZEOF SCROLLINFO
 mov s_info_vy.nPos, 0
 
 
 
  
 invoke GetClientRect, ptwi.hwnd, addr ptwi.rect_dessin  
 invoke CopyRect, addr rect_scroll_v, addr ptwi.rect_dessin
 invoke CopyRect, addr rect_scroll_h, addr ptwi.rect_dessin
 
 

 ; ********************************************************************************************************
 ; on vérifie si le bitmap tient dans la zone cliente sur x et y et afficher les scrollbars en conséquence
 ; par exemple si la barre verticale est nécessaire, il faut réduire la zone de dessin sur l'axe x donc
 ; il faut re-vérifier si la barre horizontale n'est pas à son tour nécessaire vu que x à diminuer :) 
 ; on réduit la zone de dessin sur l'axe x et y de la taille du scrollbar SCROLLBAR_TAILLE

 ; par défaut, pas de barre de scroll
 mov ptwi.flag_barre_horizontale, 0
 mov ptwi.flag_barre_verticale, 0
 
 
 ; vérifier l'axe y
 mov eax, ptwi.bitmap_y_max
 
 .if eax > ptwi.rect_dessin.bottom  
 
  ; zone réduite de dessin sur l'axe x
  sub ptwi.rect_dessin.right, SCROLLBAR_TAILLE
  mov ptwi.flag_barre_verticale, 1
 
  ; vérifier l'axe x
  mov eax, ptwi.bitmap_x_max
 
  .if eax > ptwi.rect_dessin.right
  
   ; zone réduite de dessin sur l'axe y
   sub ptwi.rect_dessin.bottom, SCROLLBAR_TAILLE
   mov ptwi.flag_barre_horizontale, 1
  
  .endif
  
 .else

  ; vérifier l'axe x  
  mov eax, ptwi.bitmap_x_max
 
  .if eax > ptwi.rect_dessin.right
  
   ; zone réduite de dessin sur l'axe y
   sub ptwi.rect_dessin.bottom, SCROLLBAR_TAILLE
   mov ptwi.flag_barre_horizontale, 1
  
   ; re-vérifier y
   .if ptwi.flag_barre_verticale == 0
   
    mov eax, ptwi.bitmap_y_max
 
    .if eax > ptwi.rect_dessin.bottom
	
	 ; zone réduite de dessin sur l'axe x
     sub ptwi.rect_dessin.right, SCROLLBAR_TAILLE
     mov ptwi.flag_barre_verticale, 1
	 
    .endif
     
   .endif 
  
  .endif
 
 .endif 
 ; ********************************************************************
 


 .if ptwi.flag_barre_horizontale == 1

  ; définir la plage de valeur de position pour la barre de scroll horizontale  
  mov eax, rect_scroll_h.bottom
  sub eax, SCROLLBAR_TAILLE
  mov rect_scroll_h.top, eax
  
  ; scrollrange 0 -> x nombre de pixels masquées
  mov eax, ptwi.bitmap_x_max
  sub eax, ptwi.rect_dessin.right
  invoke SetScrollRange, ptwi.h_scrollbar_h, SB_CTL, 0, eax, 1
 
 .endif
 
 .if ptwi.flag_barre_verticale == 1
  
  ; définir la plage de valeur de position pour la barre de scroll verticale  
  mov eax, rect_scroll_v.right
  sub eax, SCROLLBAR_TAILLE
  mov rect_scroll_v.left, eax
  mov eax, ptwi.bitmap_y_max
  sub eax, ptwi.rect_dessin.bottom
  invoke SetScrollRange, ptwi.h_scrollbar_v, SB_CTL, 0, eax, 1
  
 .endif	

	
 ; affichage des deux barres de scroll raccourci
 .if ptwi.flag_barre_verticale == 1 && ptwi.flag_barre_horizontale == 1
  
  ; deux barres de scroll donc un carré de SCROLLBAR_TAILLE * SCROLLBAR_TAILLE qui les sépares dans le coin inférieur droit
  sub rect_scroll_v.bottom, SCROLLBAR_TAILLE
  sub rect_scroll_h.right, SCROLLBAR_TAILLE
  invoke SetWindowPos, ptwi.h_scrollbar_h, NULL, rect_scroll_h.left, rect_scroll_h.top, rect_scroll_h.right, SCROLLBAR_TAILLE, SWP_NOOWNERZORDER
  invoke SetWindowPos, ptwi.h_scrollbar_v, NULL, rect_scroll_v.left, rect_scroll_v.top, SCROLLBAR_TAILLE, rect_scroll_v.bottom, SWP_NOOWNERZORDER
  invoke ShowWindow, ptwi.h_scrollbar_v, SW_SHOW
  invoke ShowWindow, ptwi.h_scrollbar_h, SW_SHOW
 
  
 ; affichage de la barre verticale complète de scroll et masquer l'horizontale
 .elseif ptwi.flag_barre_verticale == 1
  
  invoke SetWindowPos, ptwi.h_scrollbar_v, NULL, rect_scroll_v.left, rect_scroll_v.top, SCROLLBAR_TAILLE, rect_scroll_v.bottom, SWP_NOOWNERZORDER
  invoke ShowWindow, ptwi.h_scrollbar_v, SW_SHOW
  invoke ShowWindow, ptwi.h_scrollbar_h, SW_HIDE
  
  invoke SetScrollInfo, ptwi.h_scrollbar_h, SB_CTL, addr s_info_hx, 0
  
  
 ; affichage de la barres horizontale complète de scroll et masquer la verticale
 .elseif ptwi.flag_barre_horizontale == 1
  
  invoke SetWindowPos, ptwi.h_scrollbar_h, NULL, rect_scroll_h.left, rect_scroll_h.top, rect_scroll_h.right, SCROLLBAR_TAILLE, SWP_NOOWNERZORDER
  invoke ShowWindow, ptwi.h_scrollbar_h, SW_SHOW
  invoke ShowWindow, ptwi.h_scrollbar_v, SW_HIDE
   
  invoke SetScrollInfo, ptwi.h_scrollbar_v, SB_CTL, addr s_info_vy, 0
  
  ; masquer les deux barres de scroll 
 .else
  
  ;.if ptwi.flag_barre_horizontale == 1
   invoke ShowWindow, ptwi.h_scrollbar_h, SW_HIDE
   invoke SetScrollInfo, ptwi.h_scrollbar_h, SB_CTL, addr s_info_hx, 0
   ;mov ptwi.flag_barre_horizontale, 0
  ;.endif
   
  ;.if ptwi.flag_barre_verticale == 1
   invoke ShowWindow, ptwi.h_scrollbar_v, SW_HIDE
   invoke SetScrollInfo, ptwi.h_scrollbar_v, SB_CTL, addr s_info_vy, 0
   ;mov ptwi.flag_barre_verticale, 0
  ;.endif
   
   
 .endif
 
 
 xor eax, eax
 ret

 
partition_widget_resize endp 



; ******************************
partition_widget_scrollbar proc wParam:dword, lParam:dword

 LOCAL s_info:SCROLLINFO
 
 ; pas de vérification de l'handle des barres de scroll (lParam) !
 mov s_info.fMask, SIF_POS or SIF_RANGE
 mov s_info.cbSize, SIZEOF SCROLLINFO
 invoke GetScrollInfo, lParam, SB_CTL, addr s_info
 
 
 mov eax, wParam
 and eax, 0FFFFh ; isoler le message

  
 ; barre horizontale click sur la flèche de gauche et barre verticale click sur la flèche du haut
 .if eax == SB_LINELEFT
  
  ; vérifier la limite inférieur  
  .if s_info.nPos == 0
  
   ; en buté, rien à faire
   ret
  
  .else
 
   ; position -1 
   dec s_info.nPos
   mov s_info.fMask, SIF_POS 
   invoke SetScrollInfo, lParam, SB_CTL, addr s_info, 1
   invoke InvalidateRect, ptwi.hwnd, addr ptwi.rect_dessin, 0
   
  .endif
 
 ; barre horizontale click sur la flèche de droite et barre verticale click sur la flèche du bas
 .elseif eax == SB_LINERIGHT
  
  ; vérifier la limite supérieur
  mov eax, s_info.nMax
  
  .if s_info.nPos > eax
  
   ; en buté, rien à faire
   ret
  
  .else
 
   ; position +1 
   inc s_info.nPos
   mov s_info.fMask, SIF_POS 
   invoke SetScrollInfo, lParam, SB_CTL, addr s_info, 1
   invoke InvalidateRect, ptwi.hwnd, addr ptwi.rect_dessin, 0
   
  .endif
 
  

 ; gestion de l'ascenseur des deux scrollbars
 .elseif eax == SB_THUMBTRACK
 
  ; position de l'ascenseur dans les 16 bits de poids fort wParam
  mov eax, wParam
  shr eax, 16
  
  mov s_info.nPos, eax
  mov s_info.fMask, SIF_POS 
  invoke SetScrollInfo, lParam, SB_CTL, addr s_info, 1
  invoke InvalidateRect, ptwi.hwnd, addr ptwi.rect_dessin, 0
 
  
 .endif

 ret

partition_widget_scrollbar endp



; **************************************************
partition_widget_dessine_portees proc hdc:dword
 
 
 LOCAL trace_x:dword
 LOCAL trace_y:dword
 LOCAL tmp_x1:dword
 LOCAL tmp_y1:dword
 LOCAL tmp_x2:dword
 LOCAL tmp_y2:dword
 LOCAL compteur_portee:dword 
 
 LOCAL hdc_clef_sol:dword
 LOCAL hdc_clef_fa:dword
 LOCAL hdc_accolade:dword
  
 
 ; objets graphiques prédéfinis
 invoke CreateCompatibleDC, hdc
 mov hdc_clef_sol, eax
 invoke SelectObject, eax, ptwi.h_bitmap_clef_sol
 
 invoke CreateCompatibleDC, hdc
 mov hdc_clef_fa, eax
 invoke SelectObject, eax, ptwi.h_bitmap_clef_fa
 
 invoke CreateCompatibleDC, hdc
 mov hdc_accolade, eax
 invoke SelectObject, eax, ptwi.h_bitmap_accolade
 
 
 
; définir le point de départ de traçage
 mov eax, ptwi.marge_gauche
 mov trace_x, eax
 
 mov eax, ptwi.ecart_portee
 mov trace_y, eax 
  
 ; boucle principale
 mov ecx, ptwi.nb_portee_max
 mov compteur_portee, ecx
 @trace_les_portees:
 
 ; tracer l'accolade au besoin
 .if ptwi.mode_portee == MODE_PORTEE_DOUBLE
  invoke StretchBlt, ptwi.hdc_zoom_x1, trace_x, trace_y, ptwi.bitmap_accolade_x_max, ptwi.bitmap_accolade_y_max, hdc_accolade, 0, 0, ACCOLADE_BMP_X_MAX, ACCOLADE_BMP_Y_MAX, SRCCOPY
 .endif
    
 
   
  ; portée du haut
  .if ptwi.clef_simple == CLEF_SOL
   ; garder les valeurs de trace_x et trace_y
   mov edx, trace_x
   mov eax, ptwi.bitmap_accolade_x_max
   add eax, ptwi.ecart_accolade_clef_sol_x
   add edx, eax
   mov ecx, trace_y
   sub ecx, ptwi.ecart_accolade_clef_sol_y
   invoke StretchBlt, ptwi.hdc_zoom_x1, edx, ecx, ptwi.bitmap_clef_sol_x_max, ptwi.bitmap_clef_sol_y_max, hdc_clef_sol, 0, 0, CLEF_SOL_BMP_X_MAX, CLEF_SOL_BMP_Y_MAX, SRCCOPY
  
  .else
   ; CLEF_FA
   ; garder les valeurs de trace_x et trace_y
   mov edx, trace_x
   mov eax, ptwi.bitmap_accolade_x_max
   add eax, ptwi.ecart_accolade_clef_fa_x
   add edx, eax
   mov ecx, trace_y
   sub ecx, ptwi.ecart_accolade_clef_fa_y
   invoke StretchBlt, ptwi.hdc_zoom_x1, edx, ecx, ptwi.bitmap_clef_fa_x_max, ptwi.bitmap_clef_fa_y_max, hdc_clef_fa, 0, 0, CLEF_FA_BMP_X_MAX, CLEF_FA_BMP_Y_MAX, SRCCOPY
  .endif
  
  
  .if ptwi.mode_portee == MODE_PORTEE_DOUBLE
  
  ; portée du bas
  .if ptwi.clef_double == CLEF_SOL
   ; garder les valeurs de trace_x et trace_y
   mov edx, trace_x
   mov eax, ptwi.bitmap_accolade_x_max
   add eax, ptwi.ecart_accolade_clef_sol_x
   add edx, eax
   mov ecx, trace_y
   add ecx, ptwi.ecart_clef_sol
   invoke StretchBlt, ptwi.hdc_zoom_x1, edx, ecx, ptwi.bitmap_clef_sol_x_max, ptwi.bitmap_clef_sol_y_max, hdc_clef_sol, 0, 0, CLEF_SOL_BMP_X_MAX, CLEF_SOL_BMP_Y_MAX, SRCCOPY
  
  .else
   ; CLEF_FA
   ; garder les valeurs de trace_x et trace_y
   mov edx, trace_x
   mov eax, ptwi.bitmap_accolade_x_max
   add eax, ptwi.ecart_accolade_clef_fa_x
   add edx, eax
   mov ecx, trace_y
   add ecx, ptwi.ecart_clef_fa
   invoke StretchBlt, ptwi.hdc_zoom_x1, edx, ecx, ptwi.bitmap_clef_fa_x_max, ptwi.bitmap_clef_fa_y_max, hdc_clef_fa, 0, 0, CLEF_FA_BMP_X_MAX, CLEF_FA_BMP_Y_MAX, SRCCOPY
  .endif
  
   
 .endif ; ptwi.mode_portee == MODE_PORTEE_DOUBLE
 
 
 
 ; tracer la portée
 .if ptwi.mode_portee == MODE_PORTEE_SIMPLE
 
  mov eax, trace_x
  mov tmp_x1, eax
  mov eax, trace_y
  mov tmp_y1, eax
  
  mov eax, ptwi.bitmap_accolade_x_max   ; l'accolade elle même
  add eax, ptwi.ecart_accolade_portee
  add tmp_x1, eax
  
  mov eax, tmp_x1
  add eax, ptwi.portee_x_max
  mov tmp_x2, eax
  
  mov eax, tmp_y1
  add eax, ptwi.portee_simple
  mov tmp_y2, eax
  
  ; 5 rectangles imbriqués
  mov ecx, 4
  @trace_simple_portee:
  
  push ecx 
    
  ; rectangle noir
  invoke partition_widget_trace_rectangle, ptwi.hdc_zoom_x1, 0, 2, tmp_x1, tmp_y1, tmp_x2, tmp_y2
  
  mov eax, ptwi.ecart_interligne
  sub tmp_y2, eax
    
  
  pop ecx
  dec ecx
  jnz @trace_simple_portee
  
 
 
 .else
 
  ; MODE_PORTEE_DOUBLE 
  mov eax, trace_x
  mov tmp_x1, eax
  mov eax, trace_y
  mov tmp_y1, eax
  
  mov eax, ptwi.bitmap_accolade_x_max   ; l'accolade elle même
  add eax, ptwi.ecart_accolade_portee
  add tmp_x1, eax
  
  mov eax, tmp_x1
  add eax, ptwi.portee_x_max
  mov tmp_x2, eax
  
  mov eax, tmp_y1
  add eax, ptwi.portee_double
  mov tmp_y2, eax
  
  ; 5 rectangles imbriqués
  mov ecx, 5 
  @trace_double_portee:
  
  push ecx 
    
  ; rectangle noir
  invoke partition_widget_trace_rectangle, ptwi.hdc_zoom_x1, 0, 2, tmp_x1, tmp_y1, tmp_x2, tmp_y2
  
  mov eax, ptwi.ecart_interligne
  add tmp_y1, eax
  sub tmp_y2, eax
    
  
  pop ecx
  dec ecx
  jnz @trace_double_portee
  
  
 .endif 
 
 
 ; préparation de trace_y, pour la potentiel portée suivante
 mov eax, ptwi.ecart_portee
 
 .if ptwi.mode_portee == MODE_PORTEE_SIMPLE
  add eax, ptwi.portee_simple
 .else
 
  ; MODE_PORTEE_DOUBLE
  
  add eax, ptwi.portee_double  
 .endif
 
 add trace_y, eax
 
 dec compteur_portee
 jnz @trace_les_portees

 
  
 ; libérer les DC des trois bmp 
 invoke DeleteDC, hdc_clef_sol
 invoke DeleteDC, hdc_clef_fa
 invoke DeleteDC, hdc_accolade

 ret

partition_widget_dessine_portees endp



; ***************************************************************
partition_widget_trace_rectangle proc hdc:dword, couleur:dword, taille_crayon:dword, x1:dword, y1:dword, x2:dword, y2:dword

 LOCAL hpen:dword
   
 invoke CreatePen, PS_SOLID, taille_crayon, couleur
 mov hpen, eax
 invoke SelectObject, hdc, eax

 ; coin inférieur gauche du rectangle 
 invoke MoveToEx, ptwi.hdc_zoom_x1, x1, y1, NULL
 
 ; sens anti-horaire
 invoke LineTo, hdc, x1, y2
 invoke LineTo, hdc, x2, y2 
 invoke LineTo, hdc, x2, y1
 invoke LineTo, hdc, x1, y1
 
 invoke DeleteObject, hpen

 ret

partition_widget_trace_rectangle endp




; ***********************************
partition_widget_dessine_notes proc
 
 LOCAL compteur_notes_portee:dword
 LOCAL compteur_nb_portee:dword
 LOCAL trace_x:dword
 LOCAL trace_y:dword
 
 LOCAL note_x1:dword
 LOCAL note_y1:dword
 LOCAL note_x2:dword
 LOCAL note_y2:dword
 
 LOCAL y_min_clef_sol_portee_1:dword
 LOCAL y_max_clef_sol_portee_1:dword
 LOCAL y_min_clef_fa_portee_1:dword
 LOCAL y_max_clef_fa_portee_1:dword
 
 LOCAL y_min_clef_sol_portee_2:dword
 LOCAL y_max_clef_sol_portee_2:dword
 LOCAL y_min_clef_fa_portee_2:dword
 LOCAL y_max_clef_fa_portee_2:dword
 
 LOCAL note_min_x:dword ; commun aux deux portées
 
 LOCAL note_min_y_portee_1:dword
 LOCAL note_max_y_portee_1:dword
 LOCAL note_min_y_portee_2:dword
 LOCAL note_max_y_portee_2:dword
 
 LOCAL index_note_haute_portee_1:dword
 LOCAL index_note_basse_portee_1:dword
 LOCAL index_note_haute_portee_2:dword
 LOCAL index_note_basse_portee_2:dword
 
 LOCAL pointeur_note_haute_portee_1:dword
 LOCAL pointeur_note_basse_portee_1:dword
 LOCAL pointeur_note_haute_portee_2:dword
 LOCAL pointeur_note_basse_portee_2:dword
 
 
 LOCAL compteur_notes_par_temps_portee_1:dword
 LOCAL compteur_notes_par_temps_portee_2:dword
 
 LOCAL portee_suivante:dword
 LOCAL temps_suivant:dword
 
 
 LOCAL pointeur_ligne_sup_haute_portee_1:dword
 LOCAL pointeur_ligne_sup_basse_portee_1:dword
 LOCAL pointeur_ligne_sup_haute_portee_2:dword
 LOCAL pointeur_ligne_sup_basse_portee_2:dword
 
 
 LOCAL flag_note_hors_portee_haute_portee_1:dword
 LOCAL flag_note_hors_portee_basse_portee_1:dword
 LOCAL flag_note_hors_portee_haute_portee_2:dword
 LOCAL flag_note_hors_portee_basse_portee_2:dword
 
 
 ; définir l'axe des x commun aux différentes portées
 mov eax, ptwi.marge_gauche
 add eax, ptwi.bitmap_accolade_x_max
 add eax, ptwi.ecart_accolade_portee
 add eax, ptwi.espace_mesure_note_noire
 add eax, ptwi.espace_mesure_note_noire
 mov note_min_x, eax 
  
 
 ; mov eax, ptwi.ecart_portee
 ; y = SI/SOL PORTEE 1 
 
 ; calculer y_min_clef_sol_portee_1 et 2
 mov eax, 17 ; 17
 mov edx, ptwi.ecart_note_y
 mul edx
 mov edx, ptwi.ecart_portee
 sub edx, eax
 mov y_min_clef_sol_portee_1, edx

 add edx,  ptwi.ecart_portee_double
 mov y_min_clef_sol_portee_2, edx
 
 ; calculer y_max_clef_sol_portee_1 et 2
 mov eax, 18
 mov edx, ptwi.ecart_note_y
 mul edx
 mov edx, ptwi.ecart_portee
 add edx, eax
 mov y_max_clef_sol_portee_1, edx
 
 add edx,  ptwi.ecart_portee_double
 mov y_max_clef_sol_portee_2, edx
 
 
 ; calculer y_min_clef_fa_portee_1 et 2
 mov eax, 7
 mov edx, ptwi.ecart_note_y
 mul edx
 mov edx, ptwi.ecart_portee
 sub edx, eax
 mov y_min_clef_fa_portee_1, edx
 
 add edx, ptwi.ecart_portee_double
 mov y_min_clef_fa_portee_2, edx
 
 
 ; calculer y_max_clef_fa_portee_1 et 2
 mov eax, 22
 mov edx, ptwi.ecart_note_y
 mul edx
 mov edx, ptwi.ecart_portee
 add edx, eax
 mov y_max_clef_fa_portee_1, edx
 
 add edx,  ptwi.ecart_portee_double
 mov y_max_clef_fa_portee_2, edx
; ******************************************

 
; fixer la distance entre deux portées
 .if ptwi.mode_portee == MODE_PORTEE_SIMPLE
  mov eax, ptwi.portee_simple
 .else
  mov eax, ptwi.portee_double
 .endif
 
 add eax, ptwi.ecart_portee
 mov portee_suivante, eax
 
 
 
 ; fixer temps_suivant
 mov temps_suivant, 0
 
 
 
 
 ; *****************************
 ; 1 ère imbrication
 ; x portées
 mov eax, ptwi.nb_portee_max
 mov compteur_nb_portee, eax
 
 @portee_suivante:
  
 ; retour en debut de ligne 
 mov eax, note_min_x
 mov trace_x, eax   
  
 ; **************************** 
 ; 2ème imbrication
 ; x notes par portée
 mov eax, ptwi.notes_par_portee
 mov compteur_notes_portee, eax
 mov eax, note_min_x
 mov trace_x, eax
 
 
 

 
 
 @temps_note_suivante:
 
 mov flag_note_hors_portee_haute_portee_1, 0
 mov flag_note_hors_portee_basse_portee_1, 0
 mov flag_note_hors_portee_haute_portee_2, 0
 mov flag_note_hors_portee_basse_portee_2, 0
 
 ; ***************************
 ; 3 ème imbrication
 ; x potentiels notes par clef
 
 ; portée 1
 .if ptwi.clef_simple == CLEF_SOL
 
  mov eax, portee_suivante
  mov edx, ptwi.nb_portee_max
  sub edx, compteur_nb_portee
  mul edx
  
   
  mov index_note_haute_portee_1, INDEX_CLEF_SOL_MAX
  mov index_note_basse_portee_1, INDEX_CLEF_SOL_MIN
  mov edx, y_min_clef_sol_portee_1
  add edx, eax 
  mov note_min_y_portee_1, edx
  mov edx, y_max_clef_sol_portee_1
  add edx, eax
  mov note_max_y_portee_1, edx
  mov compteur_notes_par_temps_portee_1, (INDEX_CLEF_SOL_MAX - INDEX_CLEF_SOL_MIN + 1)
   
  mov eax, index_note_haute_portee_1
  mov edx, TYPE note
  mul edx
  mov edx, offset notes_infos_portee_haute
  mov edx, [edx]
  add eax, edx
  add eax, temps_suivant
  mov pointeur_note_haute_portee_1, eax
 
  mov eax, index_note_basse_portee_1
  mov edx, TYPE note
  mul edx
  mov edx, offset notes_infos_portee_haute
  mov edx, [edx]
  add eax, edx
  add eax, temps_suivant
  mov pointeur_note_basse_portee_1, eax 
   
  mov eax, offset ligne_sup_clef_sol  
  mov pointeur_ligne_sup_haute_portee_1, eax
  mov edx, 4 * (INDEX_CLEF_SOL_MAX - INDEX_CLEF_SOL_MIN)
  add eax, edx
  mov pointeur_ligne_sup_basse_portee_1, eax
   
 .else
  
  ; CLEF_FA
  mov eax, portee_suivante
  mov edx, ptwi.nb_portee_max
  sub edx, compteur_nb_portee
  mul edx
  
  mov index_note_haute_portee_1, INDEX_CLEF_FA_MAX
  mov index_note_basse_portee_1, INDEX_CLEF_FA_MIN
  mov edx, y_min_clef_fa_portee_1
  add edx, eax 
  mov note_min_y_portee_1, edx
  mov edx, y_max_clef_fa_portee_1
  add edx, eax 
  mov note_max_y_portee_1, edx
  mov compteur_notes_par_temps_portee_1, (INDEX_CLEF_FA_MAX - INDEX_CLEF_FA_MIN + 1)
  
  mov eax, index_note_haute_portee_1
  mov edx, TYPE note
  mul edx
  mov edx, offset notes_infos_portee_haute
  mov edx, [edx]
  add eax, edx
  add eax, temps_suivant
  mov pointeur_note_haute_portee_1, eax
    
  mov eax, index_note_basse_portee_1
  mov edx, TYPE note
  mul edx
  mov edx, offset notes_infos_portee_haute
  mov edx, [edx]
  add eax, edx
  add eax, temps_suivant
  mov pointeur_note_basse_portee_1, eax
 
  mov eax, offset ligne_sup_clef_fa  
  mov pointeur_ligne_sup_haute_portee_1, eax
  mov edx, 4 * (INDEX_CLEF_FA_MAX - INDEX_CLEF_FA_MIN)
  add eax, edx
  mov pointeur_ligne_sup_basse_portee_1, eax
 
 .endif
 
 
 
 ; calcul pour la portée 2 si présente
 .if ptwi.mode_portee == MODE_PORTEE_DOUBLE

  .if ptwi.clef_double == CLEF_SOL
  
   mov eax, portee_suivante
   mov edx, ptwi.nb_portee_max
   sub edx, compteur_nb_portee
   mul edx
  
   mov index_note_haute_portee_2, INDEX_CLEF_SOL_MAX
   mov index_note_basse_portee_2, INDEX_CLEF_SOL_MIN
   mov edx, y_min_clef_sol_portee_2
   add edx, eax 
   mov note_min_y_portee_2, edx
   mov edx, y_max_clef_sol_portee_2
   add edx, eax
   mov note_max_y_portee_2, edx
   mov compteur_notes_par_temps_portee_2, (INDEX_CLEF_SOL_MAX - INDEX_CLEF_SOL_MIN + 1)
   
   mov eax, index_note_haute_portee_2
   mov edx, TYPE note
   mul edx
   mov edx, offset notes_infos_portee_basse
   mov edx, [edx]
   add eax, edx
   add eax, temps_suivant
   mov pointeur_note_haute_portee_2, eax
 
   mov eax, index_note_basse_portee_2
   mov edx, TYPE note
   mul edx
   mov edx, offset notes_infos_portee_basse
   mov edx, [edx]
   add eax, edx
   add eax, temps_suivant
   mov pointeur_note_basse_portee_2, eax 
   
   mov eax, offset ligne_sup_clef_sol  
   mov pointeur_ligne_sup_haute_portee_2, eax
   mov edx, 4 * (INDEX_CLEF_SOL_MAX - INDEX_CLEF_SOL_MIN)
   add eax, edx
   mov pointeur_ligne_sup_basse_portee_2, eax
   
  .else
  
   ; CLEF_FA
   mov eax, portee_suivante
   mov edx, ptwi.nb_portee_max
   sub edx, compteur_nb_portee
   mul edx
  
   mov index_note_haute_portee_2, INDEX_CLEF_FA_MAX
   mov index_note_basse_portee_2, INDEX_CLEF_FA_MIN
   mov edx, y_min_clef_fa_portee_2
   add edx, eax 
   mov note_min_y_portee_2, edx
   mov edx, y_max_clef_fa_portee_2
   add edx, eax 
   mov note_max_y_portee_2, edx
   mov compteur_notes_par_temps_portee_2, (INDEX_CLEF_FA_MAX - INDEX_CLEF_FA_MIN + 1)
  
   mov eax, index_note_haute_portee_2
   mov edx, TYPE note
   mul edx
   mov edx, offset notes_infos_portee_basse
   mov edx, [edx]
   add eax, edx
   add eax, temps_suivant
   mov pointeur_note_haute_portee_2, eax
    
   mov eax, index_note_basse_portee_2
   mov edx, TYPE note
   mul edx
   mov edx, offset notes_infos_portee_basse
   mov edx, [edx]
   add eax, edx
   add eax, temps_suivant
   mov pointeur_note_basse_portee_2, eax
 
   mov eax, offset ligne_sup_clef_fa  
   mov pointeur_ligne_sup_haute_portee_2, eax
   mov edx, 4 * (INDEX_CLEF_FA_MAX - INDEX_CLEF_FA_MIN)
   add eax, edx
   mov pointeur_ligne_sup_basse_portee_2, eax
   
  .endif
  
 .endif 
; ************************************* 
 
  
  
  ; trace les notes de la portée du haut
  @trace_notes_portee_1:
  
  ; tracer les notes deux par deux
  ; note du haut portée 1
  mov eax, pointeur_note_haute_portee_1
  mov edx, (note ptr [eax]).flag_afficher
  
  ; ligne sup potentiel a dessiner
  mov eax, pointeur_ligne_sup_haute_portee_1
  mov eax, [eax]
  
  .if edx == 1
   
   .if eax == OUI
   
    mov eax, note_min_y_portee_1
	sub eax, ptwi.ecart_note_y
    invoke partition_widget_dessine_ligne_sup, ptwi.hdc_zoom_x1, trace_x, eax
	mov flag_note_hors_portee_haute_portee_1, 1

   .elseif eax == NOTE_HORS_PORTEE
    mov flag_note_hors_portee_haute_portee_1, 1
   .endif	
   
   invoke partition_widget_dessine_une_note, ptwi.hdc_zoom_x1, trace_x, note_min_y_portee_1, pointeur_note_haute_portee_1
   
  .else
    
   .if flag_note_hors_portee_haute_portee_1 == 1 && eax == OUI
	 mov eax, note_min_y_portee_1
	 sub eax, ptwi.ecart_note_y
     invoke partition_widget_dessine_ligne_sup, ptwi.hdc_zoom_x1, trace_x, eax
   .endif
    
  .endif
  
  add pointeur_ligne_sup_haute_portee_1, 4
  
  
  
   
  ; note du bas portée 1
  mov eax, pointeur_note_basse_portee_1
  mov edx, (note ptr [eax]).flag_afficher
  
  ; ligne sup potentiel a dessiner
  mov eax, pointeur_ligne_sup_basse_portee_1
  mov eax, [eax]
    
  
  .if edx == 1
    
   .if eax == OUI

    mov eax, note_max_y_portee_1
    sub eax, ptwi.ecart_note_y
    invoke partition_widget_dessine_ligne_sup, ptwi.hdc_zoom_x1, trace_x, eax
    mov flag_note_hors_portee_basse_portee_1, 1

	.elseif eax == NOTE_HORS_PORTEE
   
    mov flag_note_hors_portee_basse_portee_1, 1	
	
   .endif
 
   invoke partition_widget_dessine_une_note, ptwi.hdc_zoom_x1, trace_x, note_max_y_portee_1, pointeur_note_basse_portee_1
   
  .else
   
   .if flag_note_hors_portee_basse_portee_1 == 1 && eax == OUI
	 mov eax, note_max_y_portee_1
	 sub eax, ptwi.ecart_note_y
     invoke partition_widget_dessine_ligne_sup, ptwi.hdc_zoom_x1, trace_x, eax
   .endif
   
   
  .endif
  
  
  sub pointeur_ligne_sup_basse_portee_1, 4
  
  
  
  
  ; note suivante
  mov eax, ptwi.ecart_note_y
  add note_min_y_portee_1, eax
  sub note_max_y_portee_1, eax
  
  inc index_note_haute_portee_1
  dec index_note_basse_portee_1
  sub pointeur_note_haute_portee_1, TYPE note
  add pointeur_note_basse_portee_1, TYPE note
  
  sub compteur_notes_par_temps_portee_1, 2
  jnz @trace_notes_portee_1
; ***************************************************************************************************

 
 
 
 ; trace les notes de la portée du bas si présente
 .if ptwi.mode_portee == MODE_PORTEE_DOUBLE
  
  @trace_notes_portee_2:
  
  ; tracer les notes deux par deux
  ; note du haut portée 2
  mov eax, pointeur_note_haute_portee_2
  mov edx, (note ptr [eax]).flag_afficher
  
  ; ligne sup potentiel a dessiner
  mov eax, pointeur_ligne_sup_haute_portee_2
  mov eax, [eax]
  
  .if edx == 1
   
   .if eax == OUI
   
    mov eax, note_min_y_portee_2
	sub eax, ptwi.ecart_note_y
    invoke partition_widget_dessine_ligne_sup, ptwi.hdc_zoom_x1, trace_x, eax
	mov flag_note_hors_portee_haute_portee_2, 1

   .elseif eax == NOTE_HORS_PORTEE
    mov flag_note_hors_portee_haute_portee_2, 1
   .endif	
   
   invoke partition_widget_dessine_une_note, ptwi.hdc_zoom_x1, trace_x, note_min_y_portee_2, pointeur_note_haute_portee_2
   
  .else
    
   .if flag_note_hors_portee_haute_portee_2 == 1 && eax == OUI
	 mov eax, note_min_y_portee_2
	 sub eax, ptwi.ecart_note_y
     invoke partition_widget_dessine_ligne_sup, ptwi.hdc_zoom_x1, trace_x, eax
   .endif
    
  .endif
  
  add pointeur_ligne_sup_haute_portee_2, 4
  
  
  
   
  ; note du bas portée 2
  mov eax, pointeur_note_basse_portee_2
  mov edx, (note ptr [eax]).flag_afficher
  
  ; ligne sup potentiel a dessiner
  mov eax, pointeur_ligne_sup_basse_portee_2
  mov eax, [eax]
    
  
  .if edx == 1
    
   .if eax == OUI

    mov eax, note_max_y_portee_2
    sub eax, ptwi.ecart_note_y
    invoke partition_widget_dessine_ligne_sup, ptwi.hdc_zoom_x1, trace_x, eax
    mov flag_note_hors_portee_basse_portee_2, 1

	.elseif eax == NOTE_HORS_PORTEE
   
    mov flag_note_hors_portee_basse_portee_2, 1	
	
   .endif
 
   invoke partition_widget_dessine_une_note, ptwi.hdc_zoom_x1, trace_x, note_max_y_portee_2, pointeur_note_basse_portee_2
   
  .else
   
   .if flag_note_hors_portee_basse_portee_2 == 1 && eax == OUI
	 mov eax, note_max_y_portee_2
	 sub eax, ptwi.ecart_note_y
     invoke partition_widget_dessine_ligne_sup, ptwi.hdc_zoom_x1, trace_x, eax
   .endif
   
   
  .endif
  
  
  sub pointeur_ligne_sup_basse_portee_2, 4
  
  
  
  
  ; note suivante
  mov eax, ptwi.ecart_note_y
  add note_min_y_portee_2, eax
  sub note_max_y_portee_2, eax
  
  inc index_note_haute_portee_2
  dec index_note_basse_portee_2
  sub pointeur_note_haute_portee_2, TYPE note
  add pointeur_note_basse_portee_2, TYPE note
  
  sub compteur_notes_par_temps_portee_2, 2
  jnz @trace_notes_portee_2
  
 .endif
; ***************************************************************************************************
  
 
 ; fixer x pour la note suivante
 mov eax, trace_x
 add eax, ptwi.espace_mesure_note_noire
 mov trace_x, eax 
 
 
 ; temps suivant
 add temps_suivant, (NOTES_TEMPS_MAX + DECALAGE_OCTAVE_0) * TYPE note
 
 dec compteur_notes_portee
 jnz @temps_note_suivante
 
 
 
 ; portée suivante
 dec compteur_nb_portee
 jnz @portee_suivante
 
 ret

partition_widget_dessine_notes endp



; *******************************
; la_note -> pointeur sur la structure de la définition de la note
partition_widget_dessine_une_note proc hdc:dword, trace_x:dword, trace_y:dword, la_note:dword

 LOCAL hpen_hampe:dword
 LOCAL hpen_note:dword
 LOCAL hbrush:dword
 LOCAL lb:LOGBRUSH
 LOCAL note_x1:dword
 LOCAL note_y1:dword
 LOCAL note_x2:dword
 LOCAL note_y2:dword
 
 LOCAL couleur_note:dword
 LOCAL orientation_note:dword
 LOCAL type_note:dword
 LOCAL hampe_note:dword
 LOCAL alteration_note:dword
 
 
 
 mov hbrush, 0
 
 mov edx, la_note
 mov eax, (note ptr [edx]).type_
 mov type_note, eax
 
 mov eax, (note ptr [edx]).couleur
 mov couleur_note, eax
 
 mov eax, (note ptr [edx]).hampe
 mov hampe_note, eax
 
 mov eax, (note ptr [edx]).orientation
 mov orientation_note, eax
 
 mov eax, (note ptr [edx]).alteration
 mov alteration_note, eax
 
 
 mov lb.lbStyle, BS_SOLID
 mov eax, couleur_note
 mov lb.lbColor, eax
 mov lb.lbHatch, HS_VERTICAL ; pas utilisé
 
 
 
 

 ; crayon pour la note 
 invoke CreatePen, PS_SOLID, 2, couleur_note
 mov hpen_note, eax
 
 
 ; crayon pour la hampe de couleur noire
 invoke CreatePen, PS_SOLID, 2, 0
 mov hpen_hampe, eax
 invoke SelectObject, hdc, eax
 
 
 ; créer un pinceau selon le type de note 
 .if type_note == TYPE_NOTE_NOIRE
 
  ; remplissage de la note
  invoke CreateBrushIndirect, addr lb
  mov hbrush, eax
  invoke SelectObject, hdc, eax
 
 .else
 
  ; pinceau vide pour la ronde et la blanche
  invoke GetStockObject, NULL_BRUSH
  invoke SelectObject, hdc, eax
 
 .endif
 ; **************************************
 
 
 ; traçage de la hampe sauf pour le type de note ronde
 .if type_note != TYPE_NOTE_RONDE
  
  ; hampe dirigée vers le haut
  .if hampe_note == HAMPE_EN_HAUT
 
   mov eax, trace_y
   sub eax, ptwi.hampe_y
   sub eax, ptwi.hampe_y
   ; sub eax, ptwi.hampe_y
   mov edx, trace_x
   
   invoke MoveToEx, hdc, edx, eax, NULL
 
   mov eax, trace_y
   sub eax, ptwi.hampe_taille
   mov edx, trace_x
   
   invoke LineTo, hdc, edx, eax
  
  
  ; hampe dirigée vers le bas
  .elseif hampe_note == HAMPE_EN_BAS
  
   mov eax, trace_y
   sub eax, ptwi.hampe_y
   sub eax, ptwi.hampe_y
   mov edx, trace_x
   
   invoke MoveToEx, hdc, edx, eax, NULL
 
   mov eax, trace_y
   add eax, ptwi.hampe_taille
   sub eax, ptwi.note_y
   mov edx, trace_x
   
   invoke LineTo, hdc, edx, eax 
  
  
  .endif
 
 .endif
 ; **************************************************************
 
 
  
  ; traçage de la note
 .if orientation_note == ORIENTATION_NOTE_GAUCHE  
 
  
 
  ; déssiner la note à gauche de la hampe
  mov eax, trace_x
  sub eax, ptwi.note_x
  add eax, ptwi.note_correction_x
  
  ;inc eax  ; note plus proche de la hampe +1
  ; inc eax
  mov note_x1, eax
  add eax, ptwi.note_x
  mov note_x2, eax
       	  	  
 .else
 
  ; déssiner la note à droite de la hampe
  mov eax, trace_x
  add eax, ptwi.note_x
  sub eax, ptwi.note_correction_x
  mov note_x1, eax
  sub eax, ptwi.note_x
  mov note_x2, eax
  
 .endif

 
 
 
 mov eax, trace_y
 sub eax, ptwi.note_y
 mov note_y1, eax
 add eax, ptwi.note_y
 mov note_y2, eax

 mov eax, note_y1
 mov edx, note_y2
 
 mov ecx, ptwi.note_y
 sub eax, ecx
 sub edx, ecx
 
 shr ecx, 2
 sub eax, ecx
 sub edx, ecx

 invoke SelectObject, hdc, hpen_note
 
 ; trace la note
 invoke Ellipse, hdc, note_x2, note_y2, note_x1, note_y1
 

 ; tracer l'altération
 .if alteration_note != NOTE_NATURELLE

  mov edx, trace_x
  sub edx, ptwi.note_x
  sub edx, ptwi.note_x
  ; edx = x
  
  
  mov ecx, trace_y
  sub ecx, ptwi.note_y
  sub ecx, ptwi.note_y
  mov eax, ptwi.note_y
  shr eax, 2
  sub ecx, eax
  ; ecx = y
  
  invoke partition_widget_dessine_alteration, alteration_note, hdc, edx, ecx, couleur_note
    
 .endif
  
 
 
 invoke DeleteObject, hpen_hampe
 invoke DeleteObject, hpen_note
  
 .if hbrush != 0
  invoke DeleteObject, hbrush
 .endif
 
 

 ret

partition_widget_dessine_une_note endp




; **********************************
partition_widget_dessine_alteration proc alteration:dword, hdc:dword, trace_x:dword, trace_y:dword, couleur:dword

 LOCAL hdc_diese:dword
 LOCAL hdc_bemol:dword
 LOCAL hdc_tmp
 LOCAL hbitmap:dword
 
 
 invoke CreateCompatibleDC, hdc
 mov hdc_diese, eax
 invoke SelectObject, eax, ptwi.h_bitmap_diese
 
 invoke CreateCompatibleDC, hdc
 mov hdc_bemol, eax
 invoke SelectObject, eax, ptwi.h_bitmap_bemol
 
 invoke CreateCompatibleBitmap, hdc, ptwi.bitmap_diese_x_max, ptwi.bitmap_diese_y_max
 mov hbitmap, eax
 
 invoke CreateCompatibleDC, hdc
 mov hdc_tmp, eax
 invoke SelectObject, eax, hbitmap
 
 
 .if alteration == NOTE_DIESE
 
  ; mise à l'échelle du diese
  invoke StretchBlt, hdc_tmp, 0, 0, ptwi.bitmap_diese_x_max, ptwi.bitmap_diese_y_max, hdc_diese, 0, 0, DIESE_BMP_X_MAX, DIESE_BMP_Y_MAX, SRCCOPY 
 
  
  ; considérer les pixels blancs comme transparent
  invoke partition_widget_trace_bitmap_alpha, hdc, hdc_tmp, trace_x, trace_y, ptwi.bitmap_diese_x_max, ptwi.bitmap_diese_y_max, 0FFFFFFh, couleur
   
 .else
  ; tracer le bémol
  
  ; mise à l'échelle du diese
  invoke StretchBlt, hdc_tmp, 0, 0, ptwi.bitmap_bemol_x_max, ptwi.bitmap_bemol_y_max, hdc_bemol, 0, 0, BEMOL_BMP_X_MAX, BEMOL_BMP_Y_MAX, SRCCOPY 
 
  ; considérer les pixels blancs comme transparent
  invoke partition_widget_trace_bitmap_alpha, hdc, hdc_tmp, trace_x, trace_y, ptwi.bitmap_bemol_x_max, ptwi.bitmap_bemol_y_max, 0FFFFFFh, couleur
  
  
 
 .endif

 
  
 ; libérer les DC
 invoke DeleteDC, hdc_diese 
 invoke DeleteDC, hdc_bemol
 invoke DeleteDC, hdc_tmp
 invoke DeleteObject, hbitmap
 
 ret
 
 
partition_widget_dessine_alteration endp




; ************************************
partition_widget_dessine_ligne_sup proc hdc:dword, trace_x:dword, trace_y:dword

 local hpen_t2:dword
  
 
 ; ligne noire
 invoke CreatePen, PS_SOLID, 2, 0
 mov hpen_t2, eax
 invoke SelectObject, hdc, hpen_t2
 
 mov eax, trace_x
 add eax, ptwi.note_x
 add eax, ptwi.ligne_sup_x
 
 invoke MoveToEx, hdc, eax, trace_y, NULL
 
 
 mov eax, trace_x
 sub eax, ptwi.note_x
 sub eax, ptwi.ligne_sup_x
 
 invoke LineTo, hdc, eax, trace_y
 
 
 
 invoke DeleteObject, hpen_t2

 ret

partition_widget_dessine_ligne_sup endp




; *********************************************
partition_widget_zoom proc pourcentage:dword, sens:dword


 ; zoom courant
 mov eax, ptwi.zoom_partition
 mov ptwi.zoom_partition_precedent, eax ; garder l'ancien zoom, en cas d'erreur avec le nouveau zoom
 
  .if sens == ZOOM_PLUS
   
   add eax, pourcentage
   
   .if eax > ptwi.zoom_max
    ; forcer la valeur du zoom sur le max
	mov eax, ptwi.zoom_max
   
    ; vérifier si c'est le zoom courant
	.if eax == ptwi.zoom_partition
	 ; ne rien faire
	 ret
	.endif
   .endif
  
  .else
  
   ; ZOOM_MOINS
   ; Attention le registre eax peut reboucler et être supérieur ptwi.zoom_max
   sub eax, pourcentage
   
   
   .if eax < ptwi.zoom_min || eax > ptwi.zoom_max
    ; forcer la valeur du zoom sur le max
	mov eax, ptwi.zoom_min
   
    ; vérifier si c'est le zoom courant
	.if eax == ptwi.zoom_partition
	 ; ne rien faire
	 ret
	.endif 
   .endif
   
   
  .endif

 ; nouveau zoom
 mov ptwi.zoom_partition, eax

 invoke partition_widget_bitmap_zoom_x1_alloc
    
 invoke partition_widget_resize
   
 ; éffacer l'arrière plan	
 invoke partition_widget_maj_affichage, 1

 ret

partition_widget_zoom endp




; *****************************************
partition_widget_notes_reset proc

  
 mov ecx, NOTES_TEMPS_MAX * TEMPS_MAX
 mov eax, offset notes_infos_portee_haute
 mov eax, [eax]
 mov edx, offset notes_infos_portee_basse
 mov edx, [edx]
 
 @notes_reset:
 
  ; invalide les notes des deux portées
  mov (note PTR [eax]).flag_afficher, 0
  mov (note PTR [edx]).flag_afficher, 0
 
 ; note suivante
 add eax, TYPE note
 add edx, TYPE note
 dec ecx
 jnz @notes_reset
 
 
 ; remise à zéro des notes
 mov ptwi.flag_dessine_bitmap_zoom, 1
 
 invoke partition_widget_maj_affichage, 1

 ret

partition_widget_notes_reset endp




; ************************************
partition_widget_note_def proc numero_temps:dword, type_note:dword, couleur_note:dword, la_note:dword, portee_note:dword, hampe_note:dword, orientation_note:dword, flag_afficher_note:dword 

 LOCAL p_note:dword
 LOCAL numero_note:dword
 LOCAL numero_octave:dword
 LOCAL alteration:dword
 
  
 ; décompacter la_note
 mov numero_octave, 0
 mov numero_note, 0
 mov alteration, 0
 
 mov eax, la_note
 mov byte ptr [numero_octave], al
 shr eax, 8
 mov byte ptr [numero_note], al
 shr eax, 8
 mov byte ptr [alteration], al
 ; *****************************
  
 
 ; pointer sur la première note du temps choisi
 mov eax, numero_temps
 
 .if eax >= ptwi.nb_temps_max
  ; note hors plage
  xor eax, eax
  ret
 .endif

 mov edx, type note
 mul edx
 mov edx, NOTES_TEMPS_MAX + DECALAGE_OCTAVE_0 ; (57)
 mul edx
 ; eax = octave 0, note 0
 
 
 .if ptwi.mode_portee == MODE_PORTEE_DOUBLE
  
  .if portee_note == PORTEE_HAUTE
   mov edx, offset notes_infos_portee_haute
   mov edx, [edx]
   add eax, edx
  .else
   mov edx, offset notes_infos_portee_basse
   mov edx, [edx]
   add eax, edx
  .endif
   
 .else
  
   mov edx, offset notes_infos_portee_haute
   mov edx, [edx]
   add eax, edx
 .endif
 
 ; eax = pointeur sur l'adresse mémoire qui correspond à l'octave 0, note 0 (DO)
 mov p_note, eax

 mov eax, numero_octave
 mov ecx, 7  ; notes possibles par octave
 mul ecx
 add eax, numero_note ; sélection de la note 
 
 ; ajuster p_note pour qu'il pointe sur la note final a modifier
 mov edx, TYPE note
 mul edx
 add p_note, eax
  
   
 ; fixer le type de note
 mov edx, type_note
 
 .if edx == TYPE_NOTE_NOIRE || edx == TYPE_NOTE_BLANCHE || edx == TYPE_NOTE_RONDE
 
  mov eax, p_note
  mov (note PTR [eax]).type_, edx
 
 .else
  
  mov eax, p_note
  mov (note PTR [eax]).type_, TYPE_NOTE_NOIRE
 
 .endif
 ; *******************
 
 
 
 ; fixer la couleur de la note
 mov edx, couleur_note
 mov eax, p_note
 mov (note PTR [eax]).couleur, edx
 ; *************************** 

 
 
 ; fixer l'altération de la note
 mov edx, alteration
 mov eax, p_note
 mov (note PTR [eax]).alteration, edx
 ; *******************
 
 
 
 ; fixer le type de hampe de la note
 mov edx, hampe_note
 
 .if edx == HAMPE_EN_HAUT
 
  mov eax, p_note
  mov (note PTR [eax]).hampe, HAMPE_EN_HAUT
 
 .elseif edx == HAMPE_EN_BAS
  
  mov eax, p_note
  mov (note PTR [eax]).hampe, HAMPE_EN_BAS
 
 .elseif edx == HAMPE_ABSENTE
 
  mov eax, p_note
  mov (note PTR [eax]).hampe, HAMPE_ABSENTE
 
 .else
 
  ; par défaut
  mov eax, p_note
  mov (note PTR [eax]).hampe, HAMPE_EN_HAUT
 
 .endif
 ; *******************
 
 
  ; fixer l'orientation de la note
 mov edx, orientation_note
 
 .if edx == ORIENTATION_NOTE_DROITE
 
  mov eax, p_note
  mov (note PTR [eax]).orientation, ORIENTATION_NOTE_DROITE
 
 .else
  
  mov eax, p_note
  mov (note PTR [eax]).orientation, ORIENTATION_NOTE_GAUCHE
 
 .endif
 ; *******************
 
 
 ; fixer le flag d'affichage de la note
 mov edx, flag_afficher_note
 
 .if edx == 0
  
  mov eax, p_note
  mov (note PTR [eax]).flag_afficher, NON
 
 .else
 
  mov eax, p_note
  mov (note PTR [eax]).flag_afficher, OUI
 
 .endif
 ; *******************
  
 
 ; nouvelle note dans la base de données
 mov ptwi.flag_dessine_bitmap_zoom, 1
 
 mov eax, 1
 ret

partition_widget_note_def endp



; **************************************************
partition_widget_maj_affichage proc efface_arriere_plan:dword

 
 ; 1 = éfface l'arrière plan avec la couleur wc.hbrBackground
 ; 0 = n'éfface pas
 invoke InvalidateRect, ptwi.hwnd, NULL, efface_arriere_plan
  
 ret

partition_widget_maj_affichage endp



; ******************************************
; la note : note compactée par la fonction midi
; clef : type de cle de la portée CLEF_SOL ou CLEF_FA
; retour eax=1 si hors plage , sinon 0
partition_widget_hors_portee proc la_note:dword, clef:dword

 ; isoler l'octave
 mov edx, la_note
 and edx, 0FFh
 
 .if clef == CLEF_SOL
  
  ; octave min = 3, max = 8
  .if edx >= 3 && edx <= 8
   xor eax, eax
  .else
   mov eax, 1
  .endif
 
 .else
  
  ; CLEF_FA
  ; octave min = 0, max = 4
  .if edx >= 0 && edx <= 4
   xor eax, eax
  .else
   mov eax, 1
  .endif
 
 .endif


 ret

partition_widget_hors_portee endp




; **************************************
partition_widget_roulette_souris proc wParam:dword, lParam:dword

 LOCAL zoom_sens:dword
 ; LOCAL pourcentage:dword
 
 ; wParam 16 bits de poids fort (valeur signée), indicateur de distance de la rotation de la souris exprimé en multiple ou division de WHEEL_DELTA (120)
 ; valeur positive : roulette tourné vers l'avant
 ; valeur négative : roulette tourné vers l'arrière
 
 
 ; déterminer le sens de la roulette
 mov eax, wParam
 shr eax, 16
 mov edx, eax
 and edx, 8000h
 
 
 .if edx == 8000h
  
  ; adapter la valeur en positive
  not ax
  inc ax  
 
  mov zoom_sens, ZOOM_MOINS
  
 .else
  mov zoom_sens, ZOOM_PLUS
 .endif
 
 
 ; valeur qui représente des multiples de 120
 xor edx, edx
 mov ecx, WHEEL_DELTA
 div ecx
 mov ecx, 10 ; 10 %
 mul ecx
  
 invoke partition_widget_zoom, eax, zoom_sens

 ret

partition_widget_roulette_souris endp




; *************************************
partition_widget_auto_scroll_temps proc temps:dword

 LOCAL s_info_hx:SCROLLINFO
 LOCAL s_info_vy:SCROLLINFO
 
 LOCAL numero_portee:dword
 LOCAL numero_note:dword
  
 
 ; autoscrolling activé ?
 .if ptwi.flag_autoscrolling == 0
  ret
 .endif
 
 
 ; à partir du temp définir le numéro de la note et de la portée
 xor edx, edx
 mov eax, temps
 mov ecx, ptwi.notes_par_portee
 div ecx
 
 mov numero_portee, eax
 mov numero_note, edx
 
 
 
 
 mov s_info_hx.fMask, SIF_POS or SIF_RANGE
 mov s_info_hx.cbSize, SIZEOF SCROLLINFO
 invoke GetScrollInfo, ptwi.h_scrollbar_h, SB_CTL, addr s_info_hx
 
 mov s_info_vy.fMask, SIF_POS or SIF_RANGE
 mov s_info_vy.cbSize, SIZEOF SCROLLINFO
 invoke GetScrollInfo, ptwi.h_scrollbar_v, SB_CTL, addr s_info_vy


 
 ; barre verticale si présente
 .if ptwi.flag_barre_verticale == 1
 
  xor edx, edx
  mov eax, ptwi.bitmap_y_max
  mov ecx, ptwi.nb_portee_max
  
  ; add ecx, 4
  
  div ecx  ; eax = nb déplacements verticaux par portée
 
  mov ecx, numero_portee
  mul ecx  ; nouvelle position de la barre verticale
  
  ; simuler un message WM_VSCROLL avec le code SB_THUMBTRACK (wParam 16 bits de poids faible) 16 bits de poids fort = nouvelle pos 
  ; lParam handle de la barre verticale 
  shl eax, 16
  mov ax, SB_THUMBTRACK
  
  invoke PostMessage, ptwi.hwnd, WM_VSCROLL, eax, ptwi.h_scrollbar_v
 
 
 .endif
 
 
 
 
 ; barre horizontale si présente
 .if ptwi.flag_barre_horizontale == 1
 
  xor edx, edx
  mov eax, ptwi.bitmap_x_max
  mov ecx, ptwi.notes_par_portee ; s_info_hx.nMax
  add ecx, 4
  
  div ecx  ; eax = nb déplacements horizontaux par temps
 
  mov ecx, numero_note
  mul ecx  ; nouvelle position de la barre horizontale
  
  ; simuler un message WM_HSCROLL avec le code SB_THUMBTRACK (wParam 16 bits de poids faible) 16 bits de poids fort = nouvelle pos 
  ; lParam handle de la barre horizontale 
  shl eax, 16
  mov ax, SB_THUMBTRACK
  
  invoke PostMessage, ptwi.hwnd, WM_HSCROLL, eax, ptwi.h_scrollbar_h
 
 
 .endif

 
 ret

partition_widget_auto_scroll_temps endp



; ********************************************************
; ex : invoke partition_widget_trace_bitmap_alpha, ptwi.hdc_zoom_x1, hmem_clef_sol, 150, 300, ptwi.bitmap_clef_sol_x_max, ptwi.bitmap_clef_sol_y_max, 0FFFFFFh, 0
; déssiner le bitmap dans le hdc en trace_x, trace_y
partition_widget_trace_bitmap_alpha proc hdc_dest:dword, hdc_source:dword, trace_x:dword, trace_y:dword, hdc_source_x_max:dword, hdc_source_y_max:dword, couleur_alpha:dword, couleur_substitution:dword

 LOCAL hdc_dest_x:dword
 LOCAL hdc_dest_y:dword
 LOCAL hdc_source_x:dword
 LOCAL hdc_source_y:dword

   
 mov eax, trace_y
 mov hdc_dest_y, eax
 mov hdc_source_y, 0
 
 
 @axe_y:
 
  ; retour en debut de ligne pour les deux hdc
  mov eax, trace_x
  mov hdc_dest_x, eax
  
  mov hdc_source_x, 0
  
  
  mov ecx, hdc_source_x_max
 
 @axe_x:
     
  .if hdc_source_x < ecx
   
   push ecx
   
   ; récupérer la couleur de la pixel du hdc source
   invoke GetPixel, hdc_source, hdc_source_x, hdc_source_y
  
   ; si il ne s'agit de la couleur de transparence, alors tracer le point dans hdc de destination
   .if eax != couleur_alpha 
   
    ; si couleur_substitution=0 alors l'objet reste noir
    invoke SetPixel, hdc_dest, hdc_dest_x, hdc_dest_y, couleur_substitution  
	
   .endif
   
   
   pop ecx
 
  .else
  
    ; passe à la ligne suivante
    inc hdc_dest_y
	inc hdc_source_y 
	mov eax, hdc_source_y_max
   .if hdc_source_y < eax
    
	jmp @axe_y
   .else
    ; opération terminée
    ret   
   .endif
 
  .endif
 
 
 
 inc hdc_dest_x
 inc hdc_source_x
 jmp @axe_x
 



 ret

partition_widget_trace_bitmap_alpha endp



; **********************************
partition_widget_fixe_auto_scrolling proc etat:dword

 .if etat == 0
  mov ptwi.flag_autoscrolling, 0
 .else
  mov ptwi.flag_autoscrolling, 1
 .endif

 ret

partition_widget_fixe_auto_scrolling endp
 

 
; ************************************ 
partition_widget_souris_scrolling proc wParam:dword, lParam:dword
 
 LOCAL souris_x:dword
 LOCAL souris_y:dword
 LOCAL s_info_hx:SCROLLINFO
 LOCAL s_info_vy:SCROLLINFO
 
 
 ; vérifier si le click gauche est encore appuyé
 mov eax, wParam
 and eax, MK_LBUTTON
 
 .if eax != MK_LBUTTON
  ret
 .endif
 
 
 ; récupérer les coordonnées de la souris
 mov eax, lParam
 mov edx, eax
 and eax, 0FFFFh ; x
 shr edx, 16     ; y
 
 mov souris_x, eax
 mov souris_y, edx
 
 
 
 mov s_info_hx.fMask, SIF_POS or SIF_RANGE
 mov s_info_hx.cbSize, SIZEOF SCROLLINFO
 invoke GetScrollInfo, ptwi.h_scrollbar_h, SB_CTL, addr s_info_hx
 
 mov s_info_vy.fMask, SIF_POS or SIF_RANGE
 mov s_info_vy.cbSize, SIZEOF SCROLLINFO
 invoke GetScrollInfo, ptwi.h_scrollbar_v, SB_CTL, addr s_info_vy
 
 
 
 ; déplacement sur l'axe des x
 .if ptwi.flag_barre_horizontale == 1
 
  ; définir le sens du déplacement
  mov edx, souris_x
  .if edx > ptwi.click_gauche_souris_x
   
   ; vers la gauche
   sub edx, ptwi.click_gauche_souris_x
      
   ; décaler le scrolling horizontal vers la gauche
   .if  s_info_hx.nPos == 0
    jmp @axe_y
   .endif   

   
   mov eax, s_info_hx.nPos
   
   ; réduire le déplacement si besoin
   .if edx > s_info_hx.nPos
    mov eax, 0
   .else
	sub eax, edx 
   .endif
     
     
   ; simuler un message WM_HSCROLL avec le code SB_THUMBTRACK (wParam 16 bits de poids faible) 16 bits de poids fort = nouvelle pos 
   ; lParam handle de la barre horizontale 
   shl eax, 16
   mov ax, SB_THUMBTRACK
  
   invoke PostMessage, ptwi.hwnd, WM_HSCROLL, eax, ptwi.h_scrollbar_h  
   
     
  .else
  
   ; vert la droite
   mov edx, ptwi.click_gauche_souris_x
   sub edx, souris_x
     
   
   mov eax, s_info_hx.nMax
   .if  s_info_hx.nPos == eax
    jmp @axe_y
   .endif   

   ; décaler le scrolling horizontal vers la droite
   ; edx le déplacement
   mov eax, s_info_hx.nPos
   add eax, edx
      
   
   ; réduire le déplacement si besoin
   .if eax > s_info_hx.nMax
    mov eax, s_info_hx.nMax
   .endif

   
   ; simuler un message WM_HSCROLL avec le code SB_THUMBTRACK (wParam 16 bits de poids faible) 16 bits de poids fort = nouvelle pos 
   ; lParam handle de la barre horizontale 
   shl eax, 16
   mov ax, SB_THUMBTRACK
  
   invoke PostMessage, ptwi.hwnd, WM_HSCROLL, eax, ptwi.h_scrollbar_h
  
  
  .endif  
 
 
 
 .endif
 ; ***********************************************************************
 
 
 @axe_y:
 
 
  ; déplacement sur l'axe des y
  .if ptwi.flag_barre_verticale == 1
   
   ; définir le sens du déplacement
   mov edx, souris_y
  .if edx > ptwi.click_gauche_souris_y
   
   ; vers la gauche
   sub edx, ptwi.click_gauche_souris_y
   
   ; décaler le scrolling verticale le haut
   .if  s_info_vy.nPos == 0
    jmp @souris_pos
   .endif   

   ; réduire le déplacement si besoin
   mov eax, s_info_vy.nPos
   
   ; réduire le déplacement si besoin
   .if edx > s_info_vy.nPos
    mov eax, 0
   .else
	sub eax, edx 
   .endif  
  
   ; simuler un message WM_VSCROLL avec le code SB_THUMBTRACK (wParam 16 bits de poids faible) 16 bits de poids fort = nouvelle pos 
   ; lParam handle de la barre verticale 
   shl eax, 16
   mov ax, SB_THUMBTRACK
  
   invoke PostMessage, ptwi.hwnd, WM_VSCROLL, eax, ptwi.h_scrollbar_v  
      
  .else
  
   ; vert la droite
   mov edx, ptwi.click_gauche_souris_y
   sub edx, souris_y
   
   
    mov eax, s_info_vy.nMax
   .if  s_info_vy.nPos == eax
    jmp @souris_pos
   .endif   

    ; décaler le scrolling verticale vers le bas
    ; edx le déplacement
	mov eax, s_info_vy.nPos
    add eax, edx
    
   ; réduire le déplacement si besoin
   .if eax > s_info_vy.nMax
    mov eax, s_info_vy.nMax
   .endif  
  
   ; simuler un message WM_VSCROLL avec le code SB_THUMBTRACK (wParam 16 bits de poids faible) 16 bits de poids fort = nouvelle pos 
   ; lParam handle de la barre verticale 
   shl eax, 16
   mov ax, SB_THUMBTRACK
  
   invoke PostMessage, ptwi.hwnd, WM_VSCROLL, eax, ptwi.h_scrollbar_v
    
  .endif  
  
  
  .endif
 ; **********************************************************************************************
 
 
  @souris_pos:
  
  ; ancienne position de la souris = la nouvelle 
  mov eax, souris_x
  mov edx, souris_y
  mov ptwi.click_gauche_souris_x, eax
  mov ptwi.click_gauche_souris_y, edx
 
 
 
 
 
 ret
 
partition_widget_souris_scrolling endp

END
