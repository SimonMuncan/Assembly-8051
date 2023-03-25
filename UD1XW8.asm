; -----------------------------------------------------------
; Microcontroller Based Systems Homework
; Author name: Muncan Simon
; Neptun code: UD1XW8
; -------------------------------------------------------------------
; Task description: 
;   "Fast" multiplication of a 16 bit unsigned integer by an exponent of 10 (1, 10, 100, 1000, 10000). 
;   The number is in the internal memory, the exponent (0..4) is an input parameter of the subroutine. 
;   Fast multiplication means that we exploit the special properties of the exponent 
;   (e.g. 10=8+2, 100=64+32+2 etc.) 
;   Using ordinary multiplication is not an acceptable solution to this task. 
;   The result should be a 32 bit unsigned integer.
;   Inputs: Multiplicand address (pointer), exponent of multiplier (value), result address (pointer)
;   Output: Result starting at the given address
; -------------------------------------------------------------------


; Definitions
; -------------------------------------------------------------------

; Address symbols for creating pointers

INPUT1_ADR  EQU 0x30
OUTPUT_ADR  EQU 0x40


; Test data for input parameters
; (Try also other values while testing your code.)

; Input 1: 1234 (Hexadecimal: 0x04D2)
INPUT1_H    EQU 0x04    ; High byte
INPUT1_L    EQU 0xd2    ; Low byte

; Input 2: 3 (Hexadecimal: 0x03)
INPUT2      EQU 0x03


; Interrupt jump table
ORG 0x0000;
    SJMP  MAIN                  ; Reset vector

; Beginning of the user program
ORG 0x0033

; -------------------------------------------------------------------
; MAIN program
; -------------------------------------------------------------------
; Purpose: Prepare the inputs and call the converter subroutines
; -------------------------------------------------------------------

MAIN:

    ; Prepare input parameters for the subroutine

    MOV R0,  #INPUT1_ADR    ; Initialize operand 1 in the internal data memory
    MOV @R0, #INPUT1_H      ; (big endian: high byte to low address)
    INC R0                  ; |
    MOV @R0, #INPUT1_L      ; |

    MOV R0, #INPUT1_ADR     ; Input parameter 1 (address of the multiplicand)
    MOV R1, #INPUT2         ; Input parameter 2 (value: exponent of 10)
    MOV R2, #OUTPUT_ADR     ; Input parameter 3 (address of output)

; Infinite loop: Call the subroutine repeatedly
LOOP:

    CALL RAPIDMUL_U16

    SJMP  LOOP

; ===================================================================           
;                           SUBROUTINE(S)
; ===================================================================           


; -------------------------------------------------------------------
; RAPIDMUL_U16
; -------------------------------------------------------------------
; Purpose: Fast Multiplication of a 16-bit unsigned integer by 
;          an exponent of 10 (0..4)
; -------------------------------------------------------------------
; INPUT(S):
;   R0 - Address of the 16-bit multiplicand (big endian)
;   R1 - Value of the exponent
;   R2 - Address of the 32-bit result (big endian)
; OUTPUT(S): 
;   Result at the given address
; MODIFIES:
;   R1, R0, R2, R7, R6, R5, R4, PSW
; -------------------------------------------------------------------

RAPIDMUL_U16:
	MOV A, R1
	MOV R7, A	;Saving exponent to the register R7
	MOV R6, A 	;Save exponent to the register R6, we need it for initializing 
	MOV A, R0	;Save input address of multiplicand
	MOV R5, A 
	MOV A, R2 	;Moving result address to the register R1
	MOV R1, A
	MOV R4, A  	;Save address of output
	MOV A, #0x00 
	MOV @R1, A   ;Saving first byte of result
	inc R1
	MOV @R1, A   ;Saving seccond byte of result
	inc R1 
	MOV A, @R0	 ;Move highest byte 
	MOV @R1, A 	 ;Save it to the third byte
	PUSH 0x30 	 ;Save input highest byte to the stack
	INC R1 
	INC R0
	MOV A, @R0 	;Move lowest byte
	MOV @R1, A  ;Saving fourth byte
	PUSH 0x31	;Save lowest byte to the stack 
	MOV R0, #0x50 ;initialize temporary address to the register r0
	
	MOV A, @R0	
	PUSH 0x50	;Move value to the stack from address 0x50
	INC R0
	MOV A, @R0
	PUSH 0x51	;Move value to the stack from address 0x51
	INC R0
	MOV A, @R0
	PUSH 0x52	;Move value to the stack from address 0x52
	INC R0
	MOV A, @R0
	PUSH 0x53	;Move value to the stack from address 0x53
	DEC R0	;Setting back address to the 0x50
	DEC R0
	DEC R0 
	
	MOV A, R7	
	DEC R1
	DEC R1
	DEC R1 
	
	JNZ CYCLE  ;check if it is an exponent zero, if its jump to the end, otherwise jump to the loop
	LJMP ZERO
	
CYCLE: ;Each cycle multiplies by 10
; Moving the original number to a temporary location at 0x50
	MOV A, @R1
	MOV @R0, A
	MOV @R1, #0x00
	INC R1
	INC R0
	MOV A, @R1
	MOV @R0, A
	MOV @R1, #0x00
	INC R1
	INC R0
	MOV A, @R1
	MOV @R0, A
	MOV @R1, #0x00
	INC R1
	INC R0
	MOV A, @R1
	MOV @R0, A
	MOV @R1, #0x00
	
	;multiply by 2
	MOV A, @R0   ;Getting the first byte
	RL A         ;Rotating left by 1
	ANL A, #0xFE ;Masking out the unwanted bit
	ADD A, @R1 	 ;Adding it to the already existing results
	MOV @R1, A	 ;Moving the result to its place
	DEC R1		 ;Taking care of carry if there is any
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A 
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A 
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A 
	INC R1
	INC R1
	
	MOV A, @R0  ;Getting the first byte
	RL A 		;Rotating left by 1
	ANL A, #0x01 ;Masking out the unwanted bits
	ADD A, @R1	 ;Adding it to the already existing results
	MOV @R1, A	 ;Moving the result into its place
	DEC R1		 ;Taking care of carry if there is any
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A 
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A 
	INC R1
	INC R1
	
	
	DEC R0    ;Second byte
	MOV A, @R0
	RL A 
	ANL A, #0xFE
	ADD A, @R1
	MOV @R1, A 
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A 
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A 
	INC R1

	MOV A, @R0
	RL A
	ANL A, #0x01
	ADD A, @R1
	MOV @R1, A
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A
	INC R1
	
	DEC R0		;Third byte
	MOV A, @R0
	RL A 
	ANL A, #0xFE
	ADD A, @R1
	MOV @R1, A 
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A
	
	MOV A, @R0
	RL A 
	ANL A, #0x01
	ADD A, @R1
	MOV @R1, A
	
	DEC R0		;Fourth byte
	MOV A, @R0
	RL A 
	ANL A, #0xFE
	ADD A, @R1
	MOV @R1, A
	
	INC R1		;Resetting R1 and R0 to 0x43 and 0x53
	INC R1
	INC R1
	INC R0
	INC R0
	INC R0
	
	
	;multiply by 8
	MOV A, @R0	;First byte
	RL A 
	RL A 
	RL A 
	ANL A, #0xF8
	ADD A, @R1
	MOV @R1, A
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A 
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A 
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A 
	INC R1
	INC R1
	INC R1
	
	MOV A, @R0
	RL A 
	RL A 
	RL A 
	ANL A, #0x07
	DEC R1
	ADD A, @R1
	MOV @R1, A
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A 
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A 
	INC R1
	INC R1
	
	
	DEC R0		;Second byte
	MOV A, @R0
	RL A 
	RL A 
	RL A 
	ANL A, #0xF8
	ADD A, @R1
	MOV @R1, A 
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A 
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A 
	INC R1

	MOV A, @R0
	RL A
	RL A 
	RL A 
	ANL A, #0x07
	ADD A, @R1
	MOV @R1, A
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A
	INC R1
	
	DEC R0		;Third byte
	MOV A, @R0
	RL A 
	RL A 
	RL A 
	ANL A, #0xF8
	ADD A, @R1
	MOV @R1, A 
	DEC R1
	MOV A, #0X00
	ADDC A, @R1
	MOV @R1, A
	
	MOV A, @R0
	RL A 
	RL A 
	RL A 
	ANL A, #0x07
	ADD A, @R1
	MOV @R1, A
	
	DEC R0		;Fourth byte
	MOV A, @R0
	RL A 
	RL A 
	RL A 
	ANL A, #0xF8
	ADD A, @R1
	MOV @R1, A
	
	DEC R7		;Decrementing exponent and if it!s zero, exiting loop, otherwise starting loop again
	MOV A, R7
	JZ ZERO
	LJMP CYCLE
ZERO:
	CLR A
	POP 0x53	;Return previous values from the stack
	POP 0x52
	POP 0x51
	POP 0x50
	POP 0x31	;Return input numbers from the stack
	POP 0x30

	MOV A, R5
	MOV R0, A	 ; Input parameter 1 (address of the multiplicand)
	MOV A, R6
	MOV R1, A    ; Input parameter 2 (value: exponent of 10)
	MOV A, R4
	MOV R2, A    ; Input parameter 3 (address of output)

	RET
	
END
	