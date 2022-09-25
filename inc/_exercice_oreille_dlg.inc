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


IDLB_TYPE_PARTITION_2 =  1015
IDLB_TYPE_PORTEE_2  = 1014
IDLB_NB_NOTES_2 = 1011
IDLB_NB_OCTAVES_2 = 1010
IDCK_ALTERATION = 1007
IDT_NB_NOTES_OK_2 = 1021
IDT_NB_NOTES_2 = 1023
IDT_POURCENTAGE_2 = 1024
IDB_GO_2 = 1019
IDB_STOP_2 = 1018
IDT_NB_TEMPS_MAX_2 = 1003
IDT_TEMPS_2 = 1005
IDLB_NUANCE = 1027
IDB_ECOUTER_NOTE = 1025



; une note aléatoire a afficher
note_aleatoire_2 STRUCT

 la_note dword ?     ; la note au format compacté aprés conversion midi
 la_portee dword ?   ; porte du haut ou bas
 la_hampe dword ?    ; dirigé vers le haut ou bas 
 orientation dword ? ; note dirigé vers la gauche ou droite
 vision_alteration dword ?    ; vision dièse ou bémol
 code_midi dword ?          ; le code midi de la note à envoyer au piano
 
note_aleatoire_2 ENDS





exercice_oreille_dlg_controls STRUCT

 hwnd dword ?
 h_idlb_type_partition dword ?
 h_idlb_nb_portees dword ?
 h_idlb_nb_notes dword ?
 h_idlb_nb_octaves dword ?
 h_idlb_nuance dword ?
 h_idck_alteration dword ?
 h_idt_nb_notes_ok dword ?
 h_idt_nb_notes dword ?
 h_idt_pourcentage dword ?
 h_idb_go dword ?
 h_idb_stop dword ?
 h_idb_ecouter_note dword ?
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
 nuance dword ?        ; choix du niveau sonore envoyé au piano numérique ou virtuel
 
 ; variables de l'exercice
 nb_notes_ok dword ?
 pourcentage dword ?
 
 code_midi_min_clef_1 dword ?
 touche_max_clef_1 dword ?    ; pas utilisé

 code_midi_min_clef_2 dword ?
 touche_max_clef_2 dword ?    ; pas utilisé
 
 touche_aleatoire_max dword ?
 
 
 flag_alteration dword ?  ; si l'utilisateur choisi les altérations
 
 code_midi_max dword ?
 
 flag_exercice dword ? ; 1 indique si l'exercice est en cours
 
 
exercice_oreille_dlg_controls ENDS
 


; gestion de la fenêtre principale
exercice_oreille_dlg_proc proto :DWORD, :DWORD, :DWORD, :DWORD

; nc
exercice_oreille_dlg_init proto

; mise à jour de la fenêtre partition selon la configuration choisi
exercice_oreille_dlg_maj_partition proto

; mise à joue du score
exercice_oreille_dlg_maj_score proto


; bouton go, démarrage de l'exercice
exercice_oreille_dlg_go proto

; bouton stop, arrêt de l'exercice
exercice_oreille_dlg_stop proto

; gérer les réponse de l'utilisateur
exercices_oreille_dlg_gestion_reponse proto :DWORD, :DWORD

; génére une note aléatoire
exercices_oreille_aleatoire proto

