.model small
.486
	extrn leedec:near
	extrn desdec:near
	extrn des2:near
	extrn des4:near
	extrn des1:near
	extrn lee1:near
	extrn reto:near
	extrn show:near

.stack
.data
	input db 5 dup(?)
	raiz db 5 dup(?)
	radicando db 5 dup(?)
	contanpush dw ?
	possi dw ?
	sirad dw ? 					;SI para el radicando
	siraiz dw ? 				;SI para la raiz
	dobleraiz2 db ? 			;para guardar el doble de la segunda raiz
	valorraiz dw ?
	numradicando dw ?
	numro4dig dw ?
	num2inp dw ?
	numradica dw ?
	num2residuo dw ?
	numanum1 dw ?
	numeromulti dw ?
	numresiduo db ?
	valraiz2 db ?
	num1 db ?
	num2 db ? 					;guarda el numero1 para resta
	num3 db ? 					;guarda numero 2 para resta
	numpa2raiz db ?
	rslresta db ?
	dobleraiz db ?
	numciclo db ?
	numdiv db ?
	numdec db ?
	numerador db ?
	varcon db ?
	valnum1r4d dw ?
	siresul db ?
	varx db ?
	activacero db ? 			;Variable para activar un cero
	vardec dw ?
	varmul dw ?
	resconvDeHx dw ?
	num3dig dw ?
	num2raiz dw ?
	cad1 db "Ingresa Un numero para calcular la raiz cuadrada",0dh,0ah,24h
	cad2 db "Que numero elevado al cuadrado da ",24h
	cad3 db "El cuadrado de ",24h
	cad4 db " es ",24h
	cad5 db ", se lo restamos a ",24h
	cad6 db " y obtenemos ",24h
	cad7 db "Bajamos ",24h
	cad8 db " siendo la cantidad operable del radicando: ",24h
	cad9 db "Doble de la raiz(concatenado)N X N<: ",24h
	cad10 db "Resta de el residuo-numero encontrado: ",24h
	cad11 db "Numero para la raiz: ",24h
	cad12 db "Valor de la raiz: ",24h
	cad13 db "Doble de la raiz: ",24h
	cad14 db "Buscamos Numero N<9, el numero es: ",24h
.code
main:
	mov ax,@data
	mov ds,ax
	mov es,ax

	call inicializainput 		;llenamos de 0's el arreglo
	call inicializaresul 		;Llenamos de 0's el arreglo
	call inicializaradicando 	;Llenamos de 0's el arreglo
	call leeBCD 				;Lee los datos de entrada y los guarda en el arreglo
	call reto
	call raizc2

	.exit 0
;---------------------------------------------------------------------------------------
;Funcion para leer en BCD
 leeBCD: 						;Deja datos en arreglo input
 	mov ah,09h
	mov dx,offset cad1
	int 21h

 	mov ah,0h
 	mov contanpush,0 			;variable para ver cuntos push se realizaron
 	mov si,04
 	mov cx,05
 cicloLBCD:
 	call lee1 					;primer dato en AL
 	mov bx,0
 	mov bl,al
 	cmp bl,0ddh 				;comparo si es un enter
 	je salida1 					; si es enter brinco a salida1
 	push ax 					;AX a pila parte alta (L) del arreglo
 	inc contanpush
 	loop cicloLBCD


 salida1:
 	mov cx,contanpush
 ciclopopsBCD:
 	cmp cx,0 					;Comparamos si es 0
 	je fininputBCD 				;Si es 0 salta a fininputBCD
 	mov bx,offset input
 	pop ax 						;Guardo primer extraido de la pila
 	mov [bx+si],al 				;guardamos el primer dato en input parte baja
 	dec cx
 	cmp cx,0 					;Comparamos si es 0
 	je fininputBCD 				;Si es 0 salata a fininputBCD

 	;vamos a guardar segundo dato en la parte alta del arreglo
 	mov bx,offset input
 	mov dl,[bx+si] 				;obtenemos el dato que se guardo en el arreglo
 	pop ax 						;obtenemos dato de pila. Dato en AX
 	shl al,04 					;El dato del la pila lo movemos 4 pos a la izq
 	add al,dl 					;suma de dato del arreglo y el de la pila.resultado en AL
 	mov bx,offset input
 	mov [bx+si],al 				;guardamos el dato en los 4 bytes del arreglo
 	dec si
 	dec cx
 	jmp ciclopopsBCD

 fininputBCD:
  	ret
;---------------------------------------------------------------------------------------
;Funcion para inicializar arreglo
inicializainput:
	mov si,0
	mov cx,5
 cicloinp:
	mov bx,offset input
	mov byte ptr[bx+si],0
	inc si
	loop cicloinp
	ret

inicializaresul:
	mov si,0
	mov cx,5
 cicloinpr:
	mov bx,offset raiz
	mov byte ptr[bx+si],0
	inc si
	loop cicloinpr
	ret

inicializaradicando:
	mov si,0
	mov cx,5
 cicloinpra:
	mov bx,offset radicando
	mov byte ptr[bx+si],0
	inc si
	loop cicloinpra
	ret
;---------------------------------------------------------------------------------------
;Funcion principal para calcular la raiz.
raizc2:
	mov ax,0
	mov bx,0
	mov cx,0
	mov dx,0

	mov sirad,0 				;SI del radicando
	mov siraiz,0
	mov si,0
	mov varcon,0
	call buscanum 				;obtengo la posicion del primer elemento en el arreglo
	mov dx,possi 				;SI del input
	mov si,dx 					;posicion del primer elemento del arreglo
	;call des2
	;call reto

 	mov dx,0
	mov bx,offset input
	mov dx,[bx+si]
	mov cx,dx
	mov num1,0
	mov num1,dl 				;primer par de numero de input en num1
	mov dx,0

	;Aqui imprime el mensaje "Que numero elevado al cuadrado da"
	mov ah,09h
	mov dx,offset cad2
	int 21h
	mov dh,0
	mov dl,num1
	call des2
	call reto

	cmp num1,9 					;comparamos si el numero es de 1 digito o 2
	jle brincas1 				; si es menor a 9 brincamos y es un digito
	
	mov dh,0
	mov dl,num1
	mov varcon,1
	;Convertir de decimal a hexa
	call convDeHx 				;Recibe en dX y retorna en AX el resultado q quiero esta en AL
	mov num1,al
	;fin de la conversion
 brincas1:
 	cmp varcon,1
 	je saltconv
 	mov dh,0
	mov dl,num1
 	call convDeHx
 	mov num1,al
 saltconv:
	mov byte ptr numciclo,1
 	mov al,1
 cicloc2: 						;Ciclo para encontar un numero elevado al cuadrado
 	mul numciclo
 	cmp al,num1
 	jge salida3 				;si AL es mayor o igual a num1 salta a ;salida3
 	add numciclo,1 				;si el AL es menor a num1 entonces ;calculamos el sig. cuadrado
 	mov al,numciclo
 	jmp cicloc2

 salida3:
 	cmp al,num1 				;compara AL y el valor de num1
 	jle salebien 				;si son iguales o menor salta a salebien
 	sub numciclo,1 				; si AL es mayor a num1 decrementamos numciclo
 								;NUMCICLO tiene el numero
 salebien:
 	mov al,numciclo 			;primer numero de la raiz
 	mov ah,0
 	call convHxDe 				;Recibe en Ax y retorna en Dx
 	push dx
 	mov ah,09h
	mov dx,offset cad12
	int 21h
	pop dx
 	call des2 					;desplega el valor de la raiz
 	call reto

 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad3
	int 21h
	mov dl,numciclo 			;primer numero de la raiz
 	call des2

 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad4
	int 21h

	mov dl,numciclo 			;primer numero de la raiz

 	mov si,siraiz
 	mov bx,offset raiz
 	mov [bx+si],dl 				;primer numer de la raiz al arreglo(RAIZ)

 	mov varx,dl
 	mov al,dl
 	mul dl 						;calculamos el cuadrado de la raiz. resultado en AX
 	mov num2,al 				;guardo en hexadecimal
 	mov ah,0
 	call convHxDe 				;Recibe en Ax y retorna en Dx convierto a decimal
 	call des2 					;imprimo el valor del cuadrado de la raiz

 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad5
	int 21h

	mov dh,0
 	mov dl,num1 			;Numero den hexadecimal, vamos a desplegar el numero del input
 	call desdec 			;Imprime en decimal

 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad6
	int 21h
 	
 	;call convDeHx 				;Recibe en Dx Y RETORNA en AX
 	;jmp datoenAL
 ;noconviertehex:
 	mov al,num1
 ;datoenAL:
 	sub al,num2 					;Valor de la resta en AL
 	mov rslresta,al 				;valor de la restas en la variable en HEXADECIMAL
 	mov dl,rslresta
 	mov dh,0
	call desdec 					;imprimimos el valor de la resta entre el primer par de numeros y c2 de la raiz
	call reto

	mov si,sirad
	mov bx,offset radicando
	mov [bx+si],dl 					;Agregamos el primer valor del radicando a RADICANDO

	mov ah,0
	mov al,rslresta 			;guardamos el contenido de radicando en AL
	mov numradica,ax
	;push ax 					;A pila el valor del radicando
	mov dh,0

	inc possi 					;Actualizamos el si del arreglo(input)

	cmp possi,5 				;Verificamos si hay elementos en el input
	je finTodo 					;Si no hay elementos termina el programa

	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad7
	int 21h

	mov si,possi
	mov bx,offset input
	mov dl,[bx+si] 				;En DL el siguiente par de numeros del input
	mov dh,0
	mov cx,dx 					;push dx
	call des2 					;Imprime el siguiente par de numeros que se baja
	mov ax,numradica

	cmp ax,9 					;Checamos si el radicando es de una cifra o dos
	jg mayor1 					;Si es mayor a 9 brincamos. quiere decir num 2cifras

	mov dx,cx 					;par de numeros del arreglo input
	mov ax,numradica
	cmp ax,0
	jne isc
	cmp dx,0
	je iscero 					;-------------/////////////ISCERO-------------
								;Si el radicando y lo que se bajor es cero tomamos como
								;raiz el valor de cero.

 isc: 							;Si lo que esta en el radicando es distinto de cero 
	;Imprime mensaje 			;calculamos raiz
 	mov ah,09h
	mov dx,offset cad8
	int 21h

	;Vamos a juntar un numero del radicando con el del input
	mov al,[bx+si]
	SHR al,04 					;obtenemos el valor de la izquierda del segundo par de numeros
	mov dl,al 					;Valor de la izquierda del segundo bloque en DL
	mov ax,numradica
	;pop ax 						;Recupero el valor del radicando
	shl al,04 					;movemos a la izquierda el valor del radicando
	add al,dl 					;Suma del radicando y del numero de la izq del input
	mov ah,al 					;Dato en AH

	mov dl,ah
	mov al,[bx+si]
	and al,15
	mov dl,al
	mov numradicando,ax 		;Numero de 3 digitos en
	call pega3num 				;Recibe en AX y Retorna en AX esta en DECIMAL
	mov dx,ax
	call des4
	call reto
	call convDeHx 				;Recibe en Dx Y RETORNA en AX
	mov numradicando,ax 		;Numero en HEXADECIMAL
	mov dx,numradicando
	
 integrar:
	;vamos a obtener el doble de la raiz
	mov si,0
	mov bx,offset raiz
	mov dx,[bx+si]
	mov al,2
	mul dl 						;Resultado en AX=Al*dl
	call convHxDe 				;Recibe en Ax y deja en Dx
	mov dobleraiz,dl 			;Aqui esta el doble de la raiz
	mov dl,dobleraiz
	mov dh,0
	mov dl,dobleraiz

	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad13
	int 21h

	mov dl,dobleraiz
	call des2 					;imprime el doble de la raiz
	call reto
	mov dl,dobleraiz
	mov dh,0

	cmp dl,9
	jg otrocaso 				;brinca si es de dos digitos.10,11,12...

	;Aqui vamos a obtener el segundo valor de la raiz
	mov bl,9
	mov activacero,1
	jmp unociclo
 numero2raiz:
 	mov activacero,0
 	sub bl,1
 unociclo:
 	mov al,dobleraiz
 	shl al,04
 	add al,bl 				;Aqui sumamos el bit de la izq+el num del contador ej 06+09=69
 	mov ah,0
 	mov numanum1,ax

 	mov dx,numanum1
 	;call des2 				;Imprime el valor que se unio eje. 69
 	;call reto
 	mov dl,al
 	mov dh,0
 	call convDeHx 			;Recibe en Dx Y RETORNA en AX
 	mov varmul,ax
 	mov dx,ax
 	;call des4 				;Imprime el valor 69 en hexadecimal 45h
 	;call reto

 	mov ax,varmul
 	mul bl 					;Resultado en AX=Al*Cl
 	push ax
 	mov dx,ax
 	;call des4 				;Imprime el valor de la multiplicacion 69X9=num hexa
 	;call reto
 	pop ax

 	mov numpa2raiz,bl
 	cmp ax,numradicando
 	jg numero2raiz
 	
 	push ax

 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad14
	int 21h

	mov dl,numpa2raiz
	call des2
	call reto

 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad9
	int 21h
 	mov dx,varmul
 	call desdec
 	jmp inte

 otrocaso: 					;Caso de valor del doble raiz de 2 digitos

 	mov bl,9
	mov activacero,1
	jmp unociclo1
 numero2raiz1:
 	mov activacero,0
 	sub bl,1
 unociclo1:
 	mov ah,dobleraiz
 	mov al,bl
 	shl al,04
 	shr ax,04 				;Aqui sumamos el bit de la izq+el num del contador ej 06+09=69
 	mov numanum1,ax

 	mov dx,numanum1
 	mov dx,numanum1
 	call convDeHx 			;Recibe en Dx Y RETORNA en AX
 	mov varmul,ax
 	mov dx,ax

 	mov ax,varmul
 	mul bl 					;Resultado en AX=Al*Cl
 	push ax
 	mov dx,ax
 	pop ax

 	mov numpa2raiz,bl
 	cmp ax,numradicando
 	jg numero2raiz1
 	push ax

 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad14
	int 21h

	mov dl,numpa2raiz
	call des2
	call reto

 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad9
	int 21h
 	mov dx,varmul
 	call desdec
 	jmp inte

 inte:
 	mov ah,02h
 	mov dl,"x"
 	int 21h

 	mov dl,numpa2raiz
 	call des2

 	mov ah,02h
 	mov dl,"="
 	int 21h

 	pop ax
 	push ax
 	mov dx,ax
 	call desdec
 	call reto

	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad10
	int 21h

	mov dx,numradicando
	call desdec

	mov ah,02h
 	mov dl,"-"
 	int 21h

 	pop ax
 	push ax
 	mov dx,ax
	call desdec

	mov ah,02h
 	mov dl,"="
 	int 21h

 	pop ax
 	mov cx,numradicando
 	sub cx,ax

	mov ax,cx
	push ax
	call convHxDe 			;Recibe en Ax y deja en Dx
	mov cx,dx
	mov numresiduo,cl
	pop ax
	mov dx,ax
	call desdec 			;Imprime el resultado de la resta en DECIMAL
	call reto

	jmp saltas1

 iscero:
 	call reto
 	mov cl,0
 	;Guardar el valor del resultado de la resta
	mov si,sirad 			
	mov bx,offset radicando
	mov [bx+si],cl 			;Guardo en decimal
	mov valraiz2,cl

	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad11
	int 21h

	mov dl,0
	call des1 				;Imprime el valor del segundo digito de la raiz
	call reto

	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad12
	int 21h

	;guardar el numero encontrado al arreglo de la raiz
	mov si,siraiz
	mov bx,offset raiz
	mov al,[bx+si]
	shl al,04
	add al,0
	mov [bx+si],al
	mov dl,al
	mov dh,0
	mov valorraiz,dx
	call des2 				;Imprime el valor de la raiz
	call reto
	;inc siraiz 				;Incremento del si de la raiz
	;---FIN ISCERO----------------------------------------

	jmp comun1

 saltas1:
	;Guardar el valor del resultado de la resta
	mov cl,numresiduo
	mov si,sirad 			
	mov bx,offset radicando
	mov [bx+si],cl 				;Guardo en decimal
	mov valraiz2,cl

	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad11
	int 21h

	mov dl,numpa2raiz
	call des1 				;Imprime el valor del segundo digito de la raiz
	call reto

	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad12
	int 21h

	;guardar el numero encontrado al arreglo de la raiz
	mov si,siraiz
	mov bx,offset raiz
	mov al,[bx+si]
	shl al,04
	add al,numpa2raiz
	mov [bx+si],al
	mov dl,al
	mov dh,0
	mov valorraiz,dx
	call des2 				;Imprime el valor de la raiz
	call reto
	;inc siraiz 				;Incremento del si de la raiz

 comun1:
	inc possi 				;Incrementamos el si del input	
	cmp possi,5 			;Verificamos si hay elementos en el input
	je finTodo

	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad7
	int 21h


	;Bajar el siguiente par de numeros del input
	mov si,possi
	mov bx,offset input
	mov dx,[bx+si]
	push dx
	call des2 				;Imprime el valor que se ba a bajar del input


	;Aqui vamos a comparar si el radicando y lo que se va a bajar es cero o distinto
	cmp dl,0
	je isce
	cmp valraiz2,0
	je iscero2
	jmp nocero
 isce:
 	cmp valraiz2,0
 	je iscero2

 nocero:
	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad8
	int 21h

	;Aqui vamo sa bajar el par de numeros del input y lo pegamos con el radicando
	mov si,sirad
	mov bx,offset radicando
	mov ah,[bx+si]
	pop dx
	mov al,dl
	mov numro4dig,ax 		;Numero de 4 digitos
	mov dx,ax
	call des4
	call reto
	mov dx,ax
	call convDeHx 			;Recibe en Dx Y RETORNA en AX
	mov numro4dig,ax 		;Numero de 4 digitos en HEXADECIMAL

	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad13
	int 21h

	;aqui obtenemos el doble de la raiz
	mov si,siraiz
	mov bx,offset raiz
	mov dx,[bx+si]
	call convDeHx 			;Recibe en Dx Y RETORNA en AX
	mov dx,ax
	mov al,2
	mul dx
	call convHxDe 			;Recibe en Ax y deja en Dx
	mov dobleraiz2,dl 		;El doble de la raiz esta en decimal
	call des2
	call reto

	inc sirad
	;Aqui vamos a encontrar un numero menor que el radicando
	mov bl,9
	mov bh,0
	mov numpa2raiz,0
	mov activacero,1
	jmp dosciclo
 encuentra2raiz:
	mov activacero,0
 	sub bl,1
 dosciclo:
	mov ah,dobleraiz2
	mov al,bl
	call pega3num 			;Recibe en AX y retorna en AX
	mov numeromulti,ax

	mov dx,ax
	call convDeHx 			;Recibe en Dx Y RETORNA en AX
	mov varmul,ax
	mov ax,varmul
	mul bx 					;Resultado en AX Resultado en HEXADECIMAL
	push ax

	;mov ax,dx
	;call convHxDe 			;Recibe en Ax y deja en Dx
	;call des4
	;call reto

	pop ax

 	mov numpa2raiz,bl
 	cmp ax,numro4dig
 	jg encuentra2raiz

 	push ax
 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad14
	int 21h

	mov dl,numpa2raiz
	call des2
	call reto

 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad9
	int 21h
 	mov dx,numeromulti
 	call des4 				;Imprime el valo de 588

 	mov ah,02h
 	mov dl,"x"
 	int 21h

 	mov dl,numpa2raiz
 	call des2

 	mov ah,02h
 	mov dl,"="
 	int 21h

 	pop ax
 	push ax

 	mov dx,ax
 	call desdec
 	call reto

 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad10
	int 21h

 	mov dx,numro4dig
 	call conHexaDec 			;Recibe en Dx y Retorna vardec
 	mov dx,vardec
 	mov valnum1r4d,dx
 	call des4 					;Valor para la resta

 	mov ah,02h
 	mov dl,"-"
 	int 21h

 	pop ax
 	mov dx,ax
 	push ax
 	call conHexaDec 			;Recibe en Dx y Retorna vardec
 	mov dx,vardec
 	call des4 					;Imprime el segundo valor para la resta
 	
 	mov ah,02h
 	mov dl,"="
 	int 21h

 	pop ax
 	mov cx,numro4dig
 	sub cx,ax


	mov dx,cx
	call conHexaDec 			;Recibe en Dx y Retorna vardec
	mov cx,vardec
	mov dx,vardec
	call des4 					;Imprime el resultado de la resta en DECIMAL
	call reto

	push dx

	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad11
	int 21h

	pop dx

	;Guardar el valor del resultado de la resta
	mov si,sirad 			
	mov bx,offset radicando
	mov [bx+si],dx 			;Guardo en decimal

	mov dh,0
	mov dl,numpa2raiz
	call des1 				;Imprime el valor del digito de la raiz
	call reto
	push dx

	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad12
	int 21h	
	mov dx,valorraiz
	call des2

	pop dx
	;Vamos a guaradar en el numero al arreglo raiz
	mov si,sirad
	mov bx,offset raiz
	shl dl,04
	mov [bx+si],dl
	mov dl,numpa2raiz
	call des1
	call reto

	jmp finTodo

 iscero2:
 	pop dx
 	call reto 
 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad12
	int 21h	
	mov dx,valorraiz
	call des2

	;Vamos a guaradar en el numero al arreglo raiz
	mov dl,0
	call des1
	call reto

	jmp finTodo

;---------------------------------------------------------------------------------
;En el caso que sean dos numeros en el radicando despues de hacer una resta
 mayor1:
 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad8
	int 21h

 	mov si,possi
	mov bx,offset input
	mov dx,[bx+si] 				;En DL el siguiente par de numeros del input
	mov num2inp,dx
 	mov dx,num2inp
	mov ax,numradica

	mov dl,rslresta
	mov dh,0
	call conHexaDec 			;Recibe el dato en DX y retorna en vardec
	mov ax,vardec 				;Dato en Decimal

 	mov dx,num2inp
 	mov ah,al
 	mov al,dl
	;shr ax,04 					;Desplaza todo el registro 4 bits a la izq. AX=1599 Return 0159
	mov num2residuo,ax 			;Numero de 4 digitos
	mov dx,ax
	call des4

	mov dx,num2residuo
	call convDeHx 				;Recibe en Dx Y RETORNA en AX
	mov numradicando,ax 		;Numero en HEXADECIMAL
	mov dx,numradicando

	;vamos a obtener el doble de la raiz
	mov si,0
	mov bx,offset raiz
	mov dx,[bx+si]
	mov al,2
	mul dl 					;Resultado en AX=Al*dl
	mov dl,al
	mov dh,0
	call conHexaDec 		;Recibe el dato en DX y retorna en vardec
	mov dx,vardec
	mov dobleraiz,dl 		;Aqui esta el doble de la raiz en decimal

	call reto
	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad13
	int 21h

	mov dl,dobleraiz
	call des2 				;Aqui estamos imprimiendo el valor del doble de la raiz
	

	;Aqui vamos a obtener el segundo valor de la raiz
	mov bl,9
	mov activacero,1
	jmp unociclop2
 numero2raizp2:
 	mov activacero,0
 	sub bl,1
 unociclop2:
 	cmp dobleraiz,9
 	jg mayor2num

 	mov al,dobleraiz
 	shl al,04
 	add al,bl 				;Aqui sumamos el bit de la izq+el num del contador ej 06+09=69
 	mov ah,0

 	mov dl,al
 	call des2 				;Imprime el valor que se unio eje. 69
 	call reto
 	mov dl,al
 	mov dh,0
 	call convDeHx 			;Recibe en Dx Y RETORNA en AX
 	mov varmul,ax
 	mov dx,ax
 	;call des4 				;Imprime el valor 69 en hexadecimal 45h
 	;call reto

 	mov ax,varmul
 	mul bl 					;Resultado en AX=Al*Cl
 	push ax
 	mov dx,ax
 	call des4 				;Imprime el valor de la multiplicacion 69X9=num hexa
 	call reto
 	pop ax

 	mov numpa2raiz,bl
 	cmp ax,numradicando
 	jg numero2raizp2

 	jmp comun
 mayor2num:
 	call reto 
 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad14
	int 21h

	mov dl,bl
	call des2

 	call reto
 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad9
	int 21h

 	mov ah,dobleraiz
 	mov dl,bl
 	shl dl,04 				;obtenemos el valor del contador (09=90)
 	mov al,dl
 	shr ax,04 				;aqui vamos a desplazar a la derecha (1590=0159)DECIMAL
 	mov dx,ax
 	call des4

 	call convDeHx 			;Recibe en Dx Y RETORNA en AX
 	mov varmul,ax
 	mov dx,ax

 	mov ax,varmul
 	mul bl 					;Resultado en AX=Al*Cl
 	push ax
 	pop ax

 comun:
 	mov numpa2raiz,bl
 	cmp ax,numradicando
 	jge mayor2num
 	push ax
 	mov ah,02h
 	mov dl,"x"
 	int 21h

 	mov dl,numpa2raiz
 	call des1 			;Valor del segundo numero de la raiz
 	;call reto
 	mov ah,02h
 	mov dl,"="
 	int 21h
 	pop ax
 	push ax
 	mov dx,ax
 	call desdec 				;Imprime el valor de calcular un valo menor al del radicando
 	call reto

 	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad10
	int 21h
	mov dx,numradicando
	call desdec
	mov ah,02h
 	mov dl,"-"
 	int 21h
 	pop ax
 	push ax
 	mov dx,ax
 	call desdec

 	mov ah,02h
 	mov dl,"="
 	int 21h

 	pop ax
 	mov cx,numradicando
 	sub cx,ax

	mov dx,cx
	call desdec 				;Imprime el resultado de la resta en DECIMAL
	call reto

	;Imprime mensaje
 	mov ah,09h
	mov dx,offset cad12
	int 21h



	;guardar el numero encontrado al arreglo de la raiz
	mov si,siraiz
	mov bx,offset raiz
	mov al,[bx+si]
	shl al,04
	add al,numpa2raiz
	mov [bx+si],al
	mov dl,al
	call des2 				;Imprime el valor de la raiz
	call reto


 finTodo:
 	;pop ax

	ret

;--------------------------------------------------------------------------------------
;Funcion para encontrar la pisicion en el arreglo del primer numerm que se ingreso
buscanum:
	pusha
	mov si,0

 cicloBusnum: 			;regresa la posicion del primer elemento distinto de 0 del arreglo
	mov bx,offset input
	mov dl,byte ptr[bx+si]
	cmp dl,0
	jne salida2 		;se cambio por jg
	inc si
	jmp cicloBusnum

 salida2:
 	mov possi,si
 	popa
	ret
;							FIN DE FUNCION BUSCANUM

;------------------------------------------------------------------------------------
;convierte de decimal a hexadecimal
convDeHx: 						;Recibe en dx Y RETORNA en Ax
	push dx
	push bx
	push cx
	;para obtener digitos de la parte baja(L)
	mov resconvDeHx,dx
	mov bx,resconvDeHx
	and dl,15 					;Aplico mascara para obtener el bit mas a la derecha
	;call des2
	mov al,1 					;AL=1
	mul dl 						;Resultado en AX=DL*AL
	push ax

	mov dl,bl
	shr dl,04 					;Desplazamiento a la derecha
	;call des2
	mov al,0Ah 					;AL=0A (10)
	mul dl 						;resultado en AX=DL*AL
	pop cx
	add al,cl 					;Dato en AL
	push ax

	;para obtener digitos de la parte alta(H)
	mov dl,bh
	and dl,15
	;call des2
	mov al,64h
	mul dl
	pop cx
	add ax,cx
	push ax
 	
	mov dh,0
 	mov dl,bh
	shr dl,04
	;call des2
	mov ax,3E8h
	mul dx
	pop cx
	add ax,cx

	pop cx
	pop bx
	pop dx

	;call reto
	ret 						;Retorna en AX
;-------------------------------------------------------------------------------------

;convierte de hexadecimal a decimal
convHxDe: 						;Recibe en Ax y deja en Dx
	;mov ah,0h
	AAM
	shl ah,04
	add al,ah
	mov dx,ax
	ret
;------------------------------------------------------------------------------------------------
;Funcion para pegar 3 numero. ejemplos:Recibo(3400,1209). Retornar: 0340,0129.
pega3num: 						;Va a recibir en AX y retorna en AX
	push bx
	push cx
	push dx
	mov num3dig,AX
	and ah,15 					;con esto obtengo el 4
	mov cl,al
	mov al,ah
	shl al,04
	add al,cl
	push ax
	mov ax,num3dig
	shr ah,04
	pop bx
	mov bh,ah
	mov AX,bx

	pop dx
	pop cx
	pop bx

	ret
;----------------------------------------------------------------------------------------
;convierte de hexadecimal a decimal
conHexaDec: 					;Recibe el dato en DX y retorna en vardec
	mov ax,dx
	mov bx,0Ah

	mov dx,0
	div bx
	mov vardec,dx

	cmp ax,0h
	je salidasconvdec 			;Salta si son iguales

	mov dx,0
	div bx
	mov cl,dl
	shl cl,04
	add cx,vardec
	mov vardec,cx

	cmp ax,0h
	je salidasconvdec 			;Salta si son iguales

	mov dx,0
	div bx
	mov ch,dl
	mov vardec,cx

	cmp ax,0h
	je salidasconvdec 			;Salta si son iguales

	mov dx,0
	div bx
	mov bh,ch
	mov ch,dl
	shl ch,04
	add ch,bh
	mov vardec,cx

 salidasconvdec:
	
	ret

end