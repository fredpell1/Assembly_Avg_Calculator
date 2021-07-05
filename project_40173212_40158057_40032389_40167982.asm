;Project
; Frédéric Pelletier(40173212), Terrance Liang(40158057), Ibrahim Elyyan(40167982), Farnaz Zaveh(40032389)


;load our program to address $0801

.org $0801

; magic startup code (tokenized basic code for 228 SYS 2061)
.byte $0B, $08, $E4, $00, $9E, $32, $30, $36, $31, $00, $00, $00

start:
;cleaning up
     LDA #$28 ; (
    JSR $FFD2 
    LDA #8 ; determine the number of inputs
    STA input_index
    LDA #0
    STA powers_index
    LDA #0
    STA sum_high
    LDA #0
    STA sum_low

input_loop:
    LDA input_index
    CMP #0 ; testing if we have all the inputs
    BEQ skip
    JSR get_digit
    STA buffer ; in case we need it again
    ASL 
    ASL 
    ASL ; three ASL is equivalent to times 8
    CLC 
    ADC sum_low ;first digit adc
    STA sum_low
    LDA sum_high ;load sum high in AC
    ADC #$00 ; if there has been overflow, the carry will be "transfered" to the high byte
    STA sum_high; store sum high back in sum high

    LDA buffer; load first input
    ASL ; times 2
    CLC 
    ADC sum_low ;add first input into sum low
    STA sum_low
    LDA sum_high
    ADC #$00
    STA sum_high
    JSR get_digit ; get the unit position 
    CLC 
   
    ADC sum_low
    STA sum_low
    LDA sum_high
    ADC #$00
    STA sum_high 
    DEC input_index ; done with this number

    LDA input_index;loads input index value into accumulator 
    CMP #0 
    BEQ skip ;branch to skip if input index(number of units we take in is 0)

    LDA #$2B ; + sign
    JSR $FFD2 
    JMP input_loop

skip:
    LDA #$29 ; )
    JSR $FFD2 
    LDA #$2F ; /
    JSR $FFD2 
     LDA #$38 ; 8
    JSR $FFD2 
    LDA #$3D ; =
    JSR $FFD2 
    LDA #$0D
    JSR $FFD2 ; line break 

;dividing by 8 is equivalent to 3 right shift

division:
    LSR sum_high ; shifting the high byte and adding a 0 on the left
    ROR sum_low ; shifting the low byte with the carry on the left 
    LSR sum_high
    ROR sum_low
    LSR sum_high
    ROR sum_low
    BCS rounding ; if the last digit to be shifted is a 1, the decimal portion is at least 0.5 so we round up 




output_loop_1:
    LDA powers_index
    CMP #3 ; testing if all digits have been displayed 
    BCC output_loop_2
    JMP end 

output_loop_2:
    LDX powers_index
    LDA #$00
    CMP sum_high ; we compare the high byte with 0 to see if we can substract from it 
    BCC stay_loop_2
    LDA powers_ten,X ;load the position we want to display 
    CMP sum_low ; compare if we can substract from it, meaning we can increment value value_displayed
    BCC stay_loop_2
    BEQ stay_loop_2
    LDA value_displayed
    CLC 
    ADC #$30 ; getting the PETSCII value 
    JSR $FFD2
    LDA #0
    STA value_displayed ; reseting the value_displayed
    INC powers_index ; moving to the next position 
    JMP output_loop_1

stay_loop_2:
    INC value_displayed
  
    LDX powers_index
    SEC
    LDA sum_low 
    SBC powers_ten, X ; updating the value of the sum 
    STA sum_low
    LDA sum_high
    SBC #$00 ; substracting if necessary the carry 
    STA sum_high
   
    JMP output_loop_2

end:
    RTS

rounding:
    CLC
    INC sum_low
    LDA sum_high
    ADC #$00 
    STA sum_high
    JMP output_loop_1


;subroutine taken from the example code on moodle by Professor Eric Chan 
get_digit:
    JSR $FFE4
    BEQ get_digit
    JSR $FFD2 ; print on the screen what has been typed
    SEC 
    SBC #$30
    RTS




;variables

sum_high:
    .byte 0

sum_low:
    .byte 0

powers_ten:
    .byte 100,10,1

powers_index:
    .byte 0

value_displayed:
    .byte 0


input_index:
    .byte 0

buffer:
    .byte 0