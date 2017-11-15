*=$1000  ; just an example

        LDA #4  ; length of filename
        LDX #<fname
        LDY #>fname
        JSR $FFBD     ; call SETNAM
        LDA #$01
        LDX $BA       ; last used device number
        BNE  skip
        LDX #$08      ; default to device 8
skip    LDY #$00      ; $00 means: load to new address
        JSR $FFBA     ; call SETLFS

        LDX #<load_address
        LDY #>load_address
        LDA #$00      ; $00 means: load to memory (not verify)
        JSR $FFD5     ; call LOAD
        BCS  error    ; if carry set, a load error has happened
        RTS
error
        ; Accumulator contains BASIC error code

        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)
        ; A = $04 (FILE NOT FOUND)
        ; A = $1D (LOAD ERROR)
        ; A = $00 (BREAK, RUN/STOP has been pressed during loading)

                                                            ;... error handling ...
        sta $400            
        RTS

fname               TEXT                "test"
*=$2000                    
load_address                    
