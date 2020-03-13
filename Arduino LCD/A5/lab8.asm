; written by Mr. Jason Corless in 2015
; modified by Victoria Li on October 26, 2018

.cseg
.org 0

	; set the stack pointer (we're using functions here)
	ldi r16, 0x21
	out SPH, r16
	ldi r16, 0xFF
	out SPL, r16
	
	; initialize the LCD
	call lcd_init			
	
	; clear the screen
	call lcd_clr

	call lcd_init			; call lcd_init to Initialize the LCD (line 689 in lcd.asm)
	call init_strings
	call display_strings

lp:	jmp lp

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

msg1_p:	.db "$AMD to the moon ", 0	
msg2_p: .db "Diamond Hands", 0

.dseg
;
; The program copies the strings from program memory
; into data memory.  These are the strings
; that are actually displayed on the lcd
;
msg1:	.byte 50
msg2:	.byte 50


;
; Include the HD44780 LCD Driver for ATmega2560
;
; This library has it's own .cseg, .dseg, and .def
; which is why it's included last, so it would not interfere
; with the main program design.
#define LCD_LIBONLY
.include "lcd.asm"



	cpi r17, 0
	brne skip    ;go to skip if r17 is not 0, no button were pressed

	cpi r16,0x0
	brne b_left
	
	b_right:
		cpi r17,0x33
		brsh b_up
		ldi r24, 1
		rjmp skip

	b_up:
		
		ldi r24, 2
		rjmp skip

	b_left:
		cpi r16,0x1
		brne b_down
		ldi r24,4
		rjmp skip
	b_down:
		cpi r16,0x2
		brne b_select
		ldi r24,3
		rjmp skip
	b_select:
		cpi r16,0x3
		brne skip
		ldi r24,5
		rjmp skip
