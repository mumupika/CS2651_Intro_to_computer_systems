;
;Judging whether a .stringz is Palindrome.
;Written start at x3000.
;
        .ORIG x3000
        LD      R0,PTR      ;Load from the start of the stringz.
        ADD     R1,R0,#0    ;Set R1 has the starting address of the string.

AGAIN   LDR     R2,R1,#0    ;Set R2 has the first char of string.
        BRz     CONT        ;When at the end of the string, move it back 1 bit.
        ADD     R1,R1,#1    ;else, continue move after.
        BRnzp   AGAIN       ;

CONT    ADD     R1,R1,#-1   ;Move to the last pos of string.
LOOP    LDR     R3,R0,#0    ;Load the first char.
        LDR     R4,R1,#0    ;Load the last char
        NOT	    R4,R4
        ADD     R4,R4,#1   
        ADD     R3,R3,R4    ;For compare.
        BRnp    NO
        ADD     R0,R0,#1    ;Move next
        ADD     R1,R1,#-1   ;Move upper
        NOT     R2,R0
        ADD     R2,R2,#1
        ADD     R2,R1,R2    ;Judge whether iterated all chars.
        BRnz    YES
        BRp     LOOP

YES     AND     R5,R5,#0    ;Initialize
        ADD     R5,R5,#1    ;Yes!Yes!
        BRnzp   DONE
NO      AND     R5,R5,#0    ;NO:(
DONE    TRAP	x25

PTR     .FILL       STRING 
STRING  .STRINGZ    "racecar"
        .END
