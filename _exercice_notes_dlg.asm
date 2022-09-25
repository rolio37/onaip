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

.data


 c_type_partition byte "clef sol et fa", 0, \
                       "clef sol      ", 0, \
					   "clef fa       ", 0, \
					   "2 x clef sol  ", 0, \
					   "2 x clef fa   ", 0

					   
 c_nb_portees byte "1", 0, \
                   "2", 0, \
				   "3", 0, \
				   "4", 0

				   
 c_nb_notes byte "10 ", 0, \
                 "20 ", 0, \
				 "30 ", 0, \
				 "40 ", 0, \
				 "50 ", 0, \
				 "60 ", 0, \
				 "70 ", 0, \
				 "80 ", 0, \
				 "90 ", 0, \
				 "100", 0, \
				 "110", 0, \
				 "120", 0, \
				 "130", 0, \
				 "140", 0, \
				 "150", 0
 _c_nb_note byte "160", 0, \   ; ligne trop longue pour l'assembleur (trop complex ) , rajout d'un pseudo label inutilis�, la bonne blague :)
				 "170", 0, \
				 "180", 0, \
				 "190", 0, \
				 "200", 0, \
				 "210", 0, \
				 "220", 0, \
				 "230", 0, \
				 "240", 0, \
				 "250", 0
				 
				 				 			 		 
				 
				 
				 

 c_nb_octaves byte "1 octave ", 0, \
                   "2 octaves", 0, \
				   "3 octaves", 0, \
				   "4 octaves", 0
				   
					   
					   
.data?

 endc exercice_notes_dlg_controls <>

 na note_aleatoire <>
 
 
 

.code


exercice_notes_dlg_proc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
 
 
 .IF uMsg == WM_CLOSE
 
  ; arr�ter la capture au besoin 
  invoke midi_in_stop_capture
 
  ; indiquer � la fen�tre parent que la partition est libre
  ; appel direct, attention hwnd invalide pour la fen�tre r�ceptrice
  invoke onaip_dlg_proc, NULL, WM_PARTITION_LIBRE, NULL, NULL
   
   
  invoke EndDialog, hWnd, NULL
  
  
 .ELSEIF uMsg == WM_INITDIALOG
 
  ; donne son hwnd � sa cr�atrice
  mov eax, lParam
  mov edx, hWnd
  mov [eax], edx
 
 
  ; handle de la fen�tre parent
  mov eax, hWnd
  mov endc.hwnd, eax
 
  invoke exercice_notes_dlg_init
  
 .ELSEIF uMsg == WM_MIDI_BUFFER_EVENT_READY
 
 ; des events sont dans le buffer
  invoke exercices_notes_dlg_gestion_reponse, wParam, lParam 
  
  
 .ELSEIF uMsg == WM_NOUVEAU_MIDI
 
  ; le p�riph�rique midi a chang�
  ; relancer la capture midi si besoin
  
  .if endc.flag_exercice == 1
   invoke midi_in_start_capture, 1, 0, endc.hwnd
  .endif 
 
 
 .ELSEIF uMsg == WM_COMMAND
   
   
   mov eax, wParam
   
   
   .if eax == IDB_GO
  
    invoke exercice_notes_dlg_go
    ret
  
   .elseif eax == IDB_STOP
  
    invoke exercice_notes_dlg_stop
    ret
	
   .endif
  
   shr eax, 16 
    
  .if eax == CBN_SELCHANGE
   
   mov eax, lParam ; handle combobox
   
   ; le changement du nombre d'octave n'implique pas une mise � jour de la partition 
   .if eax != endc.h_idlb_nb_octaves
    
	invoke exercice_notes_dlg_maj_partition
     
   .endif
   
	
  .endif
  
 .ELSE
 
  xor eax, eax
 
 .ENDIF
 
  ret
  
exercice_notes_dlg_proc endp
 
 
 
 
; *************************
exercice_notes_dlg_init proc

 
 ; *****************************************************
 invoke GetDlgItem, endc.hwnd, IDLB_TYPE_PARTITION
 mov endc.h_idlb_type_partition, eax
 
 invoke GetDlgItem, endc.hwnd, IDLB_TYPE_PORTEE
 mov endc.h_idlb_nb_portees, eax
 
 invoke GetDlgItem, endc.hwnd, IDLB_NB_NOTES
 mov endc.h_idlb_nb_notes, eax
 
 invoke GetDlgItem, endc.hwnd, IDLB_NB_OCTAVES
 mov endc.h_idlb_nb_octaves, eax
 
 invoke GetDlgItem, endc.hwnd, IDCK_ALTERATION_DIESE
 mov endc.h_idck_alteration_diese, eax
 
 invoke GetDlgItem, endc.hwnd, IDCK_ALTERATION_BEMOL
 mov endc.h_idck_alteration_bemol, eax
 
 invoke GetDlgItem, endc.hwnd, IDT_NB_NOTES_OK
 mov endc.h_idt_nb_notes_ok, eax
 
 invoke GetDlgItem, endc.hwnd, IDT_NB_NOTES
 mov endc.h_idt_nb_notes, eax
 
 invoke GetDlgItem, endc.hwnd, IDT_POURCENTAGE
 mov endc.h_idt_pourcentage, eax
 
 invoke GetDlgItem, endc.hwnd, IDB_GO
 mov endc.h_idb_go, eax
 
 invoke GetDlgItem, endc.hwnd, IDB_STOP
 mov endc.h_idb_stop, eax
 
 invoke GetDlgItem, endc.hwnd, IDT_TEMPS
 mov endc.h_idt_temps, eax
 
 invoke GetDlgItem, endc.hwnd, IDT_NB_TEMPS_MAX
 mov endc.h_idt_nb_temps_max, eax
 ; ******************************************************
 
 
 
 ; ajouter les diff�rents type de partition
 mov ecx, 5
 mov eax, offset c_type_partition
  
 @ajoute_type_partition:
  
 push ecx
 push eax
   
  invoke SendMessage, endc.h_idlb_type_partition, CB_ADDSTRING, NULL, eax 

     
 pop eax
 add eax, 15
 pop ecx
 dec ecx
 jnz @ajoute_type_partition
 ; *************************************************
 
 
 ; ajouter le nombre de port�es possible
 mov ecx, 4
 mov eax, offset c_nb_portees
  
 @ajoute_nb_portees:
  
 push ecx
 push eax
   
  invoke SendMessage, endc.h_idlb_nb_portees, CB_ADDSTRING, NULL, eax 

     
 pop eax
 add eax, 2
 pop ecx
 dec ecx
 jnz @ajoute_nb_portees
 ; ****************************************************
 
 
 ; ajouter le nombre de notes possible
 mov ecx, 25
 mov eax, offset c_nb_notes
  
 @ajoute_nb_notes:
  
 push ecx
 push eax
   
  invoke SendMessage, endc.h_idlb_nb_notes, CB_ADDSTRING, NULL, eax 

     
 pop eax
 add eax, 4
 pop ecx
 dec ecx
 jnz @ajoute_nb_notes
 ; **************************************************** 
  
 
 ; ajouter le nombre d'octaves possible
 mov ecx, 4
 mov eax, offset c_nb_octaves
  
 @ajoute_nb_octaves:
  
 push ecx
 push eax
   
  invoke SendMessage, endc.h_idlb_nb_octaves, CB_ADDSTRING, NULL, eax 

     
 pop eax
 add eax, 10
 pop ecx
 dec ecx
 jnz @ajoute_nb_octaves
 ; **************************************************** 
 
 
 ; configuration par d�faut pour les d�butants comme moi :)
 ; clef sol et fa, 1 port�es, 20 notes, 1 octave, aucune alt�rations
 ;invoke SendMessage, endc.h_idlb_type_partition, CB_SETCURSEL, 0, NULL
 ;invoke SendMessage, endc.h_idlb_nb_portees, CB_SETCURSEL, 0, NULL
 ;invoke SendMessage, endc.h_idlb_nb_notes, CB_SETCURSEL, 1, NULL
 ;invoke SendMessage, endc.h_idlb_nb_octaves, CB_SETCURSEL, 0, NULL
 
 ; MAJ niveau max par d�faut :)
 ; clef sol et fa, 1 port�es, 250 notes, 4 octaves, alt�rations b�mol et di�se
 invoke SendMessage, endc.h_idlb_type_partition, CB_SETCURSEL, 0, NULL
 invoke SendMessage, endc.h_idlb_nb_portees, CB_SETCURSEL, 0, NULL
 invoke SendMessage, endc.h_idlb_nb_notes, CB_SETCURSEL, 24, NULL
 invoke SendMessage, endc.h_idlb_nb_octaves, CB_SETCURSEL, 3, NULL
 invoke SendMessage, endc.h_idck_alteration_diese, BM_SETCHECK, BST_CHECKED, NULL
 invoke SendMessage, endc.h_idck_alteration_bemol, BM_SETCHECK, BST_CHECKED, NULL
 
 
 
 
 mov endc.pourcentage, 0
 
 ; CB_SETCURSEL n'�mule pas un CBN_SELCHANGE
 invoke exercice_notes_dlg_maj_partition
 
 
 ; fen�tre au premier plan 
 invoke SetWindowPos, endc.hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE
 
 ; exercice par d�faut non lanc�
 mov endc.flag_exercice, 0
 
 ret
  
exercice_notes_dlg_init endp
 
 
 
; ****************************
exercice_notes_dlg_maj_partition proc

 
 
 ; r�cup�rer la configuration courante
 ; partition
 invoke SendMessage, endc.h_idlb_type_partition, CB_GETCURSEL, NULL, NULL
 
 .if eax == 0

  ; clef sol et fa
  mov endc.mode_portee, MODE_PORTEE_DOUBLE
  mov endc.clef1, CLEF_SOL
  mov endc.clef2, CLEF_FA
 
 .elseif eax == 1
  
  ; clef sol
  mov endc.mode_portee, MODE_PORTEE_SIMPLE
  mov endc.clef1, CLEF_SOL
  mov endc.clef2, 0
 
 
 .elseif eax == 2
 
  ; clef fa
  mov endc.mode_portee, MODE_PORTEE_SIMPLE
  mov endc.clef1, CLEF_FA
  mov endc.clef2, 0
 
 
 .elseif eax == 3
 
  ; 2 x clef sol
  mov endc.mode_portee, MODE_PORTEE_DOUBLE
  mov endc.clef1, CLEF_SOL
  mov endc.clef2, CLEF_SOL
 
 .else
 
  ; 2 x clef fa
  mov endc.mode_portee, MODE_PORTEE_DOUBLE
  mov endc.clef1, CLEF_FA
  mov endc.clef2, CLEF_FA
 
 .endif
 
 
 ; nombre de port�es
 invoke SendMessage, endc.h_idlb_nb_portees, CB_GETCURSEL, NULL, NULL
 
 ; index 0
 inc eax
 mov endc.nb_portees, eax
 
 ; nombre de notes
 invoke SendMessage, endc.h_idlb_nb_notes, CB_GETCURSEL, NULL, NULL
 
 ; index 0 
 inc eax
 
 ; choix de 10 en 10
 mov ecx, 10
 mul ecx
 
 mov endc.nb_notes, eax
 
 ; calcul du nombre de notes par port�e
 xor edx, edx
 mov ecx, endc.nb_portees
 div ecx
 
 ; si il y a un reste, ajouter une note de plus par port�e
 .if edx != 0
  inc eax
 .endif
 
 mov endc.nb_notes_portee, eax
 
 
 ; maj partition
 invoke partition_widget_def, endc.mode_portee, endc.clef1, endc.clef2, endc.nb_notes_portee, endc.nb_portees
 
 invoke exercice_notes_dlg_maj_score
 
 ret
 
exercice_notes_dlg_maj_partition endp 
 
 

; ***************************************
exercice_notes_dlg_maj_score proc

 ; dernier param�tre � z�ro, indique nombre non sign�
 invoke SetDlgItemInt, endc.hwnd, IDT_NB_NOTES_OK, endc.nb_notes_ok, 0
 invoke SetDlgItemInt, endc.hwnd, IDT_NB_NOTES, endc.nb_notes, 0
 
 ; les temps correspondent aux nombres de note
 invoke SetDlgItemInt, endc.hwnd, IDT_NB_TEMPS_MAX, endc.nb_notes, 0
 
 ; affich� le num�ro du temps courant
 mov eax, endc.numero_temps
 inc eax
 invoke SetDlgItemInt, endc.hwnd, IDT_TEMPS, eax, 0
 
 ; calculer le pourcentage de r�ussite
 ; pourcentage = nb_notes_ok * 100 / nb_notes 
 mov eax, endc.nb_notes_ok
 mov edx, 100
 mul edx
 xor edx, edx
 mov ecx, endc.nb_notes
 div ecx
  
 invoke SetDlgItemInt, endc.hwnd, IDT_POURCENTAGE, eax, 0 ; endc.pourcentage, 0

 ret

exercice_notes_dlg_maj_score endp
 
 
 

; ***************************************
exercice_notes_dlg_go proc

 ; d�sactiver les options de configurations pendant l'exercice
 invoke EnableWindow, endc.h_idlb_type_partition, 0
 invoke EnableWindow, endc.h_idlb_nb_portees, 0
 invoke EnableWindow, endc.h_idlb_nb_notes, 0
 invoke EnableWindow, endc.h_idlb_nb_octaves, 0
 invoke EnableWindow, endc.h_idck_alteration_diese, 0
 invoke EnableWindow, endc.h_idck_alteration_bemol, 0
 invoke EnableWindow, endc.h_idb_go, 0
 
 ; activer le bouton stop
 invoke EnableWindow, endc.h_idb_stop, 1
  
  
 ; reset du score
 mov endc.nb_notes_ok, 0
 mov endc.pourcentage, 0
 mov endc.numero_temps, 0
 invoke exercice_notes_dlg_maj_score
 
 ; reset des notes
 invoke partition_widget_notes_reset
 

 
 ; r�cup�rer les alt�rations choisi par l'utilisateur
 ; diese
 invoke SendMessage, endc.h_idck_alteration_diese, BM_GETSTATE, NULL, NULL
 and eax, BST_CHECKED
 
 .if eax == BST_CHECKED
  mov endc.flag_alteration_accidentelle_diese, 1
 .else
  mov endc.flag_alteration_accidentelle_diese, 0
 .endif
 
 ; b�mol
 invoke SendMessage, endc.h_idck_alteration_bemol, BM_GETSTATE, NULL, NULL
 and eax, BST_CHECKED
 
 .if eax == BST_CHECKED
  mov endc.flag_alteration_accidentelle_bemol, 1
 .else
  mov endc.flag_alteration_accidentelle_bemol, 0
 .endif
 
 
 
 
 ; calcul des notes al�atoires possible pour chaque clef selon le nombre d'octave
 
 invoke SendMessage, endc.h_idlb_nb_octaves, CB_GETCURSEL, NULL, NULL
 
 .if eax == 0
  
  ; 1 octave
  mov endc.touche_aleatoire_max, 12 + 1 ; + 1 pour le gros probl�me d'arrondi du processeur intel atom, BIZARRE ? 
  
  .if endc.clef1 == CLEF_SOL
   mov endc.code_midi_min_clef_1, 3Ch
   ;mov endc.touche_max_clef_1, 12
  .else
   mov endc.code_midi_min_clef_1, 30h
   ;mov endc.touche_max_clef_1, 12
  .endif  
 
 
  .if endc.clef2 == CLEF_SOL
   mov endc.code_midi_min_clef_2, 3Ch
   ;mov endc.touche_max_clef_2, 12
  
  .elseif endc.clef2 == CLEF_FA
   mov endc.code_midi_min_clef_2, 30h
   ;mov endc.touche_max_clef_2, 12
  .endif
 
 
 .elseif eax == 1
 
  ; 2 octaves
  mov endc.touche_aleatoire_max, 24 + 1
  
  .if endc.clef1 == CLEF_SOL
   mov endc.code_midi_min_clef_1, 3Ch
   ;mov endc.touche_max_clef_1, 24
  .else
   mov endc.code_midi_min_clef_1, 24h
   ;mov endc.touche_max_clef_1, 24
  .endif  
 
 
  .if endc.clef2 == CLEF_SOL
   mov endc.code_midi_min_clef_2, 3Ch
   ;mov endc.touche_max_clef_2, 24
  
  .elseif endc.clef2 == CLEF_FA
   mov endc.code_midi_min_clef_2, 24h
   ;mov endc.touche_max_clef_2, 24
  .endif
 
 
 .elseif eax == 2
 
  ; 3 octaves
  mov endc.touche_aleatoire_max, 36 + 1
  
  .if endc.clef1 == CLEF_SOL
   mov endc.code_midi_min_clef_1, 3Ch
   ;mov endc.touche_max_clef_1, 36
  .else
   mov endc.code_midi_min_clef_1, 18h
   ;mov endc.touche_max_clef_1, 36
  .endif  
 
 
  .if endc.clef2 == CLEF_SOL
   mov endc.code_midi_min_clef_2, 3Ch
   ;mov endc.touche_max_clef_2, 36
  
  .elseif endc.clef2 == CLEF_FA
   mov endc.code_midi_min_clef_2, 18h
   ;mov endc.touche_max_clef_2, 36
  .endif
 
 
 .elseif eax == 3
 
  ; 4 octaves
  mov endc.touche_aleatoire_max, 48 + 1
  
  .if endc.clef1 == CLEF_SOL
   mov endc.code_midi_min_clef_1, 30h
   ;mov endc.touche_max_clef_1, 48
  .else
   mov endc.code_midi_min_clef_1, 18h
   ;mov endc.touche_max_clef_1, 48
  .endif  
 
 
  .if endc.clef2 == CLEF_SOL
   mov endc.code_midi_min_clef_2, 30h
   ;mov endc.touche_max_clef_2, 48
  
  .elseif endc.clef2 == CLEF_FA
   mov endc.code_midi_min_clef_2, 18h
   ;mov endc.touche_max_clef_2, 48
  .endif
 
 .endif
 
 
 
 
 
 ; fixer la premi�re note al�atoire
 invoke exercices_notes_aleatoire
 
  

 ; d�marrer la capture midi
 invoke midi_in_start_capture, 1, 0, endc.hwnd
  
 ; exercice en cours
 mov endc.flag_exercice, 1
  
 ret

exercice_notes_dlg_go endp





; ********************************
exercice_notes_dlg_stop proc

 ; arr�ter la capture midi
 invoke midi_in_stop_capture
 
 
 ; activer les options de configurations
 invoke EnableWindow, endc.h_idlb_type_partition, 1
 invoke EnableWindow, endc.h_idlb_nb_portees, 1
 invoke EnableWindow, endc.h_idlb_nb_notes, 1
 invoke EnableWindow, endc.h_idlb_nb_octaves, 1
 invoke EnableWindow, endc.h_idck_alteration_diese, 1
 invoke EnableWindow, endc.h_idck_alteration_bemol, 1
 invoke EnableWindow, endc.h_idb_go, 1
 
 ; d�sactiver le bouton stop
 invoke EnableWindow, endc.h_idb_stop, 0

 ; exercice fini
 mov endc.flag_exercice, 0
 
 
 ; r�afficher la fen�tre d'exercice surement mise de c�t�
 invoke ShowWindow, endc.hwnd, SW_RESTORE
 
 
 ret

exercice_notes_dlg_stop endp
 
 
 
 
 ; **************************************
exercices_notes_aleatoire proc

 LOCAL valeur_aleatoire:dword
 LOCAL note_midi_aleatoire:dword
 LOCAL sts:SYSTEMTIME
 
 
 
 ; al�atoire
 ; invoke GetTickCount
 invoke GetSystemTime, addr sts
 xor ecx, ecx
 mov cx, sts.wMilliseconds
 rdtsc 
 mul ecx
 
 
 
 xor edx, edx
 mov ecx, endc.touche_aleatoire_max
 div ecx
 
 ; edx = valeur al�atoire de d�calage
 ; gros probl�me d'arrondi avec un intel atom mais pas pour les autres processeurs donc corriger la valeur si trop grande 
 mov eax, endc.touche_aleatoire_max
 dec eax
 
 .if eax == edx
  dec edx
 .endif
 
 mov valeur_aleatoire, edx

 ; choisir la port�e
 ; portee simple
 .if endc.mode_portee == MODE_PORTEE_SIMPLE
  
  ; soit une clef sol ou une clef de fa
  mov eax, endc.code_midi_min_clef_1
  add eax, valeur_aleatoire
  mov note_midi_aleatoire, eax    
	
  mov na.la_portee, PORTEE_HAUTE
  mov na.la_hampe, HAMPE_EN_HAUT
  mov na.orientation, ORIENTATION_NOTE_GAUCHE  
	
    
	
 .else

  ; MODE_PORTEE_DOUBLE
  ; soit deux clef sol ou deux clef de fa
  mov eax, endc.clef1
  .if eax == endc.clef2
    
   ; clef identiques
   mov eax, endc.code_midi_min_clef_1
   add eax, valeur_aleatoire
   mov note_midi_aleatoire, eax 
   
   
   ; choisir la port�e au hasard
   ; choisir un des deux al�atoirements
   invoke GetSystemTime, addr sts
   mov cx, sts.wMilliseconds
   rdtsc
   rcr eax, cl
   mov cl, ch
   rcl eax, cl
   
   .if CARRY?
    mov na.la_portee, PORTEE_HAUTE
    mov na.la_hampe, HAMPE_EN_HAUT
    mov na.orientation, ORIENTATION_NOTE_GAUCHE  
   .else
    mov na.la_portee, PORTEE_BASSE
    mov na.la_hampe, HAMPE_EN_BAS
    mov na.orientation, ORIENTATION_NOTE_DROITE     
   .endif
   
   
   
   
  
  .else
  
   ; clef sol et fa
   ; choix de la port�e al�atoire
   invoke GetSystemTime, addr sts
   mov cx, sts.wMilliseconds
   rdtsc
   rcr eax, cl
   mov cl, ch
   rcr eax, cl
   
   .if CARRY?
   
    ; clef sol
    mov eax, endc.code_midi_min_clef_1
    add eax, valeur_aleatoire
    mov note_midi_aleatoire, eax 
   
    mov na.la_portee, PORTEE_HAUTE
    mov na.la_hampe, HAMPE_EN_HAUT
    mov na.orientation, ORIENTATION_NOTE_GAUCHE 
    
   
   .else
     
	; clef fa
	mov eax, endc.code_midi_min_clef_2
    add eax, valeur_aleatoire
    mov note_midi_aleatoire, eax 

    mov na.la_portee, PORTEE_BASSE
    mov na.la_hampe, HAMPE_EN_BAS
    mov na.orientation, ORIENTATION_NOTE_DROITE
   
   .endif
   
  .endif ; .if eax == endc.clef2
 
 
 .endif ; endc.mode_portee == MODE_PORTEE_SIMPLE
 ; *************************************************
 
  
  .if endc.flag_alteration_accidentelle_diese == 1 && endc.flag_alteration_accidentelle_bemol == 1
  
   ; choisir une des deux al�atoirement
   invoke GetSystemTime, addr sts
   mov cx, sts.wMilliseconds
   rdtsc
   rcr eax, cl
   mov cl, ch
   rcl eax, cl
   
   .if CARRY?
   
    invoke midi_vers_note, note_midi_aleatoire, NOTE_DIESE
    mov na.vision_alteration, NOTE_DIESE
   
   .else
   
    invoke midi_vers_note, note_midi_aleatoire, NOTE_BEMOL
	mov na.vision_alteration, NOTE_BEMOL
   
   .endif
   
  
  .elseif endc.flag_alteration_accidentelle_diese == 1
  
   ; note diese seul
   invoke midi_vers_note, note_midi_aleatoire, NOTE_DIESE 
   mov na.vision_alteration, NOTE_DIESE
  
  .elseif endc.flag_alteration_accidentelle_bemol == 1
  
   ; note b�mol seul
   invoke midi_vers_note, note_midi_aleatoire, NOTE_BEMOL
   mov na.vision_alteration, NOTE_BEMOL
  
  .else
   
   ; aucune note accidentelle di�se ou b�mol
   ; supprime l'at�ration de la note al�atoire si besoin
   invoke midi_vers_note, note_midi_aleatoire, NOTE_NATURELLE
   and eax, 0FFFFh ; enlever l'alt�ration
   
   mov na.vision_alteration, NOTE_DIESE
  
  
  .endif
  
  ; eax contient la note convertie 
  mov na.la_note, eax	
 
 
 ; d�finir la note sur la partition
 invoke partition_widget_note_def, endc.numero_temps, TYPE_NOTE_NOIRE, COULEUR_NOTE_NOIRE, eax, na.la_portee, na.la_hampe, na.orientation, 1 

 ; scrolling auto
 invoke partition_widget_auto_scroll_temps, endc.numero_temps
  
 ; mettre � jour l'affichage sans �ffacer l'arri�re plan
 invoke partition_widget_maj_affichage, 0
 
 ret

exercices_notes_aleatoire endp 
 
 
 
 
; *********************************************
exercices_notes_dlg_gestion_reponse proc nb_events:dword, buffer_event:dword

 LOCAL t_event:dword
 ; LOCAL tmp_code_touche:dword
 LOCAL p_event:dword
 LOCAL la_note_appuyee:dword
  
  
 ;mov eax, endc.nb_notes
 ;.if endc.numero_temps >= eax
 ; ret
 ;.endif
  
  
 assume eax:ptr midi_buffer_event
 
 mov eax, buffer_event
 mov p_event, eax
  
 @event_suivant:

  
 ;mov edx, [eax].code_touche
 ;mov tmp_code_touche, edx
 mov edx, [eax].type_event
 mov t_event, edx
   
 
  
   
  
 ; g�rer seulement les touches appuy�es
 .if  t_event == MIDI_TOUCHE_APPUYEE
     
  ; conversion du code midi avec alt�ration
  invoke midi_vers_note, [eax].code_touche, na.vision_alteration
  mov la_note_appuyee, eax	 
	 
  .if eax == na.la_note

   ; afficher la note en verte
   invoke partition_widget_note_def, endc.numero_temps, TYPE_NOTE_NOIRE, COULEUR_NOTE_VERTE, eax, na.la_portee, na.la_hampe, na.orientation, 1
    	
   inc endc.nb_notes_ok
   invoke exercice_notes_dlg_maj_score
   
  .else
  
   ; erreur afficher la note en rouge erron� et laisser celle d'origine en noire
   
   .if na.orientation == ORIENTATION_NOTE_GAUCHE
    mov na.orientation, ORIENTATION_NOTE_DROITE
   .else
    mov na.orientation, ORIENTATION_NOTE_GAUCHE
   .endif
   
   
   ; pour le mode port�e double cl� sol et fa, afficher la note sur l'autre port�e, si celle ci se trouve hors plage sur la port�e courante
   .if endc.clef1 == CLEF_SOL && endc.clef2 == CLEF_FA
   
    ; v�rifier si la note sur la port�e est hors plage
	.if na.la_portee == PORTEE_HAUTE
	 invoke partition_widget_hors_portee, la_note_appuyee, CLEF_SOL
    .else
     invoke partition_widget_hors_portee, la_note_appuyee, CLEF_FA
    .endif
   
   
    ; eax = 1 alors hors plage
	.if eax == 1
	 .if na.la_portee == PORTEE_HAUTE
	  mov na.la_portee, PORTEE_BASSE
	 .else
      mov na.la_portee, PORTEE_HAUTE	 
	 .endif
	.endif
   
   .endif ; endc.clef1 == CLEF_SOL && endc.clef2 == CLEF_FA
   
   
   invoke partition_widget_note_def, endc.numero_temps, TYPE_NOTE_NOIRE, COULEUR_NOTE_ROUGE, la_note_appuyee, na.la_portee, HAMPE_ABSENTE, na.orientation, 1
     
	 
  .endif ; eax == na.la_note  
  	 
  
	
   
	
   ; v�rifier la fin de l'exercice
   mov eax, endc.nb_notes
   inc endc.numero_temps
 
   .if endc.numero_temps < eax
    
	; mettre � jour le num�ro du temps courant
    invoke exercice_notes_dlg_maj_score	
	 
    jmp @temps_suivant
   .else
   
    dec endc.numero_temps
   
    ; mettre � jour l'affichage sans �ffacer l'arri�re plan
    invoke partition_widget_maj_affichage, 0	
	invoke exercice_notes_dlg_maj_score
    invoke exercice_notes_dlg_stop
	ret
   .endif
  
 .endif ; t_event == MIDI_TOUCHE_APPUYEE
  
  
  
  ; event suivant ?
  mov eax, p_event
  add eax, type midi_buffer_event  
  mov p_event, eax
  dec nb_events
  jnz @event_suivant
 
  assume eax:nothing
 
  ; pas d'event touche appuyee
  invoke midi_in_reset_buffer_capture, 1, 0, endc.hwnd
  
  ret
 
 
  
 @temps_suivant:
 
 
 ; scrolling auto
 invoke partition_widget_auto_scroll_temps, endc.numero_temps
 
 ; nouvelle note al�atoire
 invoke exercices_notes_aleatoire 
   
 invoke midi_in_reset_buffer_capture, 1, 0, endc.hwnd

 ret

exercices_notes_dlg_gestion_reponse endp 
 
 
 END
 
 
 
 
 
 
 
