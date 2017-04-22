; Glenn Cline
; 04/11/2015
;
;============================================================
;  Quick code to create auto execute program from basic
;============================================================

*=$0801
          byte           $0c, $08, $0a, $00, $9e, $20
          byte           $34, $30, $39, $36, $00, $00
          byte           $00
;============================================================
scn_width$     = #40                              ;text width of screen (c64)
view_wd$       = #8                               ;width  of view port (viewable on screen)
view_ht$       = #8                               ;height of view port (viewable on screen)


;============================================================
;             Main Program Variables
;============================================================
scn_offset     word                $0004          ;c64 screen offset
map_offset     word                $0000          ;Offset into the Map data
cx             byte                0             ;Starting x position into the map        BYTE           60,126,126,126,126,126,60,0
               BYTE           216,132,196,100,20,24,0,0

cy             byte                0              ;Starting y position into the map
nx             byte                0              ;Horizontal variable that wraps around
ny             byte                0              ;Vertical variable that wraps around
tempy          byte                0              ;Temp storage for Y Register
map_width      byte                20             ;Width of map data
map_height     byte                10             ;Height of map data

astring        text                '-----gray defender--'
               text                '-------owooot ------'
               text                '-----o------oo------'
               text                '----o---------o-----'
               text                '---o-o---------oo---'
               text                '----o---HI-----o----'
               text                '-----o--------o-----'
               text                '------o------o------'
               text                '-------o-oooo-------'
               text                '--------------------'

;============================================================
; This is done to avoid multiplication through looped addition-->performance
; So, 20, 40, 60, 80 etc... until bottom of mapped data
map_off        byte                $00,$14,$28,$3c,$50,$64,$78,$8c,$a0,$b4 ;vertical scn_offset into map data
;============================================================

defm           mydec                              ; Quick macros to clean up input code from keyboard
               dec                 /1             ;
               jmp                 main_loop      ;
               endm
defm           myinc            
               inc                 /1
               jmp                 main_loop      
               endm

defm           add_scn_offset                     ; Add a number to a memory location
               clc                                ; Increment hi byte if carry
               lda                 /1         
               adc                 /2     
               sta                 /1         
               bcc                 @ok             
               inc                 /1+1 
@ok          
               endm

defm           set_indirect                      ; store values in $FB, $FC
               lda                 /1            ; for address indirection
               sta                 $fb           ; usage
               lda                 /2
               sta                 $fc            
               endm

;============================================================
; Check NX or NY (Internal view port x,y) against viewport width,height
; Reset the value back down (wrap around) by subtracting difference
; IE if nx>20 then nx=nx-20
; IE if ny>10 then ny=ny-10
; This is the code that causes the map to wrap around when
; moving all the way right or all the way down past the borders
;============================================================
defm           Check_NXNY                     
               clc
               adc                 /1             
               sta                 /2
               clc
               cmp                 /3         
               beq                 @reset
               bcc                 @bot
@reset         sbc                 /3
               sta                 /2
@bot 
               endm

;============================================================
; load param 1 test against param 2 if match reset to param 3
; This code keeps the map within the proper boundaries as
; defined by the map height and map width
;============================================================
defm           Range_Test                     
               lda                 /1    
               clc       
               cmp                 /2          
               bne                 @bottom
               lda                 /3             
               sbc                 #1
               sta                 /1           
@bottom
               endm
;============================================================
;                PROGRAM START (Grab Keyboard Input)
;============================================================
*=$1000        
               lda                 #$93           ; shift clear dec 147
               JSR                 $FFD2          ; clear screen
main_loop      
               jsr                 move_routine  
               jsr                 $ffe4          ; Input a key from the keyboard
               cmp                 #$51           ; q key pressed ?
               beq                 quit_prg           
               cmp                 #$41           ; a key pressed? move left
               beq                 move_left      ;      
               cmp                 #$53           ; s key pressed? move right
               beq                 move_right     ;      
               cmp                 #$57           ; w key pressed? move up
               beq                 move_up        ;      
               cmp                 #$5a           ; z key pressed? move up
               beq                 move_down      ;      
               jmp                 main_loop      
    
move_left      mydec               cx             ;Move map left  cx=cx-1
move_right     myinc               cx             ;Move map right cx=cx+1
move_up        mydec               cy             ;Move map up    cy=cy-1
move_down      myinc               cy             ;Move map down  cy=cy+1
              
quit_prg       rts

;============================================================
;                     MOVEMENT ROUTINE
; This section checks the cx and cy variables to make
; sure the map displayed on the screen stays within the 
; boundaries of the those variables
;============================================================

move_routine   Range_Test          cy,#$ff,map_height ; Test cy for -1 reset to height if match
               Range_Test          cy,map_height,#1   ; Test cy for map_height reset to 0 if match
               Range_Test          cx,#$ff,map_width  ; Test cx for -1 reset to width if match
               Range_Test          cx,map_width,#1    ; Test cx for map width reset to 0 if match


               lda                 #$e0           ;Set Inital Map screen scn_offset
               sta                 scn_offset     ;Inital location of top left
               lda                 #$04           ;view port on the screen
               sta                 scn_offset+1    
               lda                 #$00
               sta                 map_offset
               sta                 map_offset+1      
;==========================================================
;                 Beginning Loop (vertical section)
;==========================================================
               ldx                 #$0  ; Outer loop
lp_x           txa
               Check_NXNY          cy,ny,map_height    ; Reset NY if wrap at bottom of map
               jsr                 calc_offset         ; calc map offset=ny*map width
;==========================================================
;                 Beginning Loop (horizontal section)
;==========================================================
               ldy                 #$0  ; Inner Loop          
loop_y         tya
               Check_NXNY          cx,nx,map_width     ;Reset NX if wrap at right side of map

               sty                 tempy               ;Store Y register

               set_indirect        #<astring,#>astring ;Load up $fb, $fc to do an indirect lookup of astring
               lda                 map_offset        
               clc
               adc                 nx
               tay
               lda                 ($fb),y        
               pha                                    ;Store A which is the Current Char in map
               ldy                 tempy              ;Restore Y Register
               
               set_indirect        scn_offset,scn_offset+1; Load up $fb, $fc to do an indirect lookup of scn_offset

               pla                                ; Restore A, which is map character
               sta                 ($fb),y        ; Display map character on the screen
               iny                                ; increment y register, which is used here for horizontal
               cpy                 view_wd$       ; check if at end if current line width   
               bne                 loop_y         ; Nope? back to top of loop

               add_scn_offset      scn_offset,scn_width$;Jump the screen pointer down
               add_scn_offset      map_offset,map_width ;IE scn_offset=scn_offset+40, map_offset=map_offset+20

;==========================================================
               inx                                ; increment x register, which is used here for vertical
               cpx                 view_ht$       ; check if at the bottom row of the map height
               bne                 duck           ; Nope? back to top of loop
               rts
duck           jmp                 lp_x       
               rts

;==========================================================
;                         END PROGRAM 
;==========================================================
            
;==========================================================
; This sub uses a table of pre-calculated starting positions
; for each y row of the map, eliminating the need for doing
; expensive math calculations (adds or mults)
;==========================================================

calc_offset    txa                                ; Save off the X register
               pha                                ; Push to stack
               ldx                 ny             
               lda                 map_off,x      
               sta                 map_offset        
               pla                                ; Pull from stack
               tax                                ; Restore the X register
               rts               
                
;slow_down      ldx                 delay
;               inx
;               stx                 delay          
;               bne                 slow_down  
;               rts     
