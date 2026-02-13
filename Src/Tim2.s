/* The basic difference between this timer 2 logic and the previous is that the previous one uses polling which involves the cpu to maintain a check over the timer but this method is the hardware trigger i.e the timer sends a trigo pulse which the adc receives but also the timer doesent know where to send it it just sends it at the end of the time and the adc acts as a reciever between the path*/
.global TIM2_Init

.equ RCC_BASE, 0x40023800
.equ TIM2_BASE, 0x40000000
.equ TIM2_CR1, 0x00
.equ TIM2_CR2, 0x04
.equ TIM2_PSC, 0x28
.equ TIM2_ARR, 0x2C
.equ TIM2_EGR, 0x14
.equ RCC_APB1ENR, 0x40


TIM2_Init:
// ENABLING THE TIMER CLOCK 
LDR R0, =RCC_BASE
LDR R1,[R0,#RCC_APB1ENR]
LDR R2, =1
ORR R1,R1, R2
STR R1,[R0,#RCC_APB1ENR]


// CONFIGURING THE MASTER MODE 

LDR R0, =TIM2_BASE
LDR R1,[R0,#TIM2_CR2]
LDR R2, = 0x70
BIC R1,R1,R2
LDR R2, =0x20
ORR R1,R1, R2
STR R1,[R0,#TIM2_CR2]




// SETTING THE PRESCALAR AND FREQUENCY TARGET IS 100HZ

LDR R1,= 1599
STR R1,[R0,#TIM2_PSC]
LDR R1, =99
STR R1,[R0,#TIM2_ARR]


MOV R1,#1
STR R1,[R0,#TIM2_EGR]

LDR R1,[R0,#TIM2_CR1]
LDR R2, =1
ORR R1,R1, R2
STR R1,[R0,#TIM2_CR1]







