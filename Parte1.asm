#Parte 1 laboratorio 2 organización de computadores
#Programa que determina cual de dos numeros enteros ingresados por consola es el maximo
#Por Florencia Corvalan Lillo
.data
	#Se determinan los textos que seran impresos como datos 
	pedirPrimero: .asciiz "Por favor ingrese el primer entero: "
	pedirSegundo: .asciiz "Por favor ingrese el segundo entero: "
	resultado: .asciiz "El maximo es: "
	iguales: .asciiz "Los numeros son iguales."
.text
	
	#Rutina que realiza el procedimiento del calculo del maximo entre dos numeros enteros que se piden por consola
	main: 
		#Se carga el primer texto y se muestra por consola
		li $v0, 4
		la $a0, pedirPrimero
		syscall
	
		#Se lee el primer entero desde la consola y se guarda en $a1
		li $v0, 5
		syscall
		move $a1, $v0
	
		#Se carga el segundo texto y se muestra por consola
		li $v0, 4
		la $a0, pedirSegundo
		syscall
	
		#Se lee el segundo entero desde la consola y se guarda en $a2
		li $v0, 5
		syscall
		move $a2, $v0
		
		beq $a1, $a2, sonIguales
		
		#Se llama al procedimiento que calcula el maximo
		jal calculoMaximo
		
		#Se pasa el resultado desde $v0 a $a2 para guardarlo
		move $a3, $v0
		
		#Se imprime el texto de resultado
		li $v0, 4
		la $a0, resultado
		syscall
		
		#Se mueve el resultado, que esta en $a3, a $a0 para imprimirlo
		move $a0, $a3
		#Se imprime el resultado
		li $v0, 1
		syscall
		
		j termino
	
	
	#Sub rutina que determina cual de los numeros ingresado es el maximo
	calculoMaximo:
		#Se hace la comparacion $a1 < $a2
		slt $t0, $a1, $a2
		#Se carga un 1 al registro $t1 para hacer la comparacion con beq
		addi $t1, $zero, 1
		#Si $t0 es igual a $t1 = 1, el numero mayor es el que esta en $a2 y se pasa al procedimiento que determina eso
		beq $t0, $t1, segundo
		#Si $t0 es distinto de 1 se determina que el resultado, osea la salida del procedimiento es el numero en $a1
		move $v0, $a1
		
		#Se vuelve a donde se llamo el procedimiento
		jr $ra
	
	#Sub rutina que informa que los numeros son iguales
	sonIguales: 
		#Se carga el mensaje de que son iguales y se imprime por consola
		li $v0, 4
		la $a0, iguales
		syscall
		
		#Se llama al procedimiento termino para terminar la ejecucion del programa
		jal termino
		
	#Sub rutina que determina que el numero maximo es el segundo numero ingresado	
	segundo: 
		#Se pasa el resultado de $a2 al registro de salida de un procedimiento $v0
		move $v0, $a2
		
		#Se vuelve a donde se llamo a calculoMaximo
		jr $ra
	
	#Sub rutina que da termino al programa
	termino:
		#Se da termino al programa
		li $v0, 10
		syscall	
		
