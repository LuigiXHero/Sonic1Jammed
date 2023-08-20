; ---------------------------------------------------------------------------
; JAM: Add spindash dust animations
; ---------------------------------------------------------------------------
		dc.w Obj8DAni_Null-Ani_obj8D
		dc.w Obj8DAni_Null-Ani_obj8D
		dc.w Obj8DAni_Dash-Ani_obj8D
		dc.w Obj8DAni_Skid-Ani_obj8D
Obj8DAni_Null:	dc.b $1F, 0, $FF
		even
Obj8DAni_Dash:	dc.b 1, 1, 2, 3, 4, 5, 6, 7, $FF
		even
Obj8DAni_Skid:	dc.b 3, 8, 9, $A, $B, $FC
		even