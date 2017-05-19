*=$1000

                    sei
                    lda                 #<interrupt 
                    sta                 $314                
                    lda                 #>interrupt          
                    sta                 $315                
                    cli
                    rts
                    
interrupt
                    inc value
                    lda                 value               
                    cmp                 #10                 
                    bne  @end
                    lda                 #0                  
                    sta                 value               
                    
                    inc                 $400                
@end                jmp                 $ea31               

value               byte 00                    
                    