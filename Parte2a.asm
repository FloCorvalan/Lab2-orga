#Parte 2.a Laboratorio 2 Organizacion de computadores
#Programa que realiza una multiplicacion entre dos numeros enteros
#Por Florencia Corvalan Lillo 
.data
 	texto: .asciiz "El resultado de la multiplicacion es: "
 	
 	#Se definen los operandos
 	operando1: .word 7
 	operando2: .word 10
 .text
 	#Rutina que calcula la multiplicacion entre dos numeros enteros 
 	multiplicacion: 
 		
 		#Se carga el operando 1 a $a1
 		lw $a1, operando1
 	
 		#Se carga el operando 2 a $a2
 		lw $a2, operando2
 		
 		
 		#Si ninguno es cero, se calcula la multiplicacion
 		jal procedimientoMult
 		
 		#Se guarda el resultado almacenado en $v0 en $t0
 		move $t0, $v0
 		
 		#Se imprime el texto de resultado
 		li $v0, 4
 		la $a0, texto
 		syscall
 		
 		#Se mueve el resultado almacenado a $a0 para imprimirlo y se imprime por consola
 		move $a0, $t0
 		li $v0, 1
 		syscall
 		
 		#Se termina la ejecucion del programa
 		li $v0, 10
 		syscall
 
 	#Sub rutina que realiza el procedimiento que hace posible el calculo de la multiplicacion, recibe como argumentos $a1 y $a2	
 	procedimientoMult:
 		
 		#Se prueba si uno de los operandos es cero, si alguno es cero se va a la subrutina esCero
 		beq $a1, $zero, esCero
 		beq $a2, $zero, esCero
 		
 		addi $sp, $sp, -4
 		sw $ra, 0($sp)
 		
 		jal determinarSigno
 		
 		#lw $ra, 0($sp)
 		#addi $sp, $sp, 4
 		
 		#Se guarda la direccion a la siguiente instruccion de donde se llamo a procedimientoMult en el stack
 		#y se mueve el puntero al stack para darle espacio a la direccion que se va a guardar
 		#addi $sp, $sp, -4
 		#sw $ra, 0($sp)
 		
 		#Se revisara que el numero mayor este en $a1, de no estar ahi, se intercambiaran los valores, esto es para que sea mas rapido el calculo
 		jal mayor
 		
 		#Se limpia el registro $s0 que sera el acumulador de las sumas, del resultado
 		add $s0, $zero, $zero
 		
 		#Se llama a la sub rutina multiplicacionLoop
 		jal multiplicacionLoop
 		
 		jal aplicarSigno
 		
 		#Se devuelve el valor a $ra de la direccion a la siguiente instruccion de donde se llamo a procedimientoMult
 		lw $ra, 0($sp)
 		#Se restaura el puntero al stack
 		addi $sp, $sp, 4
 		
 		#Se retorna a donde se llamo a procedimientoMult
 		jr $ra
 	
 	#Sub rutina que determina que el operando mayor este en el registro $a1, comprobando e intercambiandolos de ser necesario
 	mayor:
 		#Se revisa si $a1 es mayor que $a2, ya que el numero mayor debe estar en el registro $a1 para que se haga la multiplicacion en menos sumas
 		slt $t0, $a2, $a1
 		beq $t0, $zero, cambiar 

 		#Se retorna hacia donde se llamo a mayor
 		jr $ra
 	
 	#Sub rutina que intercambia los operandos, recibe como argumentos a $a1 y $a2
 	cambiar: 
 		#Si $a1 es menor que $a2 se intercambian los valores 
 		add $t0, $zero, $a1
 		add $a1, $zero, $a2
 		add $a2, $zero, $t0
 		
 		#Se retorna hacia donde se llamo a mayor
 		jr $ra	
 		
 	#Sub rutina que realiza los calculos de la multiplicacion, mediante sumas
 	multiplicacionLoop:
 		#Se le resta uno al segundo operando
 		subi $a2, $a2, 1 
 		#Se le suma a un acumulador el primer operando 
 		add $s0, $s0, $a1    #  $s0 es el acumulador
 		#Si el segundo operando no es igual a 0, se sigue el ciclo
 		bne $a2, $zero, multiplicacionLoop
 		#Si el segundo operando es igual a 0 se mueve el resultado a la variable de retorno $v0
 		move $v0, $s0 	
 		
 		#Se vuelve a donde se llamo el procedimiento
 		jr $ra
 	
 	#Sub rutina que determina que el resultado es cero
 	esCero:
 		#Se determina que el resultado es cero
 		add $v0, $zero, $zero
 		
 		#Se vuelve a donde se llamo a procedimientoMult (a la siguiente instruccion)
 		jr $ra

	determinarSigno: 
		#Se revisa si alguno es negativo y se salta a su correspondiente sub rutina de serlo
		blt $a1, $zero, esNegativo1
		blt $a2, $zero, esNegativo2
		
		#En $s6 se guardara el signo de la multiplicacion, si es positiva sera 0 y si es negativa sera 1
		#Se determina que el signo es positivo porque ninguno de los operandos es negativo
		add $s6, $zero, $zero
		
		#Se retorna a donde se llamo determinarSigno	
		jr $ra
		
	esNegativo1:
		#Se evalua si el segundo operando tambien es negativo, de serlo salta a ambosNegativos
		blt $a2, $zero, ambosNegativos
		
		#De no serlo se determina que el signo de la multiplicacion es negativo (es decir $s6 = 1)
		addi $s6, $zero, 1
		
		#Se cambia el signo de $a1 para hacer la multiplicacion
		sub $a1, $zero, $a1
		
		#Se retorna a donde se llamo a determinarSigno
		jr $ra
	
	esNegativo2:
		 #Se determina que el signo de la multipliacion es negativo ( $s6 = 1 )
		 addi $s6, $zero, 1
		 
		 #Se cambia el signo de $a2 a positivo para hacer la multiplicacion
		 sub $a2, $zero, $a2
		 
		 #Se retorna a deonde se llamo a determinarSigno
		 jr $ra
		 
	ambosNegativos: 
		#Se determina que el signo de la multiplicacion es positivo ( $s6 = 0 )
		add $s6, $zero, $zero
		
		#Se cambian los signos de los dos operandos para hacer la multiplicacion
		sub $a1, $zero, $a1
		sub $a2, $zero, $a2
		
		#Se retorna a donde se llamo a determinarSigno
		jr $ra
		
	aplicarSigno:
		#Si el signo es negativo, es decir, $s6 = 1, osea no es igual a cero, se salta a aplicarNegativo
		bne $s6, $zero, aplicarNegativo
		
		#Si $s6 es igual a cero, es decir, es positivo el resultado, se retorna a donde se llamo aplicarSigno ya que
		#no hay que cambiarle el signo al resultado
		jr $ra

	aplicarNegativo: 
		#Se cambia el signo del resultado
		sub $v0, $zero, $v0
		
		#Se retorna a donde se llamo a aplicarSigno
		jr $ra
		
