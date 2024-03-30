.ORIG	x3000
;  The Calculator, Main Algorithm
                    LD        R6,StackBase1  ; Initialize the Stack.
                    ADD       R6,R6,#1     ; R6 is stack pointer
                    JSR       OpClear
                    LEA       R0,PromptMsg
                    PUTS
                    GETC
                    OUT                      
; Check the command
Test                LD        R1,NegX       ; Check for X   
                    ADD       R1,R1,R0
                    BRz       Exit
;
                    LD        R1,NegC       ; Check for C   
                    ADD       R1,R1,R0
                    BRz       OpClear       ; See Figure 10.27
;
                    LD        R1,NegPlus    ; Check for +   
                    ADD       R1,R1,R0
                    BRz       OpAdd         ; See Figure 10.10
;
                    LD        R1,NegMult    ; Check for *   
                    ADD       R1,R1,R0
                    BRz       OpMult        ; See Figure 10.14
;
                    LD        R1,NegMod     ; Check for %   
                    ADD       R1,R1,R0
                    BRz       OpMod         ; See Figure 10.15
;
                    LD        R1,NegXOR     ; Check for @   
                    ADD       R1,R1,R0
                    BRz       OpXOR         ; See Figure 10.15
;
                    LD        R1,NegD       ; Check for D   
                    ADD       R1,R1,R0
                    BRz       OpDisplay     ; See Figure 10.26
;
                    LD        R1, NegMinus
                    ADD       R1, R1, R0
                    BRz       OpNeg
;
; Then we must be entering an integer
;
                    BRnzp     PushValue     ; See Figure 10.23
;
NewCommand          LEA       R0,PromptMsg
                    PUTS
                    GETC
                    OUT
                    BRnzp     Test
Exit                HALT
PromptMsg            .FILL     x000A
                    .STRINGZ "Enter a command:"
NegX                .FILL     xFFA8
NegC                .FILL     xFFBD
NegPlus             .FILL     xFFD5
NegMod              .FILL     xFFDB
NegMult             .FILL     xFFD6
NegXOR              .FILL     xFFC0
NegD                .FILL     xFFBC
NegMinus            .FILL     xFFD3
STACKBASE1          .FILL     STACKBASE
; Add
OpAdd       JSR     POP             ; Get first source operand.
            ADD     R5,R5,#0        ; Test if POP was successful.
            BRp     Exit_add        ; Branch if not successful.
            ADD     R1,R0,#0        ; Make room for second operand
            JSR     POP             ; Get second source operand.
            ADD     R5,R5,#0        ; Test if POP was successful.
            BRp     Restore1        ; Not successful, put back first.
            ADD     R0,R0,R1        ; THE Add.
            JSR     RangeCheck      ; Check size of result.
            BRp     Restore2        ; Out of range, restore both.
            JSR     PUSH            ; Push sum on the stack.
            JSR     OpDisplay
            BRnzp	 NewCommand     ; On to the next task...
Restore2    ADD     R6,R6,#-1       ; Decrement stack pointer.
Restore1    ADD     R6,R6,#-1       ; Decrement stack pointer.
Exit_add    RET
; Multiply
OpMult          AND    R3,R3,#0      ; R3 holds sign of multiplier.
                JSR    POP           ; Get first source from stack.
                ADD    R5,R5,#0      ; Test for successful POP
                BRp    Exit_mult          ; Failure
                ADD    R1,R0,#0      ; Make room for next POP
                JSR    POP           ; Get second source operand
                ADD    R5,R5,#0      ; Test for successful POP
                BRp    Restore1      ; Failure; restore first POP
                ADD    R2,R0,#0      ; Moves multiplier, tests sign
                BRzp   PosMultiplier 
                ADD    R3,R3,#1      ; Sets FLAG: Multiplier is neg
                NOT    R2,R2
                ADD    R2,R2,#1      ; R2 contains -(multiplier)
PosMultiplier   AND    R0,R0,#0      ; Clear product register
                ADD    R2,R2,#0
                BRz    PushMult      ; Multiplier = 0, Done.
MultLoop        ADD    R0,R0,R1      ; THE actual "multiply"
                ADD    R2,R2,#-1     ; Iteration Control
                BRp    MultLoop
                JSR    RangeCheck
                ADD    R5,R5,#0      ; R5 contains success/failure
                BRp    Restore2
                ADD    R3,R3,#0      ; Test for negative multiplier
                BRz    PushMult
                NOT    R0,R0         ; Adjust for 
                ADD    R0,R0,#1      ; sign of result
PushMult        JSR    PUSH          ; Push product on the stack.
                JSR    OpDisplay
                BRnzp	 NewCommand      ; On to the next task...
Exit_mult       BRnzp	 NewCommand      ; On to the next task...
; Range check
RangeCheck      LD        R5,Neg999
                ADD       R4,R0,R5   ; Recall that R0 contains the 
                BRp       BadRange   ; result being checked.
                LD        R5,Pos999
                ADD       R4,R0,R5
                BRn       BadRange
                AND       R5,R5,#0   ; R5 <-- success
                RET
BadRange        ST        R7,Save    ; R7 is needed by TRAP/RET
                LEA       R0,RangeErrorMsg
                TRAP      x22        ; Output character string
                LD        R7,Save
                AND       R5,R5,#0   ; 
                ADD       R5,R5,#1   ; R5 <-- failure
                RET
Neg999          .FILL     #-999
Pos999          .FILL     #999
RangeErrorMsg   .FILL     x000A
                .STRINGZ  "Error: Number is out of range."
; init stack
OpClear         LEA       R6,StackBase  ; Initialize the Stack.
                ADD       R6,R6,#1      ; R6 is stack pointer
                BRnzp     NewCommand
; mod
OpMod       JSR     POP                 ; Get first source operand.
            ADD     R5, R5, #0          ; Test pop successful.
            BRp     Exit                ; fail, exit.
            ADD     R1, R0, #0          ; space for second operand.
            JSR     POP                 ; get teh second source operand.
            ADD     R5, R5, #0          ; test pop successful
            BRp     Restore1            ; Restore to first.
            ADD     R0, R0, #0          ; check whether positive or negative
            BRn     NMODLOOP
            NOT	    R1,	R1              ; 2's complementary.
            ADD     R1, R1, #1          ; here we have the neg mod number.
PMODLOOP    ADD     R2, R0, #0          ; keep minus the mod num until negatibe.
            ADD     R0, R0, R1
            BRzp    PMODLOOP
            BRnzp   MODST
NMODLOOP    ADD     R2, R0, #0          ; For negative number, add the mod until positive.
            ADD     R0, R0, R1
            BRn     NMODLOOP
            ADD     R2, R0, #0
MODST       ADD     R0, R2, #0          ; Store the result to R0.
            JSR     RangeCheck          ; Check the range.
            BRp     Restore2            ; if R5 fails, return to restore2.
            JSR     PUSH                ; push the value and show.
            JSR     OpDisplay
; xor
OpXOR       JSR     POP                 ; Get first source operand.
            ADD     R5, R5, #0          ; Test pop successful.
            BRp     Exit                ; fail, exit.
            ADD     R1, R0, #0          ; space for second operand.
            JSR     POP                 ; get teh second source operand.
            ADD     R5, R5, #0          ; test pop successful
            BRp     Restore1            ; Restore to first.
            AND     R2, R2, #0          
            ADD     R2, R2, #1          ; get one bit out from the op number.
            AND     R7, R7, #0          ; R2 is 1, and store each bit into the R3,R4.
XORLOOP     AND     R3, R2, R0          ; R3 get the first bit of R0.
            AND     R4, R2, R1          ; R4 get the first bit of R0.
            ADD     R3, R3, R4          ; Bit add is XOR.
            AND     R3, R3, R2          ; Restore other bit. To clear the carrier.
            ADD     R7, R7, R3          ; add the bit to the R7 result.
            ADD     R2, R2, R2          ; left shift a bit.
            BRnp    XORLOOP             ; when the number turn to 0, stop the shift.
            ADD     R0, R7, #0
            JSR     RangeCheck          ;Check range.
            BRp     Restore2
            JSR     PUSH
            JSR     OpDisplay
OpNeg       JSR     POP
            ADD     R5, R5, #0
            BRp     Exit
            NOT     R0, R0
            ADD     R0, R0, #1          ; normal not and plus 1. this is 2's complementary.
            JSR     RangeCheck
            BRp     Restore2
            JSR     PUSH
            JSR     OpDisplay
;
; This algorithm takes a sequence of ASCII digits typed by the user, 
; converts it into a binary value by calling the ASCIItoBinary 
; subroutine and pushes the binary value onto the stack.  
; 
PushValue       LEA       R1,ASCIIBUFF  ; R1 points to string being 
                LD        R2,MaxDigits  ; generated
;
ValueLoop       ADD       R3,R0,xFFF3   ; Test for carriage return
                BRz       GoodInput
                ADD       R2,R2,#0
                BRz       TooLargeInput
                ADD       R2,R2,#-1     ; Still room for more digits
                STR       R0,R1,#0      ; Store last character read
                ADD       R1,R1,#1     
                GETC
                OUT                     ; Echo it
                BRnzp     ValueLoop
;
GoodInput       LEA       R2,ASCIIBUFF
                NOT       R2,R2
                ADD       R2,R2,#1
                ADD       R1,R1,R2      ; R1 now contains no. of char.
                JSR       ASCIItoBinary
                JSR       PUSH
                JSR       OpDisplay
;
TooLargeInput   GETC                    ; Spin until carriage return
                OUT
                ADD       R3,R0,xFFF3
                BRnp      TooLargeInput
                LEA       R0,TooManyDigits
                PUTS
                BRnzp     NewCommand
TooManyDigits   .FILL     x000A
                .STRINGZ "Too many digits"
MaxDigits       .FILL     x0003
OpDisplay       JSR       POP         ; R0 gets the value to be displayed
                ADD       R5,R5,#0  
                BRp       NewCommand  ; POP failed, nothing on the stack.
                JSR       BinarytoASCII 
                LD        R0,NewlineChar
                OUT
                LEA       R0,ASCIIBUFF
                PUTS
                ADD       R6,R6,#-1   ; Push displayed number back on stack
                BRnzp     NewCommand
NewlineChar     .FILL     x000A
Save            .FILL   x0000
StackMax        .BLKW   9
StackBase       .FILL   x0000
UnderflowMsg    .FILL   x000A
                .STRINGZ "Error: Too Few Values on the Stack."
; POP
POP             LEA     R0,StackBase
                NOT     R0,R0
                ADD     R0,R0,#1       ; R0 = -addr.ofStackBase 
                ADD     R0,R0,R6       ; R6 = StackPointer
                BRp     UNDERFLOW
                LDR     R0,R6,#0       ; The actual POP 
                ADD     R6,R6,#1       ; Adjust StackPointer
                AND     R5,R5,#0       ; R5 <-- success
                RET 
Underflow       ST      R7,Save        ; TRAP/RET needs R7
                LEA     R0,UnderflowMsg
                PUTS                   ; Print error message.
                LD      R7,Save        ; Restore R7
                AND     R5,R5,#0  
                ADD     R5,R5,#1       ; R5 <-- failure
                RET

;
PUSH            ST      R1,Save1      ; R1 is needed by this routine
                LEA     R1,StackMax
                NOT     R1,R1
                ADD     R1,R1,#1      ; R1 = - addr. of StackMax    
                ADD     R1,R1,R6      ; R6 = StackPointer
                BRz     Overflow
                ADD     R6,R6,#-1     ; Adjust StackPointer for PUSH
                STR     R0,R6,#0      ; The actual PUSH
                BRnzp   Success_exit
Overflow        ST      R7,Save
                LEA     R0,OverflowMsg
                PUTS
                LD      R7,Save
                LD      R1,Save1     ; Restore R1
                AND     R5,R5,#0    
                ADD     R5,R5,#1      ; R5 <-- failure
                RET
Success_exit    LD      R1,Save1      ; Restore R1
                AND     R5,R5,#0      ; R5 <-- success
                RET
Save1          .FILL   x0000
OverflowMsg    .STRINGZ "Error: Stack is Full."
;
ASCIItoBinary   AND    R0,R0,#0      ; R0 will be used for our result 
                ADD    R1,R1,#0      ; Test number of digits.
                BRz    DoneAtoB      ; There are no digits
;   
                LD     R3,NegASCIIOffset  ; R3 gets xFFD0, i.e., -x0030
                LEA    R2,ASCIIBUFF
                ADD    R2,R2,R1
                ADD    R2,R2,#-1     ; R2 now points to "ones" digit
;               
                LDR    R4,R2,#0      ; R4 <-- "ones" digit
                ADD    R4,R4,R3      ; Strip off the ASCII template
                ADD    R0,R0,R4      ; Add ones contribution
;   
                ADD    R1,R1,#-1
                BRz    DoneAtoB      ; The original number had one digit
                ADD    R2,R2,#-1     ; R2  now points to "tens" digit
;   
                LDR    R4,R2,#0      ; R4 <-- "tens" digit
                ADD    R4,R4,R3      ; Strip off ASCII  template
                LEA    R5,LookUp10   ; LookUp10 is BASE of tens values
                ADD    R5,R5,R4      ; R5 points to the right tens value
                LDR    R4,R5,#0
                ADD    R0,R0,R4      ; Add tens contribution to total
;   
                ADD    R1,R1,#-1
                BRz    DoneAtoB      ; The original number had two digits
                ADD    R2,R2,#-1     ; R2 now points to "hundreds" digit
;           
                LDR    R4,R2,#0      ; R4 <-- "hundreds" digit
                ADD    R4,R4,R3      ; Strip off ASCII template
                LEA    R5,LookUp100  ; LookUp100 is hundreds BASE
                ADD    R5,R5,R4      ; R5 points to hundreds value
                LDR    R4,R5,#0
                ADD    R0,R0,R4      ; Add hundreds contribution to total
;         
DoneAtoB        RET
NegASCIIOffset  .FILL  xFFD0
ASCIIBUFF       .BLKW  4
LookUp10        .FILL  #0
                .FILL  #10
                .FILL  #20
                .FILL  #30
                .FILL  #40
                .FILL  #50
                .FILL  #60
                .FILL  #70
                .FILL  #80
                .FILL  #90
;
LookUp100       .FILL  #0
                .FILL  #100
                .FILL  #200
                .FILL  #300
                .FILL  #400
                .FILL  #500
                .FILL  #600
                .FILL  #700
                .FILL  #800
                .FILL  #900
;
;  This algorithm takes the 2's complement representation of a signed
;  integer, within the range -999 to +999, and converts it into an ASCII 
;  string consisting of a sign digit, followed by three decimal digits.  
;  R0 contains the initial value being converted.
;
BinarytoASCII   LEA   R1,ASCIIBUFF  ; R1 points to string being generated
                ADD   R0,R0,#0      ; R0 contains the binary value
                BRn   NegSign       ; 
                LD    R2,ASCIIplus  ; First store the ASCII plus sign
                STR   R2,R1,#0
                BRnzp Begin100
NegSign         LD    R2,ASCIIminus ; First store ASCII minus sign
                STR   R2,R1,#0
                NOT   R0,R0         ; Convert the number to absolute
                ADD   R0,R0,#1      ; value; it is easier to work with.
;   
Begin100        LD    R2,ASCIIoffset ; Prepare for "hundreds" digit
;   
                LD    R3,Neg100     ; Determine the hundreds digit
Loop100         ADD   R0,R0,R3
                BRn   End100
                ADD   R2,R2,#1
                BRnzp Loop100
;   
End100          STR    R2,R1,#1   ; Store ASCII code for hundreds digit
                LD     R3,Pos100
                ADD    R0,R0,R3   ; Correct R0 for one-too-many subtracts
;   
                LD     R2,ASCIIoffset ; Prepare for "tens" digit
;   
Begin10         LD     R3,Neg10   ; Determine the tens digit
Loop10          ADD    R0,R0,R3
                BRn    End10
                ADD    R2,R2,#1
                BRnzp  Loop10
;   
End10           STR    R2,R1,#2   ; Store ASCII code for tens digit 
                ADD    R0,R0,#10  ; Correct R0 for one-too-many subtracts
Begin1          LD     R2,ASCIIoffset ; Prepare for "ones" digit
                ADD    R2,R2,R0
                STR    R2,R1,#3
                RET
;
ASCIIplus       .FILL  x002B
ASCIIminus      .FILL  x002D
ASCIIoffset     .FILL  x0030
Neg100          .FILL  xFF9C
Pos100          .FILL  x0064
Neg10           .FILL  xFFF6
.END
