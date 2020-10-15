#Parte 3.1 Laboratorio 2 Organizacion de computadores
#Programa que aproxima la funcion seno mediante serie de Taylor, da el resultado con dos decimales
#Por Florencia Corvalan Lillo
.data
	#Se definen los textos que se utilizaran en el programa
	texto: .asciiz "Ingrese el numero del cual quiere calcular el seno: "
	resultado: .asciiz "El resultado es: "
	textoError: .asciiz "Error: el denominador no puede ser cero."
	punto: .asciiz "."
	cero: .asciiz "0"
	menos: .asciiz "-"
	#Se asignan valores doubles que se utilizaran
	decimal: .double 0.01  
	ceroDouble: .double 0.0
	
	#Se determina el orden de la serie de Taylor que debe ser un numero entero entre 0 y 5, ya que el factorial solo funciona hasta
	#el 12, y en esta serie se utiliza hasta el factorial de 2n + 1, donde n llega al orden determinado
	orden: .word 5

.text
	#Rutina que realiza la aproximacion de la funcion seno a traves de su serie de Taylor
	# (sumatoria de ((-1)elevado n ) x Xelevado(2n + 1) / (2n + 1)!, con n desde 0 hasta el valor de del orden)
	aproximacionSeno:
		
		#Se escribe el texto para pedir el numero
		li $v0, 4
		la $a0, texto
		syscall
		
		#Se pide el numero por consola
		li $v0, 5
		syscall
		
		#El numero estara en $a0 (el numero del cual se quiere calcular el seno)  $a0 = X
		move $a0, $v0
		
		#Se carga el orden de la serie de Taylor en $s2 = hasta el numero que llegara n
		lw $s2, orden
		
		#Se utilizara un contador para los sumandos de la seire que sera $s7 ($s7 = n)
		add $s7, $zero, $zero
		
		#Se carga al registro $f10 0.01 que se utilizara como "unidad" para determinar la parte decimal de la division
		l.d $f10, decimal  
		#Se carga un 0.0 al registro $f0
		l.d $f0, ceroDouble 
		
		#Se limpia $f14 y $f18 porque necesita estar en 0.0 para la ejecucion
		add.d $f14, $f0, $f0
		add.d $f18, $f0, $f0
		
		#Se llama a la sub rutina calcularSeno para hacer el calculo
		jal calcularSeno
		
		#El resultado de la aproximacion queda en $f18
		
		#Se llama a la sub rutina imprimir para imprimir los resultados
		jal imprimir
		
		#Se llama a la sub rutina termino para terminar la ejecucion del programa
		jal termino
	
	#Sub rutina que imprime el resultado 
	imprimir: 
		#Se imprime el texto de resultado
		li $v0, 4
		la $a0, resultado
		syscall
		
		#Se pasa el resultado que esta en $f18 a $f12 para poder imprimirlo
		add.d $f12, $f0, $f18
		
		#Se imprime el resultado
		li $v0, 3
		syscall
		
		#Se retorna a donde se llamo a imprimir
		jr $ra
	
	
	#Sub rutina que realiza el procedimiento necesario para aproximar la funcion seno a traves de la 
	#sumatoria de ((-1)elevado n ) x Xelevado(2n + 1) / (2n + 1)!, con n desde 0 hasta el valor de $s7 (el orden)
	calcularSeno:
		
		#Se mueve $sp y se guarda la direccion de retorno a donde se llamo a calcularSeno porque se llamaran otras subrutinas en esta subrutina
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		#Se calcula (2n + 1) y se guarda en $a1
		#Se calcula 2n
		#Se asignan los valores a los operandos
		add $a1, $zero, $s7 # $a1 = n
		addi $a2, $zero, 2  # $a2 = 2
		
		jal multiplicacion  # $a1 x $a2 = n x 2
		#Se deja el resultado que esta en $v0 en $a1
		move $a1, $v0
		
		#se le suma 1 a 2n y se deja en $a1
		addi $a1, $a1, 1  # $a1 = 2n + 1
		
		#Se restauran los valores
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		######################################################
		#Se calcula la potencia del numero del que se quiere calcular el seno Xelvado(2n + 1)
		
		#Se guardan en el stack los valores de $a1 y $ra
		addi $sp, $sp, -8
		sw $a1, 0($sp)
		sw $ra, 4($sp)
		
		#Se asignan los numeros a los operandos
		add $a2, $zero, $a1   #Se asgina el exponente que sera el numero anteriormente calculado (2n + 1)
		add $a1, $zero, $a0   #Se asigna la base que sera el numero ingresado X
		# $a2 = (2n + 1) = exponente
		# $a1 = X = base
		jal potencia
		#El resultado de la potencia queda en $v0
		#El resultado se acumula en $a2, es decir, $a2 = Xelevado(2n + 1)
		move $a2, $v0
		
		#Se restaura el valor de $a1 y de $ra
		lw $a1, 0($sp)
		lw $ra, 4($sp)
		addi $sp, $sp, 8
		############################################################
		#Se calcula el factorial de (2n + 1)
		addi $sp, $sp, -12
		sw $a1, 0($sp)
		sw $a2, 4($sp)
		sw $ra, 8($sp)
		
		#Se asigna el numero del que se quiere calcular el factorial que esta en $a1
		add $a3, $zero, $a1
		# $a3 = (2n + 1)
		jal factorial
		#El resultado esta en $v0, es decir, $v0 = (2n + 1)!
		lw $a1, 0($sp)
		lw $a2, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp, 12
		#############################################################
		
		#Se calcula la division de (Xelevado(2n+ 1))/(2n + 1)!
		
		addi $sp, $sp, -8
		sw $s2, 0($sp)
		sw $ra, 4($sp)
		#Se asignan los operandos
		# $a2 = (Xelevado(2n + 1)) 
		# $v0 = (2n + 1)!
		add $a1, $zero, $a2
		add $a2, $zero, $v0
		# $a1 = (Xelevado(2n + 1)) = numerador
		# $a2 = (2n + 1)! = denominador
		
		jal division
		#El resultado se encuentra en $f16
		lw $s2, 0($sp)
		lw $ra, 4($sp)
		addi $sp, $sp, 8
		#####################################################
		#Se calcula la potencia del -1
		
		#Se asignan los operandos para calcular (-1)elevado n
		addi $a1, $zero, -1
		add $a2, $zero, $s7
		# $a1 = -1 = base
		# $a2 = n = exponente
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal potencia
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		#El resultado de la potencia esta en $v0, es decir, $v0 = (-1)elevado n
		####################################################
		#Se determina el signo del resultado, es decir, ((-1)elevado n) x (Xelevado(2n+ 1))/(2n + 1)!
		addi $sp, $sp, -8
		sw $a0, 0($sp)
		sw $ra, 4($sp)
		
		#Se deja el resultado de la potencia del (-1) en $a0 para pasarla como argumento a determinarSignoDiv
		move $a0, $v0
		
		jal determinarSignoDiv
		#El resultado queda en $f16
		
		lw $a0, 0($sp)
		lw $ra, 4($sp)
		addi $sp, $sp, 8
		###################################################
		#Se acumulan las sumas en $f18
		add.d $f18, $f18, $f16
		
		################################################    
		
		#Se incrementa en uno el contador
		addi $s7, $s7, 1   # n = n + 1
		
		#Se revisa si se debe seguir comparando el contador con el orden total determinado
		#Si $s2 es mayor o igual a $s7 se salta nuevamente a calcularSeno
		bge $s2, $s7, calcularSeno
		################################################
		
		
		#Se retorna a donde se llamo a la sub rutina calcularSeno (no en los saltos, sino la primera vez)
		jr $ra
		
	#Sub rutina que determina el signo del resultado luego de la division en base al resultado de la potencia del (-1)
	determinarSignoDiv:
		#El resultado de la potencia de -1 esta en $a0 y el resultado de la division en $f16
		#Si el resultado de la potencia es menor a cero se debe cambiar el signo
		blt $a0, $zero, cambiarSignoDiv
		
		#Se retorna a donde se llamo a determinarSignoDiv
		jr $ra
	
	#Sub rutina que cambia el signo del resultado a negativo 
	cambiarSignoDiv:
		#Se cambia el signo mediante una resta
		sub.d $f16, $f0, $f16
		
		#Se retorna a donde se llamo a determinarSignoDiv
		jr $ra
	
	#Sub rutina que da termino a la ejecucion del programa
	termino: 
		#Se da termino a la ejecucion del programa
		li $v0, 10
		syscall
		
#############################   POTENCIA   ##############################

	#Sub rutina que realiza el calculo de la potencia de un numero. Recibe como argumentos a $a1 y $a2
	potencia: 
		#base de la potencia = $a1
		#exponente de la potencia = $a2
		
		#El resultado quedara en $v0
		
		#Se mueve $sp para almacenar $ra y se almacena $ra en memoria
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		# $s0 sera el acumulador
		addi $s0, $zero, 1
		# $s1 sera el contado, primero se limpia
		add $s1, $zero, $zero
 		
 		#Se llama a la subrutina procedimientoPot
		jal procedimientoPot
		
		#Se restauran los valores de $ra y $sp
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		#Se retorna a donde se llamo a potencia
		jr $ra
	
	#Sub rutina que realiza el procedimiento necesario para calcular la potencia
	procedimientoPot:
		#Se prueba si el exponente es cero, de serlo se salta a la sub rutina expCero
		beq $a2, $zero, expCero
		
		#Se mueve el puntero del stack y se almacena $ra, la direccion de retorno, en memoria
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		#Se llama a la sub rutina potenciaLoop que realizara los calculos necesarios
		jal potenciaLoop
		
		#Se restauran los valores de $ra y $sp
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		#Se retorna a donde se llamo a procedimientoPot
		jr $ra
	
	#Sub rutina que determina que el resultado es 1
	expCero:
		#Se asigna un 1 al registro de retorno de resultado
		addi $v0, $zero, 1
		
		#Se retorna a donde se llamo a procedimientoPot
		jr $ra
	
	#Sub rutina que realiza los calculos necesarios para calcular la potencia
	potenciaLoop:
		#Se incrementa en 1 el contador $s1 
		addi $s1, $s1, 1
		#Se multiplica el acumulador $s0 por la base $a1
		mul $s0, $s0, $a1
		#Si el contador $s1 y el exponente $a2 no son iguales aun, se salta nuevamente a la sub rutina potenciaLoop
		bne $s1, $a2, potenciaLoop
		
		#Si el contador $s1 y el exponente $a2 son iguales significa que se llego al resultado
		#Se mueve el resultado acumulado en $s0 al registro de retorno de resultados $v0
		move $v0, $s0
		
		#Se retorna a donde se llamo a potenciaLoop (no en los saltos, sino que en primera instancia)
		jr $ra
		
###############################   DIVISION   ##############################

	#Sub rutina que realiza la division entre dos numeros enteros positivos. Recibe como argumentos a $a1 y $a2
	division: 
		#El numerador esta en el registro $a1
		
		#El donominador esta en el registro $a2
		
		#Se limpia el registro $s2 y el $f14
		add $s2, $zero, $zero
		add.d $f14, $f0, $f0
	
		#Se guarda la direccion de $ra
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal procedimientoDiv
		
		#Se restaura el valor de $ra para poder volver a donde se llamo a division
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		#Se vuelve a donde se llamo a division
		jr $ra
		
		
	procedimientoDiv: 
		#Se revisa si alguno de los operandos es 0 y se determina que hacer si alguno lo es
		beq $a2, $zero, esCeroDen
		beq $a1, $zero, esCeroNum
		
		#Si el denominador es 1 el resultado es el numerador
		addi $t0, $zero, 1
		beq $t0, $a2, esElNumerador
		
		#Se compara si el numerador es menor al denominador para dejar en 0 la parte entera de la division si lo es
		slt $t0, $a1, $a2
		bne $t0, $zero, numeradorMenor
		
		#Se guarda el valor de $ra para poder volver despues
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		#Se limpia el registro $s1 para que no se produzcan errores
		add $s1, $zero, $zero
		
		#Se llama a la subrutina divisionLoop
		jal divisionLoop
		
		#Se restaura el valor de $ra
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		#Se vuelve a donde se llamo a procedimientoDiv
		jr $ra
		
		
	esCeroNum: 
		#Se asigna un cero a la salida ya que el numerador es 0 por lo tanto el resultado de la division es 0
		add $v0, $zero, $zero
		
		#Se vuelve a donde se llamo a procedimientoDiv
		jr $ra
		
	esCeroDen:
		#Se da un mensaje de error indicando que el denominador no puede ser 0
		li $v0, 4
		la $a0, textoError
		syscall
		
		jal termino
		
	esElNumerador:
		#Se castea el resultado de la parte entera y se deja en $f16
		mtc1.d $a1, $f16
		cvt.d.w $f16, $f16
		 
		#Se suma la parte entera con la parte decimal y se deja en $f16, $f16 = resultado final
		add.d $f16, $f16, $f14
		
		jr $ra
		
	divisionLoop: 
		#El resto queda en $a1
		#Se le resta a $a1 el valor de $a2
		sub $a1, $a1, $a2
		#Se le suma 1 al contador que lleva la cuenta de la parte entera de la division
		add $s1, $s1, 1
		#Si $a1 es mayor o igual que $a2 se sigue el ciclo
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
	
	numeradorMenor: 
		#Si el numerador es menor que el denominador significa que la parte entera es 0
		#Se guarda el valor de $ra 
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		#Se determina que la parte entera de la division es 0
		add $v0, $zero, $zero
		
		#Se llama a la subrutina divisionResto que calcula la parte decimal de la division
		jal divisionResto
		
		#Se restaura $ra
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		#Se vuelve a donde se llamo a procedimientoDiv
		jr $ra
	
	divisionResto:
		#Se respaldan $ra y $a2
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
		 lw $a2, 4($sp)
		 
		 lw $v0, 8($sp)
		 #Si la diferencia del resto amplificado en 100 con el denominador es menor a cero, significa que para esta implementacion
		 #el resultado de los decimales es cero y se salta a una sub rutina que determina eso
		 sub $t0, $a1, $a2
		 blt $t0, $zero, decimalesCero
		 
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
		 
		 #Se vuelve a donde se llamo a divisionResto
		 jr $ra
		 
	divisionRestoLoop: 
		#El resto queda en $a1
		#Esta operacion es similar a la de la parte entera
		sub $a1, $a1, $a2
		#add $s2, $s2, 1
		add.d $f14, $f14, $f10  
		bge $a1, $a2, divisionRestoLoop 
		
		#Se deja el resultado de la division de la parte decimal en el registro $v1
		#move $v1, $s2
		
		#Se vuelve a donde se llamo a divisionRestoLoop
		jr $ra 	 
		
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
	
###############################   FACTORIAL   ##############################
	
	#Sub rutina que realiza el factorial de un numero. Recibe como argumento a $a3
	factorial:
		#Se guardan los valores de los registros que se utilizaran en el stack
		addi $sp, $sp, -12
		sw $a1, 0($sp)
		sw $a2, 4($sp)
		sw $ra, 8($sp)
	
		#Numero al que se le calculara el factorial estara en $a3
		jal procedimientoFact
		
		#Se restauran los registros que fueron utilizados 
		lw $a1, 0($sp)
		lw $a2, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp, 12
		
		jr $ra

	procedimientoFact: 
		beq $a3, $zero, esCeroFact
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		#El acumulador será $a3
		###############
		add $a1, $zero, $zero
		addi $a2, $zero, 1
		jal factorialLoop
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
		
		
	factorialLoop:
		addi $a1, $a1, 1
		addi $sp, $sp, -8
		sw $ra, 0($sp)
		sw $a1, 4($sp)
		
		jal multiplicacion
		
		lw $ra, 0($sp)
		lw $a1, 4($sp)
		addi $sp, $sp, 8
		
		move $a2, $v0
		bne $a1, $a3, factorialLoop
		move $v0, $a2
		
		jr $ra
		
	
	esCeroFact:
		addi $v0, $zero, 1
		
		jr $ra
############################################ MULTIPLICACION ###########################################
	#Sub rutina que realiza la multiplicacion entre dos numeros enteros positivos. Recibe como argumentos a $a1 y $a2
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
		
