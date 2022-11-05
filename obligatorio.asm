.data

#define DS 0

;;----------  Constantes  --------------------------------------
;;--------------------------------------------------------------

ENTRADA EQU 10
PUERTO_SALIDA_DEFECTO EQU 1
PUERTO_LOG_DEFECTO EQU 2
STACK_SIZE EQU 31

;;----------  Variables  --------------------------------------
;;-------------------------------------------------------------

stack DW DUP(STACK_SIZE) 0
tope DW 0  
puertoLog DW PUERTO_LOG_DEFECTO
puertoSalida DW PUERTO_SALIDA_DEFECTO

;;---------  Constante Auxiliar  -------------------------------
;;--------------------------------------------------------------
						
base equ stack 

.code

main:
	mov DX, [puertoLog] 
	mov AX, 0			
	out DX, AX							; Muestro el 0 en puertoLog		
	in AX, ENTRADA						; AX = codigo						
	out DX, AX							; Lo muestro en el puerto		
	
	cmp AX,1
	je NUM
	cmp AX,2
	je PORT
	cmp AX,3
	je LOG
	cmp AX,4
	je TOP
	cmp AX,5
	je DUMP
	cmp AX,6
	je DUPP
	cmp AX,7
	je SWAP
	cmp AX,8
	je OPPOSITE
	cmp AX,9
	je FACT
	cmp AX,10
	je SUM_ALL
	cmp AX,11
	je SUM_ONE
	cmp AX,12
	je SUBB
	cmp AX,13
	je MULTIPLY
	cmp AX,14
	je DIVV
	cmp AX,15
	je MOD
	cmp AX,16
	je ANDD
	cmp AX,17
	je ORR
	cmp AX,18
	je LEFTS
	cmp AX,19
	je RIGHTS
	cmp AX,254
	je CLEAR
	cmp AX,255
	je HALT
	jmp comandoInvalido


comandoInvalido:
	mov AX,2
	mov DX, [puertoLog]
	out DX, AX	
	jmp main


NUM:
	in AX, ENTRADA							; AX = parametro
	mov DX, [puertoLog]						
	out DX, AX								; Muestro en DX parametro
	mov BX,[tope]							; BX = tope
	cmp BX, 62								; tope = maxima cantidad de elementos?
	jz fullStack							
	call pushStack	
	jmp exito								; Mensaje de exito
	
	
fullStack:
	mov AX, 4
	out DX, AX								; Muestro codigo 4 asociado al desbordamiento del stack
	jmp main

exito:
	mov DX, [puertoLog]
	mov AX, 16								; Muestro codigo 16 asociado al exito en la operacion 
	out DX, AX	
	jmp main


PORT:					
	in AX, ENTRADA							; AX = parametro
	mov DX, [puertoLog]						
	out DX, AX								; Muestro en DX parametro
	mov [puertoSalida], AX					; puertoSalida = parametro
	mov AX, 16								; Muestro codigo 16 asociado al exito en la operacion
	out DX, AX 								
	jmp main

LOG:
	in AX, ENTRADA							; AX = parametro
	mov DX, [puertoLog]			
	out DX, AX								; Muestro en DX parametro
	mov [puertoLog], AX						; puertoLog = parametro
	jmp exito

TOP:
	mov DI,[tope]							; DI = tope
	cmp DI,0								; tope == 0 ?
	je faltaOperandos						; si es 0 faltan operandos 
	sub DI,2								; tope >= 1 pero el dato en byte anterior 
	mov BX, base				
	mov AX, [ BX + DI ]						; AX = stack[tope]
	mov DX, [puertoSalida]					; Muestro en puerto salida el valor cargado 
	out DX, AX	
	jmp exito
	

faltaOperandos:
	mov DX, [puertoLog]						; DX = puertoLog
	mov AX, 8	
	out DX, AX								; Muestro codigo 8 asociado a la falta de operandos en el stack
	jmp main

DUMP:
	mov DI, [tope]							; DI = tope
	mov BX, base							; BX = base stack
	mov DX, [puertoSalida]			
	jmp while_dump
		
while_dump:
	cmp DI, 0								; tope == 0 ?
	jz exito								; recorri todo stack
	sub DI, 2						
	mov AX, [ BX + DI ]						; AX = stack[tope]			
	out DX, AX								; Muestro en puertoSalida el operando
	jmp while_dump

DUPP:
	mov DX, [puertoLog]						; DX = puertoLog
	mov BX,[tope]							; BX = tope
	cmp BX,0								; tope == 0 ?
	je faltaOperandos
	sub BX,62								; tope == maxima cantidad de elementos?
	jz fullStack						
	call popStack							; BX = stack[tope]
	mov AX, BX						
	call pushStack							; push con el operando en AX
	call pushStack							; push el mismo operando ( se preserva el contexto )
	jmp exito


SWAP:
	mov DX, [puertoLog]						; DX = puertoLog
	mov BX,[tope]							; BX = tope
	cmp BX,0								; tope == 0 ?
	jz faltaOperandos
	sub BX,2								; tope == 1?
	jz eliminarUno
	call popStack							; BX = stack[tope]
	mov CX, BX								; CX = stack[tope]
	call popStack							; BX = stack[tope - 2]
	mov AX, CX 								; AX = stack[tope]
	call pushStack							; push con AX (tope)
	mov AX, BX								; AX = stack[tope - 2]
	call pushStack							; push con valor de AX (anterior al tope ahora en tope)
	jmp exito
	
	
eliminarUno:
	call popStack			
	jmp faltaOperandos


OPPOSITE:
	mov BX,[tope]							; BX = tope
	cmp BX,0
	jz faltaOperandos
	call popStack							; BX = stack[tope]		
	neg BX							
	mov AX, BX								; AX = neg stack[tope]	
	call pushStack							; push con valor de AX
	call exito

FACT:
	mov CX,[tope]			
	cmp CX, 0			
	jle faltaOperandos		
	push BX
	call popStack							; BX = stack[tope]	
	mov AX, BX						
	call factorial							; llamada al procedimiento factorial con AX = stack[tope]	
	mov AX, BX
	call pushStack							;push con AX
	jmp exito

SUM_ALL:
	mov CX,[tope]	
	xor AX, AX					
while_sum:
	cmp CX, 0								; tope == 0? termine de sumar 
	je end_sum						
	call popStack							; BX = stack[tope]
	add AX, BX								; AX = contador
	sub CX, 2
	jmp while_sum
end_sum:						
	call pushStack 							; push contador
	jmp exito

SUM_ONE:
	mov DX, [puertoLog]
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	call popStack	 						; BX = stack[tope]
	mov CX, BX 								; CX = stack[tope]
	call popStack							; BX = stack[tope - 2]
	add BX, CX								; AX = stack[tope] + stack[tope - 2]
	mov AX, BX						
	call pushStack							; push AX 
	jmp exito

SUBB:										; Misma logica 
	mov DX, [puertoLog]
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	call popStack	 
	mov CX, BX 				
	call popStack			
	sub BX, CX				
	mov AX, BX
	call pushStack			
	jmp exito

MULTIPLY: 									; Misma logica 
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	xor DX, DX				
	call popStack
	mov CX, BX				
	call popStack
	mov AX, BX				
	imul CX					
	call pushStack			
	jmp exito

DIVV:						
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	call popStack	 						; BX = stack[tope] 
	mov CX, BX 								; CX = stack[tope] divisor
	call popStack							; BX = stack[tope - 2] dividendo
	mov AX, BX								; AX = Dividendo 
	cmp AX, 0
	jl Dividendo_negativo			
	xor DX, DX			
	jmp Dividir
Dividendo_negativo:
	mov DX, 0xffff							; DX = -1
Dividir:
	idiv CX				
	call pushStack							; push con AX con el resultado 
	jmp exito

MOD:
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	call popStack							; BX = stack[tope]
	mov CX, BX 								; CX = stack[tope]
	call popStack							; BX = stack[tope - 2]
	mov AX, BX			
	cmp AX, 0
	jl modNegativo
	xor DX, DX			
	idiv CX
	mov AX, DX								;division deja el mod en DX
	call pushStack							;push con AX = MOD 
	jmp exito

modNegativo:
	mov DX, 0xffff							; DX = -1 misma idea que en div
	idiv CX
	mov AX, DX								;division deja el mod en DX
	call pushStack							;push con AX = MOD 
	jmp exito	
	
ANDD:
	mov BX,[tope]							; Misma logica anterior
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	call popStack	 
	mov CX, BX 				
	call popStack			
	and BX, CX
	mov AX, BX
	call pushStack			
	jmp exito

ORR:										;Misma logica
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	call popStack
	mov CX, BX 				
	call popStack			
	or BX, CX
	mov AX, BX
	call pushStack			
	jmp exito

LEFTS:		
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	call popStack							;BX = stack[tope]
	mov CX, BX 								; CX = BX = cantidad a shiftear
	call popStack							;BX = operando
	cmp CH, 0								; parte alta != 0 ?
	jne cargarCero
	sal BX, CL		
	mov AX, BX
	call pushStack	
	jmp exito

cargarCero:
	mov AX, 0								; Numero mayor a 16 entonces AX =  0
	call pushStack							;push con AX
	jmp exito


RIGHTS:										;Misma logica cargando -1 en operando si la cantidad es mayor a 16
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	call popStack	
	mov CX, BX 		
	call popStack	
	cmp CH, 0		
	jne cargarMenosUno
	sar BX, CL		
	mov AX, BX
	call pushStack	
	jmp exito
	

cargarMenosUno:
	mov AX, -1		
	call pushStack
	jmp exito

CLEAR:				
	mov word ptr [tope], 0				; Borrado logico dejo el tope en 0
	jmp exito	
	jmp main

HALT:									
	mov AX, 16							;Muestro mensaje de exito 
	mov DX, [puertoLog]
	out DX, AX							
endLoop:								;Loop infinito
	jmp endLoop


;;---------  Funciones Auxiliares  -----------------------------
;;--------------------------------------------------------------

pushStack proc
	push BX
	push DI						
	mov DI, [tope]	
	mov BX, base
	mov [BX + DI],AX 		; stack[tope] = AX			
	ADD DI,2
	mov [tope], DI
	pop DI
	pop BX
	ret
pushStack endp


popStack proc
	push DI
	mov DI,[tope]
	sub DI,2	
	mov [tope],DI
	mov BX, base
	mov BX, [BX+DI]			; BX = stack[tope]
	pop DI
	ret
popStack endp


factorial proc
	cmp AX, 0			
	je paso_base		
	dec AX				
	call factorial		
	inc AX
	mov CX, AX
	mul BX				
	mov BX, AX
	mov AX, CX
	jmp fin_factorial	
paso_base:
	mov BX, 1			
fin_factorial:
	ret
factorial endp

.ports
ENTRADA:1, -8, 1, 4097, 19, 4, 255

;10: 16, 1, 2, 16, 1, 2, 1, 3, 16, 4, 1, -1, 16, 4, 1, 1, 16, 4, 254, 1, 1, 1, 2, 1, 3, 1, 4, 1, 5, 1, 6, 1, 7, 1, 8, 1, 9, 1, 10, 1, 11, 1, 12, 1, 13, 1, 14, 1, 15, 1, 16, 1, 17, 1, 18, 1, 19, 1, 20, 1, 21, 1, 22, 1, 23, 1, 24, 1, 25, 1, 26, 1, 27, 1, 28, 1, 29, 1, 30, 1, 31, 16, 2, 15, 5, 255
;10: 1,1, 1,2, 1,3, 1,4, 1,5, 1,1, 1,9, 1,8, 1,-1400, 1,10, 1,11, 1,12, 1,13, 11, 4, 12, 4, 13, 4, 14, 4, 15, 4, 16, 4, 17, 4, 18, 4, 7, 4, 19, 4, 10, 4, 8, 4, 6, 5, 254, 255 
;10:1, -8, 1, 4097, 19, 4, 255
;PUERTO_ENTRADA: 11, 6, 1,1234, 7, 1,4321, 5, 12, 5, 9, 5, 1,-5, 8, 16, 1,1, 1,2, 1,3, 1,4, 1,5, 1,6, 1,7, 1,8, 1,9, 1,10, 1,11, 1,12, 1,13, 1,14, 1,15, 1,16, 1,17, 1,18, 1,19, 1,20, 1,21, 1,22, 1,23, 1,24, 1,24, 1,26, 1,27, 1,28, 1,29, 1,30, 1,31, 1,32, 1,33, 5, 255
;PUERTO_ENTRADA: 1,2,1,4,7,5,255
;PUERTO_ENTRADA: 1,1, 1,2, 1,3, 1,4,1,5,1,6,1,7,1,8,1,9,1,10,1,11,1,12,1,13,1,14,1,15,1,16,1,17,1,18,1,19,1,220,1,21,1,22,1,23,1,24,1,25,1,26,1,27,1,28,1,29,1,30,4,6,5,255

