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


IDW_PARTITION = 1001


partition_dlg_controls STRUCT

  h_idw_partition dword ?
  hwnd dword ?
     
 partition_dlg_controls ENDS


; gestion de la fenêtre principale
partition_dlg_proc proto :DWORD, :DWORD, :DWORD, :DWORD

; nc
partition_dlg_init proto

; changer le titre de la fenêtre
partition_dlg_titre_fenetre proto :dword
