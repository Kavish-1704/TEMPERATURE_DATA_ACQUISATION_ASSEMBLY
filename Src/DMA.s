/*So here is some theory about direct memory access 
DMA is a specialised hardware module that transfers data between memory and peripherals without involving the CPU hence releaving the load on the CPU where it can parallel do some other mathematical computation without worrying about the data transportation from the peripherals 

AMBA(Advanced Microcontrollere Bus archictecture)
this is the bus architecture associated with the DMA and mcu:
1. AHB(Advanced High-Performance Bus)
this bus is used for the transportation of data from fast components i.e flash,cpu,ram
2.APB(Advanced Peripheral Bus)
this bus is used for the transportation of dat from relatively slow peripherals i.e uart timer adc

Transfer Method : Our Mcu uses Flow-Though transfer 
--> it reads data from the source and then stores in the DMA buffer 
waits for the destination register to be free and then writes data to the destination by the rule of FIFO

DMA structure 
--> Main unit -->DMA1(for slow peripherals on APB1) and DMA2(for fast peripherals on APB2/AHB)
-->Streams-->8 independent engines avaliable inside the controller
-->channels-->8 input lines connected to each stream 
-!constraints --> A stream can only listen to one channel at a time

Operation modes 
--> Direct mode ->Data is transferred immediately
                -! source and destination data widths must be equal
                -!! can only used for memory-to-memory or peripheral-to-peripheral transfers 
--> FIFO Mode   -> First in first out 
                -> uses small internal buffer(4 words deep)
                ->allows packing and unpacking to different data sizes 





WE ARE USING DMA1 STREAM 6
*/


.global DMA_Init
.global DMA2_Init


.equ RCC_BASE, 0x40023800
.equ DMA1_BASE, 0x40026000
.equ USART2_BASE, 0x40004400
.equ USART2_DR, 0x04
.equ DMA1_CR, 0xD0
.equ DMA1_NDTR, 0xD4
.equ DMA1_PAR, 0xD8
.equ DMA1_MOAR, 0xDC
.equ DMA1_HIFC, 0x0C
.equ RCC_AHB1ENR, 0x30
.equ ADC1_BASE,   0x40012000
.equ DMA2_BASE, 0x40026400
.equ DMA_S0CR, 0x10
.equ DMA_S0NDTR, 0x14
.equ DMA_S0PAR,0x18
.equ DMA_S0M0AR, 0x1C
.equ DMA_AHB1ENR, 0x30



DMA2_Init:
PUSH {R4,R5,LR}
MOV R4, R0
MOV R5, R1

LDR R0, = RCC_BASE
LDR R1, [R0,#RCC_AHB1ENR]
LDR R2, =0x00400000
ORR R1,R1,R2
STR R1,[R0,#RCC_AHB1ENR]

LDR R0, =DMA2_BASE
LDR R1,[R0,#DMA_S0CR]
LDR R2, =1
BIC R1,R1, R2
STR R1,[R0,#DMA_S0CR]

wait_dma2:
    LDR R1,[R0,#DMA_S0CR]
    LDR R2,=1
    TST R1, R2
    BNE wait_dma2

LDR R2, =ADC1_BASE
ADD R2,R2,#0X4C
STR R2, [R0,#DMA_S0PAR]

STR R4, [R0,#DMA_S0M0AR]

STR R5, [R0,#DMA_S0NDTR]

LDR R1,[R0,#DMA_S0CR]
LDR R2, =0x01C00000
BIC R1,R2
LDR R2, =0x30000
ORR R1,R1, R2
LDR R2, =0x2000
ORR R1,R1,R2 // MSIZE 16BIT
LDR R2, =0x800
ORR R1,R1,R2// PSIZE
LDR R2, =0x400
ORR R1,R1,R2 // MEMORY INCREMENT
LDR R2, =0x100
ORR R1,R1,R2 // CIRCULAR MODE
LDR R2, =0xC0
BIC R1,R1,R2 // DIRECTION PERI TO MEMORY

STR R1,[R0,#DMA_S0CR]

// ENABLE STREAM 
LDR R2, =1
ORR R1,R1,R2
STR R1,[R0,#DMA_S0CR]

POP {R4,R5,PC}



DMA_Init:
PUSH {R4,R5,LR}
MOV R4,R0
MOV R5,R1
// ENABLING THE CLOCK
LDR R0, =RCC_BASE
LDR R1,[R0,#RCC_AHB1ENR]
LDR R2,=(1<<21)
ORR R1,R1,R2
STR R1,[R0,#RCC_AHB1ENR]

// DISABLING THE STREAM
LDR R0, =DMA1_BASE

LDR R2,=DMA1_CR
LDR R1,[R0,R2]
LDR R3,=1
BIC R1,R1,R3
STR R1,[R0,R2]
wait_loop:

LDR R1,[R0,R2]
TST R1,R3

BNE wait_loop

// CLEARING THE STATUS FLAGE 
LDR R0, =DMA1_BASE
LDR R1, = 0x003F0000
STR R1,[R0,#DMA1_HIFC]

// SETTING THE ROUTE
LDR R0, =DMA1_BASE
LDR R2,=DMA1_MOAR
STR R4, [R0,R2]


LDR R2, =USART2_BASE
ADD R2,R2,#USART2_DR
LDR R3,=DMA1_PAR
STR R2,[R0,R3]

LDR R0, = DMA1_BASE
LDR R2,=DMA1_NDTR
STR R5, [R0,R2]

// CONFIGURING THE STREAM 

LDR R0, =DMA1_BASE

// CONTROLLING THE CHANNEL 4
LDR R2,=DMA1_CR
LDR R1, [R0,R2]
LDR R2,=(7<<25)
BIC R1,R1,R2
LDR R2,=(4<<25)
ORR R1,R1,R2
// SETTING THE DIRECTION OF TRANSFER MEM-TO PERIPH IS 01
LDR R2,=(01<<6)
ORR R1,R1,R2

// ENBLING THE MEMORY INCRIMENT
LDR R2,=(1<<10)
ORR R1,R1,R2

// DISABLING THE PERIPHERAL INCREMENT
LDR R2,=(1<<9)
BIC R1,R1,R2

LDR R2,=DMA1_CR
STR R1,[R0,R2]

LDR R0, = DMA1_BASE

LDR R1,[R0,R2]
LDR R3,=1
ORR R1,R1,R3

STR R1,[R0,R2]

// DESTINATION ADDRESS 



POP {R4, R5, PC}





 






