

*=$0801

        BYTE    $0E,$08,$0A,$00,$9E,$20,$28,$32,$30,$36,$34,$29,$00,$00,$00

; [CODE START] ----------------------------------------------------------------

*=$0810

;http://dustlayer.com/vic-ii/2013/4/23/vic-ii-for-beginners-part-2-to-have-or-to-not-have-character

Character_Set
                    sei                                     ; disable interrupts while we copy
                    ldx                 #$08                ; we loop 8 times (8x255 = 2Kb)
                    lda                 #$33                ; make the CPU see the Character Generator ROM...
                    sta                 $01                 ; ...at $D000 by storing %00110011 into location $01
                    lda                 #$d0                ; load high byte of $D000
                    sta                 $fc                 ; store it in a free location we use as vector
                    LDA                 #$30                ;
                    STA                 $fe                 ;
                    LDA                 #0                  ;
                    STA                 $fd
                    ldy                 #$00                ; init counter with 0
                    sty                 $fb                 ; store it as low byte in the $FB/$FC vector
loop                lda                 ($fb),y             ; read byte from vector stored in $fb/$fc
                    sta                 ($fd),y             ; write to the RAM under ROM at same position
                    iny                                     ; do this 255 times...
                    bne                 loop                ; ..for low byte $00 to $FF
                    inc                 $fc                 ; when we passed $FF increase high byte...
                    inc                 $fe
                    dex                                     ; ... and decrease X by one before restart
                    bne                 loop                ; We repeat this until X becomes Zero
                    lda                 #$37                ; switch in I/O mapped registers again...
                    sta                 $01                 ; ... with %00110111 so CPU can see them
                    cli                                     ; turn off interrupt disable flag
                    LDA                 #28    
                    STA                 $d018               ;
                
; ***********************************************************************************
;
        sei
        lda #0
        sta $d020
        sta $d021
        jsr initStarfield
                    jsr                 CreateStarScreen    ; Initialise Starfield
                    
                    

Main

@w1     bit $d011                       ; Wait for Raster to be off screen 
        bpl @w1 
@w2     bit $d011 
        bmi @w2
        inc rasterCount
        jsr DoStarfield

        jmp Main


; Starfield.asm
; Jay Aldred 2017.


; 2 x 25 char arrays for starfield
; 1)  f9d0 = start  . fa97 = end (from char 58 to 107)
; 2)  fa98 = start  . fb5f = end


starScreenChar  = $0400
StarScreenCols  = $d800

starfieldPtr    = $f0
starfieldPtr2   = $f2
starfieldPtr3   = $f4
starfieldPtr4   = $f6

zeroPointer     = $f8

rasterCount     = $fa


staticStar1     = $3250
staticStar2     = $31e0


DoStarfield

; Erase it
        lda #0
        tay
        sta (starfieldPtr),y
        sta (starfieldPtr2),y
        sta (starfieldPtr3),y
        sta (starfieldPtr4),y
; ***********************************
        lda rasterCount
        and #1
        beq @star1
        inc starfieldPtr
        bne @ok
        inc starfieldPtr+1
@ok
        lda starfieldPtr
        cmp #$98
        bne @star1
        lda starfieldPtr+1
        cmp #$32
        bne @star1
        lda #$d0                        ; Reset 1
        sta starfieldPtr
        lda #$31
        sta starfieldPtr+1
@star1
; ***********************************
        inc starfieldPtr2
        bne @ok2
        inc starfieldPtr2+1
@ok2
        lda starfieldPtr2
        cmp #$60
        bne @star2
        lda starfieldPtr2+1
        cmp #$33
        bne @star2
        lda #$98                        ; Reset 2
        sta starfieldPtr2
        lda #$32
        sta starfieldPtr2+1
@star2
; ***********************************
        lda rasterCount
        and #1
        beq @star3
        inc starfieldPtr3
        bne @ok3
        inc starfieldPtr3+1
@ok3
        lda starfieldPtr3
        cmp #$98
        bne @star3
        lda starfieldPtr3+1
        cmp #$32
        bne @star3
        lda #$d0                        ; Reset 1
        sta starfieldPtr3
        lda #$31
        sta starfieldPtr3+1
@star3
; ***********************************
        lda starfieldPtr4
        clc
        adc #2
        sta starfieldPtr4
        bcc @ok4
        inc starfieldPtr4+1
@ok4
        lda starfieldPtr4+1
        cmp #$33
        bne @star4
        lda starfieldPtr4
        cmp #$60
        bcc @star4
        lda #$98                        ; Reset 2
        sta starfieldPtr4
        lda #$32
        sta starfieldPtr4+1
@star4
;; ***********************************

; Draw it!

        lda #192                        ; 2 static stars that flicker
        ldy rasterCount
        cpy #230
        bcc @show
        lda #0
@show   sta staticStar1         ;$fa50

        tya
        eor #$80
        tay
        lda #192
        cpy #230
        bcc @show2
        lda #0
@show2  sta staticStar2         ;$f9e0
                
        ldy #0
        lda (starfieldPtr),y            ; Moving stars dont overlap other stars
        ora #3
        sta (starfieldPtr),y

        lda (starfieldPtr2),y
        ora #3
        sta (starfieldPtr2),y

        lda (starfieldPtr3),y
        ora #12
        sta (starfieldPtr3),y

        lda (starfieldPtr4),y
        ora #48
        sta (starfieldPtr4),y

        rts



 
initStarfield
        lda #$d0                        ; Reset 1
        sta starfieldPtr
        lda #$31
        sta starfieldPtr+1

        lda #$98                        ; Reset 2
        sta starfieldPtr2
        lda #$32
        sta starfieldPtr2+1

        lda #$40                        ; Reset 1
        sta starfieldPtr3
        lda #$32
        sta starfieldPtr3+1

        lda #$e0                        ; Reset 2
        sta starfieldPtr4
        lda #$32
        sta starfieldPtr4+1

        rts



; [Create Star Screen] --------------------------------------------------------

; Creates the starfield charmap and colour charmap

CreateStarScreen
        ldx #40-1                       ; Create starfield of chars
@lp     txa
        pha
        tay
        lda StarfieldRow,x

        sta @smc1+1
        ldx #58+25
        cmp #58+25
        bcc @low
        ldx #58+50
@low    stx @smc3+1
        txa
        sec
        sbc #25
        sta @smc2+1
        lda #<starScreenChar
        sta zeroPointer
        lda #>starScreenChar
        sta zeroPointer+1 
        ldx #25-1
@smc1   lda #3
        sta (zeropointer),y
        lda zeropointer
        clc
        adc #40
        sta zeropointer
        bcc @clr
        inc zeropointer+1
@clr    inc @smc1+1
        lda @smc1+1
@smc3   cmp #0
        bne @onscreen
@smc2   lda #0
        sta @smc1+1
@onscreen        
        dex
        bpl @smc1

        pla
        tax
        dex
        bpl @lp

        lda #<StarScreenCols           ; Fill colour map with vertical stripes of colour for starfield
        sta zeroPointer
        lda #>StarScreenCols
        sta zeroPointer+1
        ldx #25-1
@lp1    stx @smcx+1
        ldx #0
        ldy #40-1
@lp2
        lda starfieldCols,x
        sta (zeroPointer),y
        inx
@smcz   cpx #20                        ; Loop around 'starfieldCols'
        bne @col
        ldx #0
@col
        dey
        bpl @lp2
        lda zeroPointer
        clc
        adc #40
        sta zeroPointer
        bcc @hiOk
        inc zeroPointer+1
@hiOk
@smcx
        ldx #0
        dex
        bpl @lp1
        rts


starColLimit = @smcz+1

; Dark starfield so it doesnt distract from bullets and text
starfieldCols

        byte 14,10,12,15,14,13,12,11,10,14
        byte 14,10,14,15,14,13,12,11,10,12

;        byte 14,10,14,13,10,12,14,10,12,14
;        byte 11,12,14,10,12,14,15,10,12,14
        
; Star positions, 40 X positions, range 58-107
starfieldRow
        byte 058,092,073,064,091,062,093,081,066,094
        byte 086,059,079,087,080,071,076,067,082,095
        byte 100,078,099,060,075,063,084,065,083,096
        byte 068,088,074,061,090,098,085,101,097,077




            