; -------------------------------------------------------------------------------
; Options/Level Select macros
; -------------------------------------------------------------------------------

; -------------------------------------------------------------------------------
; Options text
; -------------------------------------------------------------------------------

OPT_TEXT macro maxLen, text
	local conv, c, chr, chr2, str, len

	; Cut string at max length if needed
len	= strlen(\text)
str	EQUS	\text
	if len>maxLen
len		= maxLen
str		SUBSTR 1,maxLen,\text
	endif

	; Convert string to fit with the font
conv	EQUS	'    *        +   !"#$%&'
conv	EQUS	"\conv\'()   ,-  123456789:;<=>?@ABCDEFGH/0"
c	= 0
	while c<len
chr		SUBSTR c+1,c+1,"\str"
		if '\chr'=' '
			; Space
			dc.b	$FF
		elseif '\chr'>' '
			; Non-space
chr2			SUBSTR '\chr'-$1F,'\chr'-$1F,"\conv"
			dc.b	'\chr2'-$20
		endif
c		= c+1
	endw

	; Pad out to max length
	dcb.b	maxLen-len,$FF
	endm

; -------------------------------------------------------------------------------
; Option list start
; -------------------------------------------------------------------------------

opt_list_no = 0
OPT_START macro
opt_count = 0
	even
	dc.b	(opt_count_\#opt_list_no\)-1, 0
	endm

; -------------------------------------------------------------------------------
; Bit size option
; -------------------------------------------------------------------------------

OPT_BIT macro var, bitNo, text, opt1, opt2
opt_count = opt_count+1
	dc.b	0, \bitNo
	dc.w	\var
	OPT_TEXT OPT_LINE_LEN-OPT_OPT_LEN, \text
	OPT_TEXT OPT_OPT_LEN, \opt1
	OPT_TEXT OPT_OPT_LEN, \opt2
	even
	endm

; -------------------------------------------------------------------------------
; Byte size option
; -------------------------------------------------------------------------------

OPT_BYTE macro var, min, max, text
opt_count = opt_count+1
	dc.b	1, ((\max)-(\min)+1)*OPT_OPT_LEN
	dc.w	\var
	dc.b	\min, \max
	OPT_TEXT OPT_LINE_LEN-OPT_OPT_LEN, \text
	rept	(\max)-(\min)+1
		OPT_TEXT OPT_OPT_LEN, \5
		shift
	endr
	even
	endm

; -------------------------------------------------------------------------------
; Generic number option (byte)
; -------------------------------------------------------------------------------

OPT_NUM_BYTE macro var, min, max, exit, text
opt_count = opt_count+1
	dc.b	2, \exit
	dc.w	\var
	dc.b	\min, \max
	OPT_TEXT OPT_LINE_LEN-OPT_OPT_LEN, \text
	even
	endm

; -------------------------------------------------------------------------------
; Generic number option (word)
; -------------------------------------------------------------------------------

OPT_NUM_WORD macro var, min, max, exit, text
opt_count = opt_count+1
	dc.b	3, \exit
	dc.w	\var
	dc.w	\min, \max
	OPT_TEXT OPT_LINE_LEN-OPT_OPT_LEN, \text
	even
	endm

; -------------------------------------------------------------------------------
; Level option
; -------------------------------------------------------------------------------

OPT_LEVEL macro zone, act, text
opt_count = opt_count+1
	dc.b	4, 0
	dc.b	\zone, \act
	OPT_TEXT OPT_LINE_LEN, \text
	even
	endm

; -------------------------------------------------------------------------------
; Exit option
; -------------------------------------------------------------------------------

OPT_EXIT macro text
opt_count = opt_count+1
	dc.b	5, 0
	OPT_TEXT OPT_LINE_LEN, \text
	even
	endm

; -------------------------------------------------------------------------------
; Note option
; -------------------------------------------------------------------------------

OPT_NOTE macro text
	dc.b	5, 0
	OPT_TEXT OPT_LINE_LEN, \text
	even
	endm

; -------------------------------------------------------------------------------
; Option list end
; -------------------------------------------------------------------------------

OPT_END macro
	dc.w	$FFFF
opt_count_\#opt_list_no	EQU opt_count
opt_list_no = opt_list_no+1
	endm

; -------------------------------------------------------------------------------