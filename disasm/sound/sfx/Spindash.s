	sHeaderSFX
	sHeaderVoice	Spindash_Patches
	sHeaderTick	$01
	sHeaderCH	$80, tFM5, Spindash_FM5, $FE, $00
	sHeaderFinish

Spindash_FM5:
	sVoice		00
;	sSpinRev
	sVib	$00, $01, $20, $F6
	dc.b nG5, $16, sTie
	sVibOff
	dc.b nG6, $18, sTie

Spindash_Loop1	dc.b $04, sTie
	sVolAddFM		$03
	sLoop		$00, $10, Spindash_Loop1
	sEnd


Spindash_Patches:

	sNewVoice	00					; voice number $00
	sAlgorithm	$04
	sFeedback	$06
	sDetune		$00, $00, $00, $00
	sMultiple	$00, $03, $0C, $09
	sRateScale	$02, $02, $02, $02
	sAttackRate	$1F, $0C, $0F, $15
	sAmpMod		$00, $00, $00, $00
	sDecay1Rate	$00, $00, $00, $00
	sDecay1Level	$00, $00, $00, $00
	sDecay2Rate	$00, $00, $00, $00
	sReleaseRate	$0F, $0F, $0F, $0F
	sTotalLevel	$00, $1D, $00, $00
	sFinishVoice