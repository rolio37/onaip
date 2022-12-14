COMMENT &

    onaip -- piano software

    Copyright (C) 2015-2022  Ch?dotal Julien

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


MIDI_CODE_MIN = 15h
MIDI_CODE_MAX = 6Ch

MIDI_TOUCHE_APPUYEE = 90h
MIDI_TOUCHE_RELACHEE = 80h

MIDI_MAX_EVENT = 88

; MIDI_NOTE_DIESE = 1


WM_MIDI_BUFFER_EVENT_READY = WM_USER + 2  ; wParam le nombre d'event, lParam pointeur sur le d?but de la structure midi_buffer_event


; structure qui repr?sente un ?v?nement touche appuy?e/rel?ch?...
midi_buffer_event STRUCT

 type_event dword ?         ; MIDI_TOUCHE_APPUYEE ou MIDI_TOUCHE_RELACHEE
 code_touche dword ?         ; de 15h ? 6Ch
 vitesse_touche dword ?      ; de 0 ? 7Fh
 temps dword ?              ; temps ?coul? depuis le d?but de la capture en ms
 

midi_buffer_event ENDS





; fixe les p?riph?riques disponibles pour MIDI IN/OUT
init_midi proto :onaip_dlg_controls 
 
; gestion des entr?es midi
midi_in_proc proto :DWORD, :DWORD, :DWORD, :DWORD, :DWORD 
midi_out_proc proto :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

; retourne la cha?ne du p?riph?rique midi in correspondant ? son num?ro
midi_in_peripherique proto :DWORD


; retourne la cha?ne du p?riph?rique midi out correspondant ? son num?ro
midi_out_peripherique proto :DWORD


; ouvrir le p?riph?rique midi in
midi_in_ouvrir proto :DWORD

; ouvrir le p?riph?rique midi out
midi_out_ouvrir proto :DWORD

; fermer
midi_in_fermer proto

midi_out_fermer proto 

; retourne la pr?sence du p?riph?rique midi out
midi_out_ok proto

; envoyer un code touche midi vers le p?riph?rique
midi_out_touche_midi proto :DWORD, :DWORD


; s?lectionne la vitesse
midi_out_vitesse proto :DWORD

; s?lectionne le port midi in
midi_in_port proto :DWORD

; s?lectionne le port midi out
midi_out_port proto :DWORD

; d?finit si le port midi in doit ?tre ignor?
midi_in_ignore_port proto :DWORD

; fonction qui lance la capture sur le p?riph?rique midi in
midi_in_start_capture proto :DWORD, :DWORD, :DWORD

; stopper la capture des donn?es
midi_in_stop_capture proto

; revenir au debut du buffer et continuer la capture
midi_in_reset_buffer_capture proto :DWORD, :DWORD, :DWORD

; g?re les messages re?us du p?riph?rique (MIM_DATA)
midi_in_gestion_buffer_event proto :DWORD, :DWORD

; fonction qui converti le code midi vers une valeur note sur 32 bits
midi_vers_note proto :DWORD, :DWORD 


; fonction de gestion du mutex
midi_mutex_lock proto
midi_mutex_unlock proto
