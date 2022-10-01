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






.data?

 mic MIDIINCAPSA <>
 moc MIDIOUTCAPSA <>

 h_midi_in DWORD ? 
 h_midi_out DWORD ?

 ; ** Gestion du buffer midi event ** 
 mbe midi_buffer_event MIDI_MAX_EVENT dup(<>)
 midi_event_total dword ?
 midi_event_touche_appuyee dword ?
 midi_event_touche_relachee dword ?
 midi_event_hwnd dword ?
 midi_event_condition_touche_appuyee dword ?
 midi_event_condition_touche_relachee dword ?
 
.data

 flag_midi_mutex dword 0

 flag_midi_in dword 0  ; 0 aucun midi ouvert sinon 1
 flag_midi_out dword 0 
  
 nb_peripherique_midi_in dword 0
 nb_peripherique_midi_out dword 0

 flag_capture_in dword 0     ; flag pour la capture du piano virtuel ou/et réel 
 
 port_midi_out dword 0
 port_midi_in dword 0
 
 ignore_port_midi_in dword 0    ; si 1 tous les ports en entrée
 vitesse_midi_out dword 40h ; nuance mf
 
 midi_max_event dword MIDI_MAX_EVENT ; limite de buffer arbitraire
 
 
 table_midi_note_taille_ligne dword 4 * 4
 table_midi_champ_note_offset dword 0
 table_midi_champ_note_diese_offset dword 4
 table_midi_champ_vision_diese_offset dword 8
 table_midi_champ_vision_bemol_offset dword 12
 
 
                       ; NOTE    |  ALTERATION    | VISION DIESE | VISION BEMOL 
 table_midi_note dword NOTE_DO,        NON,           NOTE_SI,       NON, 
                       NOTE_DO,        OUI,           NON,           NOTE_RE,
					   NOTE_RE,        NON,           NON,           NON, 
					   NOTE_RE,        OUI,           NON,           NOTE_MI,
					   NOTE_MI,        NON,           NON,           NOTE_FA,
					   NOTE_FA,        NON,           NOTE_MI,       NON
 table_midi_not_ dword NOTE_FA,        OUI,           NON,           NOTE_SOL,
					   NOTE_SOL,       NON,           NON,           NON,
					   NOTE_SOL,       OUI,           NON,           NOTE_LA,
					   NOTE_LA,        NON,           NON,           NON,
					   NOTE_LA,        OUI,           NON,           NOTE_SI,
					   NOTE_SI,        NON,           NON,           NOTE_DO
 
.code







; *************************************************************
; retourne 0 si aucune chaîne n'est disponible pour le périphérique midi in numéro ?
midi_in_peripherique proc numero_peripherique:DWORD


 invoke midiInGetNumDevs

 mov nb_peripherique_midi_in, eax

 .if numero_peripherique >= eax
  ; numéro de périphérique hors plage
  xor eax, eax
  ret
 .endif
 
 
 invoke midiInGetDevCaps, numero_peripherique, addr mic, sizeof MIDIINCAPSA
   
 .if eax != MMSYSERR_NOERROR
  xor eax, eax
  ret
 .endif
 
 ; eax = nom du périphérique
 mov eax, offset mic.szPname 
 ret
  
midi_in_peripherique endp


; **************************************************************
; retourne 0 si aucune chaîne n'est disponible pour le périphérique midi in numéro ?
midi_out_peripherique proc numero_peripherique:DWORD


 invoke midiOutGetNumDevs

 mov nb_peripherique_midi_out, eax

 .if numero_peripherique >= eax
  ; numéro de périphérique hors plage
  xor eax, eax
  ret
 .endif
 
 
 invoke midiOutGetDevCaps, numero_peripherique, addr moc, sizeof MIDIOUTCAPSA
   
 .if eax != MMSYSERR_NOERROR
  xor eax, eax
  ret
 .endif
 
 ; eax = nom du périphérique
 mov eax, offset moc.szPname 
 ret
  
midi_out_peripherique endp




; ***********************************
; eax = 0 ok sinon GETLASTERROR
midi_in_ouvrir proc numero_peripherique:DWORD

 .if nb_peripherique_midi_in == 0
  ; pas de peripherique midi in de disponible
  mov eax, 1
  ret
 .endif


 ; arrêter la capture de l'ancien midi in, si besoin
 invoke midi_in_stop_capture

 
 ; vérifier s'il n'y a pas un déjà d'ouvert
 .if flag_midi_in == 1
  
  invoke midiInClose, h_midi_in
  
  .if eax != MMSYSERR_NOERROR
   invoke GetLastError
   ret
  .endif
  
 .endif

 ; on ouvre le périphérique midi en entrée
 invoke midiInOpen, addr h_midi_in, numero_peripherique, addr midi_in_proc, 0, CALLBACK_FUNCTION 
  
 .if eax != MMSYSERR_NOERROR
  invoke GetLastError
  ret
 .endif

 ; ok
 mov flag_midi_in, 1
 xor eax, eax
 ret

midi_in_ouvrir endp


; ***********************************
; eax = 0 ok sinon GETLASTERROR
midi_out_ouvrir proc numero_peripherique:DWORD

 .if nb_peripherique_midi_out == 0
  ; pas de peripherique midi out de disponible
  mov eax, 1
  ret
 .endif

 ; vérifier s'il n'y a pas un déjà d'ouvert
 .if flag_midi_out == 1
  
  invoke midiOutClose, h_midi_out
  
  .if eax != MMSYSERR_NOERROR
   invoke GetLastError
   ret
  .endif
  
 .endif

 ; on ouvre le périphérique midi en entrée
 invoke midiOutOpen, addr h_midi_out, numero_peripherique, addr midi_out_proc, 0, CALLBACK_FUNCTION 
 
 .if eax != MMSYSERR_NOERROR
  invoke GetLastError
  ret
 .endif

 ; ok
 mov flag_midi_out, 1
 xor eax, eax
 ret

midi_out_ouvrir endp



; ***********************************
midi_out_ok proc

 ; retourne dans eax -> flag_midi_out
 mov eax, flag_midi_out
 ret

midi_out_ok endp



; *******************************************************************
; gestion MIDI IN
midi_in_proc proc hMidiIn:DWORD, wMsg:DWORD, dwInstance:DWORD, dwParam1:DWORD, dwParam2:DWORD

 LOCAL code_midi:byte
 LOCAL code_touche:byte
 
 .if wMsg == MIM_DATA

   invoke midi_in_gestion_buffer_event, dwParam1, dwParam2
 
 .endif


 ret

midi_in_proc endp


; *******************************************************************
; gestion MIDI OUT
midi_out_proc proc hMidiOut:DWORD, wMsg:DWORD, dwInstance:DWORD, dwParam1:DWORD, dwParam2:DWORD
 
 

 
 
 ret

midi_out_proc endp


; ***************************************************************
midi_out_touche_midi proc etat_touche:DWORD, code_touche:DWORD

   ; périphérique ouvert ? 
  .if flag_midi_out == 0
   ret
  .endif


 .if etat_touche != MIDI_TOUCHE_APPUYEE && etat_touche != MIDI_TOUCHE_RELACHEE
  ret
 .endif
 
 ; 16 ports max 0 -> 15
 .if port_midi_out > 0Fh
  ret
 .endif
 
 ; limiter les codes midi au piano 88 touches
 .if code_touche < 15h || code_touche > 6Ch
  ret
 .endif 
 
 ; vitesse maximum 7Fh
 .if vitesse_midi_out > 7Fh
  ret
 .endif
 

 mov eax, vitesse_midi_out
 shl eax, 8
 
 mov edx, code_touche
 mov al, dl
 shl eax, 8
  
 mov edx, etat_touche
 or edx, port_midi_out
 mov al, dl
   
 invoke midiOutShortMsg, h_midi_out, eax
 

 ret
 
midi_out_touche_midi endp


; *****************************************************
midi_out_vitesse proc vitesse:DWORD

 mov eax, vitesse
 mov vitesse_midi_out, eax
 
 ret
 
midi_out_vitesse endp


; *************************************************
midi_in_port proc port:DWORD

 mov eax, port
 mov port_midi_in, eax
 
 ret
  
midi_in_port endp


; *************************************************
midi_out_port proc port:DWORD

 mov eax, port
 mov port_midi_out, eax
 
 ret
  
midi_out_port endp


; *********************************
midi_in_fermer proc
  
 .if flag_midi_in == 1 
  invoke midiInClose, h_midi_in
  mov flag_midi_in, 0
 .endif
 
 ret
 
midi_in_fermer endp


; *********************************
midi_out_fermer proc
  
 .if flag_midi_out == 1
  invoke midiOutClose, h_midi_out
  mov flag_midi_out, 0
 .endif
 
 ret
 
midi_out_fermer endp



; ************************************
midi_in_ignore_port proc ignore:DWORD
  
 ; 1 = port midi in ignoré
 .if ignore != 0
  mov ignore_port_midi_in, 1
 .else
  mov ignore_port_midi_in, 0
 .endif

 ret
 
midi_in_ignore_port endp



; ************************************
; condition : nombre de touche appuyée et relâchée avant d'arrêter la capture et l'envoie d'un message à la procédure définie
midi_in_start_capture proc nb_touche_appuyee:DWORD, nb_touche_relachee:DWORD, hwnd_fenetre_destination:DWORD


 ; capture pour le périphérique/piano virtuel et physique 
 

 
 ; reset
 mov midi_event_total, 0
 mov midi_event_touche_appuyee, 0
 mov midi_event_touche_relachee, 0
 
 mov eax, hwnd_fenetre_destination
 mov midi_event_hwnd, eax

 mov eax, nb_touche_appuyee
 mov midi_event_condition_touche_appuyee, eax
 
 mov eax, nb_touche_relachee
 mov midi_event_condition_touche_relachee, eax
 
 
 mov flag_capture_in, 1
 
 ; périphérique réel ouvert ?
 .if flag_midi_in == 1
  ; commencer la capture des données
  invoke midiInStart, h_midi_in
 .endif
 
 ret
 
midi_in_start_capture endp



; **************************
midi_in_stop_capture proc

   ; les prochaines captures sont ignorées
   ; cela permet de vider la file d'attente, une fois l'api midiInStop appelé
   mov flag_capture_in, 0

  ; !!! déverrouiller le vérrou avant l'appel de l'api midiInStop !!!
  ; car il reste des messages midi bloqués en file d'attente et la fonction reste bloquante dans ce cas
  invoke midi_mutex_unlock
   
 .if flag_midi_in == 1
  ; arrêter la capture
  invoke midiInStop, h_midi_in
  
 .endif

 
 ret

midi_in_stop_capture endp



; ******************************************
midi_in_reset_buffer_capture proc nb_touche_appuyee:DWORD, nb_touche_relachee:DWORD, hwnd_fenetre_destination:DWORD

 mov midi_event_total, 0
 mov midi_event_touche_appuyee, 0
 mov midi_event_touche_relachee, 0
 
 mov eax, hwnd_fenetre_destination
 mov midi_event_hwnd, eax

 mov eax, nb_touche_appuyee
 mov midi_event_condition_touche_appuyee, eax
 
 mov eax, nb_touche_relachee
 mov midi_event_condition_touche_relachee, eax

 invoke midi_mutex_unlock
 
 ret

midi_in_reset_buffer_capture endp



; *****************
midi_in_gestion_buffer_event proc midi_message:DWORD, temps:DWORD

 LOCAL midi_code:dword
 LOCAL port_midi:dword
 LOCAL touche_midi:dword
 LOCAL vitesse:dword
 
 .if midi_event_total == MIDI_MAX_EVENT
  ; buffer plein
  ret
 .endif
 
 
 ; prendre ou attendre la libération du vérrou
 invoke midi_mutex_lock
  
  
 ; capture ok ?
 ; valable aussi bien pour le clavier virtuel que physique (midi in) 
 .if flag_capture_in == 0
  
  ; il reste des messages midi en attente mais la capture a été désactivée
  ; ignorer ces messages midi
  jmp @mutex_unlock
  
 .endif  
  
  
 mov eax, midi_message
 and eax, 0FFh
 mov edx, eax
  
   
 ; isole le code midi
 and eax, 0F0h
 
 .if eax == MIDI_TOUCHE_APPUYEE || eax == MIDI_TOUCHE_RELACHEE
  
  ; code midi
  mov midi_code, eax
    
  ; isole le numéro de port midi
  and edx, 0Fh
  mov port_midi, edx

  ; vérifier si le port midi correspond à celui attendu
  .if ignore_port_midi_in == 0
   .if port_midi_in != edx
    ; prendre ou attendre la libération du vérrou
    jmp @mutex_unlock
   .endif
  
  .endif
  
  ; isoler la code touche
  mov eax, midi_message
  shr eax, 8
  mov edx, eax
  and eax, 0FFh
  
  ; vérifier si la touche est bien entre 15h et 6Ch
  .if eax >= 15h && eax <= 6Ch
   mov touche_midi, eax
  .else
   ; code touche incorrect
   jmp @mutex_unlock
  .endif  
  
  ; isoler la vitesse
  shr edx, 8
  and edx, 0FFh
  
  ; vérifier si la vitesse est bien entre 0 et 7Fh
  .if edx <= 7Fh
   mov vitesse, edx  
  .else
   ; vitesse incorrect
   jmp @mutex_unlock
  .endif
  
  
  
  ; faire pointer eax, sur l'event suivant
  mov eax, TYPE midi_buffer_event
  mov ecx, midi_event_total
  mul ecx
  add eax, offset mbe
  
  
  ; définir le type d'event
  .if midi_code == MIDI_TOUCHE_APPUYEE && vitesse == 0 || midi_code == MIDI_TOUCHE_RELACHEE
  
   ; touche relâchée
   mov (midi_buffer_event PTR [eax]).type_event, MIDI_TOUCHE_RELACHEE
   inc midi_event_touche_relachee
   
  .else
   
   ; touche appuyée
   mov (midi_buffer_event PTR [eax]).type_event, MIDI_TOUCHE_APPUYEE  
   inc midi_event_touche_appuyee
   
  .endif
  
  
  ; code touche
  mov edx, touche_midi
  mov (midi_buffer_event PTR [eax]).code_touche, edx
  
  ; vitesse
  mov edx, vitesse
  mov (midi_buffer_event PTR [eax]).vitesse_touche, edx
  
  ; temps
  mov edx, temps
  mov (midi_buffer_event PTR [eax]).temps, edx
  
  inc midi_event_total
  
  ; ******************************************************************************
  
  ; vérifier si les conditions sont validées pour stopper la capture et envoyer un message à la fenêtre
  mov eax, midi_event_touche_appuyee
  mov edx, midi_event_touche_relachee
  
  .if eax >= midi_event_condition_touche_appuyee && edx >= midi_event_condition_touche_relachee
  
  
   
   ; envoyer un message 
   invoke PostMessageA, midi_event_hwnd, WM_MIDI_BUFFER_EVENT_READY, midi_event_total, addr mbe
   
   ; le verrou reste fermer(=1) tant que la procédure qui reçoit le message WM_MIDI_BUFFER_EVENT_READY
   ; n'a pas relancer la nouvelle capture
   ret
  
  .endif
  
  
 .endif ; eax == MIDI_TOUCHE_APPUYEE || eax == MIDI_TOUCHE_RELACHEE
 
 
 @mutex_unlock:
 
 ; la condition de capture des données n'est pas atteinte, libérer le vérrou
 invoke midi_mutex_unlock
 
 
 ret
 
midi_in_gestion_buffer_event endp



; ***********************************
; en retour eax = contient la définition de la note compactée si erreur alors 0
; 8 bits précédents ah = altération, ah = numéro de la note, al = numéro de l'octave
; choix_alteration utilisé seulement si le code_midi est une altération
midi_vers_note proc code_midi:DWORD, choix_alteration:DWORD

 LOCAL numero_note:dword
 LOCAL numero_octave:dword
 LOCAL table_midi_index:dword
 LOCAL alteration:dword
 
 
 
 ; fixer le code_midi
 mov edx, code_midi

 .if edx >= MIDI_CODE_MIN && edx <= MIDI_CODE_MAX || edx == 0

  
  ; calculer l'octave pour la note
  xor edx, edx
  mov eax, code_midi
  mov ecx, 12
  div ecx
  dec eax
  mov numero_octave, eax
  mov numero_note, edx ; edx contient le reste donc le numéro de la note
  
  
  
  
  ; définir si la note est altérer en diese avec le tableau de conversion midi
  mov eax, table_midi_note_taille_ligne
  mov edx, numero_note
  mul edx
  add eax, offset table_midi_note
  mov table_midi_index, eax
  
  ; fixer le vrai numéro de note 1 à 7 sans les altérations
  ; add eax, table_midi_champ_note_offset 1er champ de tableau offset 0
  mov eax, [eax]
  mov numero_note, eax
  
  
  
  mov eax, table_midi_index
  add eax, table_midi_champ_note_diese_offset
  mov eax, [eax]
  
  ; note altérer
  .if eax == OUI
  
   .if choix_alteration == NOTE_BEMOL

    ; la note en # = à la note suivante en b
    inc numero_note
	mov alteration, NOTE_BEMOL
  
   .else
   
    ; par défault note #
    mov alteration, NOTE_DIESE
	
   .endif
    
    
  .else
   
   ; note natuelle
   mov alteration, NOTE_NATURELLE
  
  .endif
  
  
  
  
 .else
  xor eax, eax
  ret  
 .endif

 
 ; fixer eax
 xor eax, eax
 mov edx, alteration
 mov al, dl
 shl eax, 16
 
 mov edx, numero_note
 mov ah, dl
 
 mov edx, numero_octave
 mov al, dl


 ret

midi_vers_note endp



; ******************************
midi_mutex_lock proc
 
 
 @attente_liberation:
 
  ; évite de la charge cpu inutile
  invoke Sleep, 1
 
  mov ecx, 1
  xor eax, eax
 
 lock cmpxchg flag_midi_mutex, ecx
 jnz @attente_liberation
 
 ret
 
midi_mutex_lock endp



; **************************
midi_mutex_unlock proc

 mov flag_midi_mutex, 0

 ret

midi_mutex_unlock endp



END
