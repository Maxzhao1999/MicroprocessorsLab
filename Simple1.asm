	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message,LCD_delay_ms	    ; external LCD subroutines
	extern	LCD_Write_Hex			    ; external LCD subroutines
	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	extern  convert_to_decimal, dec_0, dec_2, cpr1h, cpr1l, cpr2h, cpr2l, f_count, thresh, thresl
	extern	Timer_Setup, loopsh, loopsl,fcounterl, fcounterh, CM_Setup
	global  calc
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine
frequencyl  res 1
frequencyh  res 1
bufferfreqh res 1
bufferfreql res 1
tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
;myTable data	    "Hello World!\n"	; message, plus carriage return
;	constant    myTable_l=.13	; length of data
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	call	ADC_Setup	; setup ADC
	call	Timer_Setup
	call	CM_Setup
	movlw	0x0
	movwf	loopsh
	movwf	loopsl
	goto	start
	
	; ******* Main programme ****************************************
start 	
;	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
;	movlw	upper(myTable)	; address of data in PM
;	movwf	TBLPTRU		; load upper bits to TBLPTRU
;	movlw	high(myTable)	; address of data in PM
;	movwf	TBLPTRH		; load high byte to TBLPTRH
;	movlw	low(myTable)	; address of data in PM
;	movwf	TBLPTRL		; load low byte to TBLPTRL
;	movlw	myTable_l	; bytes to read
;	movwf 	counter		; our counter register
;loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
;	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
;	decfsz	counter		; count down to zero
;	bra	loop		; keep going until finished
;		
;	movlw	myTable_l-1	; output message to LCD (leave out "\n")
;	lfsr	FSR2, myArray
;	call	LCD_Write_Message

;	movlw	myTable_l	; output message to UART
;	lfsr	FSR2, myArray
;	call	UART_Transmit_Message
	
measure_loop
;	movf	fcounterh, W
;	cpfseq	bufferfreqh
;	bra	compare
;	movf	fcounterl, W
;	cpfsgt	bufferfreql
;	bra	usebuffer
;	bra	usecurrent
;	
;compare
;	cpfsgt	bufferfreqh
;	bra	usebuffer
;	bra	usecurrent
;usebuffer	
;	movf	bufferfreqh, W
;	movwf	fcounterh
;	movf	bufferfreql, W
;	movwf	fcounterl
;	bra	display
;usecurrent
;	movwf	bufferfreqh
;	movf	fcounterl, W
;	movwf	bufferfreql
;	
;	bra	display
display
	call	convert_to_decimal
	movf	dec_2, W, ACCESS
	call	LCD_Write_Hex
	movf	dec_0, W, ACCESS
	call	LCD_Write_Hex
	bra	measure_loop
;	movlw	0x0B
;	movwf	thresh
;	movlw	0xFF
;	movwf	thresl
;	call	compare
;	movlw	0x7A
;	cpfsgt	loopsh
;	bra	measure_loop		; goto current line in code
;	goto	calc
;carry
;	movlw	0x0
;	addwfc	frequencyh, 1
;	clrf	frequencyl
;	return
;	
;calc
;	movlw	0x02
;	subwf	f_count
;	movlw	0x01
;	addwf	frequencyl
;	bc	carry
;	movlw	0x02
;	cpfsgt	f_count
;	goto	display
;	goto	calc
;display
;	call	convert_to_decimal
;	movlw	0xFF
;	call	LCD_delay_ms
;	movf	fcounter,W
;	call	LCD_Write_Hex
;	movf	fcounter,W
;	call	LCD_Write_Hex
;	calc
calc
;	movlw	0x02
;	subwf	fcounter
;	movlw	0x01
;	addwf	frequencyl
;	bc	carry
;	movlw	0x02
;	cpfsgt	fcounter
;	bra	display
;	bra	calc



;	movf	dec_0, W, ACCESS
;	call	LCD_Write_Hex
;	call	delay
	return
;carry
;	movlw	0x0
;	addwfc	frequencyh, 1
;	clrf	frequencyl
;	return
	
	
;	clrf	fcounter
	

	; a delay subroutine if you need one, times around loop in delay_count
;delay	decfsz	delay_count	; decrement until zero
;	bra delay
;	return

delay
	movlw	0x0F
	movwf	0x09, ACCESS
dloop	call	delayx
	decfsz	0x09, f, ACCESS
	bra	dloop
	return	FAST
	
delayx
	movlw	0xFF
	movwf	0x10, ACCESS
dloopx	call	delayy
	decfsz	0x10, f, ACCESS
	bra	dloopx
	return
	
delayy
	movlw	0xF
	movwf	0x11, ACCESS
dloopy
	decfsz	0x11, f, ACCESS
	bra	dloopy
	return
	end