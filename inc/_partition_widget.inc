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


; sens du zoom
ZOOM_PLUS = 0
ZOOM_MOINS = 1

; taille en épaisseur des scrollbars
SCROLLBAR_TAILLE = 20    

; valeur de rapport entre le déplacement du scrolling et celui de la souris
SCROLLING_MOUSE_SHR = 4

; maximum de temps sur une partition
TEMPS_MAX = 500 

; maximum de note(touche blanche) par temps 
NOTES_TEMPS_MAX = 52

; taille des fichiers bmp
CLEF_FA_BMP_X_MAX = 55
CLEF_FA_BMP_Y_MAX = 63

CLEF_SOL_BMP_X_MAX = 53
CLEF_SOL_BMP_Y_MAX = 136

ACCOLADE_BMP_X_MAX = 30
ACCOLADE_BMP_Y_MAX = 400

DIESE_BMP_X_MAX = 18
DIESE_BMP_Y_MAX = 64

BEMOL_BMP_X_MAX = 14
BEMOL_BMP_Y_MAX = 47


; taille/distance réel des objets graphiques en zoom 100%

MARGE_GAUCHE = 30
MARGE_DROITE = 60
ECART_PORTEE = 400
ECART_PORTEE_DOUBLE = 320
PORTEE_SIMPLE = 80
PORTEE_DOUBLE = 400
ESPACE_MESURE_NOTE_NOIRE = 100
ECART_ACCOLADE_PORTEE = 4
ECART_ACCOLADE_CLEF_SOL_X = 10
ECART_ACCOLADE_CLEF_SOL_Y = 30
ECART_ACCOLADE_CLEF_FA_X = 10
ECART_ACCOLADE_CLEF_FA_Y = 0
ECART_CLEF_SOL = 298
ECART_CLEF_FA = 321
ECART_INTERLIGNE = 20
ECART_NOTE_Y = ECART_INTERLIGNE / 2
LIGNE_SUP_X = 6

HAMPE_TAILLE = ECART_INTERLIGNE * 4
HAMPE_X = 2
HAMPE_Y = 6
NOTE_X = 24
NOTE_Y = 20
NOTE_CORRECTION_X = 1



; code de choix de la portée pour la note
PORTEE_HAUTE = 1
PORTEE_BASSE = 0


; couleur des notes
COULEUR_NOTE_NOIRE = 0
COULEUR_NOTE_VERTE = 007F00h
COULEUR_NOTE_ROUGE = 00FFh

; ********************************
; type de partition
MODE_PORTEE_SIMPLE = 0 
MODE_PORTEE_DOUBLE = 1
CLEF_FA = 3
CLEF_SOL = 4
ARMATURE_DIESE = 5
ARMATURE_BEMOL = 6
ARMATURE_NATURELLE = 7 ; absence d'altération

; champ de bits des note altérées pour l'armature
ARMATURE_DO = 1
ARMATURE_RE = 2
ARMATURE_MI = 4
ARMATURE_FA = 8
ARMATURE_SOL = 16
ARMATURE_LA = 32
ARMATURE_SI = 64

TYPE_NOTE_NOIRE = 0; 
TYPE_NOTE_BLANCHE = 1;
TYPE_NOTE_RONDE = 2;


NOTE_DO = 0;
NOTE_RE = 1;
NOTE_MI = 2;
NOTE_FA = 3;
NOTE_SOL = 4;
NOTE_LA = 5;
NOTE_SI = 6;

_7NOTES = 7;

NON = 0
OUI = 1
NOTE_HORS_PORTEE = 2

HAMPE_ABSENTE = 0
HAMPE_EN_HAUT = 1
HAMPE_EN_BAS = 2

ORIENTATION_NOTE_GAUCHE = 0
ORIENTATION_NOTE_DROITE = 1


NOTE_NATURELLE = 0
NOTE_DIESE = 1
NOTE_BEMOL = 2

DECALAGE_OCTAVE_0 = 5 ; padding

; plage de note affichable sur chaque clef
INDEX_CLEF_SOL_MIN = 21
INDEX_CLEF_SOL_MAX = 56
INDEX_CLEF_FA_MIN = DECALAGE_OCTAVE_0 ; correspond au padding
INDEX_CLEF_FA_MAX = 34

; *************************************

; *************************************
; correspond à une note sur 52 possibles
note STRUCT

 type_ dword ?  ; noir ronde
 couleur dword ?
 alteration dword ? 
 hampe dword ?            ; hampe vers le bas ou le haut ou absente
 orientation dword ?      ; note à gauche ou à droite de la hampe
 flag_afficher dword ?  
  
note ENDS



partition_widget_infos STRUCT
 
 h_partition_widget dword ?
 h_scrollbar_v dword ?
 h_scrollbar_h dword ?
 
 hwnd dword ?
 hbitmap_zoom_x1 dword ?            ; le bitmap qui représente l'image en taille réel de la partition
 hbitmap_zoom_affichage dword ?     ; l'image réellement affiché à l'écran
 hdc_zoom_x1 dword ?                ; handle graphique sur le dessin de référence
 hdc_zoom_affichage dword ?         ; handle graphique sur le dessin d'affichage 
 rect_dessin RECT <>                ; rectangle de la zone de dessin valide/visible
 bitmap_x_max dword ?               ; taille max en pixel de hbitmap_zoom_x1
 bitmap_y_max dword ?
 
 bitmap_zoom_x_max dword ?          ; taille de l'image finale à afficher
 bitmap_zoom_y_max dword ?
 
 rect_bitmap RECT <>                ; la zone de dessin complète
 flag_barre_verticale dword ?       
 flag_barre_horizontale dword ?
 
 
 ; image prédéfinie
 h_bitmap_clef_fa dword ?
 h_bitmap_clef_sol dword ?
 h_bitmap_accolade dword ?
 h_bitmap_diese dword ?
 h_bitmap_bemol dword ?
 
 
 
 
 ; taille des objets dans le zoom courant 
 bitmap_clef_sol_x_max dword ?
 bitmap_clef_sol_y_max dword ?
 
 bitmap_clef_fa_x_max dword ?
 bitmap_clef_fa_y_max dword ?
 
 bitmap_accolade_x_max dword ?
 bitmap_accolade_y_max dword ?
 
 bitmap_diese_x_max dword ?
 bitmap_diese_y_max dword ?
 
 bitmap_bemol_x_max dword ?
 bitmap_bemol_y_max dword ?
 
 
 ; infos de mise en page
 marge_gauche dword ?
 marge_droite dword ?
 ecart_portee dword ?
 ecart_accolade_portee dword ? 
 ecart_accolade_clef_sol_x dword ?
 ecart_accolade_clef_sol_y dword ?
 ecart_accolade_clef_fa_x dword ?
 ecart_accolade_clef_fa_y dword ?
 ecart_clef_sol dword ?    ; ecart de clef entre la 1er portée et la deuxième pour la clef de sol en dessous
 ecart_clef_fa dword ?     ; pour la cle de fa en dessous
 portee_double dword ?    ; taille du premier rectangle (le plus grand)
 portee_simple dword ? 
 ecart_portee_double dword ?    ; valeur d'écart entre les deux portées pour le mode portée double 
 espace_mesure_note_noire dword ?  ; l'espace nécessaire pour chaque note
 portee_x_max dword ? 
 ecart_interligne dword ?
 ecart_note_y dword ?              ; ecart de deux notes sur l'axe y
 note_x dword ?
 note_y dword ?
 note_correction_x dword ?
 hampe_taille dword ?   ; taille de la hampe
 hampe_y dword ?        ; décalage par rapport au point initial de traçage
 hampe_x dword ?        ; idem
 ligne_sup_x dword ?
 
 
 
 
 
 
 ; informations portée
 mode_portee dword ?       ; portee simple ou double
 zoom_partition sdword ?    ; zoom global de l'ensemble de la partition  -2 = taille / 2 | 2 = taille * 2
 zoom_min dword ?
 zoom_max dword ?
 zoom_partition_precedent dword ?  ; zoom pour les cas d'erreur d'allocation de resource avec CreateCompatibleBitmap
 
  
 clef_simple dword ?       ; type de clef sol et/ou fa   
 clef_double dword ? 
 notes_par_portee dword ?  
 nb_portee_max dword ?       ; nombres maximum de portée
 armature_type dword ?     ; diese ou bémol
 armature_notes dword ?    
 nb_temps_max dword ?      ; nombres maximum de temps de la configuration actuelle <= TEMPS_MAX
 
 flag_dessine_bitmap_zoom dword ?   ; évite de redéssiner la partition, si aucune modification est éffectué dessus  
 flag_autoscrolling dword ?         ; pour dés/activer le scrolling automatique
 
 
 click_gauche_souris_x dword ?    ; valeur de départ du click gauche
 click_gauche_souris_y dword ?    ; à comparer lors d'un WM_MOUSEMOVE pour déplacer le scrolling de la partition
 
 
partition_widget_infos ENDS


; enregistre la classe piano_widget_class
partition_widget_class_register proto

; window proc du widget
partition_widget_proc proto :HWND, :UINT, :WPARAM, :LPARAM

; nc
partition_widget_dessine_partition proto 


; nc
partition_widget_init proto

; allocation du bitmap de taille réel de travail
partition_widget_bitmap_zoom_x1_alloc proto


; fonction qui calcul la zone final de dessin disponible et ajoute au besoin les barres de scroll
partition_widget_resize proto

; gestion des scrollbars
partition_widget_scrollbar proto :dword, :dword


; dessine les portées avec les clées, armature, accolade
partition_widget_dessine_portees proto :dword

; dessine les notes de musique
partition_widget_dessine_notes proto

; nc
partition_widget_dessine_une_note proto :dword, :dword, :dword, :dword


; déssine l'altération dièse ou bémole
partition_widget_dessine_alteration proto :dword, :dword, :dword, :dword, :dword

; déssine la ligne supplémentaire en dehors des portées
partition_widget_dessine_ligne_sup proto :dword, :dword, :dword


; nc
partition_widget_trace_rectangle proto :dword, :dword, :dword, :dword, :dword, :dword, :dword



; mise à zéro de la base de données des notes
partition_widget_notes_reset proto

; définir une note
partition_widget_note_def proto :dword, :dword, :dword, :dword, :dword, :dword, :dword, :dword

; mettre à jour l'affichage des notes
partition_widget_maj_affichage proto :dword

; définir les paramètres de la partition
partition_widget_def proto :dword, :dword, :dword, :dword, :dword

; indique si une note est hors de sa portée 
partition_widget_hors_portee proto :dword, :dword

; gestion du zoom de la partition
partition_widget_zoom proto :dword, :dword

; gestion de la roulette de la souris pour le zoom
partition_widget_roulette_souris proto :dword, :dword

; fixe le scrolling verticale et horizontale de la partition automatiquement
partition_widget_auto_scroll_temps proto :dword


; trace les images pixels par pixels en ignorant les pixels de couleur qui représente la transparence
partition_widget_trace_bitmap_alpha proto :dword, :dword, :dword, :dword, :dword, :dword, :dword, :dword

; calcul la taille des objets au zoom choisi
partition_widget_calcul_zoom proto

; dés/active l'auto scrolling de la partition
partition_widget_fixe_auto_scrolling proto :dword

; gére le scrolling via le click gauche de la souris avec son déplacemement
partition_widget_souris_scrolling proto :dword, :dword

