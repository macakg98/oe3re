; OE3RE - Projekat 31 - Parsiranje tekstualnog fajla
; Matija Saljic
; Martin Cvijovic

.386
.model flat, stdcall
.stack 4096
 ExitProcess proto, dwExitCode: dword

 INCLUDE Irvine32.inc

 ; TODO: Kaze da ne vidi Irvine32.inc i njegove metode, svejedno ga izvrsava?

.data
		; variables are here
		Msg1 BYTE "IRVINE32 TEST", 13, 10, 0
.code
	main proc
		; code is here
		mov edx, OFFSET Msg1
		call WriteString
	EndLoop:
		jmp EndLoop
	invoke ExitProcess, 0
	main endp
end main

; TEST BRANCH CODE? ??