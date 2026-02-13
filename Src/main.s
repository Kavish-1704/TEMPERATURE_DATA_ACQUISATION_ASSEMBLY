.syntax unified
.cpu cortex-m4 
.thumb

.global main


.equ DMA1_BASE, 0x40026000
.equ DMA1_S6CR, 0xA0

.section .data 
.align 2
Raw_Temp:   .hword 0
String_Buf: .space 16

.section .text 

main:
    BL UART_init
    BL adc_init
    
    // Setup ADC DMA   
    LDR R0, =Raw_Temp
    MOV R1, #1
    BL DMA2_Init
    
    // Start Timer Trigger   
    BL TIM2_Init

Loop:
   
    //WAIT FOR UART TO FINISH SENDING               
      
    LDR R0, =DMA1_BASE
    ADD R0, R0, #DMA1_S6CR    
Wait_DMA:
    LDR R1, [R0]
    TST R1, #1               // Check Bit 0 (EN)   
    BNE Wait_DMA             // Loop until EN becomes 0   


    //  READ DATA   
    LDR R0, =Raw_Temp
    LDRH R0, [R0]

    // CONVERT TO CELSIUS   
    BL adc_convert

    //  CONVERT TO STRING   
    LDR R1, =String_Buf
    BL Itoa
    
    //  SEND NEW PACKET VIA DMA   
    BL DMA_Init

    // SEND NEWLINE (Manual CPU Send)   
       
    MOV R0, #13
    BL UART_SendChar
    MOV R0, #10
    BL UART_SendChar

    // DELAY (Slows down the loop to prevent IDE Crash)   
    LDR R5, =2000000 
Delay_Loop:
    SUBS R5, R5, #1
    BNE Delay_Loop

    B Loop