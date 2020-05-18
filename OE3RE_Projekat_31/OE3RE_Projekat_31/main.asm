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
					 ; // sluzi za bacanje greske ukoliko je fajl neispravno napisan
	x0 dword ?
	y0 dword ?
	x1 dword ?
	y1 dword ?
	color dword ?

	tempByte byte ?
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
	drawRect proc
		; // matija ovde izvodis svoje magije, ako ima nesto ovde onda sam to uneo za debagovanje
		mov ebx, 10 ; // osnova u kojoj stampamo broj mora biti upisana u EBX
		mov eax, x0
		call WriteInt
		mov edx, offset stringEmptyLine
		call WriteString

		mov eax, y0
		call WriteInt
		mov edx, offset stringEmptyLine
		call WriteString
				
		mov eax, x1
		call WriteInt
		mov edx, offset stringEmptyLine
		call WriteString
					
		mov eax, y1
		call WriteInt
		mov edx, offset stringEmptyLine
		call WriteString

		mov eax, color
		call WriteInt
		mov edx, offset stringEmptyLine
		call WriteString

		ret
	drawRect endp
	
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

		mov edx, offset textBuffer
		call WriteString

		mov bytesCnt, eax
		jnc CHECKSIZE
		jz FORCEEXIT ; // kad stignemo do EOF-a zavrsavamo
		
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
		; // call WriteString ; // 
		; // ucitali smo jednu liniju, obradjujemo i zovemo opet dok ne dobijem
		
		mov eax, 0
		mov tempByte, 0

		mov ecx, 0 ; // od 0 do 4 teramo ecx
		           ; // 0 -> x0, 1 -> y0, 2 -> x1, 3 -> y1, 4 -> color (0-255)
				   ; // citamo u eax, pomocu ecx znamo gde ga store-ujemo


		mov esi, offset textBuffer

	LINELOOP:
		mov bl, [esi]
		mov tempByte, bl

		; //sub tempByte, 48

		cmp tempByte, 0
		je FORCEEXIT

		cmp tempByte, '\'
		je NEWLINE

		cmp tempByte, '0'
		jl VARCHECK
		cmp tempByte, '9'
		jg VARCHECK

		sub tempByte, 48
		imul eax, 10
		add al, tempByte

		inc esi
		jmp LINELOOP
	
	NEWLINE: ; // ?
		inc esi
		jmp VARCHECK

	VARCHECK:
		cmp ecx, 0
		je ASSIGNX0
		cmp ecx, 1
		je ASSIGNY0
		cmp ecx, 2
		je ASSIGNX1
		cmp ecx, 3
		je ASSIGNY1
		cmp ecx, 4
		je ASSIGNCOLOR 

		; // do ovde ne treba da se stigne?


	ASSIGNX0:
		mov x0, eax
		jmp NEXT
	ASSIGNY0:
		mov y0, eax
		jmp NEXT
	ASSIGNX1:
		mov x1, eax
		jmp NEXT
	ASSIGNY1:
		mov y1, eax
		jmp NEXT
	ASSIGNCOLOR:
		mov color, eax
		call drawRect

		mov ecx, 0
		mov eax, 0
		mov tempByte, 0
		inc esi
		jmp LINELOOP

	NEXT:
		inc esi
		mov eax, 0
		mov tempByte, 0
		inc ecx
		jmp LINELOOP
		; // x0 y0 x1 y1 color
		; // svi su byte = 8bit, registri su 16bitni

	FORCEEXIT:
		invoke ExitProcess, 0
	main endp
end main
