; ---------------------------------------------------------------------------
; JAM: Add spindash dust mappings
; CHG: Uses DPLCs
; ---------------------------------------------------------------------------
		dc.w Map_obj8D_1A-Map_obj8D, Map_obj8D_1B-Map_obj8D	
		dc.w Map_obj8D_21-Map_obj8D, Map_obj8D_27-Map_obj8D	
		dc.w Map_obj8D_2D-Map_obj8D, Map_obj8D_38-Map_obj8D	
		dc.w Map_obj8D_43-Map_obj8D, Map_obj8D_4E-Map_obj8D	
		dc.w Map_obj8D_59-Map_obj8D, Map_obj8D_5F-Map_obj8D	
		dc.w Map_obj8D_65-Map_obj8D, Map_obj8D_6B-Map_obj8D	
		dc.w Map_obj8D_1A-Map_obj8D	
Map_obj8D_1A:	dc.b 0
Map_obj8D_1B:	dc.b 1
		dc.b 4, $8D, 0, 0, $E0		; 4, $8D, 0, 0, $E0
Map_obj8D_21:	dc.b 1
		dc.b 4, $8D, 0, 0, $E0		; 4, $8D, 0, 8, $E0
Map_obj8D_27:	dc.b 1
		dc.b 4, $8D, 0, 0, $E0		; 4, $8D, 0, $10, $E0
Map_obj8D_2D:	dc.b 2
		dc.b $F4, $81, 0, 0, $E8	; $F4, $81, 0, $18, $E8
		dc.b 4, $8D, 0, 2, $E0		; 4, $8D, 0, $1A, $E0
Map_obj8D_38:	dc.b 2
		dc.b $F4, $85, 0, 0, $E8	; $F4, $85, 0, $22, $E8
		dc.b 4, $8D, 0, 4, $E0		; 4, $8D, 0, $26, $E0
Map_obj8D_43:	dc.b 2
		dc.b $F4, $89, 0, 0, $E0	; $F4, $89, 0, $2E, $E0
		dc.b 4, $8D, 0, 6, $E0		; 4, $8D, 0, $34, $E0
Map_obj8D_4E:	dc.b 2
		dc.b $F4, $89, 0, 0, $E0	; $F4, $89, 0, $3C, $E0
		dc.b 4, $8D, 0, 6, $E0		; 4, $8D, 0, $42, $E0
Map_obj8D_59:	dc.b 1
		dc.b $F8, $85, 0, 0, $F8	; $F8, $85, 0, $4A, $F8
Map_obj8D_5F:	dc.b 1
		dc.b $F8, $85, 0, 4, $F8	; $F8, $85, 0, $4E, $F8
Map_obj8D_65:	dc.b 1
		dc.b $F8, $85, 0, 8, $F8	; $F8, $85, 0, $52, $F8
Map_obj8D_6B:	dc.b 1
		dc.b $F8, $85, 0, $C, $F8	; $F8, $85, 0, $56, $F8
		even