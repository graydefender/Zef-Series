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
Const_GMAP_L        byte                <GAMEMAP0,<GAMEMAP1,<GAMEMAP2,<GAMEMAP3,<GAMEMAP4,<GAMEMAP5,<GAMEMAP6,<GAMEMAP7,<GAMEMAP8,<GAMEMAP9
Const_GMAP_H        byte                >GAMEMAP0,>GAMEMAP1,>GAMEMAP2,>GAMEMAP3,>GAMEMAP4,>GAMEMAP5,>GAMEMAP6,>GAMEMAP7,>GAMEMAP8,>GAMEMAP9
Const_Screen_L      byte                $00,$28,$50,$78,$A0,$C8,$F0,$18,$40,$68,$90,$b8,$E0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0
Const_Screen_H      byte                $04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07
;============================================================
;         *******   G A M E    M A P   *******
;============================================================

GAMEMAP0             text                '@@@@@gray defender@@xxxxxxxxxxxxx xxxxxo'
GAMEMAP1             text                '@@@@@@@owooot @@@@@@xxxxxxxxxxxxx xxxxxo'
GAMEMAP2             text                '@@@@@o@@@@@@oo@@@@@@xxxxvvvvxxx      xxo'
GAMEMAP3             text                '@@@@o@@@@@@@@@o@@@@@xxxxxxvvvxxxxxxx xxo'
GAMEMAP4             text                '@@@o@o@@@@@@@@@oo@@@xxxxxxxxxxx      xxo'
GAMEMAP5             text                '@@@@o@@@HI@@@@@o@@@@aaabbbcccdd eeefffgo'
GAMEMAP6             text                '@@@@@o@@@@@@@@o@@@@@01234g12345    1234o'
GAMEMAP7             text                '@@@@@@o@@@@@@o@@@@@@jjjjjjkkkkkll mmmmmo'
GAMEMAP8             text                '@@@@@@@o@oooo@@@@@@@nnnnnnooooopp qqqqqo'
GAMEMAP9             text                '@@@@@@@@@@@@@@@@@@@@rrrrrrssssstt uuuvvo'
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
                    jsr                 Character_Set       
                    
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
input               lda                 gamemap0,y                   
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


;water                BYTE    $C6,$31,$8C,$43,$30,$8C,$63,$18
water                BYTE    $30,$0C,$03,$C0,$30,$0C,$03,$C0
;water               BYTE                $7E,$81,$7E,$81,$7E,$81,$7E,$81
;water               BYTE    $DC,$23,$DC,$22,$9D,$62,$9C,$23                    
;water               BYTE                $F0,$0F,$F0,$0F,$F0,$0F,$F0,$0F
;water               BYTE    $CC,$33,$CC,$33,$CC,$33,$CC,$33        








