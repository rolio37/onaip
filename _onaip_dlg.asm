COMMENT &

    onaip -- piano software

    Copyright (C) 2015-2022  Ch�dotal Julien

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


 


.data?

 odc onaip_dlg_controls <>

 
.data

 index_temps dword 0    ; index du temps pour le mode libre
 
 
 NomDlgAproposde byte "APROPOSDE_DLG", 0
 NomDlgPartition byte "PARTITION_DLG", 0
 NomDlgExerciceNote byte "EXERCICE_NOTES_DLG", 0
 NomDlgExerciceOreille byte "EXERCICE_OREILLE_DLG", 0
 
 
 TitreDlgPartitionModeLibre byte "Partition - Mode libre ( -/+ Zoom )", 0  
 TitreDlgPartitionModeLectureNotes byte "Partition - Mode exercice -> lecture des notes ( +/- Zoom )", 0
 TitreDlgPartitionModeTravailOreille byte "Partition - Mode exercice -> travail de l'oreille ( +/- Zoom )", 0
 

 ErrMsgMidiIn byte "Impossible d'ouvrir le p�riph�rique midi in courant, actualiser la liste ?", 0
 ErrMsgMidiOut byte "Impossible d'ouvrir le p�riph�rique midi out courant, actualiser la liste ?:", 0
 ErrMsgMidi byte "Information", 0
 

 ErrMidiIn1 byte "aucun p�riph�rique disponible", 0
 ErrMidiOut1 byte "aucun p�riph�rique disponible", 0
 
 
 c_port_midi byte "port 1 ", 0,  \
                  "port 2 ", 0,  \
				  "port 3 ", 0,  \
				  "port 4 ", 0,  \
				  "port 5 ", 0,  \
				  "port 6 ", 0,  \
				  "port 7 ", 0,  \
				  "port 8 ", 0,  \
				  "port 9 ", 0,  \
				  "port 10", 0,  \
				  "port 11", 0,  \
				  "port 12", 0,  \
				  "port 13", 0,  \
				  "port 14", 0,  \
				  "port 15", 0,  \
				  "port 16", 0


				  

 
 
 

.code


onaip_dlg_proc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

 LOCAL rect1:RECT
 
 .IF uMsg == WM_CLOSE
 
  invoke EndDialog, odc.hwnd_exercice, NULL
  invoke EndDialog, odc.hwnd_partition, NULL
  
  
  ; stopper la capture
  invoke midi_in_stop_capture
  
  ; il s'agit de la fen�tre principale donc fermer les deux p�riph�riques midi in et out si besoin
  invoke midi_in_fermer
  invoke midi_out_fermer
  
  invoke EndDialog, hWnd, NULL
 
 
 .ELSEIF uMsg == WM_INITDIALOG

  ; handle de la fen�tre parent
  mov eax, hWnd
  mov odc.hwnd, eax
 
  invoke onaip_dlg_init
 
 
  invoke PostMessage, hWnd, WM_PARTITION_LIBRE, NULL, NULL
 
 
 .ELSEIF uMsg == WM_PARTITION_LIBRE
  
  ; la fen�tre exercice a �t� ferm�
  mov odc.hwnd_exercice, 0
 
  ; reprendre la main sur la fen�tre partition
  invoke partition_widget_def, MODE_PORTEE_DOUBLE, CLEF_SOL, CLEF_FA, 20, 1
 
 
  mov index_temps, 0
  
  ; lancer la capture
  invoke midi_in_start_capture, 1, 0, odc.hwnd
 
  ; r�sactiver les choix des exercices dans le menu
  invoke onaip_dlg_etat_menu_exercices, 1
 
  invoke partition_dlg_titre_fenetre, addr TitreDlgPartitionModeLibre
 
 
  ; ****************************************************************
 .ELSEIF uMsg == WM_LANCE_PARTITION_DLG
 
  ; fen�tre principal au premier plan 
  invoke SetWindowPos, odc.hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE
 
  ; lancer la fen�tre de la partition
  invoke GetModuleHandleA, NULL
  invoke DialogBoxParam, eax, ADDR NomDlgPartition, NULL, ADDR partition_dlg_proc, ADDR odc.hwnd_partition ; r�cup�rer le hwnd de la fen�tre partition
  
  
  
  ; ************************************************************************************************
 .ELSEIF uMsg == WM_SIZE
  
  invoke GetClientRect, hWnd, addr rect1
  sub rect1.right, PIANO_PADDING_X
  sub rect1.bottom, PIANO_PADDING_Y
  
  
  
  invoke SetWindowPos, odc.h_idw_piano, NULL, rect1.left, rect1.top, rect1.right, rect1.bottom, SWP_NOMOVE or SWP_NOOWNERZORDER
 
 .ELSEIF uMsg == WM_MIDI_BUFFER_EVENT_READY
 
 
  ; des events sont dans le buffer
  invoke onaip_dlg_gestion_partition_mode_libre, wParam, lParam
 
  
 .ELSEIF uMsg == WM_COMMAND
   
   
   mov eax, wParam
   shr eax, 16
 
    ; menu 
   .if eax == 0
    
    .if wParam == IDM_APROPOSDE	

	 invoke GetModuleHandleA, NULL
	 invoke DialogBoxParam, eax, ADDR NomDlgAproposde, NULL, ADDR aproposde_dlg_proc, NULL
	 ret 
	 
	.elseif wParam == IDM_LECTURE_NOTE

	 ; arr�ter la capture de la fen�tre principale
	 invoke midi_in_stop_capture
	
     ; d�sactiver les choix des exercices dans le menu
	 invoke onaip_dlg_etat_menu_exercices, 0
	
	 invoke partition_dlg_titre_fenetre, addr TitreDlgPartitionModeLectureNotes
	
     invoke GetModuleHandleA, NULL
	 invoke DialogBoxParam, eax, ADDR NomDlgExerciceNote, NULL, ADDR exercice_notes_dlg_proc, ADDR odc.hwnd_exercice ; r�cup�rer le hwnd de la fen�tre exercice
	 
	 ret 
		
  	
	.elseif wParam == IDM_TRAVAIL_OREILLE

	 ; arr�ter la capture de la fen�tre principale
	 invoke midi_in_stop_capture
	
     ; d�sactiver les choix des exercices dans le menu
	 invoke onaip_dlg_etat_menu_exercices, 0
	
	 invoke partition_dlg_titre_fenetre, addr TitreDlgPartitionModeTravailOreille
	
     invoke GetModuleHandleA, NULL
	 invoke DialogBoxParam, eax, ADDR NomDlgExerciceOreille, NULL, ADDR exercice_oreille_dlg_proc, ADDR odc.hwnd_exercice ; r�cup�rer le hwnd de la fen�tre exercice
	 
	 ret 
	
	
    .elseif wParam == IDM_MIDI_ACTUALISER
    
     ; menu Options -> Midi -> Actualiser les p�riph�riques	
	 invoke onaip_dlg_menu_midi_actualiser
     ret	 
	 
	 
	.elseif wParam == IDM_PARTITION_AUTOSCROLLING
    
	 ; menu Options -> Partition -> D�filement automatique	
	 invoke onaip_dlg_menu_partition_autoscrolling
	 ret
	 
	.endif
   .endif
 
  
   ; *******************************
   .if eax == CBN_SELCHANGE
    
	mov eax, lParam
     
	.if eax == odc.h_idcb_midi_in
	 
	 invoke onaip_dlg_open_midi_in
	
	.elseif eax == odc.h_idcb_midi_out
     
	 invoke onaip_dlg_open_midi_out
 
    .elseif eax == odc.h_idcb_midi_port_out
	 
	 invoke onaip_dlg_maj_port_midi_out
    
	.elseif eax == odc.h_idcb_midi_port_in
	 
	 invoke onaip_dlg_maj_port_midi_in
	 
    .endif	
   
    ; *******************************
   .elseif eax == BN_CLICKED
    
    mov eax, lParam

    .if eax == odc.h_idck_midi_in	
     
     invoke onaip_dlg_maj_midi_in_etat
   
    .elseif eax == odc.h_idck_midi_out
	
	 invoke onaip_dlg_maj_midi_out_etat
	
    .elseif eax == odc.h_idck_midi_port_out    
	; en sortie, choix de port obligatoire
 
    .elseif eax == odc.h_idck_midi_port_in
    ; le port midi in peut �tre ignor�	
    invoke onaip_dlg_maj_midi_port_in_etat
	
    .endif
	
 
	
   .endif
 
 
 
 .ELSE
 
  xor eax, eax
 
 .ENDIF
 
 ret

onaip_dlg_proc endp





; ************************************************
onaip_dlg_init proc
 
 ; ic�ne de la fen�tre
 invoke GetModuleHandle, NULL
 invoke LoadIcon, eax, IDI_APPLICATION
 invoke SetClassLong, odc.hwnd, GCL_HICON, eax
 
 
 ; *****************************************************
 invoke GetDlgItem, odc.hwnd, IDCB_MIDI_IN
 mov odc.h_idcb_midi_in, eax
 invoke GetDlgItem, odc.hwnd, IDCB_MIDI_PORT_IN
 mov odc.h_idcb_midi_port_in, eax
 invoke GetDlgItem, odc.hwnd, IDCK_MIDI_PORT_IN
 mov odc.h_idck_midi_port_in, eax
 invoke GetDlgItem, odc.hwnd, IDCK_MIDI_IN
 mov odc.h_idck_midi_in, eax
 invoke GetDlgItem, odc.hwnd, IDI_MIDI_IN
 mov odc.h_idi_midi_in, eax
  
 invoke GetDlgItem, odc.hwnd, IDCB_MIDI_OUT
 mov odc.h_idcb_midi_out, eax
 invoke GetDlgItem, odc.hwnd, IDCB_MIDI_PORT_OUT
 mov odc.h_idcb_midi_port_out, eax
 invoke GetDlgItem, odc.hwnd, IDCK_MIDI_PORT_OUT
 mov odc.h_idck_midi_port_out, eax
 invoke GetDlgItem, odc.hwnd, IDCK_MIDI_OUT
 mov odc.h_idck_midi_out, eax
 invoke GetDlgItem, odc.hwnd, IDI_MIDI_OUT
 mov odc.h_idi_midi_out, eax  

 invoke GetDlgItem, odc.hwnd, IDW_PIANO
 mov odc.h_idw_piano, eax 
 
 ; invoke GetDlgItem, odc.hwnd, IDM_ONAIP_DLG
 
 invoke GetMenu, odc.hwnd
 mov odc.h_menu, eax 
 
 
 ; pas de fen�tre exercice encore lanc�
 mov odc.hwnd_exercice, 0
 
 ; ******************************************************
 
 ; les 4 checkbox coch�s par d�faut
 invoke SendMessage, odc.h_idck_midi_port_in, BM_SETCHECK, BST_CHECKED, NULL
 invoke SendMessage, odc.h_idck_midi_in, BM_SETCHECK, BST_CHECKED, NULL
 invoke SendMessage, odc.h_idck_midi_port_out, BM_SETCHECK, BST_CHECKED, NULL
 invoke SendMessage, odc.h_idck_midi_out, BM_SETCHECK, BST_CHECKED, NULL
 ; ***************************************************************************
  
 ; ajouter les 16 num�ros de port dans chaque combobox
 mov ecx, 16
 mov eax, offset c_port_midi
  
 @ajoute_numero_de_port:
  
 push ecx
 push eax
   
  invoke SendMessage, odc.h_idcb_midi_port_in, CB_ADDSTRING, NULL, eax 
  
 pop eax
 push eax
  
  invoke SendMessage, odc.h_idcb_midi_port_out, CB_ADDSTRING, NULL, eax
     
 pop eax
 add eax, 8 ; nombre suivant
 pop ecx
 dec ecx
 jnz @ajoute_numero_de_port
  
  ; fen�tre de la partiton lanc� en diff�r�
 invoke PostMessage, odc.hwnd, WM_LANCE_PARTITION_DLG, NULL, NULL
 
  
 invoke onaip_dlg_menu_midi_actualiser
   
 ret
 
onaip_dlg_init endp



; ***************************
onaip_dlg_menu_midi_actualiser proc


 ; on arr�te la capture en cours et on ferme le midi in/out
 invoke midi_in_stop_capture
 invoke midi_in_fermer
 invoke midi_out_fermer


 ; vider les deux comboboxes
 invoke SendMessage, odc.h_idcb_midi_in, CB_RESETCONTENT, NULL, NULL
 invoke SendMessage, odc.h_idcb_midi_out, CB_RESETCONTENT, NULL, NULL
 
 ; mettre � jour les p�riph�riques midi disponibles
 invoke onaip_dlg_maj_midi_in
 invoke onaip_dlg_maj_midi_out
  
 invoke SendMessage, odc.h_idcb_midi_in, CB_SETCURSEL, 0, NULL
 invoke SendMessage, odc.h_idcb_midi_out, CB_SETCURSEL, 0, NULL
  
 ; par d�faut s�lection du port 1 pour les deux
 invoke SendMessage, odc.h_idcb_midi_port_in, CB_SETCURSEL, 0, NULL
 invoke SendMessage, odc.h_idcb_midi_port_out, CB_SETCURSEL, 0, NULL
 ; ****************************************************

 ; CB_SETCURSEL n'envoi pas la notification CBN_SELCHANGE 
 invoke onaip_dlg_open_midi_in
 invoke onaip_dlg_open_midi_out
 invoke onaip_dlg_maj_port_midi_out
 invoke onaip_dlg_maj_port_midi_in
 
 
 ret

onaip_dlg_menu_midi_actualiser endp





; ********************************
onaip_dlg_maj_midi_in proc
 
 LOCAL num_periph:dword
 
 
 
 mov num_periph, 0
 
 @ajoute_midi_in:
 
 invoke midi_in_peripherique, num_periph 
 
 .if eax != 0

  invoke SendMessage, odc.h_idcb_midi_in, CB_ADDSTRING, NULL, eax
 
  inc num_periph
  jmp @ajoute_midi_in
 .endif
 
  
 .if num_periph == 0
  invoke SendMessage, odc.h_idcb_midi_in, CB_ADDSTRING, NULL, addr ErrMidiIn1
 .endif 
 
 
 ret
  
onaip_dlg_maj_midi_in endp


; ******************************************************************************
onaip_dlg_maj_midi_out proc
 
 LOCAL num_periph:dword
 
 
 
 mov num_periph, 0
 
 @ajoute_midi_out:
 
 invoke midi_out_peripherique, num_periph 
 
 .if eax != 0

  invoke SendMessage, odc.h_idcb_midi_out, CB_ADDSTRING, NULL, eax
 
  inc num_periph
  jmp @ajoute_midi_out
 .endif
 
  
 .if num_periph == 0
  invoke SendMessage, odc.h_idcb_midi_out, CB_ADDSTRING, NULL, addr ErrMidiOut1
 .endif 
 
 
 ret
  
onaip_dlg_maj_midi_out endp


; ***************************************************************
onaip_dlg_maj_port_midi_out proc

 invoke SendMessage, odc.h_idcb_midi_port_out, CB_GETCURSEL, NULL, NULL
   
 invoke midi_out_port, eax  
   
 ret
 
onaip_dlg_maj_port_midi_out endp


; ***************************************************************
onaip_dlg_maj_port_midi_in proc

 invoke SendMessage, odc.h_idcb_midi_port_in, CB_GETCURSEL, NULL, NULL
   
 invoke midi_in_port, eax  
   
 ret
 
onaip_dlg_maj_port_midi_in endp




; *****************************************************
; eax = 0 ok, sinon GETLASTERROR
onaip_dlg_open_midi_in proc

 invoke SendMessage, odc.h_idcb_midi_in, CB_GETCURSEL, NULL, NULL

 invoke midi_in_ouvrir, eax

 ; le p�riph�rique midi in a chang�, relancer la capture de la fen�tre concern�e
 .if odc.hwnd_exercice == 0
  
  ; relancer la capture
  invoke midi_in_start_capture, 1, 0, odc.hwnd
 
 .else
 
  
  ; une fen�tre d'exercice est en cours d'�xecution
  ; lui envoy� un message pour la pr�venir d'un nouveau p�riph�rique midi in
  invoke PostMessage, odc.hwnd_exercice, WM_NOUVEAU_MIDI, NULL, NULL
   
 .endif
 
 
 ret

onaip_dlg_open_midi_in endp


; *****************************************************
; eax = 0 ok
onaip_dlg_open_midi_out proc

 invoke SendMessage, odc.h_idcb_midi_out, CB_GETCURSEL, NULL, NULL

 invoke midi_out_ouvrir, eax

 ret

onaip_dlg_open_midi_out endp


; ***************************************************
onaip_dlg_midi_out proc code_touche:DWORD, etat_touche:DWORD
 
 local port_midi:dword
 
   
 ; vitesse 40h pour le clavier virtuel 
 xor edx, edx
 mov edx, 40h
 shl edx, 8
  
 mov eax, code_touche
 mov dl, al
 shl edx, 8
    
 mov eax, etat_touche
 mov dl, al
  
 push edx
 invoke SendMessage, odc.h_idcb_midi_port_in, CB_GETCURSEL, NULL, NULL
 mov port_midi, eax
 pop edx 
 
 or edx, eax 
 
 
 ; simuler un message MIM_DATA pour le clavier virtuel (appel direct de la proc�dure, pas de send/postmessage)
 ; dernier param�tre -> le temps � 0
 invoke midi_in_proc, 0, MIM_DATA, 0, edx, 0
  
 
 invoke midi_out_touche_midi, etat_touche, code_touche
 
 ret
  
onaip_dlg_midi_out endp




; **********************************
onaip_dlg_maj_midi_in_etat proc
  
 ; si d�cocher d�sactiver le combox midi in et le fermer 
 invoke SendMessage, odc.h_idck_midi_in, BM_GETSTATE, NULL, NULL
 and eax, BST_CHECKED
 
 .if eax == BST_CHECKED
 
  invoke onaip_dlg_open_midi_in
  invoke EnableWindow, odc.h_idcb_midi_in, 1
  invoke EnableWindow, odc.h_idck_midi_port_in, 1
  invoke onaip_dlg_maj_midi_port_in_etat
  
  
 .else
  
  invoke EnableWindow, odc.h_idcb_midi_in, 0
  invoke EnableWindow, odc.h_idck_midi_port_in, 0
  invoke EnableWindow, odc.h_idcb_midi_port_in, 0
  
  ; stopper la capture en cours
  invoke midi_in_stop_capture
     
  invoke midi_in_fermer
  
  
  
 .endif
  
 ret

onaip_dlg_maj_midi_in_etat endp


; **********************************
onaip_dlg_maj_midi_out_etat proc
  
 invoke SendMessage, odc.h_idck_midi_out, BM_GETSTATE, NULL, NULL
 and eax, BST_CHECKED
 
 .if eax == BST_CHECKED
 
  invoke onaip_dlg_open_midi_out
  invoke EnableWindow, odc.h_idcb_midi_out, 1
  invoke EnableWindow, odc.h_idcb_midi_port_out, 1
  
 .else
  
  invoke EnableWindow, odc.h_idcb_midi_out, 0
  invoke EnableWindow, odc.h_idck_midi_port_out, 0
  invoke EnableWindow, odc.h_idcb_midi_port_out, 0
  
  invoke midi_out_fermer
  
 .endif
  
 ret

onaip_dlg_maj_midi_out_etat endp


; *********************************************
onaip_dlg_maj_midi_port_in_etat proc
 
 invoke SendMessage, odc.h_idck_midi_port_in, BM_GETSTATE, NULL, NULL
 and eax, BST_CHECKED
 
 .if eax == BST_CHECKED
  
  invoke EnableWindow, odc.h_idcb_midi_port_in, 1
  invoke midi_in_ignore_port, 0  ; port non ignor�
 
 .else
  
  invoke EnableWindow, odc.h_idcb_midi_port_in, 0
  invoke midi_in_ignore_port, 1  ; port ignor�
  
 .endif
 

 ret
 
onaip_dlg_maj_midi_port_in_etat endp



; ***********************************************
onaip_dlg_gestion_partition_mode_libre proc nb_events:dword, buffer_event:dword

 LOCAL t_event:dword
 LOCAL tmp_code_touche:dword
 LOCAL p_event:dword
 
  
  
 ; si 50 notes sont d�finis alors reset
 .if index_temps >= 20
  ; reset des notes
  invoke partition_widget_notes_reset
  mov index_temps, 0
 .endif	 
	 
	 
 
  assume eax:ptr midi_buffer_event
  mov eax, buffer_event
  mov p_event, eax
  
  @event_suivant:

  
  mov edx, [eax].code_touche
  mov tmp_code_touche, edx
  mov edx, [eax].type_event
  mov t_event, edx
   
 
  ; conversion du code midi avec alt�ration (vision di�se) 
  invoke midi_vers_note, [eax].code_touche, NOTE_DIESE
   
  
  ; g�rer seulement les touches appuy�es
  .if  t_event == MIDI_TOUCHE_APPUYEE
     
  ; note sur la portee de la clef de fa 
  .if tmp_code_touche >= 15h  && tmp_code_touche <= 3Bh
   invoke partition_widget_note_def, index_temps, TYPE_NOTE_NOIRE, 0h, eax, PORTEE_BASSE, HAMPE_EN_BAS, ORIENTATION_NOTE_DROITE, 1
  .else
   invoke partition_widget_note_def, index_temps, TYPE_NOTE_NOIRE, 0h, eax, PORTEE_HAUTE, HAMPE_EN_HAUT, ORIENTATION_NOTE_GAUCHE, 1
  .endif 
     
   inc index_temps
  
  .endif
  
  ; event suivant ?
  mov eax, p_event
  add eax, type midi_buffer_event  
  mov p_event, eax
  dec nb_events
  jnz @event_suivant
    
	
	
  assume eax:nothing
  
    
  invoke midi_in_reset_buffer_capture, 1, 0, odc.hwnd
  
  ; scrolling auto sur le temps - 1
  mov eax, index_temps
  dec eax
  invoke partition_widget_auto_scroll_temps, eax
  
  
  ; mettre � jour l'affichage sans �ffacer l'arri�re plan
  invoke partition_widget_maj_affichage, 0
  
  

 ret

onaip_dlg_gestion_partition_mode_libre endp



; ******************************************
onaip_dlg_etat_menu_exercices proc etat:dword

 LOCAL mi:MENUITEMINFO 
   
 mov mi.cbSize, sizeof MENUITEMINFO
 mov mi.fMask, MIIM_STATE
   
 .if etat == 0
  mov mi.fState, MFS_DISABLED 
 .else
  mov mi.fState, MFS_ENABLED
 .endif

  
 invoke SetMenuItemInfo, odc.h_menu, IDM_LECTURE_NOTE, 0, addr mi
 invoke SetMenuItemInfo, odc.h_menu, IDM_TRAVAIL_OREILLE, 0, addr mi

 ret
 
onaip_dlg_etat_menu_exercices endp



; *******************************************************
onaip_dlg_menu_partition_autoscrolling proc

 LOCAL mi:MENUITEMINFO 
   
 mov mi.cbSize, sizeof MENUITEMINFO
 mov mi.fMask, MIIM_STATE
 
 invoke GetMenuItemInfo, odc.h_menu, IDM_PARTITION_AUTOSCROLLING, 0, addr mi
 
 ; l'option d�filement automatique et cocher ?
 mov eax, mi.fState
 and eax, MFS_CHECKED
 
 .if eax == MFS_CHECKED
  
  ; d�cocher l'option du menu
  xor mi.fState, MFS_CHECKED
  
  
  ; d�sactiver le d�filement automatique
  invoke partition_widget_fixe_auto_scrolling, 0
 
 .else
 
  ; cocher l'option du menu
  or mi.fState, MFS_CHECKED
 
 
  ; activer le d�filement automatique
  invoke partition_widget_fixe_auto_scrolling, 1
 
 .endif
 
 
 ; fixer le nouvelle etat de l'option
 invoke SetMenuItemInfo, odc.h_menu, IDM_PARTITION_AUTOSCROLLING, 0, addr mi
 
 ret

onaip_dlg_menu_partition_autoscrolling endp



END


