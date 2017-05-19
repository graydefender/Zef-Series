*=$0801
                    byte                $0c, $08, $0a, $00, $9e, $20
                    byte                $34, $30, $39, $36, $00, $00
                    byte                $00

;http://dustlayer.com/vic-ii/2013/4/23/vic-ii-for-beginners-part-2-to-have-or-to-not-have-character

*=$1000
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
                 ;
                    STA                 $d018               ;

; ***********************************************************************************
;

                    ldx                 #0                  
@loop               lda                 water,x             
                    sta                 $3000,x             
                    inx
                    cpx                 #8                  
                    bne @loop
                    
                    lda                 #0
                    sta                 $400

;
setup               = *
                    sei                                     ; disable interrupts
                    lda                 #<intcode           ; get low byte of target routine
                    sta                 788                 ; put into interrupt vector
                    lda                 #>intcode           ; do the same with the high byte
                    sta                 789
                    cli                                     ; re-enable interrupts
                    rts                                     ; return to caller
intcode             = *
                    inc                 value
                    lda                 value
                    cmp                 #$a
                    bne                 end
                    lda                 #0
                    sta                 value
                    lda                 $3000
                    sta                 temp
                    lda                 $3001
                    sta                 $3000
                    lda                 $3002
                    sta                 $3001
                    lda                 $3003
                    sta                 $3002
                    lda                 $3004
                    sta                 $3003
                    lda                 $3005
                    sta                 $3004
                    lda                 $3006
                    sta                 $3005
                    lda                 $3007
                    sta                 $3006
                    lda                 temp
                    sta                 $3007
end                 jmp                 $ea31
temp                byte                00
value               byte                00


;water                BYTE    $C6,$31,$8C,$43,$30,$8C,$63,$18
water                BYTE    $30,$0C,$03,$C0,$30,$0C,$03,$C0
;water               BYTE                $7E,$81,$7E,$81,$7E,$81,$7E,$81
;water               BYTE    $DC,$23,$DC,$22,$9D,$62,$9C,$23                    
;water               BYTE                $F0,$0F,$F0,$0F,$F0,$0F,$F0,$0F
;water               BYTE    $CC,$33,$CC,$33,$CC,$33,$CC,$33        



            