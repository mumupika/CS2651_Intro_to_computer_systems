;To judge whether a number is even or odd.
;
.ORIG x3000
READ    AND R0,R0,#0
        LD R2,NUM
JUDGE   AND R1,R1,#0
        ADD R1,R1,#1
        AND R2,R1,R2 ;LOGICAL AND to judge 0/1
        BRp ODD
        BRz EVEN

ODD     LD R0,O
        TRAP x21
        LD R0,D
        TRAP x21
        TRAP x21
        TRAP x25

EVEN    LD R0,E
        TRAP x21
        LD R0,V
        TRAP x21
        LD R0,EL
        TRAP x21
        LD R0,N
        TRAP x21
        TRAP x25
;OBJECTS
P       .FILL xFE04
DDR     .FILL xFE06
O       .FILL x004F
D       .FILL x0064
E       .FILL x0045
EL      .FILL x0065
V       .FILL x0076
N       .FILL x006E
COUNT   .FILL #-48
NUM     .FILL #42
.END
