*=$1000

defm                store_values                    ; This macro loads first
                    lda                 /1,y        ; param then stores in
                    sta                 /2          ; second param                    
                    lda                 /3,y        ; the loads third and
                    sta                 /4          ; stores in forth
                    endm

defm                shift_window
                    lda                 /1                  
                    sta                 WIN_X               
                    lda                 /2                  
                    sta                 WIN_Y               
                    lda                 /3                  
                    sta                 WD                  
                    lda                 /4                  
                    sta                 HT   
                    jsr Scroll_Window_Up                                     
endm
                  
                    shift_window        #5,#0,#10,#5   
         
                    
                    rts
                    
Scroll_Window_Up
                    ldy                 WIN_Y
                    iny
                    clc
                    lda                 WIN_X               
                    adc                 WD                  
                    sta                 MAX_WIDTH
                    clc
                    lda                 WIN_Y                                   
                    adc                 HT                                      
                    sta                 max_ht+1    
loop                ldx                 WIN_X
                    store_values        Const_Screen_H,input+2,Const_Screen_L,input+1                    
                    store_values        Const_Screen_H,lastline+2,Const_Screen_L,lastline+1                    
                    dey
                    store_values        Const_Screen_H,output+2,Const_Screen_L,output+1                    
                    iny
input               lda $428,x
output              sta $400,x 
                    lda #$20
lastline            sta $428,x
                    inx
                    cpx                 MAX_WIDTH                  
                    bne                 input                                  
                    iny
max_ht              cpy                 #10                  
                    bne                 loop               
                    rts


string              null                ">NORTH"
string_pos          byte 00
;*********************************                    
Const_Screen_L      byte                $00,$28,$50,$78,$A0,$C8,$F0,$18,$40,$68,$90,$b8,$E0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0
Const_Screen_H      byte                $04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07
WIN_X               byte                0
WIN_Y               byte                0
WD                  byte                40
HT                  byte                25
MAX_WIDTH           byte                00   ; Starting position plus width of window                    
                    
    

                    