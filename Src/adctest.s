.syntax unified
.thumb
.cpu cortex-m4

.equ RCC_BASE,    0x40023800
.equ RCC_APB2ENR, 0x44
.equ ADC1_BASE,   0x40012000
.equ ADC_SMPR1,   0x0C
.equ ADC_SQR3,    0x34
.equ ADC_CR2,     0x08
.equ ADC_CCR,     0x304

.global adc_Init
.global adc_Convert

adc_Init:
    PUSH {LR}

    /* 1. ENABLE CLOCK */
    LDR R0, =RCC_BASE
    LDR R1, [R0, #RCC_APB2ENR]
    LDR R2, =(1<<8)
    ORR R1, R1, R2
    STR R1, [R0, #RCC_APB2ENR]

    /* 2. ENABLE INTERNAL SENSORS (CCR) */
    LDR R0, =ADC1_BASE
    LDR R2, =ADC_CCR 
    LDR R1, [R0, R2]
    LDR R3, =(1<<23)        /* Bit 23: Enable Temp & VREF */
    ORR R1, R1, R3
    STR R1, [R0, R2]

    /* NEW: WAKEUP DELAY (Crucial!) */
    /* Give the sensor 10us to wake up before we do anything else */
    MOV R2, #1000
Wakeup_Loop:
    SUBS R2, R2, #1
    BNE Wakeup_Loop


    /* 3. SAMPLING TIME (Channel 17 -> 480 Cycles) */
    LDR R1, [R0, #ADC_SMPR1]
    LDR R2, =(7<<21)        /* CHANGED: Channel 17 is Bits 23:21 */
    ORR R1, R1, R2
    STR R1, [R0, #ADC_SMPR1]


    /* 4. SEQUENCE (Channel 17) */
    LDR R1, [R0, #ADC_SQR3]
    MOV R2, #17             /* CHANGED: Listen to VREFINT (1.2V) */
    ORR R1, R1, R2
    STR R1, [R0, #ADC_SQR3]


    /* 5. CR2 CONFIGURATION */
    LDR R1, [R0, #ADC_CR2]

    /* A. Enable External Trigger (Rising Edge) */
    LDR R2, =(1<<28)
    ORR R1, R1, R2
    LDR R2, =(1<<29)
    BIC R1, R1, R2

    /* B. Select Timer 2 TRGO (6) */
    LDR R2, =(0xF << 24)
    BIC R1, R1, R2
    LDR R2, =(6 << 24)
    ORR R1, R1, R2

    /* C. Enable DMA & DDS */
    LDR R2, =(1<<8)
    ORR R1, R1, R2
    LDR R2, =(1<<9)
    ORR R1, R1, R2

    /* D. Enable ADC */
    LDR R2, =(1<<0)
    ORR R1, R1, R2
    
    STR R1, [R0, #ADC_CR2]

    POP {PC}


/* DISABLE MATH FOR DIAGNOSTIC
   We want to see the RAW number.
   If VREF is working, R0 should be ~1490.
*/
adc_Convert:
    BX LR   /* Just return R0 (Raw Value) immediately */
