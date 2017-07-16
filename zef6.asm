; Gray Defender
; 04/11/2015 
; Revised 
; 4/20/2017 
; Rewrote part of the program that displays data on the screen
; tried to make it more efficient
; Changed input routine to read kbd from $c5
; 5/6/2017
; Added shifting water effect with program interrupt and
; redefined character set
; 5/18/17 
; Added printed text output along with scrolling text window
; 6/14/17
; Added background border and colors into the project
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
Const_SCN_View_WD                     = #19            ;width  of view port (viewable on screen)
Const_SCN_View_HT                     = #16            ;height of view port (viewable on screen)
Const_gmap_width                      = 40             ;Width  of game map data
Const_gmap_height                     = 16             ;Height of game map data
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

Const_Black         = 0
Const_White         = 1                   
Const_Green         = 5    
Const_LGray         = 15
Const_Yellow        = 7
;============================================================
; This is done to avoid multiplication through looped addition-->performance
; If each map row was 20 wide then:
; 20, 40, 60, 80 etc... until bottom of mapped data
Const_GMAP_L        byte                <GAMEMAP0,<GAMEMAP1,<GAMEMAP2,<GAMEMAP3,<GAMEMAP4,<GAMEMAP5,<GAMEMAP6,<GAMEMAP7,<GAMEMAP8,<GAMEMAP9,<GAMEMAP10,<GAMEMAP11,<GAMEMAP12,<GAMEMAP13,<GAMEMAP14,<GAMEMAP15
Const_GMAP_H        byte                >GAMEMAP0,>GAMEMAP1,>GAMEMAP2,>GAMEMAP3,>GAMEMAP4,>GAMEMAP5,>GAMEMAP6,>GAMEMAP7,>GAMEMAP8,>GAMEMAP9,>GAMEMAP10,>GAMEMAP11,>GAMEMAP12,>GAMEMAP13,>GAMEMAP14,>GAMEMAP15
Const_Scr_L         byte                $00,$28,$50,$78,$A0,$C8,$F0,$18,$40,$68,$90,$b8,$E0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0
Const_Scr_H         byte                $04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07

Const_Screen_L      byte                $29,$51,$79,$a1,$c9,$f1,$19,$41,$69,$91,$b9,$e1,$09,$31,$59,$81,$a9,$d1,$f9,$21,$49,$71,$99,$c1,$e9
Const_Screen_H      byte                $04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07,$07
;Const_Screen_L      byte                $29,$51,$79,$a1,$c9,$f1,$19,$41,$69,$91,$b9,$e1,$09,$31,$59,$81,$a9,$d1,$f9,$21,$49,$71,$99,$c1,$e9
Const_COL_H          byte               $d8,$d8,$d8,$d8,$d8,$d8,$d9,$d9,$d9,$d9,$d9,$d9,$da,$da,$da,$da,$da,$da,$da,$db,$db,$db,$db,$db,$db

;============================================================
;         *******   G A M E    M A P   *******
;============================================================

GAMEMAP0             text                '@@@@@@@@@@@@@@@@@@@@::::::@@@@@@@@@@@@@@'
GAMEMAP1             text                '@@@@@@@@@@@@@@@@@@@@@:::::@@@@@@::---@@@'
GAMEMAP2             text                '@@@@@::::::::@@@@@@@@@@::@@@@@@::--@@@@@'
GAMEMAP3             text                '@@@@@:::::::::@@@@@@@@@@@@@@@@::---@@@@@'
GAMEMAP4             text                '@@@@@@@:+++::::::@@@@@@@@@@::::---:@@@@@'
GAMEMAP5             text                '@@@@@@@@@@:::::::::@@@@@@@:::::---:@@@@@'
GAMEMAP6             text                '@@@@@@@@@@@@@@@@:::::::::::@@@@@@@@@@@@@'
GAMEMAP7             text                '@@::::::@@@@@@@@::::::::@@@@@@@@@@@@@@@@'
GAMEMAP8             text                '@@:::::::@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
GAMEMAP9             text                '@@@@@@@@@@@@@@@@@@@@@@@@@@@@:::::@@@@@@@'
GAMEMAP10            text                '@@@@@@@@@@@@@@@@@@@@@@@@@@::::oo::@@@@@@'
GAMEMAP11            text                '@@@@@@@@::::::::::::@@@@@@@@:::::@@@@@@@'
GAMEMAP12            text                '@@@@@@@@@@@::::ooo::::::::::oo:@@@@@@@@@'
GAMEMAP13            text                '@@@@@@@@@@@@@@@@@::::ooo:::::::@@@@@@@@@'
GAMEMAP14            text                '@@@@@@@@@@@@@@::::::ooo:::@@@@@@@@@@@@@@'
GAMEMAP15            text                '@@@@@@@@@@@@@@@@@@:::::::::@@@@@@@@@@@@@'                    
                    
;============================================================
;                  Program Macros
;============================================================
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

defm                Print_Text
                    
                    lda                 #</1                
                    sta                 main_string+1       
                    lda                 #>/1                
                    sta                 main_string+2                    
                    jsr                 Display_Text                              
endm   
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
                    jsr                 Character_Set       
                    jsr                 drawmap             
                    
main_loop           jsr                 move_routine
                    lda                 #128                ; Player character reverse @ redefined               
                    sta                 $54a 
                    lda                 #7                  ; Yellow player character           
                    sta                 $d94a                     
                    jsr delay
                    
@nokey              lda                 Const_KBD_BUFFER    ; Input a key from the keyboard
                    cmp                 #Const_NOKEY        ; Nothing being pressed                    
                    beq                 @nokey              
                    cmp                 #Const_Qkey         ; q key pressed ?
                    beq                 quit_prg            
                    cmp                 #Const_LEFT         ; a key pressed? move left
                    beq                 move_left           ;
                    cmp                 #Const_RIGHT        ; s key pressed? move right
                    beq                 _move_right          ;
                    cmp                 #Const_DOWN         ; w key pressed? move up
                    beq                 _move_up             ;
                    cmp                 #Const_UP           ; z key pressed? move up
                    bne                 main_loop           ;
move_down        
                    lda                 $572                ; Position directly below player
                    jsr                 Check_CAN_MOVE      
                    beq                 @yes_can_move       
                    shift_window        #1,#18,#10,#6    
                    Print_Text          str_blocked
                    jmp                 main_loop 
 
@yes_can_move       inc                 vy                  ; Move map down  vy=vy+1
                    Range_Test          vy,#Const_gmap_height,#1  ;Test vy for map_height reset to 0 if match
                    shift_window        #1,#18,#10,#6    
                    Print_Text          str_south

                    jmp                 main_loop           
_move_up            jmp move_up
_move_right         jmp move_right                    
quit_prg            rts
move_left           lda                 $549                    ; Position directly left of player
                    jsr                 Check_CAN_MOVE      
                    beq                 @yes_can_move       
                    shift_window        #1,#18,#10,#6                  
                    Print_Text          str_blocked      
                    jmp                 main_loop                                         
@yes_can_move       dec                 vx                        ;Move map left  vx=vx-1
                    Range_Test          vx,#$ff,#Const_gmap_width;Test vx for -1 reset to width if match
                    shift_window        #1,#18,#10,#6    
                    Print_Text          str_west
                    
                    jmp main_loop
move_right          lda                 $54b                    ; Position directly right of player
                    jsr                 Check_CAN_MOVE      
                    beq                 @yes_can_move       
                    shift_window        #1,#18,#10,#6                       
                    Print_Text          str_blocked 
                    jmp                 main_loop                     
@yes_can_move       inc                 vx                        ;Move map right vx=vx+1
                    Range_Test          vx,#Const_gmap_width,#1
                    shift_window        #1,#18,#10,#6    
                    Print_Text          str_east

                    jmp main_loop
move_up             lda                 $522                   ; Position directly above player
                    jsr                 Check_CAN_MOVE      
                    beq                 @yes_can_move                      
                    shift_window        #1,#18,#10,#6                                           
                    Print_Text          str_blocked
                    jmp main_loop
@yes_can_move       dec                 vy                        ;Move map up    vy=vy-1
                    Range_Test          vy,#$ff,#Const_gmap_height;Test vy for -1 reset to height if match
                    shift_window        #1,#18,#10,#6    
                    Print_Text          str_north
                    
 
                    jmp main_loop


;============================================================
;                     MOVEMENT ROUTINE
; Two loops that draw the map based on the view port vars
;============================================================

move_routine        ldy                 #0                  
loop_vert           store_values_y      Const_Screen_L,output+1,Const_Screen_H,output+2               
                    store_values_y      Const_Screen_L,out_color+1,Const_COL_H,out_color+2               
                    tya
                    sta                 tempy+1                                   
                    Check_Wrap          vy,#Const_gmap_height
                    store_values_y      Const_GMAP_L,input+1,Const_GMAP_H,input+2                  
                    ldx                 #0                  
loop_horiz          txa
                    Check_Wrap          vx,#Const_gmap_width                                         
input               lda                 gamemap0,y                   
output              sta                 $400,x
                    jsr get_mapcolor
out_color           sta $d800,x
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

;==========================================================
;              Check where player can move
;==========================================================

Check_CAN_MOVE     
                    ldy                 #0                                      
@inner_loop         cmp allowable_chars,y
                    beq @allowed
                    cmp                 #0                  
                    beq                 @not_allowed        
                    iny
                    cpy                 #2                  
                    bne @inner_loop
@not_allowed
                    lda #1                    
                    rts
@allowed
                    lda #0
                    rts
                    
allowable_chars     byte $3a,00
;;=================================                   
                  
;==========================================================
;                         Window SUBS 
;==========================================================
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
loop_scr            ldx                 WIN_X
                    store_values        Const_Scr_H,input_scr+2,Const_Scr_L ,input_scr+1                    
                    store_values        Const_Scr_H,lastline+2,Const_Scr_L ,lastline+1                    
                    dey
                    store_values        Const_Scr_H,output_scr+2,Const_Scr_L ,output_scr+1                    
                    iny
input_scr           lda $428,x
output_scr          sta $400,x 
                    lda #$20
lastline            sta $428,x
                    inx
                    cpx                 MAX_WIDTH                  
                    bne                 input_scr
                    iny
max_ht              cpy                 #10                  
                    bne                 loop_scr               
                    rts

Display_Text          
                    lda #Const_Yellow
                    sta $286           
                    lda                 #0                  
                    sta                 string_pos                              
Top_loop            clc                                 ; Set Cursor Position
                    ldx                 max_ht+1        ; 
                    dex                                 ;
                    ldy                 WIN_X           ;                     
                    jsr                 $e50a           ; X=Row, Y=Column
                    ldx                 #0                  
loop123             ldy                 string_pos                              
main_string         lda                 $ffff,y
                    beq                 @exit_loop          
                    jsr                 $ffd2               
                    inx
                    inc                 string_pos
                    cpx                 WD
                    bne                 loop123 
                    jsr                 Scroll_Window_Up    
                    jmp                 Top_loop                    
@exit_loop
                    rts 

get_mapcolor
                    cmp                 #0                  
                    beq                 @water_color        
                    cmp                 #58                
                    beq                 @land_color
                    cmp                 #15                
                    beq                 @object1_color
                    lda                 #8                  
                    rts
@water_color        lda                 #Const_White                                      
                    rts                    
@land_color         lda                 #Const_Green
                    rts
@object1_color      lda                 #3                                      
                    rts

;==========================================================
;                         DRAWMAP
;==========================================================

drawmap
                    lda                 #$00
                    sta                 scr_data+1          
                    sta                 col_data+1
                    lda                 #04
                    sta                 scr_data+2          
                    lda                 #$d8
                    sta                 col_data+2          
                    
                    lda                 #<MAP_DATA
                    sta                 gamemap+1
                    lda                 #>MAP_DATA
                    sta                 gamemap+2  

                    lda                 #<MAP_COLOR
                    sta                 col_map+1
                    lda                 #>MAP_COLOR
                    sta                 col_map+2  

                             
                    ldx                 #4
main_lp             ldy                 #$00
gamemap             lda                 $ffff,y             ; Load from the map
scr_data            sta                 $0400,y             ; Store on the screen
col_map             lda                 $ffff,y                                 
col_data            sta                 $d800,y             ; Store on the screen
                    dey
                    bne                 gamemap
                    inc                 scr_data+2          
                    inc                 col_data+2          
                    inc                 col_map+2
                    inc                 gamemap+2
                    dex
                    bne                 main_lp
                    rts
                    
MAP_DATA
                    BYTE                $56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$56
                    BYTE                $56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56,$56
MAP_COLOR
                    
        BYTE    $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
        BYTE    $0F,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$03,$0F,$06,$06,$06,$06,$01,$01,$01,$01,$01,$01,$01,$01,$01,$06,$06,$06,$06,$06,$0F
        BYTE    $0F,$0C,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$03,$0F,$06,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$06,$06,$06,$06,$0F
        BYTE    $0F,$0C,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$03,$0F,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F
        BYTE    $0F,$0C,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F,$06,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$06,$06,$06,$06,$0F
        BYTE    $0F,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F
        BYTE    $0F,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F,$06,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$06,$06,$06,$06,$0F
        BYTE    $0F,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F
        BYTE    $0F,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F,$03,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F
        BYTE    $0F,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F,$03,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F
        BYTE    $0F,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F,$03,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F
        BYTE    $0F,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F,$03,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F
        BYTE    $0F,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$03,$03,$0F,$03,$03,$03,$03,$03,$03,$03,$06,$06,$06,$06,$06,$06,$03,$03,$03,$03,$03,$0F
        BYTE    $0F,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$0F,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$0F
        BYTE    $0F,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$03,$03,$03,$0F,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$06,$06,$0C,$0C,$0C,$0C,$0C,$06,$0F
        BYTE    $0F,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F,$06,$06,$06,$06,$06,$06,$06,$06,$03,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F
        BYTE    $0F,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$0F,$03,$03,$03,$03,$03,$03,$03,$03,$03,$06,$06,$06,$06,$06,$06,$06,$06,$06,$0F
        BYTE    $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
        BYTE    $0F,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$0F
        BYTE    $0F,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$0F
        BYTE    $0F,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$0F
        BYTE    $0F,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$0F
        BYTE    $0F,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$0F
        BYTE    $0F,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$0F
        BYTE    $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F



                    
str_north           null                ">NORTH"
str_south           null                ">SOUTH"
str_east            null                ">EAST"
str_west            null                ">WEST"                    
str_blocked         null                ">BLOCKED"
                    
string_pos          byte                00
WIN_X               byte                0
WIN_Y               byte                0
WD                  byte                40
HT                  byte                25
MAX_WIDTH           byte                00   ; Starting position plus width of window        
                    

;==========================================================
;                         Redefine Character Set 
;==========================================================
                    
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
                 ;
                    STA                 $d018               ;

; ***********************************************************************************
;

                    ldx                 #0                  
@loop               lda                 water,x             
                    sta                 $3000,x             ; Redefine @ sign
                    lda                 player_ch,x                                    
                    sta                 $3400,x             ; Redefine Reverse @ sign
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
                    rts                                     ; return from subroutine
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


water               BYTE $88,$77,$00,$00,$22,$dd,$00,$00                    
player_ch           BYTE    $18,$BC,$BC,$BC,$98,$FE,$98,$A4
                    