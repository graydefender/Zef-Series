; Gray Defender
; 04/11/2015
; Revised 
; 4/20/2017 
; Rewrote part of the program that displays data on the screen
; tried to make it more efficient
; Changed input routine to read kbd from $c5
;============================================================
;  Quick code to create auto execute program from basic
;============================================================

*=$0801
                    byte                $0c, $08, $0a, $00, $9e, $20
                    byte                $34, $30, $39, $36, $00, $00
                    byte                $00
;============================================================
;          Adjustable Variables and constants
;============================================================
Const_SCREEN_WD                       = #40            ;text width of screen (c64)
Const_SCN_View_WD                     = #15            ;width  of view port (viewable on screen)
Const_SCN_View_HT                     = #10            ;height of view port (viewable on screen)
Const_gmap_width                      = 40             ;Width  of game map data
Const_gmap_height                     = 10             ;Height of game map data
vx                  byte                5             ;Starting x position into the game map data
vy                  byte                5              ;Starting y position into the game map data
;============================================================
;                  keyboard constants
;============================================================

Const_KBD_BUFFER    = $c5                                   ; 
Const_UP            = $09                                   ;
Const_DOWN          = $0c                                   ;values
Const_LEFT          = $0a                                   ;for up down left right
Const_RIGHT         = $0d                                   ;
Const_QKEY          = $3e
Const_NOKEY         = $40
                   
;============================================================
; This is done to avoid multiplication through looped addition-->performance
; If each map row was 20 wide then:
; 20, 40, 60, 80 etc... until bottom of mapped data
Const_GMAP_L        byte                $00,$28,$50,$78,$a0,$c8,$f0,$18,$40,$68 
Const_GMAP_H        byte                $20,$20,$20,$20,$20,$20,$20,$21,$21,$21
Const_Screen_L      byte                $00,$28,$50,$78,$A0,$C8,$F0,$18,$40,$68,$90,$b8,$E0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0
Const_Screen_H      byte                $04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07
;============================================================
;         *******   G A M E    M A P   *******
;============================================================

*=$2000
GAMEMAP             text                '-----gray defender--xxxxxxxxxxxxx xxxxxo'
                    text                '-------owooot ------xxxxxxxxxxxxx xxxxxo'
                    text                '-----o------oo------xxxxvvvvxxx      xxo'
                    text                '----o---------o-----xxxxxxvvvxxxxxxx xxo'
                    text                '---o-o---------oo---xxxxxxxxxxx      xxo'
                    text                '----o---HI-----o----aaabbbcccdd eeefffgo'
                    text                '-----o--------o-----01234g12345    1234o'
                    text                '------o------o------jjjjjjkkkkkll mmmmmo'
                    text                '-------o-oooo-------nnnnnnooooopp qqqqqo'
                    text                '--------------------rrrrrrssssstt uuuvvo'
;============================================================
;                  Program Macros
;============================================================

defm                store_values_y                    ; This macro loads first
                    lda                 /1,y          ; param then stores in
                    sta                 /2            ; second param                    
                    lda                 /3,y          ; the loads third and
                    sta                 /4            ; stores in forth
                    endm

;============================================================
; Check NX or NY (Internal view port x,y) against viewport width,height
; Reset the value back down (wrap around) by subtracting difference
; IE if nx>20 then nx=nx-20
; IE if ny>10 then ny=ny-10
; This is the code that causes the map to wrap around when
; moving all the way right or all the way down past the borders
;============================================================
defm                Check_NXNY
                    clc
                    adc                 /1                  
                    sta                 /2                  
                    clc
                    cmp                 /3                  
                    beq                 @reset              
                    bcc                 @bot                
@reset              sbc                 /3
                    sta                 /2                  
@bot                
                    endm

;============================================================
; load param 1 test against param 2 if match reset to param 3 -1
; storing result in param 1
; This code keeps the map within the proper boundaries as
; defined by the map height and map width
;============================================================
defm                Range_Test
                    lda                 /1                  
                    clc
                    cmp                 /2                  
                    bne                 @bottom             
                    lda                 /3                  
                    sbc                 #1                  
                    sta                 /1                  
@bottom
                    endm

defm                Check_Wrap
                    clc
                    adc                 /1
                    cmp                 /2
                    bcc                 @skip               
                    sbc                 /2                                      
@skip
                    tay
                    endm
                    
;============================================================
;                PROGRAM START (Grab Keyboard Input)
;============================================================
*=$1000
                    lda                 #$93                ; shift clear dec 147
                    jsr                 $FFD2               ; clear screen
main_loop           jsr                 move_routine
                    jsr delay
                    
@nokey              lda                 Const_KBD_BUFFER    ; Input a key from the keyboard
                    cmp                 #Const_NOKEY        ; Nothing being pressed                    
                    beq                 @nokey              
                    cmp                 #Const_Qkey         ; q key pressed ?
                    beq                 quit_prg            
                    cmp                 #Const_LEFT         ; a key pressed? move left
                    beq                 move_left           ;
                    cmp                 #Const_RIGHT        ; s key pressed? move right
                    beq                 move_right          ;
                    cmp                 #Const_DOWN         ; w key pressed? move up
                    beq                 move_up             ;
                    cmp                 #Const_UP           ; z key pressed? move up
                    bne                 main_loop           ;
move_down           inc                 vy                  ; Move map down  vy=vy+1
                    Range_Test          vy,#Const_gmap_height,#1  ;Test vy for map_height reset to 0 if match
                    jmp main_loop
move_left           dec                 vx                        ;Move map left  vx=vx-1
                    Range_Test          vx,#$ff,#Const_gmap_width ;Test vx for -1 reset to width if match
                    jmp main_loop
move_right          inc                 vx                        ;Move map right vx=vx+1
                    Range_Test          vx,#Const_gmap_width,#1 
                    jmp main_loop
move_up             dec                 vy                        ;Move map up    vy=vy-1
                    Range_Test          vy,#$ff,#Const_gmap_height;Test vy for -1 reset to height if match
                    jmp main_loop
quit_prg            rts

;============================================================
;                     MOVEMENT ROUTINE
; Two loops that draw the map based on the view port vars
;============================================================

move_routine        ldy                 #0                  
loop_vert           store_values_y      Const_Screen_L,output+1,Const_Screen_H,output+2               
                    tya
                    sta                 tempy+1                                   
                    Check_Wrap          vy,#Const_gmap_height
                    store_values_y      Const_GMAP_L,input+1,Const_GMAP_H,input+2                  
                    ldx                 #0                  
loop_horiz          txa
                    Check_Wrap          vx,#Const_gmap_width                                         
input               lda                 gamemap,y                   
output              sta                 $400,x
                    inx
loop_cpx            cpx                 Const_SCN_View_WD     
                    bne                 loop_horiz                              
tempy               ldy                 #$00
                    iny                      
                    cpy                 #Const_SCN_View_HT    
                    bne                 loop_vert          
                    rts
;==========================================================
;                         END PROGRAM
;==========================================================
delay               ldy #50
@loop2              ldx                 #0
@loop               dex
                    bne                 @loop               
                    dey
                    bne @loop2
                    rts
                    







