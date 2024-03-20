;
;The program should right shift a bit for a number.
;Stored in number.
;
        .ORIG x3000 ;Start at x3000
        LD      R0,NUM
        LD      R2,DST
;LOOP 1:continue moving.
TO      AND     R1,R1,#0
        ADD     R1,R1,#15 ;counter to move 15-i bits.
;Loop function: checking whether needs to move higher bit.
LOOP    ADD     R0,R0,#0
        BRn     NEG
        BRp     POS
;NEG: We should add 1 after moving.
NEG     ADD     R0,R0,R0
        ADD     R0,R0,#1
        ADD     R1,R1,#-1
        BRnz    DONE
        BRnzp   LOOP
;Pos: NO need to add 1.
POS     ADD     R0,R0,R0
        ADD     R1,R1,#-1
        BRnz    DONE
        BRnzp   LOOP ;When R1 is not 0, continue loop.
DONE    LD      R1,TURN
        AND     R0,R0,R1 ;turn the result back
        ADD     R2,R2,#-1
        BRnz    OVER ;if OKay, store the result.
        BRnzp   TO
OVER    ST      R0,NUM
        HALT
NUM     .FILL   x0006
DST     .FILL   x0002
TURN    .FILL   x7FFF
        .END