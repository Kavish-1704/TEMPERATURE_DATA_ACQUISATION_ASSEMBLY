.syntax unified
.cpu cortex-m4 
.thumb

.global main

/* ==============================================================================
   DATA SECTION
   Buffers for storing data
   ============================================================================== */
.section .data 
.align 2

Raw_Temp:
    .hword 0        /* Variable where ADC stores data via DMA2 */

String_Buf:
    .space 16       /* Buffer for ASCII string */


/* ==============================================================================
   TEXT SECTION
   Main Program Code
   ============================================================================== */
.section .text 

main:
    /* 1. INITIALIZE UART */
    /* We do this first so we can debug if needed */
    BL UART_init

    /* 2. INITIALIZE ADC */
    /* Configures the ADC logic and pin but doesn't start converting yet */
    BL adc_init

    /* 3. INITIALIZE DMA2 (ADC -> RAM) */
    /* This creates the "pipe" from ADC Data Register to Raw_Temp variable */
    /* R0 = Destination Address (Raw_Temp) */
    /* R1 = Length (1 Half-word) */
    LDR R0, =Raw_Temp
    MOV R1, #1
    BL DMA2_Init

    /* 4. INITIALIZE TIMER 2 */
    /* This starts the 100Hz "Heartbeat" that triggers the ADC */
    BL TIM2_Init


/* ==============================================================================
   MAIN LOOP
   The CPU has no job in data acquisition (Hardware handles that).
   It just processes and displays the result.
   ============================================================================== */
Loop:
    /* A. READ DATA */
    /* We just read the variable. DMA2 updates it automatically in background. */
    LDR R0, =Raw_Temp
    LDRH R0, [R0]

    /* B. CONVERT TO CELSIUS */
    /* Input: R0 (Raw), Output: R0 (Celsius) */
    BL adc_convert

    /* C. CONVERT TO STRING */
    /* Input: R0 (Value), R1 (Buffer Address) */
    /* Output: R0 (Buffer Start), R1 (Length) - Returned by Itoa */
    LDR R1, =String_Buf
    BL Itoa
    
    /* D. SEND VIA DMA1 (UART) */
    /* Input: R0 (Buffer Start), R1 (Length) - Setup by Itoa return */
    /* This function triggers the UART DMA transfer */
    BL DMA_Init

    /* Small delay to let DMA/USART pipeline settle before newline */
    MOV R4, #2000
DMA_Settle_Loop:
    SUBS R4, R4, #1
    BNE DMA_Settle_Loop

    /* E. SEND NEWLINE (Manually) */
    /* Itoa doesn't add \r\n, so we do it here for clean terminal output */
    MOV R0, #13      /* \r */
    BL UART_SendChar
    MOV R0, #10      /* \n */
    BL UART_SendChar

    /* F. DELAY */
    /* Slow down the loop so the terminal isn't flooded (approx 0.1s) */
    LDR R5, =1600000
Delay_Loop:
    SUBS R5, R5, #1
    BNE Delay_Loop

    /* G. REPEAT */
    B Loop