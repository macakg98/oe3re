; OE3RE - Projekat 31 - Parsiranje tekstualnog fajla
; Matija Saljic
; Martin Cvijovic

.386
.model flat, stdcall
.stack 4096
 ExitProcess proto, dwExitCode: dword
.data
		; variables are here
.code
	main proc
		; code is here

	invoke ExitProcess, 0
	main endp
end main

; TEST BRANCH CODE? ??