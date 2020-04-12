; OE3RE - Projekat 31 - Parsiranje tekstualnog fajla
; Matija Saljic
; Martin Cvijovic

.386
.model flat, stdcall
.stack 4096
 ExitProcess proto, dwExitCode: dword

 INCLUDE Irvine32.inc

 ; // maksimalna velicina jednog bafera u B
 BUFFER_SIZE = 100 

.data?
	fileName BYTE ?
	fileHandle dword ?
	textBuffer byte buffer_size DUP(?); // jedan bafer (jedno ucitavanje se smesta u ovu promenljivu)
	bytesCnt dword ? ; // koliko bajtova je procitano (broj moze biti promenljiv)
					 ; // mora da bude uvek konstantan jer se ucitava uvek isti broj promenljivih
					 ; // sluzi za bacanje greske ukoliko je fajl neispravno napisan
.data
	infoProgram1 BYTE "Matija Saljic 411/16, Martin Cvijovic 558/17",13,10,0
	infoProgram2 BYTE "Projekat 31: Parsiranje tekstualnog fajla",13,10,0
	infoInputFileName BYTE "Unesite ime datoteke: ",13,10,0
	infoSuccessfulRead BYTE "Datoteka je uspesno otvorena",13,10,0
	infoUnsuccessfulRead BYTE "Nije moguce otvoriti datoteku",13,10,0
	infoContent BYTE "Sadrzaj trenutne linije je: ",13,10,0 ; // za debagovanje
.code
	main proc
		; // ucitaj ime fajla
		mov edx, offset infoProgram1
		call WriteString
		mov edx, offset infoProgram2
		call WriteString
		mov edx, offset infoInputFileName
		call WriteString

	READFILENAME:
		call ReadString
		jnc READSUCCESSFILENAME
		jmp READFILENAME
	
	READSUCCESSFILENAME:
		mov fileName, al
		mov edx, offset fileName
		call WriteString

	invoke ExitProcess, 0

	ENDPOINT:
	main endp
end main
