*=$1000

                    clc
                    ldx                 #5
                    ldy                 #39               
                    
                    jsr                 $e50a              
                    stx                 $400                
                    sty                 $401                

                    lda                 #$31
                    ldy #3
                    jsr                 $ea13               
                    lda                 #$32                
                    jsr $ea13
                    ;jsr $ea13
                    
              ;      rts
                    
;                    LDA                 #$32

;                    LDY                 #$00                ;     clear Y
;                    STY                 $CF                 ;     clear the cursor blink phase
;                    JSR                 $EA13               ;     print character A and colour X

  LDX #$01    ; Select row
  LDY #35    ; Select column
  JSR $E50C   ; Set cursor
 
  LDA #<STRING  ; Load lo-byte of string adress
  LDY #>STRING  ; Load hi-byte of string adress
  JSR $AB1E     ; Print string
  RTS           ; End.
 
STRING     null "HELLO WORLD!!!"

                    rts