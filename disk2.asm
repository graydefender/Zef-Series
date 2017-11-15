*=$1000  ; just an example

        LDA #4 ; length of filename
        LDX #<fname
        LDY #>fname
        JSR $FFBD     ; call SETNAM

        LDA #$02      ; file number 2
        LDX $BA       ; last used device number
        BNE .skip
        LDX #$08      ; default to device 8
.skip   LDY #$02      ; secondary address 2
        JSR $FFBA     ; call SETLFS

        JSR $FFC0     ; call OPEN
        BCS .error    ; if carry set, the file could not be opened

        ; check drive error channel here to test for
        ; FILE NOT FOUND error etc.

        LDX #$02      ; filenumber 2
        JSR $FFC6     ; call CHKIN (file 2 now used as input)

        LDA #<load_address
        STA $AE
        LDA #>load_address
        STA $AF

        LDY #$00
.loop   JSR $FFB7     ; call READST (read status byte)
        BNE .eof      ; either EOF or read error
        JSR $FFCF     ; call CHRIN (get a byte from file)
        STA ($AE),Y   ; write byte to memory
        INC $AE
        BNE .skip2
        INC $AF
.skip2  JMP .loop     ; next byte

.eof
        AND #$40      ; end of file?
        BEQ .readerror
.close
        LDA #$02      ; filenumber 2
        JSR $FFC3     ; call CLOSE

        JSR $FFCC     ; call CLRCHN
        RTS
.error
        ; Akkumulator contains BASIC error code

        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)

        ;... error handling for open errors ...
        JMP .close    ; even if OPEN failed, the file has to be closed
.readerror
        ; for further information, the drive error channel has to be read

        ;... error handling for read errors ...
        JMP .close

fname  
        text  "test"

*=$2000
load_address
                    