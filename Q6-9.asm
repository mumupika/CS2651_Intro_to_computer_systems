;Using the iteration construct, 
;write an LC-3 machine language routine that displays 
;exactly 100 Zs on the screen.
;
            .ORIG x3000
DISPLAY     LD R0,Z
            LD R1,COUNT
LOOP        TRAP x21        ;Display character of R0
            ADD R1,R1,#-1   ;minus 1
            BRp LOOP
            TRAP x25
Z           .FILL x5A
COUNT       .FILL #100
            .END