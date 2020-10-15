#Parte 2.c Laboratorio 2 Organizacion de computadores
#Programa que divide dos numeros enteros positivos, dando el resultado con dos decimales
#Por Florencia Corvalan Lillo
.data
	################  OPERANDOS  ########################
	#Se determinan los operandos
	numerador: .word 1
	denominador: .word 7
	#####################################################

	#Se definen los textos que se utilizaran eventualmente en el programa
	texto: .asciiz "El resultado de la division es: " 
	punto: .asciiz "."
	cero: .asciiz "0"
	textoError: .asciiz "Error: el denominador no puede ser cero."
	
	#Se asignan valores doubles que se utilizaran
	decimal: .double 0.01  
	ceroDouble: .double 0.0
	
.text
	#Rutina que realiza la division entre dos numeros enteros positivos
	division: 
		#Se carga el numerador al registro $a1
		lw $a1, numerador
		
		#Se carga el donominador al registro $a2
		lw $a2, denominador
		
		#Se carga al registro $f10 0.01 que se utilizara como "unidad" para determinar la parte decimal de la division
		l.d $f10, decimal  
		#Se carga un 0.0 al registro $f0
		l.d $f0, ceroDouble 
		
		#Se limpia el registro $f14 porque necesita estar en 0.0 para la ejecucion
		add.d $f14, $f0, $f0
		
		#Se limpia el registro $v1 y $s2 ya que seran utiliazdos y necesitan estar en 0
		add $v1, $zero, $zero
		add $s2, $zero, $zero
		
		
		#Se llama a la sub rutina procedimientoDiv, donde se calculara la division
		jal procedimientoDiv
		
		#Se llama a la sub rutina imprimir para imprimir el resultado como se debe
		jal imprimir
		
		#Se llama a la sub rutnia termino que terminara la ejecucion del programa
		jal termino
	
	#Sub rutina que termina la ejecucion del programa
	termino:
		#Se termina la ejecucion del programa
		li $v0, 10
		syscall
	
	#Sub rutina que imprime el resultado 
	imprimir:
		#El resultado se encuentra en $f16
		#Se imprime el texto de salida
		li $v0, 4
		la $a0, texto
		syscall
		
		#Se pasa el resultado de la division que esta en $f16 a $f12 para poder imprimirlo y se imprime 
		li $v0, 3
		add.d $f12, $f16, $f0
		syscall
		
		#Se vuelve a donde se llamo a imprimir
		jr $ra

	
	#Sub rutina que hace posible el calculo de la division
	procedimientoDiv: 
		#Se revisa si alguno de los operandos es 0 y se determina que hacer si alguno lo es
		beq $a2, $zero, esCeroDen
		beq $a1, $zero, esCeroNum
	
		#Si el denominador es 1 el resultado es el numerador
		addi $t0, $zero, 1
		beq $t0, $a2, esElNumerador
		
		#Se compara si el numerador es menor al denominador para dejar en 0 la parte entera de la division si lo es y realizar solo los calculos necesarios
		slt $t0, $a1, $a2
		bne $t0, $zero, numeradorMenor
		
		#Se guarda el valor de $ra para poder volver despues
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		#Se limpia el registro $s1 para que no se produzcan errores
		add $s1, $zero, $zero
		
		#Se llama a la subrutina divisionLoop
		jal divisionLoop
		
		#Se restaura el valor de $ra y de $sp
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		#Se vuelve a donde se llamo a procedimientoDiv
		jr $ra
		
	#Sub rutina que determina que el resultado es cero 
	esCeroNum: 
		#Se asigna un cero a la salida ya que el numerador es 0 por lo tanto el resultado de la division es 0
		add.d $f16, $f0, $f0
		
		#Se vuelve a donde se llamo a procedimientoDiv
		jr $ra
	
	#Sub rutina que da un mensaje de error y termina la ejecucion del programa
	esCeroDen:
		#Se da un mensaje de error indicando que el denominador no puede ser 0
		li $v0, 4
		la $a0, textoError
		syscall
		
		#Se da termino a la ejecucion del programa
		jal termino
	
	#Sub rutina que determina que el resultado es igual al numerador
	esElNumerador:
		
		#Se castea el resultado de la parte entera y se deja en $f16
		mtc1.d $a1, $f16
		cvt.d.w $f16, $f16
		 
		#Se suma la parte entera con la parte decimal y se deja en $f16, $f16 = resultado final
		add.d $f16, $f16, $f14
		
		jr $ra
		
	#Sub rutina que realiza los calculos de la division mediante restas. Recibe como argumentos a $a1 y $a2
	divisionLoop: 
		#El resto queda en $a1
		#Se le resta a $a1 el valor de $a2
		sub $a1, $a1, $a2
		#Se le suma 1 al contador que lleva la cuenta de la parte entera de la division
		add $s1, $s1, 1
		#Si $a1 es mayor o igual que $a2 se sigue el ciclo, porque se le puede seguir restando a $a1
		bge $a1, $a2, divisionLoop 
		
		#Se pone el valor de $s1, es decir, el resultado (entero) de la division en $v0
		move $v0, $s1
		
		#Si el resto no es igual a 0 se va a la division del resto
		bne $a1, $zero, divisionResto
		
		#Se castea el resultado de la parte entera y se deja en $f16
		mtc1.d $v0, $f16
		cvt.d.w $f16, $f16
		 
		#Se suma la parte entera con la parte decimal (que en este caso es 0.0) y se deja en $f16, $f16 = resultado final
		add.d $f16, $f16, $f14
		
		#Se vuelve a donde se llamo a divisionLoop
		jr $ra 
	
	#Sub rutina que realiza el procedimiento cuando el numerador es menor
	numeradorMenor: 
		#Si el numerador es menor que el denominador significa que la parte entera es 0
		#Se guarda el valor de $ra y se mueve $sp 
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		#Se determina que la parte entera de la division es 0
		add $v0, $zero, $zero
		
		#Se llama a la subrutina divisionResto que calcula la parte decimal de la division
		jal divisionResto
		
		#Se restaura $ra y $sp
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		#Se vuelve a donde se llamo a procedimientoDiv
		jr $ra
	
	#Sub rutina que realiza el calculo de los decimales de la division
	divisionResto:
		#Se respaldan $ra, $a2 y $v0 porque seran utilizados en multiplicacion y se mueve $sp
		 addi $sp, $sp, -12
		 sw $ra, 0($sp)
		 sw $a2, 4($sp)
		 sw $v0, 8($sp)
		 
		 #Se asigna un 100 a uno de los operandos de la multiplicacion
		 #El otro operando se encuentra en $a1 y es el resto
		 addi $a2, $zero, 100 
		 
		 #Se llama a la subrutina multiplicacion
		 jal multiplicacion
		 
		 #El resultado de la multiplicacion se deja en $a1 para luego dividirlo y obtener la parte decimal
		 move $a1, $v0
		 #Se restaura el valor de $a2 para hacer la comparacion
		 lw $a2, 4($sp)
		 
		 lw $v0, 8($sp)
		 #Si la diferencia del resto amplificado en 100 con el denominador es menor a cero, significa que para esta implementacion
		 #el resultado de los decimales es cero y se salta a una sub rutina que determina eso
		 sub $t0, $a1, $a2
		 blt $t0, $zero, decimalesCero
		 
		 #Si la diferencia no es menor a cero se realiza la division del resto
		 #Se llama a la subrutnia que dividira el resto y obtener la parte decimal de la division
		 jal divisionRestoLoop
		 
		 #Se restauran los valores de $ra y $sp
		 lw $ra, 0($sp)
		 
		 addi $sp, $sp, 12
		 
		 #Se castea el resultado de la parte entera y se deja en $f16
		 mtc1.d $v0, $f16
		 cvt.d.w $f16, $f16
		 
		 #Se suma la parte entera con la parte decimal y se deja en $f16, $f16 = resultado final
		 add.d $f16, $f16, $f14
		 
		 #Se vuelve a donde se llamo a divisionResto o divisionLoop (en el caso de ser la parte entera distinta de cero)
		 jr $ra
	
	#Sub rutina que realiza los calculos de la division del resto para calcular los dos decimales
	divisionRestoLoop: 
		#El resto queda en $a1
		#Esta operacion es similar a la de la parte entera
		sub $a1, $a1, $a2
		add.d $f14, $f14, $f10  ################################### limpiar $f14
		bge $a1, $a2, divisionRestoLoop 
		
		#El resultado de la parte decimal esta en $f14
		
		#Se vuelve a donde se llamo a divisionRestoLoop
		jr $ra 	 
	
	#Sub rutina que determina que el resultado de los decimales es cero
	#Esto significa que para esta implementacion, en la que se piden solo 2 decimales el resultado de los decimales es cero 
	decimalesCero:
		
		#Se castea el resultado de la parte entera y se deja en $f16
		mtc1.d $v0, $f16
		cvt.d.w $f16, $f16
		 
		#Se suma la parte entera con la parte decimal y se deja en $f16, $f16 = resultado final
		add.d $f16, $f16, $f14
		
		#Se restauran los valores de $ra y $sp que se habian modificado en divisionResto
		lw $ra, 0($sp)
		lw $v0, 8($sp)
		addi $sp, $sp, 12
		
		#Se vuelve a donde se llamo a divisionResto
		jr $ra

#################################   MULTIPLICACION   ###########################################
	#Sub rutina que calcula la multiplicacion de dos numeros enteros positivos. Recibe como argumentos a $a1 y $a2
	#y retorna el resultado en $v0
	multiplicacion: 
 		#Se mueve $sp y se guarda en el stack la direccion de retorno en $ra
 		addi $sp, $sp, -4
 		sw $ra, 0($sp)
 		
 		#Si ninguno es cero, se calcula la multiplicacion
 		jal procedimientoMult
 		
 		#Se restauran los valores de $ra y $sp
 		lw $ra, 0($sp)
 		addi $sp, $sp, 4
 		
 		jr $ra
 
 	#Sub rutina que realiza el procedimiento que hace posible el calculo de la multiplicacion, recibe como argumentos $a1 y $a2	
 	procedimientoMult:
 		
 		#Se prueba si uno de los operandos es cero, si alguno es cero se va a la subrutina esCero
 		beq $a1, $zero, esCero
 		beq $a2, $zero, esCero
 		
 		#Se guarda la direccion a la siguiente instruccion de donde se llamo a procedimientoMult en el stack
 		#y se mueve el puntero al stack para darle espacio a la direccion que se va a guardar
 		addi $sp, $sp, -4
 		sw $ra, 0($sp)
 		
 		#Se llama a la sub rutina que determinara el signo del resultado de la multiplicacion y dejara los operandos listos para operar
 		jal determinarSigno
 		
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

	#Sub rutina que determina el signo del resultado de la multiplicacion
	determinarSigno: 
		#Se revisa si alguno es negativo y se salta a su correspondiente sub rutina de serlo
		blt $a1, $zero, esNegativo1
		blt $a2, $zero, esNegativo2
		
		#En $s6 se guardara el signo de la multiplicacion, si es positiva sera 0 y si es negativa sera 1
		#Se determina que el signo es positivo porque ninguno de los operandos es negativo
		add $s6, $zero, $zero
		
		#Se retorna a donde se llamo determinarSigno	
		jr $ra
	
	#Sub rutina que determina si el signo de la multiplicacion es positivo o negativo siendo el primer operando negativo
	esNegativo1:
		#Se evalua si el segundo operando tambien es negativo, de serlo salta a ambosNegativos
		blt $a2, $zero, ambosNegativos
		
		#De no serlo se determina que el signo de la multiplicacion es negativo (es decir $s6 = 1)
		addi $s6, $zero, 1
		
		#Se cambia el signo de $a1 para hacer la multiplicacion
		sub $a1, $zero, $a1
		
		#Se retorna a donde se llamo a determinarSigno
		jr $ra
	
	#Sub rutina que determina el signo de la multiplicacion cuando solo el segundo operando es negativo (resultado negativo)
	esNegativo2:
		 #Se determina que el signo de la multipliacion es negativo ( $s6 = 1 )
		 addi $s6, $zero, 1
		 
		 #Se cambia el signo de $a2 a positivo para hacer la multiplicacion
		 sub $a2, $zero, $a2
		 
		 #Se retorna a deonde se llamo a determinarSigno
		 jr $ra
	
	#Sub rutina que determina que el signo del resultado de la multiplicacion es positivo, porque ambos operandos son negativos	 
	ambosNegativos: 
		#Se determina que el signo de la multiplicacion es positivo ( $s6 = 0 )
		add $s6, $zero, $zero
		
		#Se cambian los signos de los dos operandos para hacer la multiplicacion
		sub $a1, $zero, $a1
		sub $a2, $zero, $a2
		
		#Se retorna a donde se llamo a determinarSigno
		jr $ra
		
	#Sub rutina que le aplica el signo al resultado de la multiplicacion
	aplicarSigno:
		#Si el signo es negativo, es decir, $s6 = 1, osea no es igual a cero, se salta a aplicarNegativo
		bne $s6, $zero, aplicarNegativo
		
		#Si $s6 es igual a cero, es decir, es positivo el resultado, se retorna a donde se llamo aplicarSigno ya que
		#no hay que cambiarle el signo al resultado
		jr $ra

	#Sub rutina que le aplica signo negativo al resultado de la multiplicacion
	aplicarNegativo: 
		#Se cambia el signo del resultado
		sub $v0, $zero, $v0
		
		#Se retorna a donde se llamo a aplicarSigno
		jr $ra
