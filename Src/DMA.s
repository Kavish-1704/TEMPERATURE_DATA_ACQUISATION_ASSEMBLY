.syntax unified
.cpu cortex-m4
.thumb

.global DMA_Init
.global DMA2_Init

/* ==============================================================================
   OFFSETS & CONSTANTS
   ============================================================================== */
.equ RCC_BASE,    0x40023800
.equ RCC_AHB1ENR, 0x30

.equ DMA1_BASE,   0x40026000
.equ DMA2_BASE,   0x40026400

/* DMA1 Stream 6 (UART TX) Offsets */
.equ DMA1_S6CR,   0xA0
.equ DMA1_S6NDTR, 0xA4
.equ DMA1_S6PAR,  0xA8
.equ DMA1_S6M0AR, 0xAC
.equ DMA1_HIFCR,  0x0C

/* DMA2 Stream 0 (ADC1) Offsets */
.equ DMA2_S0CR,   0x10
.equ DMA2_S0NDTR, 0x14
.equ DMA2_S0PAR,  0x18
.equ DMA2_S0M0AR, 0x1C

.equ ADC1_BASE,   0x40012000
.equ USART2_BASE, 0x40004400


/* ==============================================================================
   DMA2 INIT (ADC1 -> RAM)
   Stream 0, Channel 0
   ============================================================================== */
DMA2_Init:
    PUSH {R4, R5, LR}
    MOV R4, R0              /* R4 = Destination Address (RAM) */
    MOV R5, R1              /* R5 = Length */

    /* 1. ENABLE DMA2 CLOCK */
    LDR R0, =RCC_BASE
    LDR R1, [R0, #RCC_AHB1ENR]
    ORR R1, R1, #(1<<22)    /* Bit 22 = DMA2EN */
    STR R1, [R0, #RCC_AHB1ENR]

    /* 2. DISABLE STREAM 0 */
    LDR R0, =DMA2_BASE
    LDR R1, [R0, #DMA2_S0CR]
    BIC R1, R1, #1          /* Clear EN bit */
    STR R1, [R0, #DMA2_S0CR]

wait_dma2_disable:
    LDR R1, [R0, #DMA2_S0CR]
    TST R1, #1
    BNE wait_dma2_disable

    /* 3. SET PERIPHERAL ADDRESS (ADC_DR) */
    LDR R2, =ADC1_BASE
    ADD R2, R2, #0x4C       /* ADC_DR Offset */
    STR R2, [R0, #DMA2_S0PAR]

    /* 4. SET MEMORY ADDRESS (RAM) */
    STR R4, [R0, #DMA2_S0M0AR]

    /* 5. SET LENGTH */
    STR R5, [R0, #DMA2_S0NDTR]

    /* 6. CONFIGURE CONTROL REGISTER (CR) */
    LDR R1, [R0, #DMA2_S0CR]

    /* Clear Channel Select (Bits 27:25) -> Channel 0 */
    BIC R1, R1, #(7<<25)
    
    /* Clear Direction (Bits 7:6) -> 00 (Peri-to-Mem) */
    BIC R1, R1, #(3<<6)

    /* Set Config Bits:
       - PSIZE = 16-bit (01) -> Bit 11
       - MSIZE = 16-bit (01) -> Bit 13
       - MINC  = 1 (Increment Mem) -> Bit 10
       - CIRC  = 1 (Circular Mode) -> Bit 8
       - PL    = High Priority (10) -> Bit 17
    */
    LDR R2, =(1<<11) | (1<<13) | (1<<10) | (1<<8) | (2<<16)
    ORR R1, R1, R2

    STR R1, [R0, #DMA2_S0CR]

    /* 7. ENABLE STREAM */
    ORR R1, R1, #1
    STR R1, [R0, #DMA2_S0CR]

    POP {R4, R5, PC}


/* ==============================================================================
   DMA1 INIT (RAM -> UART2 TX)
   Stream 6, Channel 4
   ============================================================================== */
DMA_Init:
    PUSH {R4, R5, LR}
    MOV R4, R0              /* R4 = Source Address (RAM) */
    MOV R5, R1              /* R5 = Length */

    /* 1. ENABLE DMA1 CLOCK */
    LDR R0, =RCC_BASE
    LDR R1, [R0, #RCC_AHB1ENR]
    ORR R1, R1, #(1<<21)    /* Bit 21 = DMA1EN */
    STR R1, [R0, #RCC_AHB1ENR]

    /* 2. DISABLE STREAM 6 */
    LDR R0, =DMA1_BASE
    LDR R1, [R0, #DMA1_S6CR]
    BIC R1, R1, #1
    STR R1, [R0, #DMA1_S6CR]

wait_dma1_disable:
    LDR R1, [R0, #DMA1_S6CR]
    TST R1, #1
    BNE wait_dma1_disable

    /* 3. CLEAR FLAGS (Stream 6 is in HIFCR) */
    LDR R2, =0x003F0000     /* Clear all flags for Stream 6 */
    STR R2, [R0, #DMA1_HIFCR]

    /* 4. SET PERIPHERAL ADDRESS (USART2_DR) */
    LDR R2, =USART2_BASE
    ADD R2, R2, #0x04       /* DR Offset */
    STR R2, [R0, #DMA1_S6PAR]

    /* 5. SET MEMORY ADDRESS (Source) */
    STR R4, [R0, #DMA1_S6M0AR]

    /* 6. SET LENGTH */
    STR R5, [R0, #DMA1_S6NDTR]

    /* 7. CONFIGURE CONTROL REGISTER (CR) */
    LDR R1, [R0, #DMA1_S6CR]

    /* Select Channel 4 (Bits 27:25 = 100) */
    BIC R1, R1, #(7<<25)
    ORR R1, R1, #(4<<25)

    /* Set Direction: Mem-to-Peri (01) -> Bit 6 */
    BIC R1, R1, #(3<<6)
    ORR R1, R1, #(1<<6)

    /* Set MINC (Memory Increment) -> Bit 10 */
    ORR R1, R1, #(1<<10)

    /* Disable PINC (Peripheral Increment) -> Bit 9 (Already 0 by default, but safe to clear) */
    BIC R1, R1, #(1<<9)

    STR R1, [R0, #DMA1_S6CR]

    /* 8. ENABLE STREAM */
    ORR R1, R1, #1
    STR R1, [R0, #DMA1_S6CR]

    POP {R4, R5, PC}