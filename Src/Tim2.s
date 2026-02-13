/* The basic difference between this timer 2 logic and the previous is that 
   the previous one uses polling which involves the cpu to maintain a check 
   over the timer but this method is the hardware trigger i.e the timer 
   sends a trigo pulse which the adc receives. */

.syntax unified
.thumb
.cpu cortex-m4

.global TIM2_Init

.equ RCC_BASE,    0x40023800
.equ RCC_APB1ENR, 0x40

.equ TIM2_BASE,   0x40000000
.equ TIM2_CR1,    0x00
.equ TIM2_CR2,    0x04
.equ TIM2_PSC,    0x28
.equ TIM2_ARR,    0x2C
.equ TIM2_EGR,    0x14

TIM2_Init:
    PUSH {LR}               /* Missing in original */

    /* 1. ENABLE TIMER 2 CLOCK */
    LDR R0, =RCC_BASE
    LDR R1, [R0, #RCC_APB1ENR]
    ORR R1, R1, #1          /* Bit 0 = TIM2EN */
    STR R1, [R0, #RCC_APB1ENR]


    /* 2. CONFIGURE MASTER MODE (MMS = 010 -> Update Event as TRGO) */
    LDR R0, =TIM2_BASE
    LDR R1, [R0, #TIM2_CR2]
    BIC R1, R1, #(7<<4)     /* Clear MMS Bits (6:4) */
    ORR R1, R1, #(2<<4)     /* Set MMS = 010 (Update) */
    STR R1, [R0, #TIM2_CR2]


    /* 3. SET FREQUENCY (Target 100Hz) */
    /* Formula: F_timer = F_clk / ((PSC+1)*(ARR+1)) */
    /* Assuming 16MHz Clock: 16,000,000 / (1600 * 100) = 100 Hz */
    
    LDR R1, =1599           /* PSC = 1600 - 1 */
    STR R1, [R0, #TIM2_PSC]

    LDR R1, =99             /* ARR = 100 - 1 */
    STR R1, [R0, #TIM2_ARR]


    /* 4. FORCE UPDATE (EGR) */
    /* This loads the PSC/ARR values into shadow registers immediately */
    MOV R1, #1
    STR R1, [R0, #TIM2_EGR]


    /* 5. ENABLE TIMER (CEN) */
    LDR R1, [R0, #TIM2_CR1]
    ORR R1, R1, #1          /* CEN = 1 */
    STR R1, [R0, #TIM2_CR1]

    POP {PC}                /* Missing in original */