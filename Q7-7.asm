;
;Target: To write an assembly program,
;counting how many 1's have in R0
;Store the result in R1.
;

;Start here:
        .ORIG x3000
        AND R1,R1,#0    ;Set R1=0,initialize.
        LD R0,NUM
        BRzp LOOP        ;Bigger than zero, started at 0.
        ADD R1,R1,#1    ;If smaller than 0,first +1.
LOOP    ADD R0,R0,R0
        BRp LOOP         ;If bigger than zero, no 1 detected.
        BRz STOP
        ADD R1,R1,#1
        ADD R0,R0,#0
        BRnp LOOP
STOP    TRAP x25
NUM     .FILL x1370
        .END
