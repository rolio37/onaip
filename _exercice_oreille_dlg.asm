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


 c_type_partition byte "clef sol et fa", 0, \
                       "clef sol      ", 0, \
					   "clef fa       ", 0, 

					   
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
 _c_nb_note byte "160", 0, \   ; ligne trop longue pour l'assembleur (trop complex ) , rajout d'un label inutilisé
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
				   
					   
					   
 c_nuances byte "pppp", 0, \
                "ppp ", 0, \
				"pp  ", 0, \
                "p   ", 0, \
                "mp  ", 0, \
                "mf  ", 0, \
                "f   ", 0, \
                "ff  ", 0, \
                "fff ", 0, \
                "ffff", 0

 nuances_table_valeur dword 8, 20, 31, 42, 53, 64, 80, 96, 112, 127
				
				
 err_midi_out byte "Pas de périphérique midi out disponible !", 0
 err_msg byte "Erreur : ", 0 
 
					   
.data?

 eodc exercice_oreille_dlg_controls <>

 na note_aleatoire_2 <>
 
 
 

.code


exercice_oreille_dlg_proc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
 
 
 .IF uMsg == WM_CLOSE
 
 
  ; remettre la nuance/vitesse du midi out en mf 64 (40h)
  invoke midi_out_vitesse, 64
 
  ; arrêter la capture au besoin 
  invoke midi_in_stop_capture
 
  ; indiquer à la fenêtre parent que la partition est libre
  ; appel direct, attention hwnd invalide pour la fenêtre réceptrice
  invoke onaip_dlg_proc, NULL, WM_PARTITION_LIBRE, NULL, NULL
   
   
  invoke EndDialog, hWnd, NULL
  
  
 .ELSEIF uMsg == WM_INITDIALOG
 
  ; donne son hwnd à sa créatrice
  mov eax, lParam
  mov edx, hWnd
  mov [eax], edx
 
 
  ; handle de la fenêtre parent
  mov eax, hWnd
  mov eodc.hwnd, eax
 
  invoke exercice_oreille_dlg_init
  
 .ELSEIF uMsg == WM_MIDI_BUFFER_EVENT_READY
 
 ; des events sont dans le buffer
 invoke exercices_oreille_dlg_gestion_reponse, wParam, lParam 
  
  
 .ELSEIF uMsg == WM_NOUVEAU_MIDI
 
  ; le périphérique midi a changé
  ; relancer la capture midi si besoin
  
  .if eodc.flag_exercice == 1
   invoke midi_in_start_capture, 1, 0, eodc.hwnd
  .endif 
 
 
 .ELSEIF uMsg == WM_COMMAND
   
   
   mov eax, wParam
   
   
   .if eax == IDB_GO_2
  
    invoke exercice_oreille_dlg_go
    ret
  
   .elseif eax == IDB_STOP_2
  
    invoke exercice_oreille_dlg_stop
    ret
	
	
   .elseif eax == IDB_ECOUTER_NOTE

    ; vérifier la présence du périphérique midi out
	invoke midi_out_ok
	
	.if eax == 0
	
	 invoke MessageBoxA, eodc.hwnd, addr err_midi_out, addr err_msg, MB_OK or MB_ICONSTOP
	 ret
	 
	.endif
   
   
    ; envoyer le son au piano
    invoke midi_out_touche_midi, MIDI_TOUCHE_APPUYEE, na.code_midi
   
    ret   
	
   .endif
  
   shr eax, 16 
    
  .if eax == CBN_SELCHANGE
   
   mov eax, lParam ; handle combobox
   
   ; gestion de la nuance
   .if eax == eodc.h_idlb_nuance
   
    invoke SendMessage, eodc.h_idlb_nuance, CB_GETCURSEL, NULL, NULL
    
   ; calculer valeur de la nuance correspondante
   mov ecx, 4
   mul ecx
   add eax, offset nuances_table_valeur
   mov eax, [eax]
   mov eodc.nuance, eax
	 
   invoke midi_out_vitesse, eax	 
	  
   ret
   
  .endif
   
   
   ; le changement du nombre d'octave n'implique pas une mise à jour de la partition 
   .if eax != eodc.h_idlb_nb_octaves
    
	invoke exercice_oreille_dlg_maj_partition
     
   .endif
   
	
  .endif
  
 .ELSE
 
  xor eax, eax
 
 .ENDIF
 
  ret
  
exercice_oreille_dlg_proc endp
 
 
 
 
; *************************
exercice_oreille_dlg_init proc

 
 ; *****************************************************
 invoke GetDlgItem, eodc.hwnd, IDLB_TYPE_PARTITION_2
 mov eodc.h_idlb_type_partition, eax
 
 invoke GetDlgItem, eodc.hwnd, IDLB_TYPE_PORTEE_2
 mov eodc.h_idlb_nb_portees, eax
 
 invoke GetDlgItem, eodc.hwnd, IDLB_NB_NOTES_2
 mov eodc.h_idlb_nb_notes, eax
 
 invoke GetDlgItem, eodc.hwnd, IDLB_NB_OCTAVES_2
 mov eodc.h_idlb_nb_octaves, eax
 
 invoke GetDlgItem, eodc.hwnd, IDCK_ALTERATION
 mov eodc.h_idck_alteration, eax
 
 invoke GetDlgItem, eodc.hwnd, IDT_NB_NOTES_OK_2
 mov eodc.h_idt_nb_notes_ok, eax
 
 invoke GetDlgItem, eodc.hwnd, IDT_NB_NOTES_2
 mov eodc.h_idt_nb_notes, eax
 
 invoke GetDlgItem, eodc.hwnd, IDT_POURCENTAGE_2
 mov eodc.h_idt_pourcentage, eax
 
 invoke GetDlgItem, eodc.hwnd, IDB_GO_2
 mov eodc.h_idb_go, eax
 
 invoke GetDlgItem, eodc.hwnd, IDB_STOP_2
 mov eodc.h_idb_stop, eax
 
 invoke GetDlgItem, eodc.hwnd, IDT_TEMPS_2
 mov eodc.h_idt_temps, eax
 
 invoke GetDlgItem, eodc.hwnd, IDT_NB_TEMPS_MAX_2
 mov eodc.h_idt_nb_temps_max, eax
 
 invoke GetDlgItem, eodc.hwnd, IDB_ECOUTER_NOTE
 mov eodc.h_idb_ecouter_note, eax
 
 invoke GetDlgItem, eodc.hwnd, IDLB_NUANCE
 mov eodc.h_idlb_nuance, eax
 
 
 ; ******************************************************
 
 
 
 ; ajouter les différents type de partition
 mov ecx, 3
 mov eax, offset c_type_partition
  
 @ajoute_type_partition:
  
 push ecx
 push eax
   
  invoke SendMessage, eodc.h_idlb_type_partition, CB_ADDSTRING, NULL, eax 

     
 pop eax
 add eax, 15
 pop ecx
 dec ecx
 jnz @ajoute_type_partition
 ; *************************************************
 
 
 ; ajouter le nombre de portées possible
 mov ecx, 4
 mov eax, offset c_nb_portees
  
 @ajoute_nb_portees:
  
 push ecx
 push eax
   
  invoke SendMessage, eodc.h_idlb_nb_portees, CB_ADDSTRING, NULL, eax 

     
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
   
  invoke SendMessage, eodc.h_idlb_nb_notes, CB_ADDSTRING, NULL, eax 

     
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
   
  invoke SendMessage, eodc.h_idlb_nb_octaves, CB_ADDSTRING, NULL, eax 

     
 pop eax
 add eax, 10
 pop ecx
 dec ecx
 jnz @ajoute_nb_octaves
 ; **************************************************** 
 
 
 ; ajouter les nuances possibles
 mov ecx, 10
 mov eax, offset c_nuances
  
 @ajoute_nuances:
  
 push ecx
 push eax
   
  invoke SendMessage, eodc.h_idlb_nuance, CB_ADDSTRING, NULL, eax 

     
 pop eax
 add eax, 5
 pop ecx
 dec ecx
 jnz @ajoute_nuances
 ; ****************************************************
 
 
 ; clef sol et fa, 1 portées, 20 notes, 1 octave, aucune altérations 
 invoke SendMessage, eodc.h_idlb_type_partition, CB_SETCURSEL, 0, NULL
 invoke SendMessage, eodc.h_idlb_nb_portees, CB_SETCURSEL, 0, NULL
 invoke SendMessage, eodc.h_idlb_nb_notes, CB_SETCURSEL, 1, NULL
 invoke SendMessage, eodc.h_idlb_nb_octaves, CB_SETCURSEL, 0, NULL
 
 ; choix de la nuance par défault sur mf
 invoke SendMessage, eodc.h_idlb_nuance, CB_SETCURSEL, 5, NULL
 mov eodc.nuance, 64 
 
 
 mov eodc.pourcentage, 0
 
 ; CB_SETCURSEL n'émule pas un CBN_SELCHANGE
 invoke exercice_oreille_dlg_maj_partition
 
 
 ; fenêtre au premier plan 
 invoke SetWindowPos, eodc.hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE
 
 ; exercice par défaut non lancé
 mov eodc.flag_exercice, 0
 
 ret
  
exercice_oreille_dlg_init endp
 
 

; ****************************
exercice_oreille_dlg_maj_partition proc

 
 
 ; récupérer la configuration courante
 ; partition
 invoke SendMessage, eodc.h_idlb_type_partition, CB_GETCURSEL, NULL, NULL
 
 .if eax == 0

  ; clef sol et fa
  mov eodc.mode_portee, MODE_PORTEE_DOUBLE
  mov eodc.clef1, CLEF_SOL
  mov eodc.clef2, CLEF_FA
 
 .elseif eax == 1
  
  ; clef sol
  mov eodc.mode_portee, MODE_PORTEE_SIMPLE
  mov eodc.clef1, CLEF_SOL
  mov eodc.clef2, 0
 
 
 .else
 
  ; clef fa
  mov eodc.mode_portee, MODE_PORTEE_SIMPLE
  mov eodc.clef1, CLEF_FA
  mov eodc.clef2, 0
 
 .endif
  
 
 
 ; nombre de portées
 invoke SendMessage, eodc.h_idlb_nb_portees, CB_GETCURSEL, NULL, NULL
 
 ; index 0
 inc eax
 mov eodc.nb_portees, eax
 
 ; nombre de notes
 invoke SendMessage, eodc.h_idlb_nb_notes, CB_GETCURSEL, NULL, NULL
 
 ; index 0 
 inc eax
 
 ; choix de 10 en 10
 mov ecx, 10
 mul ecx
 
 mov eodc.nb_notes, eax
 
 ; calcul du nombre de notes par portée
 xor edx, edx
 mov ecx, eodc.nb_portees
 div ecx
 
 ; si il y a un reste, ajouter une note de plus par portée
 .if edx != 0
  inc eax
 .endif
 
 mov eodc.nb_notes_portee, eax
 
 
 ; maj partition
 invoke partition_widget_def, eodc.mode_portee, eodc.clef1, eodc.clef2, eodc.nb_notes_portee, eodc.nb_portees
 
 invoke exercice_oreille_dlg_maj_score
 
 ret
 
exercice_oreille_dlg_maj_partition endp 
 
 


; ***************************************
exercice_oreille_dlg_maj_score proc

 ; dernier paramètre à zéro, indique nombre non signé
 invoke SetDlgItemInt, eodc.hwnd, IDT_NB_NOTES_OK_2, eodc.nb_notes_ok, 0
 invoke SetDlgItemInt, eodc.hwnd, IDT_NB_NOTES_2, eodc.nb_notes, 0
 
 ; les temps correspondent aux nombres de note
 invoke SetDlgItemInt, eodc.hwnd, IDT_NB_TEMPS_MAX_2, eodc.nb_notes, 0
 
 ; affiché le numéro du temps courant
 mov eax, eodc.numero_temps
 inc eax
 invoke SetDlgItemInt, eodc.hwnd, IDT_TEMPS_2, eax, 0
 
 ; calculer le pourcentage de réussite
 ; pourcentage = nb_notes_ok * 100 / nb_notes 
 mov eax, eodc.nb_notes_ok
 mov edx, 100
 mul edx
 xor edx, edx
 mov ecx, eodc.nb_notes
 div ecx
  
 invoke SetDlgItemInt, eodc.hwnd, IDT_POURCENTAGE_2, eax, 0 ; eodc.pourcentage, 0

 ret

exercice_oreille_dlg_maj_score endp
 
 


; ***************************************
exercice_oreille_dlg_go proc

 ; désactiver les options de configurations pendant l'exercice
 invoke EnableWindow, eodc.h_idlb_type_partition, 0
 invoke EnableWindow, eodc.h_idlb_nb_portees, 0
 invoke EnableWindow, eodc.h_idlb_nb_notes, 0
 invoke EnableWindow, eodc.h_idlb_nb_octaves, 0
 invoke EnableWindow, eodc.h_idck_alteration, 0
 invoke EnableWindow, eodc.h_idb_go, 0
  
 ; activer le bouton stop et le bouton ecouter
 invoke EnableWindow, eodc.h_idb_stop, 1
 invoke EnableWindow, eodc.h_idb_ecouter_note, 1
 
  
 ; reset du score
 mov eodc.nb_notes_ok, 0
 mov eodc.pourcentage, 0
 mov eodc.numero_temps, 0
 invoke exercice_oreille_dlg_maj_score
 
 ; reset des notes
 invoke partition_widget_notes_reset
 

 
 ; vérifier si l'option altérations est choisi par l'utilisateur
 invoke SendMessage, eodc.h_idck_alteration, BM_GETSTATE, NULL, NULL
 and eax, BST_CHECKED
 
 .if eax == BST_CHECKED
  mov eodc.flag_alteration, 1
 .else
  mov eodc.flag_alteration, 0
 .endif
 
 
 
 
 ; calcul des notes aléatoires possible pour chaque clef selon le nombre d'octave
 
 invoke SendMessage, eodc.h_idlb_nb_octaves, CB_GETCURSEL, NULL, NULL
 
 .if eax == 0
  
  ; 1 octave
  mov eodc.touche_aleatoire_max, 12 + 1 ; + 1 pour le gros problème d'arrondi du processeur intel atom, BIZARRE ? 
  
  .if eodc.clef1 == CLEF_SOL
   mov eodc.code_midi_min_clef_1, 3Ch
  .else
   mov eodc.code_midi_min_clef_1, 30h
  .endif  
 
 
  .if eodc.clef2 == CLEF_SOL
   mov eodc.code_midi_min_clef_2, 3Ch
  .elseif eodc.clef2 == CLEF_FA
   mov eodc.code_midi_min_clef_2, 30h
  .endif
 
 
 .elseif eax == 1
 
  ; 2 octaves
  mov eodc.touche_aleatoire_max, 24 + 1
  
  .if eodc.clef1 == CLEF_SOL
   mov eodc.code_midi_min_clef_1, 3Ch
  .else
   mov eodc.code_midi_min_clef_1, 24h
  .endif  
 
 
  .if eodc.clef2 == CLEF_SOL
   mov eodc.code_midi_min_clef_2, 3Ch
  .elseif eodc.clef2 == CLEF_FA
   mov eodc.code_midi_min_clef_2, 24h
  .endif
 
 
 .elseif eax == 2
 
  ; 3 octaves
  mov eodc.touche_aleatoire_max, 36 + 1
  
  .if eodc.clef1 == CLEF_SOL
   mov eodc.code_midi_min_clef_1, 3Ch
  .else
   mov eodc.code_midi_min_clef_1, 18h
  .endif  
 
 
  .if eodc.clef2 == CLEF_SOL
   mov eodc.code_midi_min_clef_2, 3Ch
  .elseif eodc.clef2 == CLEF_FA
   mov eodc.code_midi_min_clef_2, 18h
  .endif
 
 
 .elseif eax == 3
 
  ; 4 octaves
  mov eodc.touche_aleatoire_max, 48 + 1
  
  .if eodc.clef1 == CLEF_SOL
   mov eodc.code_midi_min_clef_1, 30h
  .else
   mov eodc.code_midi_min_clef_1, 18h
  .endif  
 
 
  .if eodc.clef2 == CLEF_SOL
   mov eodc.code_midi_min_clef_2, 30h
  .elseif eodc.clef2 == CLEF_FA
   mov eodc.code_midi_min_clef_2, 18h
  .endif
 
 .endif
 
 
 
 
 
 ; fixer la première note aléatoire
 invoke exercices_oreille_aleatoire
 
  

 ; démarrer la capture midi
 invoke midi_in_start_capture, 1, 0, eodc.hwnd
  
 ; exercice en cours
 mov eodc.flag_exercice, 1
  
 ret

exercice_oreille_dlg_go endp





; ********************************
exercice_oreille_dlg_stop proc

 ; arrêter la capture midi
 invoke midi_in_stop_capture
 
 
 ; activer les options de configurations
 invoke EnableWindow, eodc.h_idlb_type_partition, 1
 invoke EnableWindow, eodc.h_idlb_nb_portees, 1
 invoke EnableWindow, eodc.h_idlb_nb_notes, 1
 invoke EnableWindow, eodc.h_idlb_nb_octaves, 1
 invoke EnableWindow, eodc.h_idck_alteration, 1
 invoke EnableWindow, eodc.h_idb_go, 1
 
 ; désactiver le bouton stop et le bouton ecouter
 invoke EnableWindow, eodc.h_idb_stop, 0
 invoke EnableWindow, eodc.h_idb_ecouter_note, 0
 
 ; exercice fini
 mov eodc.flag_exercice, 0
 
 ret

exercice_oreille_dlg_stop endp
 
 
 
 
; **************************************
exercices_oreille_aleatoire proc

 LOCAL valeur_aleatoire:dword
 LOCAL sts:SYSTEMTIME
 
 
 
 ; aléatoire
 invoke GetSystemTime, addr sts
 xor ecx, ecx
 mov cx, sts.wMilliseconds
 rdtsc 
 mul ecx
 
 
 
 xor edx, edx
 mov ecx, eodc.touche_aleatoire_max
 div ecx
 
 ; edx = valeur aléatoire de décalage
 ; gros problème d'arrondi avec un intel atom mais pas pour les autres processeurs donc corriger la valeur si trop grande 
 mov eax, eodc.touche_aleatoire_max
 dec eax
 
 .if eax == edx
  dec edx
 .endif
 
 mov valeur_aleatoire, edx

 
 ; choisir la portée
 ; portee simple
 .if eodc.mode_portee == MODE_PORTEE_SIMPLE
  
  ; soit une clef sol ou une clef de fa
  mov eax, eodc.code_midi_min_clef_1
  add eax, valeur_aleatoire
  mov na.code_midi, eax   
	
  mov na.la_portee, PORTEE_HAUTE
  mov na.la_hampe, HAMPE_EN_HAUT
  mov na.orientation, ORIENTATION_NOTE_GAUCHE  
  
 .else
  
  ; clef sol et fa
  ; choix de la portée aléatoire
  invoke GetSystemTime, addr sts
  mov cx, sts.wMilliseconds
  rdtsc
  rcr eax, cl
  mov cl, ch
  rcr eax, cl
   
  .if CARRY?
  
   ; clef sol
   mov eax, eodc.code_midi_min_clef_1
   add eax, valeur_aleatoire
   mov na.code_midi, eax
  
   mov na.la_portee, PORTEE_HAUTE
   mov na.la_hampe, HAMPE_EN_HAUT
   mov na.orientation, ORIENTATION_NOTE_GAUCHE 
    
   
  .else
     
   ; clef fa
   mov eax, eodc.code_midi_min_clef_2
   add eax, valeur_aleatoire
   mov na.code_midi, eax
	
   mov na.la_portee, PORTEE_BASSE
   mov na.la_hampe, HAMPE_EN_BAS
   mov na.orientation, ORIENTATION_NOTE_DROITE
   
  .endif
  
 
 .endif ; eodc.mode_portee == MODE_PORTEE_SIMPLE
 ; *************************************************
 
  
  .if eodc.flag_alteration == 1
  
   ; choisir une des deux aléatoirement
   invoke GetSystemTime, addr sts
   mov cx, sts.wMilliseconds
   rdtsc
   rcr eax, cl
   mov cl, ch
   rcl eax, cl
   
   .if CARRY?
   
    invoke midi_vers_note, na.code_midi, NOTE_DIESE
    mov na.vision_alteration, NOTE_DIESE
   
   .else
   
    invoke midi_vers_note, na.code_midi, NOTE_BEMOL
	mov na.vision_alteration, NOTE_BEMOL
   
   .endif
  
  
  .else ; eodc.flag_alteration == 0
 
 
   ; aucune note voulu altéré en dièse ou en bémol
   invoke midi_vers_note, na.code_midi, NOTE_NATURELLE
   
   ; vérifier si une altération est défini alors soustraire le code midi de 1 suite à la suppression de cette altération
   mov edx, eax
   shr edx, 16
   
   .if edx != NOTE_NATURELLE

     dec na.code_midi
     and eax, 0FFFFh ; enlever l'altération
	 
   .endif
 
   mov na.vision_alteration, NOTE_DIESE
  
  
  .endif
  
  ; eax contient la note convertie 
  mov na.la_note, eax	
 

 ; scrolling auto
 invoke partition_widget_auto_scroll_temps, eodc.numero_temps
  
 ; mettre à jour l'affichage sans éffacer l'arrière plan
 invoke partition_widget_maj_affichage, 0
 
 ret

exercices_oreille_aleatoire endp 
 
 
 
 
; *********************************************
exercices_oreille_dlg_gestion_reponse proc nb_events:dword, buffer_event:dword

 LOCAL t_event:dword
 LOCAL p_event:dword
 LOCAL la_note_appuyee:dword
  
  

 ; stopper le son de la note sur le piano
 invoke midi_out_touche_midi, MIDI_TOUCHE_RELACHEE, na.code_midi
 
  
 assume eax:ptr midi_buffer_event
 
 mov eax, buffer_event
 mov p_event, eax
  
 @event_suivant:

  
 
 mov edx, [eax].type_event
 mov t_event, edx
   
 
  
   
  
 ; gérer seulement les touches appuyées
 .if  t_event == MIDI_TOUCHE_APPUYEE
     
  ; conversion du code midi avec altération
  invoke midi_vers_note, [eax].code_touche, na.vision_alteration
  mov la_note_appuyee, eax	 
	 
  .if eax == na.la_note

   ; afficher la note en verte
   invoke partition_widget_note_def, eodc.numero_temps, TYPE_NOTE_NOIRE, COULEUR_NOTE_VERTE, eax, na.la_portee, na.la_hampe, na.orientation, 1
    	
   inc eodc.nb_notes_ok
   invoke exercice_oreille_dlg_maj_score
   
  .else
  
   ; erreur afficher la note en rouge erroné et afficher celle d'origine en noire
    
   invoke partition_widget_note_def, eodc.numero_temps, TYPE_NOTE_NOIRE, COULEUR_NOTE_NOIRE, na.la_note, na.la_portee, na.la_hampe, na.orientation, 1 
   
   .if na.orientation == ORIENTATION_NOTE_GAUCHE
    mov na.orientation, ORIENTATION_NOTE_DROITE
   .else
    mov na.orientation, ORIENTATION_NOTE_GAUCHE
   .endif
   
   
   ; pour le mode portée double clé sol et fa, afficher la note sur l'autre portée, si celle ci se trouve hors plage sur la portée courante
   .if eodc.clef1 == CLEF_SOL && eodc.clef2 == CLEF_FA
   
    ; vérifier si la note sur la portée est hors plage
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
   
   .endif ; eodc.clef1 == CLEF_SOL && eodc.clef2 == CLEF_FA
   
   
   
   
   invoke partition_widget_note_def, eodc.numero_temps, TYPE_NOTE_NOIRE, COULEUR_NOTE_ROUGE, la_note_appuyee, na.la_portee, HAMPE_ABSENTE, na.orientation, 1
     
	 
  .endif ; eax == na.la_note  
  	 
  
	
   
	
   ; vérifier la fin de l'exercice
   mov eax, eodc.nb_notes
   inc eodc.numero_temps
 
   .if eodc.numero_temps < eax
    
    ; mettre à jour le numéro du temps courant
    invoke exercice_oreille_dlg_maj_score	
	 
    jmp @temps_suivant
   .else
   
    dec eodc.numero_temps
   
    ; mettre à jour l'affichage sans éffacer l'arrière plan
    invoke partition_widget_maj_affichage, 0	
	invoke exercice_oreille_dlg_maj_score
    invoke exercice_oreille_dlg_stop
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
  invoke midi_in_reset_buffer_capture, 1, 0, eodc.hwnd
  
  ret
 
 
  
 @temps_suivant:
 
 
 ; scrolling auto
 invoke partition_widget_auto_scroll_temps, eodc.numero_temps
 
 ; nouvelle note aléatoire
 invoke exercices_oreille_aleatoire 
   
 invoke midi_in_reset_buffer_capture, 1, 0, eodc.hwnd

 ret

exercices_oreille_dlg_gestion_reponse endp 
 
 
 
 END
 
 
 
 
 
 
 
