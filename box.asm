
*=$1000

                    
                    lda                 #$93                ; shift clear dec 147
                    jsr                 $FFD2               ; clear screen
start_over                    jsr                 Init_Random           

                    GET_RAND            #37,Const_BOX_X,#41,width       
                    GET_RAND            #21,Const_BOX_Y,#26,height
                    lda                 #15                 
                    sta                 RAND_MAX            
                    jsr                 RAND                
                    sta Const_Box_Color
                  ; jsr                 draw_box            
                  ; jmp                 start_over          
                    
                   ; rts
                    
@loop2             jsr                 Box_Effect
                   jmp @loop2
                    rts
                    
draw_box
                    ldy                 Const_BOX_Y                  
                    lda                 Const_Screen_L,y    
                    sta                 left_top_edge+1
                    sta                 left_top_edgec+1
                    lda                 Const_Screen_H,y    
                    sta                 left_top_edge+2  
                    lda                 Const_Screen_C,y    
                    sta                 left_top_edgec+2
                    clc
                    dey
                    tya
                    adc                 height              
                    tay                   
                    lda                 Const_Screen_L,y    
                    sta                 left_bot_edge+1         
                    sta                 left_bot_edgec+1         
                    lda                 Const_Screen_H,y    
                    sta                 left_bot_edge+2     
                    lda                 Const_Screen_C,y                        
                    sta                 left_bot_edgec+2         
                    ldx                 Const_BOX_X                 
                    ldy #0
                    lda                 #$2                 
left_top_edge       sta                 $400,x                    
left_bot_edge       sta                 $450,x
                    lda                 Const_Box_Color    
left_top_edgec      sta                 $d800,x                                 
left_bot_edgec      sta                 $d800,x

                    inx
                    iny
box_width           cpy                 width
                    bne                 left_top_edge-2                         
                    ldx #2                                ; Accounts for top and bottom of box => just draw middle 
                    ldy                 Const_BOX_Y        
                    iny
loop2               lda                 Const_Screen_L,y    
                    sta                 box_top_left+1         
                    sta                 box_top_right+1         
                    sta                 box_top_leftc+1         
                    sta                 box_top_rightc+1         
                    lda                 Const_Screen_H,y    
                    sta                 box_top_left+2         
                    sta                 box_top_right+2  
                    lda                 Const_Screen_C,y       
                    sta                 box_top_leftc+2         
                    sta                 box_top_rightc+2                             

                    txa
                    pha
                    ldx                 Const_Box_X 
                    lda                 #$1                 
box_top_left        sta                 $400,x
                    lda                 Const_Box_Color   
box_top_leftc       sta                 $d800,x

                    dex                 
                    txa
                    clc
                    adc                 width                                   
                    tax
                    lda #1
box_top_right       sta                 $400,x                    
                    lda                 Const_Box_Color   
box_top_rightc      sta                 $d800,x  
                    pla
                    tax
                    inx
                    iny
                    cpx                 height                
                    bne                 loop2              
                    rts

   
defm                GET_RAND

@do_over            lda                 /1                 ; Get RAND Start Pos
                    sta                 RAND_MAX            
                    jsr                 RAND                ; Get random between 0 and 37
                    sta                 /2                   
                    lda                 /3                 ; Get rand WIDTH
                    sta                 RAND_MAX            
@larger             jsr                 RAND                
                    cmp                 #3                  
                    bcc @larger
                    sta                 /4 
                  
                    clc
                    adc                 /2        
                    cmp                 /3
                    bcs                 @do_over  
endm 
                          
  
Const_Screen_L      byte                $00,$28,$50,$78,$A0,$C8,$F0,$18,$40,$68,$90,$b8,$E0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0
Const_Screen_H      byte                $04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07
Const_Screen_C      byte                $d8,$d8,$d8,$d8,$d8,$d8,$d8,$d9,$d9,$d9,$d9,$d9,$d9,$da,$da,$da,$da,$da,$da,$da,$db,$db,$db,$db,$db
RAND_MAX            byte                00
height              byte 25  
width               byte 40
Const_BOX_X         byte                0
Const_Box_Y         byte                0
Const_Box_Color     byte 2   
                 
                    
;============================================================
Init_Random
                    LDA                 #$FF                ; maximum frequency value
                    STA                 $D40E               ; voice 3 frequency low byte
                    STA                 $D40F               ; voice 3 frequency high byte
                    LDA                 #$80                ; noise SIRENform, gate bit off
                    STA                 $D412               ; voice 3 control register
                    rts

RAND              
                    LDA                 $D41B               ; get random value from 0-255
                    CMP                 RAND_MAX               ; narrow random result down
                                                            ; to between zero - g$len
                    BCC                 @dont_crash         ; ~ to 0-3
                    jmp                 RAND                
@dont_crash         rts                    

delay               ldy #5
@loop2              ldx                 #0
@loop               dex
                    bne                 @loop               
                    dey
                    bne @loop2
                    rts
                    
Box_Effect
                    lda                 #0                  
                    sta                 Const_Box_X         
                    sta                 Const_Box_Y         
                    lda                 #40                 
                    sta                 width               
                    lda                 #25                 
                    sta                 height              

                    ldx                 #0                  
@loop               txa
                    pha
                    jsr                 draw_box            
                    jsr delay
                    pla
                    tax
                    inc                 Const_Box_X         
                    inc                 Const_Box_Y
                    dec                 width               
                    dec                 width               
                    dec                 height              
                    dec                 height              
                    inc Const_Box_Color
                    inx
                    cpx #12
                    bne                 @loop               
                    rts
Box_Effect2
                    lda                 #0                  
                    sta                 Const_Box_X         
                    sta                 Const_Box_Y         
                    lda                 #40                 
                    sta                 width               
                    lda                 #25                 
                    sta                 height              
                    
                    ldx                 #0                  
@loop               txa
                    pha
                    lda                 #2                  
                    sta                 Const_Box_Color     
                     
                    jsr                 draw_box            
                    jsr delay
                    lda                 #3                  
                    sta                 Const_Box_Color     
                    jsr                 draw_box            
                    
                    pla
                    tax
                    inc                 Const_Box_X         
                    inc                 Const_Box_Y
                    dec                 width               
                    dec                 width               
                    dec                 height              
                    dec                 height              
                    
                    inx
                    cpx #12
                    bne                 @loop               
  
                    ldx #12
                     jmp @intoit               
@loop2               txa
                    pha
                    lda                 #2                  
                    sta                 Const_Box_Color     
                     
                    jsr                 draw_box            
                    jsr delay
                    lda                 #3                  
                    sta                 Const_Box_Color     
                    jsr                 draw_box            
                    
                    pla
                    tax
@intoit                    dec                 Const_Box_X         
                    dec                 Const_Box_Y
                    inc                 width               
                    inc                 width               
                    inc                 height              
                    inc                 height              
                    
                    dex
                    cpx #0
                    bne                 @loop2                    
                    rts

                                        