.syntax unified
.thumb
.cpu cortex-m4

.global UART_init
.global UART_SendChar

.equ RCC_BASE,    0x40023800
.equ RCC_AHB1ENR, 0x30
.equ RCC_APB1ENR, 0x40

.equ GPIOA_BASE,  0x40020000
.equ GPIOA_MODER, 0x00
.equ GPIOA_AFRL,  0x20

.equ USART2_BASE, 0x40004400
.equ USART2_BRR,  0x08
.equ USART_CR1,   0x0C
.equ USART_SR,    0x00
.equ USART_DR,    0x04
.equ USART2_CR3,  0x14

UART_init:
    PUSH {LR}

    // 1. ENABLE CLOCKS   
    LDR R0, =RCC_BASE

    // Enable GPIOA   
    LDR R1, [R0, #RCC_AHB1ENR]
    ORR R1, R1, #(1<<0)
    STR R1, [R0, #RCC_AHB1ENR]

    // Enable USART2   
    LDR R1, [R0, #RCC_APB1ENR]
    ORR R1, R1, #(1<<17)
    STR R1, [R0, #RCC_APB1ENR]


    // 2. CONFIGURE GPIO PA2 (TX)   
    LDR R0, =GPIOA_BASE

    // Set PA2 to Alternate Function Mode (10)   
    LDR R1, [R0, #GPIOA_MODER]
    BIC R1, R1, #(3<<4)     // Clear Bits 4,5   
    ORR R1, R1, #(2<<4)     // Set Bit 5 (10)   
    STR R1, [R0, #GPIOA_MODER]

    // Set PA2 to AF7 (USART2)   
    LDR R1, [R0, #GPIOA_AFRL]
    BIC R1, R1, #(0xF<<8)   // Clear Bits 8-11   
    ORR R1, R1, #(0x7<<8)   // Set to 0111 (AF7)   
    STR R1, [R0, #GPIOA_AFRL]


    // 3. CONFIGURE USART2   
    LDR R0, =USART2_BASE

    // Set Baud Rate: 9600 @ 16MHz --> 0x0683   
    LDR R1, =0x0683
    STR R1, [R0, #USART2_BRR]

    // Enable DMA Transmitter  
    LDR R1, [R0, #USART2_CR3]
    ORR R1, R1, #(1<<7)
    STR R1, [R0, #USART2_CR3]

    // Enable UART (UE) & Transmitter (TE)   
   
    LDR R1, [R0, #USART_CR1]
    LDR R2, =0xFFFF
    BIC R1, R1, R2    // Reset CR1   
    ORR R1, R1, #(1<<13)    // UE   
    ORR R1, R1, #(1<<3)     // TE   
    STR R1, [R0, #USART_CR1]

    POP {PC}


UART_SendChar:
    LDR R2, =USART2_BASE

wait_loop:
    LDR R1, [R2, #USART_SR]
    TST R1, #(1<<7)         // Check TXE (Transmit Data Register Empty)   
    BEQ wait_loop              

    STR R0, [R2, #USART_DR]  
    BX LR
