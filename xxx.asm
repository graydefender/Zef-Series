*=$1000


;                    lda                 #$31               
;                    jsr                 $ffd2               
;                    ldx                 #1                  
;                    jsr                 $e9ff               
;                    clc
;                    ldx                 #10                 
;                    ldy                 #10                 
;                    jsr $fff0
;                    lda                 #$32                
;                    jsr                 $ffd2               

;                    jsr                 $ffed              
;                    stx                 $400                
;                    sty                 $401                

                   ; clc
                    ldy                 POS_Y
                    iny
                    clc
                    lda                 POS_X               
                    adc                 WD                  
                    sta                 @new_compare+1
                    sta                 @new_compare2+1  
                    clc
                    lda POS_Y
                    adc HT
                    sta @new_compare3+1    
@loop               ldx POS_X
                    lda                 Const_Screen_H,y    
                    sta                 @screen1+2           
                    lda                 Const_Screen_L,y    
                    sta                 @screen1+1          
                    dey
                    lda                 Const_Screen_H,y    
                    sta                 @screen2+2           
                    lda                 Const_Screen_L,y    
                    sta                 @screen2+1          
                    iny
@screen1            lda $428,x
@screen2            sta $400,x
                    inx
@new_compare        cpx                 #10                  
                    bne @screen1
                    iny
@new_compare3       cpy                 #10                  
                    bne                 @loop               
                    
                    dey
                    lda                 Const_Screen_H,y    
                    sta                 @loop2+2           
                    lda                 Const_Screen_L,y    
                    sta                 @loop2+1          
                    ldx                 POS_X               
                    lda                 #$20                
@loop2              sta                 $400,x              
                    inx
@new_compare2       cpx #10
                    bne @loop2                    
                    rts
Const_Screen_L      byte                $00,$28,$50,$78,$A0,$C8,$F0,$18,$40,$68,$90,$b8,$E0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0
Const_Screen_H      byte                $04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07
POS_X               byte                15
POS_Y               byte                5
WD                  byte                10
HT                  byte                10
                    
                    
    

                    