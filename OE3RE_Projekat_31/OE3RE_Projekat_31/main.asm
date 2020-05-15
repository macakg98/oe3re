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
	fileName byte ?
	fileHandle dword ?
	textBuffer byte buffer_size DUP(?); // jedan bafer (jedno ucitavanje se smesta u ovu promenljivu)
	bytesCnt dword ? ; // koliko bajtova je procitano (broj moze biti promenljiv)
					 ; // mora da bude uvek konstantan jer se ucitava uvek isti broj promenljivih
					 ; // sluzi za bacanje greske ukoliko je fajl neispravno napisaninfoUnsuccessfulRead
	x0 byte ?
	y0 byte ?
	x1 byte ?
	y1 byte ?
	color byte ?
.data
	infoProgram1 BYTE "Matija Saljic 411/16, Martin Cvijovic 558/17",13,10,0
	infoProgram2 BYTE "Projekat 31: Parsiranje tekstualnog fajla",13,10,0
	infoInputFileName BYTE "Unesite ime datoteke (max 100 karaktera, obavezno dodati ekstenziju .txt na kraj): ",13,10,0
	infoSuccessfulOpen BYTE "Datoteka je uspesno otvorena",13,10,0
	infoUnsuccessfulOpen BYTE "Nije moguce otvoriti datoteku, izlazim...",13,10,0
	infoContent BYTE "Sadrzaj trenutne linije je: ",13,10,0 ; // za debagovanje
	infoBadLength BYTE "Velicina fajla je veca od dozvoljene! Ucitajte novi fajl! Izlazim...", 13, 10, 0
	infoUnsuccesfulRead BYTE "Greska u citanju linije iz fajla!", 13, 10, 0
	infoSuccessfulRead BYTE "Uspesno procitana linija iz fajla", 13, 10, 0
	stringEmptyLine BYTE "    ", 13, 10, 0
.code
	main proc
		; // ucitaj ime fajla
		mov edx, offset infoProgram1
		call WriteString
		mov edx, offset stringEmptyLine
		call WriteString
		mov edx, offset infoProgram2
		call WriteString
		mov edx, offset stringEmptyLine
		call WriteString
		mov edx, offset infoInputFileName
		call WriteString

		; // ucitavamo fileName, max 100 karaktera

		mov ecx, BUFFER_SIZE ; 
		mov edx, offset fileName
		call ReadString

		mov ecx, 0

		mov edx, offset fileName
		call OpenInputFile

		.IF (eax == INVALID_HANDLE_VALUE) ; // failed ucitavanje
			mov edx, offset infoUnsuccessfulOpen
			call WriteString
			jmp FORCEEXIT ; // izlazim
		.ENDIF

		mov edx, offset infoSuccessfulOpen ; // uspesno ucitavanje
		call WriteString
		
		mov fileHandle, eax ; // cuvamo filehandle iz eax-a

		; // citamo liniju po liniju
		; // format : x0 y0 x1 y1 color BYTE
		; // mnogo prostora za gresku :DDDDDDDDd

		mov edx, offset textBuffer
		mov ecx, BUFFER_SIZE  ; // max 100
		call ReadFromFile

		mov bytesCnt, eax
		jnc CHECKSIZE
		
		mov edx, offset infoUnsuccesfulRead
		call WriteString
		jmp FORCEEXIT

	CHECKSIZE:
		cmp eax, BUFFER_SIZE
		jb PARSERECTDATA ; // potprogram koji parsira liniju i zove drawRect(matijin deo)
						 ; // skacemo na njega ukoliko je procitana linija u dozvoljenim granicama
		
		mov edx, offset infoBadLength
		call WriteString
		jmp FORCEEXIT

	PARSERECTDATA:
		; // mov edx, offset infoSuccessfulRead ; // debugging
		; // call WriteString ; // debugging


		
	FORCEEXIT:
		invoke ExitProcess, 0
	main endp
end main
