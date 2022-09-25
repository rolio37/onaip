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


 ; taille d'origine l'image du piano
 PIANO88_BMP_X_MAX = 415
 PIANO88_BMP_Y_MAX = 33 




piano_widget_infos STRUCT
 
 h_bitmap_piano dword ?
 h_bitmap_piano_midi dword ?
 h_mem_piano dword ?               ; mémoire alloué des codes couleurs (rouge) qui correspondent aux codes midi
 zoom_piano dword ?                ; facteur d'agrandissement du piano
 
 hwnd dword ?
 ; piano_dc dword ?
 
piano_widget_infos ENDS







; enregistre la classe piano_widget_class
piano_widget_class_register proto

; window proc du widget
piano_widget_proc proto :HWND, :UINT, :WPARAM, :LPARAM

; nc
piano_widget_dessine_piano proto 

; nc
piano_widget_click_gauche proto :UINT, :LPARAM

; nc
piano_widget_init proto

