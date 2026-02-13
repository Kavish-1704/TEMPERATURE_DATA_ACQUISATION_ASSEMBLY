/*So this file is specifically for the purpose of converting the interger output given by the uart to ascii so that our pc can understand the value 

*/ 
.syntax unified 
.cpu cortex-m4
.thumb


.global Itoa 

Itoa:

PUSH {R4,R5,LR}

ADD R1,R1,#11// MOVING POINTER TO THE END OF THE BUFFER
MOVS R2,#0// NULL TERMINATOR 
STRB R2, [R1] // STORE /0

MOV R5,#0 // R5 IS THE LENGTH COUNTER 

// EDGE CASE : ZERO
CMP R0,#0
BNE conversion_loop//  IF NOT 0 START CONVERTING 
MOVS R2,#48 // ASCII 0
SUB R1,R1,#1 // MOVE POINTER BACK
STRB R2,[R1]
MOV R0,R1
MOV R1,#1 // LENGTH =1
POP {R4,R5,PC}

conversion_loop:
// CALCULATING THE REMAINDER 
MOV R2,#10
UDIV R2,R0,R2

MOV R3,#10
MUL R3,R2,R3

SUB R4,R0,R3

// STORE ASCII
ADD R4,R4,#48
SUB R1,R1,#1
STRB R4,[R1]

ADD R5,R5,#1

MOV R0,R2
CMP R0,#0
BNE conversion_loop

MOV R0,R1
MOV R1,R5

POP {R4,R5,PC}

