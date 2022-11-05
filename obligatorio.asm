.data
#define DS 100h
;;----------Constantes------------------------------------------
;;--------------------------------------------------------------

PUERTO_ENTRADA EQU 10
PUERTO_SALIDA_DEFECTO EQU 1
PUERTO_LOG_DEFECTO EQU 2
STACK_SIZE EQU 31

;;----------Variables------------------------------------------
;;--------------------------------------------------------------

stack DW DUP(STACK_SIZE) 0
tope dw 0  
						
base equ stack 

puertoLog dw PUERTO_LOG_DEFECTO
puertoSalida dw PUERTO_SALIDA_DEFECTO

.code

main:
	mov dx, [puertoLog]
	mov ax, 0
	out dx, ax					
	in ax, PUERTO_ENTRADA									
	out dx, ax					
	
	cmp ax,1
	je NUM
	cmp ax,2
	je PORT
	cmp ax,3
	je LOG
	cmp ax,4
	je TOP
	cmp ax,5
	je DUMP
	cmp ax,6
	je DUPP
	cmp ax,7
	je SWAP
	cmp ax,8
	je OPPOSITE
	cmp ax,9
	je FACT
	cmp ax,10
	je SUM_ALL
	cmp ax,11
	je SUM_ONE
	cmp ax,12
	je SUBB
	cmp ax,13
	je MULTIPLY
	cmp ax,14
	je DIVV
	cmp ax,15
	je MOD
	cmp ax,16
	je ANDD
	cmp ax,17
	je ORR
	cmp ax,18
	je LEFTS
	cmp ax,19
	je RIGHTS
	cmp ax,254
	je CLEAR
	cmp ax,255
	je HALT
	jmp comandoInvalido


comandoInvalido:
	mov ax,2
	mov dx, [puertoLog]
	out dx, ax	
	jmp main


NUM:
	in ax, PUERTO_ENTRADA							; leo parametro
	mov dx, [puertoLog]						;
	out dx, ax	
	mov BX,[tope]							; out en bitacora del parametro leido
	cmp BX, 62	; if (tope == stack_size)
	jz fullStack						
	call pushStack	
	jmp exito						; se agrega el parametro al stack
	
	
fullStack:
	mov ax, 4
	out dx, ax								; out 4 : desbordamiento de la pila
	jmp main

exito:
	mov dx, [puertoLog]
	mov ax, 16
	out dx, ax	
	jmp main


PORT:					
	in ax, PUERTO_ENTRADA				; parametro = IN(ENTRADA)
	mov dx, [puertoLog]			; dx = puertoLog
	out dx, ax					; out en bitacora del parametro leido
	mov [puertoSalida], ax		; puertoSalida = parametro
	mov ax, 16		; ax = 16
	out dx, ax 					; out 16 : proceso exitoso
	jmp main


LOG:
						; preservo valores de registros
	in ax, PUERTO_ENTRADA				; parametro = IN(ENTRADA)
	mov dx, [puertoLog]			; dx = puertoLog
	out dx, ax					; out en bitacora del parametro leido
	mov [puertoLog], ax			; puertoLog = parametro
	;mov ax, CODIGO_EXITO		; ax = 16
	;mov dx, [puertoLog] 		; dx = nuevo puerto log
	;out dx, ax 					; out 16 : proceso exitoso
	;jmp main
	jmp exito

TOP:
	mov DI,[tope]
	cmp DI,0
	je faltaOperandos
	sub DI,2
	mov bx, base
	mov ax, [bx+di]					; ax = stack[tope]
	mov dx, [puertoSalida]			; dx = puertoSalida
	out dx, ax	
	jmp exito
	

faltaOperandos:
	mov dx, [puertoLog]				; dx = puertoLog
	mov ax, 8	
	out dx, ax						; out 8 : falta de operandos en la pila
	jmp main


DUMP:
	mov di, [tope]
	mov bx, base
	mov dx, [puertoSalida]	
	jmp while_dump
		
while_dump:
	cmp di, 0
	jz exito						
	sub di, 2	
	mov ax, [bx+di]					
	out dx, ax						
	jmp while_dump

DUPP:

	mov dx, [puertoLog]	
	mov BX,[tope]
	cmp BX,0
	je faltaOperandos
	sub BX,62
	jz fullStack					
	;cmp word ptr [tope], DOBLE_STACK_SIZE	; if (tope == stack_size)
	;je pila_llena_dup
	;cmp word ptr [tope], 0					; if (tope == 0)
	;je pila_vacia_dup	
	call popStack							; bx = stack[tope]
;TODO CHANGE POP TO AX 	
	mov ax, bx								; ax = bx
	call pushStack							; push(ax)
	call pushStack							; push(ax)
	;mov ax, CODIGO_EXITO
	;out dx, ax								; out 16 : proceso exitoso
	;jmp fin_dup
	jmp exito


SWAP:
	mov dx, [puertoLog]
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
;TODO: CHANGE BX TO AX 
	call popStack
	mov cx, bx			; cx = valor que habia en el tope del stack
	call popStack		; bx = valor que habia debajo del tope en el stack
	mov ax, cx 
	call pushStack		; push(cx) = push(tope)
	mov ax, bx
	call pushStack		; push(bx) = push(topeMenosUno)
	jmp exito
	
	
eliminarUno:

	call popStack			
	jmp faltaOperandos


OPPOSITE:
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	call popStack					
	neg bx							
	mov ax, bx						
	call pushStack					
	call exito		
FACT:
	mov CX,[tope]			
	cmp CX, 0			
	jle faltaOperandos
	push bx
	call popStack			
	mov ax, bx				
	call factorial			
	mov ax, bx
	call pushStack			
	jmp exito


SUM_ALL:
	mov CX,[tope]
;TODO CHANGE AX TO BX BECAUSE POP WILL RETURN IN AX
	xor ax, ax					
while_sum:
	cmp CX, 0
	je end_sum					
	call popStack				
	add ax, bx					
	sub CX,2
	jmp while_sum
end_sum:						
	call pushStack
	jmp exito

SUM_ONE:
	mov dx, [puertoLog]
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	
call popStack	 
	mov cx, bx 				
	call popStack			
	add bx, cx				
	mov ax, bx
	call pushStack			
	jmp exito


SUBB:
mov dx, [puertoLog]
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	call popStack	 
	mov cx, bx 				
	call popStack			
	sub bx, cx				
	mov ax, bx
	call pushStack			
	jmp exito

MULTIPLY:
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	xor dx, dx				
	call popStack
	mov cx, bx				
	call popStack
	mov ax, bx				
	imul cx					
	call pushStack			
	jmp exito


DIVV:
mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	call popStack	 
	mov cx, bx 				
	call popStack			
	mov ax, bx					
	cmp ax, 0
	jl dividendo_negativo
	xor dx, dx			
	jmp dividir
dividendo_negativo:
	mov dx, 0xffff		
dividir:
	idiv cx				
	call pushStack		
	jmp exito


MOD:
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	call popStack
	mov cx, bx 			
	call popStack	
	mov ax, bx			
	cmp ax, 0
	jl modNegativo
	xor dx, dx			
	idiv cx
	mov ax, dx
	call pushStack		
	jmp exito

modNegativo:
	mov dx, 0xffff			
	idiv cx
	mov ax, dx
	call pushStack		
	jmp exito	
	

ANDD:
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	call popStack	 
	mov cx, bx 				
	call popStack			
	and bx, cx
	mov ax, bx
	call pushStack			
	jmp exito

ORR:
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	call popStack
	mov cx, bx 				
	call popStack			
	or bx, cx
	mov ax, bx
	call pushStack			
	jmp exito

LEFTS:		
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	call popStack	
	mov cx, bx 		
	call popStack	
	cmp ch, 0		
	jne cargarCero
	sal bx, cl		
	mov ax, bx
	call pushStack	
	jmp exito

cargarCero:
	mov ax, 0		
	call pushStack
	jmp exito

	


RIGHTS:		
	mov BX,[tope]
	cmp BX,0
	jz faltaOperandos
	sub BX,2
	jz eliminarUno
	call popStack	
	mov cx, bx 		
	call popStack	
	cmp ch, 0		
	jne cargarMenosUno
	sar bx, cl		
	mov ax, bx
	call pushStack	
	jmp exito
	

cargarMenosUno:
	mov ax, -1		
	call pushStack
	jmp exito

CLEAR:				
	mov word ptr [tope], 0				; tope = 0 (borrado logico)
	jmp exito	
	jmp main

HALT:
	mov ax, 16
	mov dx, [puertoLog]
	out dx, ax							
endLoop:
	jmp endLoop



pushStack proc
	push BX
	push DI						
	mov DI, [tope]	
	mov BX, base
	mov [BX + DI],AX 				
	ADD DI,2
	mov [tope], DI
	pop DI
	pop BX
	ret
pushStack endp

; retorna el resultado en el registro BX
popStack proc
	push DI
	mov DI,[tope]
	sub DI,2	
	mov [tope],DI
	mov BX, base
	mov BX, [BX+DI]			; bx = stack[tope]
	pop DI
	ret
popStack endp


factorial proc
	cmp ax, 0			; n==0 ?
	je paso_base		; return 1
	dec ax				; n' = n-1
	call factorial		; ax = factorial(n')
	inc ax
	mov cx, ax
	mul bx				; dx::ax = ax * bx
	mov bx, ax
	mov ax, cx
	jmp fin_factorial	; return n * factorial(n')
paso_base:
	mov bx, 1			
fin_factorial:
	ret
factorial endp

.ports
10:1, -8, 1, 4097, 19, 4, 255

;10: 16, 1, 2, 16, 1, 2, 1, 3, 16, 4, 1, -1, 16, 4, 1, 1, 16, 4, 254, 1, 1, 1, 2, 1, 3, 1, 4, 1, 5, 1, 6, 1, 7, 1, 8, 1, 9, 1, 10, 1, 11, 1, 12, 1, 13, 1, 14, 1, 15, 1, 16, 1, 17, 1, 18, 1, 19, 1, 20, 1, 21, 1, 22, 1, 23, 1, 24, 1, 25, 1, 26, 1, 27, 1, 28, 1, 29, 1, 30, 1, 31, 16, 2, 15, 5, 255

;10: 1,1, 1,2, 1,3, 1,4, 1,5, 1,1, 1,9, 1,8, 1,-1400, 1,10, 1,11, 1,12, 1,13, 11, 4, 12, 4, 13, 4, 14, 4, 15, 4, 16, 4, 17, 4, 18, 4, 7, 4, 19, 4, 10, 4, 8, 4, 6, 5, 254, 255 
;10:1, -8, 1, 4097, 19, 4, 255


 ;PUERTO_ENTRADA: 11, 6, 1,1234, 7, 1,4321, 5, 12, 5, 9, 5, 1,-5, 8, 16, 1,1, 1,2, 1,3, 1,4, 1,5, 1,6, 1,7, 1,8, 1,9, 1,10, 1,11, 1,12, 1,13, 1,14, 1,15, 1,16, 1,17, 1,18, 1,19, 1,20, 1,21, 1,22, 1,23, 1,24, 1,24, 1,26, 1,27, 1,28, 1,29, 1,30, 1,31, 1,32, 1,33, 5, 255



;PUERTO_ENTRADA: 1,2,1,4,7,5,255
;PUERTO_ENTRADA: 1,1, 1,2, 1,3, 1,4,1,5,1,6,1,7,1,8,1,9,1,10,1,11,1,12,1,13,1,14,1,15,1,16,1,17,1,18,1,19,1,220,1,21,1,22,1,23,1,24,1,25,1,26,1,27,1,28,1,29,1,30,4,6,5,255


