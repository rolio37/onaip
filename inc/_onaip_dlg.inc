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


WM_LANCE_PARTITION_DLG = WM_USER + 1
WM_PARTITION_LIBRE = WM_USER + 3        ; message envoyé par la fenêtre enfant (exercice) pour rendre la main à la fenêtre principale sur la partition
WM_NOUVEAU_MIDI = WM_USER + 4    ; message reçu de la fenêtre principale, relancer la capture au besoin


IDM_ONAIP_DLG = 10000
IDM_MIDI_ACTUALISER = 10002
IDM_LECTURE_NOTE = 10003
IDM_TRAVAIL_OREILLE = 10001
IDM_APROPOSDE = 10004
IDM_PARTITION_AUTOSCROLLING = 10006

IDCB_MIDI_IN = 1002
IDCB_MIDI_PORT_IN = 1006
IDCK_MIDI_PORT_IN = 1003
IDCK_MIDI_IN = 1004
IDI_MIDI_IN = 1005
IDI_MIDI_OUT = 1007
IDCK_MIDI_OUT = 1008
IDCK_MIDI_PORT_OUT = 1009
IDCB_MIDI_PORT_OUT = 1010
IDCB_MIDI_OUT = 1011
IDW_PIANO = 1013
 
 onaip_dlg_controls STRUCT

  h_idcb_midi_in dword ?
  h_idcb_midi_port_in dword ?
  h_idck_midi_port_in dword ?
  h_idck_midi_in dword ?
  h_idi_midi_in dword ?
  h_idcb_midi_out dword ?
  h_idcb_midi_port_out dword ?
  h_idck_midi_port_out dword ?
  h_idck_midi_out dword ?
  h_idi_midi_out dword ?
  h_idw_piano dword ?
  h_menu dword ?
  
  
  hwnd dword ?
  hwnd_partition dword ?
  hwnd_exercice dword ?
   
 onaip_dlg_controls ENDS

 
 PIANO_PADDING_X = 20
 PIANO_PADDING_Y = 80
 
 
; gestion de la fenêtre principale
onaip_dlg_proc proto :DWORD, :DWORD, :DWORD, :DWORD

; initialisation de la fenêtre
onaip_dlg_init proto


; mettre à jour le combobox pour le midi in
onaip_dlg_maj_midi_in proto

; mettre à jour le combobox pour le midi out
onaip_dlg_maj_midi_out proto

; ouvre le périphérique midi in sélectionné
onaip_dlg_open_midi_in proto

; ouvre le périphérique midi out sélectionné
onaip_dlg_open_midi_out proto

; envoyer le code 
onaip_dlg_midi_out proto :DWORD, :DWORD

; mettre à jour le combobox pour le port midi in
onaip_dlg_maj_port_midi_in proto

; mettre à jour le combobox pour le port midi out
onaip_dlg_maj_port_midi_out proto

; mettre à jour l'état des comboxes et checkboxes midi in
onaip_dlg_maj_midi_in_etat proto

; mettre à jour l'état des comboxes et checkboxes midi out
onaip_dlg_maj_midi_out_etat proto

; mettre à jour l'état du combox port in
onaip_dlg_maj_midi_port_in_etat proto

; gérer les touches appuyées pour le mode libre
onaip_dlg_gestion_partition_mode_libre proto :dword, :dword

; activer ou désactiver les exercices dans le menu
onaip_dlg_etat_menu_exercices proto :dword

; mettre à jour les périphériques midi in/out disponibles
onaip_dlg_menu_midi_actualiser proto

; menu Options -> Midi -> Actualiser les périphériques
onaip_dlg_menu_partition_autoscrolling proto
