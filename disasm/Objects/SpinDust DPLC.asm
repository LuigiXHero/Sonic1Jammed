; ---------------------------------------------------------------------------
; JAM: Add spindash dust DPLCs
; ---------------------------------------------------------------------------
		dc.w DPLC_obj8D_1A-DPLC_obj8D, DPLC_obj8D_1B-DPLC_obj8D
		dc.w DPLC_obj8D_1E-DPLC_obj8D, DPLC_obj8D_21-DPLC_obj8D
		dc.w DPLC_obj8D_24-DPLC_obj8D, DPLC_obj8D_29-DPLC_obj8D
		dc.w DPLC_obj8D_2E-DPLC_obj8D, DPLC_obj8D_33-DPLC_obj8D
		dc.w DPLC_obj8D_38-DPLC_obj8D, DPLC_obj8D_38-DPLC_obj8D
		dc.w DPLC_obj8D_38-DPLC_obj8D, DPLC_obj8D_38-DPLC_obj8D
		dc.w DPLC_obj8D_3C-DPLC_obj8D
DPLC_obj8D_1A:	dc.b 0
DPLC_obj8D_1B:	dc.b 1, $70, 0
DPLC_obj8D_1E:	dc.b 1, $70, 8
DPLC_obj8D_21:	dc.b 1, $70, $10
DPLC_obj8D_24:	dc.b 2, $10, $18, $70, $1A
DPLC_obj8D_29:	dc.b 2, $30, $22, $70, $26
DPLC_obj8D_2E:	dc.b 2, $50, $2E, $70, $34
DPLC_obj8D_33:	dc.b 2, $50, $3C, $70, $42
DPLC_obj8D_38:	dc.b 0	
DPLC_obj8D_3C:	dc.b 1, $F0, $4A
		even