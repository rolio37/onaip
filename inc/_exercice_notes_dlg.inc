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


WM_NOUVEAU_MIDI = WM_USER + 4    ; message reçu de la fenêtre principale, relancer la capture au besoin






IDLB_TYPE_PARTITION =  1002
IDLB_TYPE_PORTEE  = 1005
IDLB_NB_NOTES = 1006
IDLB_NB_OCTAVES = 1009
IDCK_ALTERATION_DIESE = 1011
IDCK_ALTERATION_BEMOL = 1012
IDT_NB_NOTES_OK = 1014
IDT_NB_NOTES = 1015
IDT_POURCENTAGE = 1018
IDB_GO = 1019
IDB_STOP = 1021
IDT_NB_TEMPS_MAX = 1025
IDT_TEMPS = 1026



; une note aléatoire a afficher
note_aleatoire STRUCT

 la_note dword ?     ; la note au format compacté aprés conversion midi
 la_portee dword ?   ; porte du haut ou bas
 la_hampe dword ?    ; dirigé vers le haut ou bas 
 orientation dword ? ; note dirigé vers la gauche ou droite
 vision_alteration dword ?    ; vision dièse ou bémol
 
note_aleatoire ENDS





exercice_notes_dlg_controls STRUCT

 hwnd dword ?
 h_idlb_type_partition dword ?
 h_idlb_nb_portees dword ?
 h_idlb_nb_notes dword ?
 h_idlb_nb_octaves dword ?
 h_idck_alteration_diese dword ?
 h_idck_alteration_bemol dword ?
 h_idt_nb_notes_ok dword ?
 h_idt_nb_notes dword ?
 h_idt_pourcentage dword ?
 h_idb_go dword ?
 h_idb_stop dword ?
 h_idt_temps dword ?
 h_idt_nb_temps_max dword ?
 
 
 
 
 ; variables pour la configuration de la partition
 mode_portee dword ?
 clef1 dword ?
 clef2 dword ?
 nb_notes_portee dword ?
 nb_portees dword ?
 nb_notes dword  ?
 numero_temps dword ?
 
 
 ; variables de l'exercice
 nb_notes_ok dword ?
 pourcentage dword ?
 
 code_midi_min_clef_1 dword ?
 touche_max_clef_1 dword ?    ; pas utilisé

 code_midi_min_clef_2 dword ?
 touche_max_clef_2 dword ?    ; pas utilisé
 
 touche_aleatoire_max dword ?
 
 
 flag_alteration_accidentelle_diese dword ?
 flag_alteration_accidentelle_bemol dword ?
 
 code_midi_max dword ?
 
 flag_exercice dword ? ; 1 indique si l'exercice est en cours
 
 
exercice_notes_dlg_controls ENDS
 


; gestion de la fenêtre principale
exercice_notes_dlg_proc proto :DWORD, :DWORD, :DWORD, :DWORD

; nc
exercice_notes_dlg_init proto

; mise à jour de la fenêtre partition selon la configuration choisi
exercice_notes_dlg_maj_partition proto

; mise à joue du score
exercice_notes_dlg_maj_score proto


; bouton go, démarrage de l'exercice
exercice_notes_dlg_go proto

; bouton stop, arrêt de l'exercice
exercice_notes_dlg_stop proto

; gérer les réponse de l'utilisateur
exercices_notes_dlg_gestion_reponse proto :DWORD, :DWORD

; génére une note aléatoire
exercices_notes_aleatoire proto

