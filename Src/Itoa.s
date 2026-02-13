.syntax unified 
.cpu cortex-m4
.thumb

/* CRITICAL: Define this as code section */
.section .text
.global Itoa 

/* Signed integer to ASCII conversion.
 * Input : R0 = signed 32-bit integer
 *         R1 = buffer base address (>= 12 bytes)
 * Output: R0 = pointer to first character
 *         R1 = length in bytes (without terminator)
 */
Itoa:
    PUSH {R4, R5, R6, R7, LR}

    /* SETUP BUFFER POINTER AT END */
    ADD R1, R1, #11         /* Move to end of 12-byte buffer */
    MOVS R2, #0             /* Null terminator */
    STRB R2, [R1]           /* Store '\0' at end */

    MOV R5, #0              /* R5 = length counter */
    MOV R7, #0              /* R7 = sign flag (0 = positive, 1 = negative) */

    /* EDGE CASE: ZERO */
    CMP R0, #0
    BNE check_negative

    /* Handle Zero */
    MOVS R2, #48            /* ASCII '0' */
    SUB R1, R1, #1          /* Move back */
    STRB R2, [R1]           /* Store '0' */
    
    MOV R0, R1              /* Return start addr */
    MOV R1, #1              /* Return length */
    POP {R4, R5, R6, R7, PC}

check_negative:
    /* If R0 < 0, make it positive and remember the sign */
    CMP R0, #0
    BGE start_conversion

    RSB R0, R0, #0          /* R0 = -R0 (absolute value) */
    MOV R7, #1              /* Mark as negative */

start_conversion:
conversion_loop:
    /* CALCULATE REMAINDER: remainder = Num - (Num/10)*10 */
    MOV R2, #10
    UDIV R2, R0, R2         /* R2 = quotient = Num / 10 */

    MOV R3, #10
    MUL R3, R2, R3          /* R3 = quotient * 10 */

    SUB R4, R0, R3          /* R4 = remainder */

    /* STORE ASCII DIGIT */
    ADD R4, R4, #48         /* Convert to ASCII '0'..'9' */
    SUB R1, R1, #1          /* Move pointer back */
    STRB R4, [R1]           /* Store digit */

    ADD R5, R5, #1          /* length++ */

    MOV R0, R2              /* Update number = quotient */
    CMP R0, #0
    BNE conversion_loop

    /* PREPEND '-' IF NEGATIVE */
    CMP R7, #0
    BEQ finish

    SUB R1, R1, #1
    MOV R2, #45             /* '-' */
    STRB R2, [R1]
    ADD R5, R5, #1

finish:
    MOV R0, R1              /* Return start address */
    MOV R1, R5              /* Return length */

    POP {R4, R5, R6, R7, PC}