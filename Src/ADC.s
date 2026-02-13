.syntax unified
.thumb
.cpu cortex-m4

.equ RCC_BASE,    0x40023800
.equ RCC_APB2ENR, 0x44

.equ ADC1_BASE,   0x40012000
.equ ADC_SMPR1,   0x0C
.equ ADC_SQR3,    0x34
.equ ADC_CR2,     0x08
.equ ADC_SR,      0x00
.equ ADC_DR,      0x4C
.equ ADC_CCR,     0x304

.global adc_init
.global adc_read
.global adc_convert
.global adc_main
.global adc_start

adc_init:
    PUSH {LR}

    // 1. ENABLING THE CLOCK 
    LDR R0, =RCC_BASE
    LDR R1, [R0, #RCC_APB2ENR]
    ORR R1, R1, #(1<<8)
    STR R1, [R0, #RCC_APB2ENR]

    // 2. SET SAMPLING TIME CHANNEL 18 
    LDR R0, =ADC1_BASE
    LDR R1, [R0, #ADC_SMPR1]
    LDR R2, =(7<<24)        
    ORR R1, R1, R2
    STR R1, [R0, #ADC_SMPR1]

    // 3. SETTING THE SEQUENCE
    LDR R1, [R0, #ADC_SQR3]
    MOV R2, #18
    ORR R1, R1, R2
    STR R1, [R0, #ADC_SQR3]

    // 4. ENABLE TEMP SENSOR (CCR) 
    LDR R2, =ADC_CCR 
    LDR R1, [R0, R2]
    LDR R3, =(1<<23)         //TSVREFE 
    ORR R1, R1, R3
    STR R1, [R0, R2]

    // 5. CR2 CONFIGURATION (Triggers & DMA) 
    LDR R1, [R0, #ADC_CR2]

    // A. Enable External Trigger (EXTEN = 01 Rising Edge) 
    LDR R2, =(1<<28)
    ORR R1, R1, R2          
    LDR R2, =(1<<29)
    BIC R1, R1, R2          

    // B. Select Timer 2 TRGO (EXTSEL = 6 -> 0110) 
   
    LDR R2, =(0xF << 24)
    BIC R1, R1, R2
    LDR R2, =(6 << 24)
    ORR R1, R1, R2

    // C. Enable DMA (Bit 8) & DDS (Bit 9) 
    LDR R2, =(1<<8)
    ORR R1, R1, R2
    LDR R2, =(1<<9)
    ORR R1, R1, R2

    // D. Enable ADC  
    LDR R2, =(1<<0)
    ORR R1, R1, R2
    
    STR R1, [R0, #ADC_CR2]

    POP {PC}


  // Math: Temp = ((mV - 760) * 2 / 5) + 25   
adc_convert:
    PUSH {R4, LR}

      // Convert Raw to Millivolts   
    LDR R1, =3300
    MUL R0, R0, R1
    LDR R1, =4095
    UDIV R0, R0, R1

      // Sub V25 (760mV)   
    SUB R0, R0, #760

      // Scale by Slope (2.5 mV/C) -> * 2 / 5   
    LSL R0, R0, #1 
    MOV R1, #5
    SDIV R0, R0, R1 
      // Add 25 C  
    ADD R0, R0, #25

    POP {R4, PC}