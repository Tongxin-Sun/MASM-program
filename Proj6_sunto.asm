TITLE Low-level I/O Procedures     (Proj6_sunto.asm)

; Author: Tongxin Sun
; Last Modified: 06/09/2023
; OSU email address: sunto@oregonstate.edu
; Course number/section:   CS271 Section 1
; Project Number:  6               Due Date: 06/11/2023
; Description: This program prompts the user to enter a certain number of signed 
;			   integers from the keyboard, then displays all the entered integers
;			   in a list. Finally, it displays the sum and truncated average of 
;			   these integers.

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Prompts the user with input requirement, and gets the user's keyboard input into 
; memory.
;
; Preconditions: byteCount is type BYTE.
;
; Postconditions: registers EAX, ECX, EDI, and EDX are restored.
;
; Receives:
; prompt	 = prompt address
; buffer     = buffer address
; bufferSize = buffer size
; byteCount  = byteCount address
; lineNumber = current line number
;
; returns: 
; byteCount  = user entered string size address
; buffer     = user entered string address
; ---------------------------------------------------------------------------------
mGetString MACRO prompt:REQ, buffer: REQ, bufferSize: REQ, byteCount: REQ, lineNumber: REQ
	; preserves registers
	PUSH    EAX
	PUSH    ECX
	PUSH    EDX
	PUSH    EDI

	; display the lineNumber
	PUSH    OFFSET strContainer
	PUSH    lineNumber
	CALL    WriteVal

	; displays prompt
	MOV		EDX, prompt
	CALL    WriteString

	; gets the user¡¯s keyboard input into a memory location
	MOV     EDX, buffer
	MOV     ECX, bufferSize
	CALL    ReadString

	; reads the number of bytes entered to the byteCount variable.
	CLD
	MOV     EDI, byteCount
	STOSB

	; restores registers
	POP		EDI
	POP     EDX
	POP	    ECX
	POP	    EAX

ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Print the string which is stored in a specified memory location.
;
; Preconditions: 
; string is type BYTE.
; the string can be converted to a valid signed integer no larger than 32-bit SDWORD.
; string is 0-terminated.
;
; Postconditions: registers EDX is restored.
;
; Receives:
; stringAdd = address of the string
;
; returns: 
; The content of the string will be displayed to the console.
; ---------------------------------------------------------------------------------
mDisplayString MACRO stringAdd:REQ
	PUSH    EDX
	MOV     EDX, stringAdd
	CALL    WriteString
	POP     EDX
	
ENDM

NUMBER_OF_VALUES = 10

.data

titlePrompt         BYTE    "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 13, 10
					BYTE    "Written by: Tongxin Sun", 13, 10, 0
programIntro1       BYTE    "Please provide ", 0
programIntro2       BYTE    " signed decimal integers.", 13, 10
					BYTE    "Each number needs to be small enough to fit inside a 32 bit register. ", 13, 10
					BYTE    "After you have finished inputting the raw numbers I will display a list ", 13, 10
					BYTE    "of the integers, their sum, and their average value.", 13, 10, 13, 10
					BYTE	"**EC1: Number each line of user input and display a running subtotal of ", 13, 10
					BYTE    "the user¡¯s valid numbers. These displays must use WriteVal.", 13, 10, 13, 10, 0
inputPrompt			BYTE	" Please enter a signed number: ", 0
strContainer		BYTE	50 DUP(?)
inputBufferSize		DWORD   SIZEOF strContainer
inputCharCount		DWORD   ?
outputInteger		SDWORD  ?
signedIntegers		SDWORD  NUMBER_OF_VALUES DUP(?)
invalidMessage		BYTE    "ERROR: You did not enter a signed number or your number was too big.", 13, 10, 13, 10, 0
emptySpace          BYTE    ", ", 0
displayPrompt       BYTE    "You entered the following numbers: ", 13, 10, 0
sumPrompt           BYTE    "The sum of these numbers is: ", 0
averagePrompt       BYTE    "The truncated average is: ", 0
sum                 SDWORD  0
goodbyeMessage		BYTE	13, 10, "Thanks for playing!", 13, 10, 0
lineCount			SDWORD  0
subtotalPrompt      BYTE    "The current subtotal is: ", 0

.code
main PROC
; -------------------------------------------------------
; Displays the program title, author, and introduction.
; -------------------------------------------------------
	; program introduction
	MOV     EDX, OFFSET titlePrompt
	CALL    WriteString
	CALL    Crlf
	MOV     EDX, OFFSET programIntro1
	CALL    WriteString

	PUSH    OFFSET strContainer
	PUSH    NUMBER_OF_VALUES
	CALL    WriteVal

	MOV     EDX, OFFSET programIntro2
	CALL    WriteString

; -------------------------------------------------------
; Prompts the user for the number of integers specified by
; NUMBER_OF_VALUES. 
; Validates the entered integers and displays a running 
; subtotal after the user entered each valid integer.
; -------------------------------------------------------
	; initializes ECX to be NUMBER_OF_VALUES.
	MOV     ECX, NUMBER_OF_VALUES

	; EDI points to the array where we will store all the 
	; inputs (i.e., signedIntegers).
	CLD
	MOV     EDI, OFFSET signedIntegers

	; iteratively read integers from the user and store 
	; them into signedIntegers.
_enterNumber:

	; for each valid integer entered, increment lineCount
	INC		lineCount

	; parameters passed and call the RealVal procedure
	PUSH    lineCount
	PUSH    OFFSET invalidMessage
	PUSH    OFFSET outputInteger
	PUSH    OFFSET inputPrompt
	PUSH    OFFSET strContainer
	PUSH    inputBufferSize
	PUSH    OFFSET inputCharCount
	CALL	ReadVal

	; outputInteger holds the signed integer converted 
	; from its ascii representation by the RealVal 
	; procedure
	; stores this 32-bit value into signedIntegers array
	MOV     EAX, outputInteger
	STOSD

	; calculates and displays the running subtotal
	ADD     sum, EAX
	MOV     EDX, OFFSET subtotalPrompt
	CALL    WriteString

	PUSH    OFFSET strContainer
	PUSH    sum
	CALL    WriteVal
	CALL    Crlf
	CALL    Crlf

	; prompts the user to enter the next integer until 
	; all the numbers have been entered
	LOOP    _enterNumber

; -------------------------------------------------------
; Displays all the valid integers that the user has entered.
; -------------------------------------------------------
	CALL    Crlf
	MOV     EDX, OFFSET displayPrompt
	CALL    WriteString

	; iteratively display each value in signedIntegers
	MOV     ECX, LENGTHOF signedIntegers

	; ESI points to the integer to be displayed
	CLD
	MOV     ESI, OFFSET signedIntegers

_displayIntegers:

	LODSD

	; calls the WriteVal procedure to convert each integer 
	; back into ASCII representation, and displays them
	PUSH    OFFSET strContainer
	PUSH    EAX
	CALL    WriteVal

	; if the current number displayed is the last integer,
	; we don't want to print a separating sign (', '). 
	; So we jump to _finishDisplayIntegers
	CMP     ECX, 1
	JE      _displaySum

	; otherwise, writes a ", " to separate each number
	MOV     EDX, OFFSET emptySpace
	CALL    WriteString
	LOOP    _displayIntegers

; -------------------------------------------------------
; Displays the sum of entered integers.
; -------------------------------------------------------
_displaySum:

	CALL    Crlf
	MOV     EDX, OFFSET sumPrompt
	CALL    WriteString

	PUSH    OFFSET strContainer
	PUSH    sum
	CALL    WriteVal

; -------------------------------------------------------
; Displays the average of entered integers.
; -------------------------------------------------------
	; calculate average
	MOV		EAX, sum
	MOV		EBX, NUMBER_OF_VALUES
	CDQ
	IDIV	EBX
	
	; display truncated average
	CALL    Crlf
	MOV		EDX, OFFSET averagePrompt
	CALL	WriteString

	PUSH    OFFSET strContainer
	PUSH    EAX
	CALL    WriteVal

; -------------------------------------------------------
; Displays a goodbye message to the user and exit the program
; -------------------------------------------------------
	; farewell 
	CALL	Crlf
	MOV		EDX, OFFSET goodbyeMessage
	CALL	WriteString
	CALL	Crlf

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Reads one input from the user, validates the input and stores the integer in memory.
;
; Preconditions: 
; byteCount, buffer size are type DWORD
; buffer length is at least 12.
;
; Postconditions: registers EBP, ESI, EDI, EAX, EBX, ECX, EDX are restored.
;
; Receives: 
; [EBP + 8]  = address of byteCount
; [EBP + 12] = buffer size
; [EBP + 16] = address of buffer
; [EBP + 20] = address of prompt
; [EBP + 24] = address of output 
; [EBP + 28] = address of invalidPrompt
; [EBP + 32] = lineNumber
;
; Returns: 
; The signed integer that the user entered will be stored in the addres of output.
; ---------------------------------------------------------------------------------

ReadVal PROC
	
	LOCAL	counter:DWORD
	LOCAL   inputInteger:SDWORD

	PUSH	ESI
	PUSH	EDI
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX

_readData:
	; uses the mGetString macro to get an input from the user
	mGetString [EBP + 20], [EBP + 16], [EBP + 12], [EBP + 8], [EBP + 32]

	; sets ECX to the number of characters entered
	MOV     ESI, [EBP + 8]
	CLD
	LODSD
	MOV     counter, EAX
	MOV     ECX, counter

	; initializes inputInteger to 0
	MOV     inputInteger, 0

	; ESI points to buffer
	MOV     ESI, [EBP + 16] 

	; determines if the input integer is positive or negative
	CLD
	LODSB
	CMP     AL, 45
	JE      _negativeInteger

_positiveInteger:

	; if the first character is the plus sign ('+'), reads the next character.
	; otherwise, continue to the positiveIntegerLoop
	CMP     AL, 43
	JNE     _positiveIntegerLoop
	LODSB
	DEC		ECX

_positiveIntegerLoop:
	; validates if the input integer is in the range [48, 57]
	CMP     AL, 48
	JL      _invalidInput
	CMP     AL, 57
	JG      _invalidInput

	; if positive integer, uses the algorithm inputInteger = 10 * inputInteger + (AL - 48)
	; to calculate inputInteger iteratively.
	SUB		AL, 48
	MOVZX   EBX, AL
	MOV     EAX, 10
	IMUL    inputInteger

	; if overflow, then the number is too large.
	JO      _invalidInput
	MOV     inputInteger, EAX
	ADD     inputInteger, EBX
	JO      _invalidInput

	CLD     
	LODSB
	LOOP    _positiveIntegerLoop
	JMP     _output

_negativeInteger:
	DEC		ECX
_negativeIntegerLoop:

	; if negative integer, reads the next character
	CLD
	LODSB

	; validates if the input integer is in the range [48, 57]
	CMP     AL, 48
	JL      _invalidInput
	CMP     AL, 57
	JG      _invalidInput

	; uses the algorithm inputInteger = 10 * inputInteger - (AL - 48)
	; to calculate inputInteger iteratively.
	SUB     AL, 48
	MOVSX   EBX, AL
	MOV     EAX, 10
	IMUL    inputInteger
	JO      _invalidInput
	MOV     inputInteger, EAX
	SUB     inputInteger, EBX
	JO      _invalidInput
	LOOP    _negativeIntegerLoop

_output:

	; after evaluation, if the inputInteger is not too large, output 
	; the integer to output
	MOV     EDI, [EBP + 24]
	MOV     EAX, inputInteger
	CLD
	STOSD
	JMP     _finish

	; if the input is invalid, prompts the user an error message and 
	; lets the user enter again.
_invalidInput:
	MOV     EDX, [EBP + 28]
	CALL    WriteString
	JMP     _readData

_finish:
	POP	    EDX
	POP  	ECX
	POP 	EBX
	POP 	EAX
	POP 	EDI
	POP 	ESI
	RET     28

ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Convert a numeric SDWORD value (input parameter, by value) to a string of ASCII digits.
; Invoke the mDisplayString macro to print the ASCII representation of the SDWORD value 
; to the console.
;
; Preconditions: 
; integer is type SDWORD
; strOutput is type BYTE and has a length no less than 12
;
; Postconditions: registers EAX, EBX, ECX, EDX, EBP and EDI are restored.
;
; Receives: 
; [EBP + 8]  = integer
; [EBP + 12] = address of strOutput
;
; Returns: the integer will be printed to the console.
; ---------------------------------------------------------------------------------
WriteVal PROC

	PUSH	EBP
	MOV		EBP, ESP

	PUSH    EAX
	PUSH    ECX
	PUSH    EBX
	PUSH    EDX
	PUSH    EDI
	
	; initializes EAX to be the integer that we want to convert
	MOV     EAX, [EBP + 8]

	; initializes ECX
	MOV		ECX, 0

_integerToString:

	; increment ECX after reaching each character
	INC		ECX

	; iteratively divides the integer by 10 to get the remainder
	CDQ
	MOV     EBX, 10
	IDIV    EBX

	; when the quotient = 0, stop the loop and jumpt to finish
	CMP     EAX, 0
	JE      _finish

	; when the quotient < 0, the integer is negative, jumpt to _negativeInteger
	; to continue the loop
	JL      _negativeInteger

	; otherwise, the integer is positive, continue the loop
	; find its ASCII representation and push to stack
	ADD     EDX, 48
	PUSH    EDX
	JMP     _integerToString

_negativeInteger:
	; if negative integer, we need to negate the remainder 
	NEG     EDX

	; then, find its ASCII representation and push to stack
	ADD     EDX, 48
	PUSH    EDX
	JMP     _integerToString

	; when quotient is 0, we need to finish converting and push
	; the remainder to the stack
_finish:
	; if the remainder < 0, jumpt to _negativeFinish 
	CMP     EDX, 0
	JL      _negativeFinish

	; otherwise, convert the final remainder to the ASCII 
	; representation to push to stack
	ADD     EDX, 48
	PUSH    EDX
	JMP     _storeString

_negativeFinish:
	; if the remainder is negative, we need to negate it before
	; pushing it to the stack
	NEG     EDX
	ADD     EDX, 48
	PUSH    EDX

	; finally, push a minus sign ('-') to the stack
	PUSH    45
	INC     ECX

	; pop ASCII values iteratively
_storeString:
	; EDI points to the strOutput
	MOV     EDI, [EBP + 12]
	CLD
_storeStringLoop:
	POP     EAX
	STOSB
	LOOP    _storeStringLoop

	; finally put a terminating 0 at the end
	MOV     AL, 0
	STOSB

	; print the ASCII representation of the SDWORD value to the console
	mDisplayString [EBP + 12]

	POP     EDI
	POP     EDX
	POP     EBX
	POP     ECX
	POP     EAX

	POP		EBP
	RET     8

WriteVal ENDP
END main


