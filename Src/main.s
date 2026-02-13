.syntax unified
.cpu cortex-m4 
.thumb

.global main

.section .text 

main:
    /* 1. UART INIT ONLY */
    BL UART_init

    /* 2. PRINT TEST */
    MOV R0, #'A'
    BL UART_SendChar
    MOV R0, #'L'
    BL UART_SendChar
    MOV R0, #'I'
    BL UART_SendChar
    MOV R0, #'V'
    BL UART_SendChar
    MOV R0, #'E'
    BL UART_SendChar
    
    /* 3. NEWLINE */
    MOV R0, #13
    BL UART_SendChar
    MOV R0, #10
    BL UART_SendChar

    /* 4. INFINITE LOOP (Blinky logic could go here) */
Loop:
    B Loop
