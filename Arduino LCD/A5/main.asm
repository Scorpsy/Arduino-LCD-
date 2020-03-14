;
; A5.asm
;
; Created: 3/12/2020 2:14:26 PM
; Author : matthewarinanta
;

;
;	Things "Finished":
;			Determine which button pressed
;			Display message, basic stuff
;
;
;
;	Things left to do:
;			Display button count
;			Change message to other lines
;
;
;





.cseg
.org 0

;Fixed Variables

.def button_c	= r20
.def msg_c		= r21




;Initializations
	; set the stack pointer (we're using functions here)
	ldi r16, 0x21
	out SPH, r16
	ldi r16, 0xFF
	out SPL, r16
	clr r16
	
	; initialize the LCD
	call lcd_init		
	call init_strings	
	
	; clear the screen
	call lcd_clr

	; initialize built-in Analog to Digital Converter
	; initialize the Analog to Digital converter
	ldi r16, 0x87
	sts ADCSRA, r16
	ldi r16, 0x40
	sts ADMUX, r16

	ldi r16,0
	sts BUTTON_CU, r16
	sts BUTTON_P, r16

	clr r16
	clr r24

main_loop:
	call check_button
	cpi r24,0
	breq main_loop

checker:
	lds r1,BUTTON_CU
	lds r2, BUTTON_P
	cp r1,r2
	breq main_loop

	clr r16
	clr r17

	inc button_c
	call button_ini


	rjmp main_loop

done: jmp done


;Button Initializing function

button_ini:

	cpi r24,1
	breq n_right

	cpi r24,2
	breq n_up

	cpi r24,3
	breq n_down

	cpi r24,4
	breq n_left

	cpi r24,5
	breq n_select

	rjmp gon

	n_right:
		nop

		;ldi r16,1
		sts BUTTON_P, r24
		clr r24

		rjmp gon

	n_up:
		inc msg_c
		call display_strings

		sts BUTTON_P, r24
		clr r24

		rjmp gon

	n_down:
		dec msg_c
		call lcd_clr

		sts BUTTON_P, r24
		clr r24


		rjmp gon

	n_left:
		

		;call display_strings

		sts BUTTON_P, r24
		clr r24


		rjmp gon

	n_select:
		;call display_strings
		;call delay_h

		;call display_strings
		;call delay_h

		sts BUTTON_P, r24
		clr r24

		rjmp gon

gon: 
		ret



;Button Checking Function

check_button:
	; start a2d conversion
	lds r16, ADCSRA	  ; get the current value of SDRA
	ori r16, 0x40     ; set the ADSC bit to 1 to initiate conversion
	sts ADCSRA, r16

	; wait for A2D conversion to complete
wait:
	
	lds r16, ADCSRA
	andi r16, 0x40     ; see if conversion is over by checking ADSC bit
	brne wait          ; ADSC will be reset to 0 is finished

	; read the value available as 10 bits in ADCH0:ADCL
	lds r16, ADCL  ;0x0
	lds r17, ADCH  ;0x0 [32]

	ldi r18, low(0x3E9) 
	ldi r19, high(0x3E9)
	cp r16, r18
	cpc r17,r19
	brsh skip

	
	b_right:
		ldi r18, low(0x032);
		ldi r19, high(0x032)
		cp r16, r18
		cpc r17,r19

		brsh b_up

		ldi r24, 1
		sts BUTTON_CU, r24

		rjmp skip

	b_up:
		ldi r18, low(0x0C3)
		ldi r19, high(0x0C3)
		cp r16, r18
		cpc r17,r19

		brsh b_down

		ldi r24, 2
		sts BUTTON_CU, r24

		rjmp skip
	
	b_down:
		ldi r18, low(0x17C)
		ldi r19, high(0x17C)
		cp r16, r18
		cpc r17,r19

		brsh b_left

		ldi r24,3
		sts BUTTON_CU, r24

		rjmp skip

	b_left:
		ldi r18, low(0x22B)
		ldi r19, high(0x22B)
		cp r16, r18
		cpc r17,r19

		brsh b_select

		ldi r24,4
		sts BUTTON_CU, r24

		rjmp skip
	
	b_select:
		ldi r18, low(0x316)
		ldi r19, high(0x316)
		cp r16, r18
		cpc r17,r19

		brsh skip

		ldi r24,5
		sts BUTTON_CU, r24

skip:	
		ret




; copy two strings: msg1_p from program memory to msg1 in data memory and
;                   msg2_p from program memory to msg2 in data memory
; subroutine str_init is defined in lcd.asm at line 893
init_strings:
	push r16
	; copy strings from program memory to data memory
	ldi r16, high(msg1)		; address of the destination string in data memory
	push r16
	ldi r16, low(msg1)
	push r16
	ldi r16, high(msg1_p << 1) ; address the source string in program memory
	push r16
	ldi r16, low(msg1_p << 1)
	push r16
	call str_init			; copy from program to data
	pop r16					; remove the parameters from the stack
	pop r16
	pop r16
	pop r16

	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	ldi r16, high(msg2_p << 1)
	push r16
	ldi r16, low(msg2_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16

	pop r16
	ret

display_strings:

	; This subroutine sets the position the next
	; character will be on the lcd
	;
	; The first parameter pushed on the stack is the Y (row) position
	; 
	; The second parameter pushed on the stack is the X (column) position
	; 
	; This call moves the cursor to the top left corner (ie. 0,0)
	; subroutines used are defined in lcd.asm in the following lines:
	; The string to be displayed must be stored in the data memory
	; - lcd_clr at line 661
	; - lcd_gotoxy at line 589
	; - lcd_puts at line 538
	push r16

	call lcd_clr

	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the first line
	ldi r16, high(msg1)
	push r16
	ldi r16, low(msg1)
	push r16
	call lcd_puts
	pop r16
	pop r16

	; Now move the cursor to the second line (ie. 0,1)
	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the second line
	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	call lcd_puts
	pop r16
	pop r16

	pop r16
	ret

;
; delay functions
;

; delay for 0.5 secs
delay_h:
	push r18
	push r19
	push r20
	
	; Nested delay loop
	ldi  r18, 0x29
    ldi  r19, 0x96
    ldi  r20, 0x80

L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1

	ret

; delay for 1 secs
delay_s:
	push r18
	push r19
	push r20
	; Nested delay loop
	ldi  r18, 0x52
    ldi  r19, 0x2B
    ldi  r20, 0x00
L2: dec  r20
    brne L2
    dec  r19
    brne L2
    dec  r18
    brne L2
	ret


;Strings will be used
start_S	: .db "*******************", 0
msg1_p	:	.db "(o-_-o) (o-_-o)", 0	
msg2_p	: .db "$AMD to the moon ", 0
msg3_p	:	.db " ", 0	
msg4_p	: .db " ", 0

.dseg
;
; The program copies the strings from program memory
; into data memory.  These are the strings
; that are actually displayed on the lcd
;
msg1:	.byte 50
msg2:	.byte 50

.equ msg_length = 19

line1: .byte 19
line2: .byte 19
line3: .byte 19
line4: .byte 19

BUTTON_CU :.byte 1
BUTTON_P :.byte 1

;
; Include the HD44780 LCD Driver for ATmega2560
;
; This library has it's own .cseg, .dseg, and .def
; which is why it's included last, so it would not interfere
; with the main program design.
#define LCD_LIBONLY
.include "lcd.asm"
