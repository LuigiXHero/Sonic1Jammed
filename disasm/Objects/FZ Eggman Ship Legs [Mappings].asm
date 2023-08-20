; ---------------------------------------------------------------------------
; Sprite mappings - legs on Eggman's escape ship (FZ)
; ---------------------------------------------------------------------------
Map_FZLegs:	index *
		ptr frame_fzlegs_extended
		ptr frame_fzlegs_halfway
		ptr frame_fzlegs_retracted
		
frame_fzlegs_extended:
		spritemap
		piece	-$C, $14, 4x3, 0, xflip, pal2
		piece	-$14, $24, 1x1, $C, xflip, pal2
		endsprite
		
frame_fzlegs_halfway:
		spritemap
		piece	$C, $C, 2x2, $D, xflip, pal2
		piece	$C, $1C, 1x1, $11, xflip, pal2
		piece	-$14, $14, 4x2, $12, xflip, pal2
		endsprite
		
frame_fzlegs_retracted:
		spritemap
		piece	$C, $C, 1x2, $1A, xflip, pal2
		piece	-$14, $14, 4x1, $1C, xflip, pal2
		endsprite
		even
