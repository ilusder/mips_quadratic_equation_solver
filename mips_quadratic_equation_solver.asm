###############################
#         Ilya Deryabin       #
#    ax^2 + b*x + c = 0 V0.0  #
###############################
	.eqv  LIMIT      80
	.macro prints
		li $v0, 4
		syscall
	.end_macro
	.macro printc
		li $v0, 11
		syscall
	.end_macro
	.macro printd
		li $v0, 3
		syscall
	.end_macro
	.data
	# Declare main as a global function

accuracy:	.double	0.01
zero:	.double	0
four:	.double 4
num2:	.double	2
hello:	.asciiz "Welcome to equation programm!\n"
mess1:	.asciiz "Enter A:\n"
mess2:	.asciiz "Enter B:\n"
mess3:	.asciiz "Enter C:\n"
mess_det: .asciiz "Determinant is: "
mess_res: .asciiz "Solution\n"
mess_fail: .asciiz "Error\n"
msg1: 	.asciiz "Enter a number(single precision floating point) please: \n"
msg2: 	.asciiz "The Answer is: "
msg3: 	.asciiz "R^2: "
msg4: 	.asciiz "Delta: "
msx1:	.asciiz "X1: "
msx2:	.asciiz "X2: "
nl: 	.asciiz "\n"
	.globl main

	# All program code is placed after the
	# .text assembler directive
	.text 		

# The label 'main' represents the starting point
main:	la $a0, hello
	prints
	

start:	la $a0, mess1
	prints
	li $v0, 7
	syscall
	mov.d $f22, $f0
	la $a0, mess2
	prints
	li $v0, 7
	syscall
	mov.d $f24, $f0
	la $a0, mess3
	prints
	li $v0, 7
	syscall
	mov.d $f26, $f0

	#$f22 - A ; $f24 - B; $f26 - C
	mov.d $f0, $f22
	jal solve
	
	
	jal print_solution

	li $a0, '\n'
	printc
	j exit
	
fail:	la $a0, mess_fail
	prints
	
	# Exit the program by means of a syscall.
	# There are many syscalls - pick the desired one
	# by placing its code in $v0. The code for exit is "10"
exit:	li $v0, 10 # Sets $v0 to "10" to select exit syscall
	syscall # Exit
	
#####################################
#Solve equation
#input: $f22 - A ; $f24 - B; $f26 - C;
# output $f8 - x1[re] $f10 - x1[im], $f18 x2[re], $f20 - x2[im]
# if not - out error code (TBD)
#####################################
solve: 		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $a0, 0($sp)      # Store previous value
    		
		l.d	$f28, four
		mul.d $f28, $f28, $f22   #(4*a)
		mul.d $f28, $f28, $f26	#(4*a*c)
		
		mul.d $f30, $f24, $f24 #(b^2)
		sub.d $f30, $f30, $f28  #b^2 - 4 * a * c 
		
		l.d $f28, zero
		c.lt.d $f28, $f30
		bc1t	solve_bigger
		li $t1, 'j'		#det is complex
		abs.d	$f30, $f30
		b solve_det

solve_bigger:	li $t1, 0		#det is real
		
		
solve_det:	mov.d $f0, $f30
		addi	$sp, $sp, -4
		sw	$ra, 0($sp)
		jal	sqrt		

		mov.d  $f30, $f12   #f30 contains determinant, $t1 contain complex or real
		
		la $a0, mess_det
		prints
		
		mov.d $f12, $f30
		printd	#print determinant

		#calculate 2*a
		l.d	$f28, num2
		mul.d	$f28, $f28, $f22	# $f28 contains (2 * a)
		
		bne $t1, 'j', det_not_i
		#complex
		move $a0, $t1  #print j after determinant
		printc
		li $a0, '\n'
		printc	
		neg.d $f8, $f24  # $f8 is -b   - for x1
		div.d $f8, $f8, $f28		# x1[re] = -b/(2*a)
		div.d $f10, $f30, $f28		# x1[im] = +sqrt(det)/(2*a)
		mov.d $f18, $f8			# x2[re] = x1[re]
		neg.d $f20, $f10		# x2[im] = -x1[im]
		b solve_end
		
det_not_i:	#not complex
		neg.d $f8, $f24  # $f8 is -b   - for x1
		add.d $f8, $f8, $f30
		div.d $f8, $f8, $f28		# x1[re] = (-b+sqrt(det))/(2*a)
		l.d $f10, zero			# x1[im] = 0
		neg.d $f18, $f24  # $f12 is -b   - for x2
		sub.d $f18, $f18, $f30
		div.d $f18, $f18, $f28		# x2[re] = (-b-sqrt(det))/(2*a)
		l.d $f20, zero
		li $a0, '\n'
		printc
		
		
solve_end:	lw $a0, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
    		lw 	$ra, 0($sp)
		addi	$sp, $sp, 4
		jr $ra	

#####################################
#Print solution of equation
#input: $f8 - x1[re] $f10 - x1[im], $f18 x2[re], $f20 - x2[im]
#####################################
print_solution: addi $sp, $sp,-4     # Moving Stack pointer
    		sw $a0, 0($sp)      # Store previous value
		
		l.d $f30, zero
									
		
		la $a0, msx1
		prints
		mov.d $f12, $f8
		printd
		
		c.eq.d $f10, $f30
		bc1t	not_complex_x1
		
		li $a0, ' '
		printc
		li $a0, '+'
		printc
		li $a0, ' '
		printc
		
		mov.d $f12, $f10
		printd
		
		li $a0, 'j'
		printc
				
not_complex_x1:	li $a0, '\n'
		printc
		
		la $a0, msx2
		prints
		
		mov.d $f12, $f18
		printd
		
		c.eq.d $f20, $f30
		bc1t	not_complex_x2
		
		li $a0, ' '
		printc
		li $a0, '+'
		printc
		li $a0, ' '
		printc
		
		mov.d $f12, $f20
		printd
		
		li $a0, 'j'
		printc
		
		
not_complex_x2:		li $a0, '\n'
		printc
		lw $a0, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		
#####################################
#Sqrt
#input: $f0
# output $f12
#####################################		
sqrt:	addi $sp, $sp,-4     # Moving Stack pointer
    	sw $a0, 0($sp)      # Store previous value
    	l.d	$f2, zero	# $f2 = LOW = 0
    	c.eq.d	$f0, $f2
    	bc1f	sqrt_cont   # branch if not zero 
    	mov.d $f12, $f0
    	jr $ra
    	
    	
sqrt_cont: mov.d	$f4, $f0 	# $f4  holds the number to calculate the root of
	mov.d	$f14, $f0 	# $f14 =  HIGH
	
	l.d	$f2, zero	# $f2 = LOW = 0
	l.d	$f10, num2	# $f10 = 2
	l.d	$f16, accuracy	# $f16 = 0.0001

sqrt2:	add.d	$f6, $f14, $f2 # R = H+L
	div.d 	$f6, $f6, $f10 # R = R/2
	mul.d	$f8, $f6, $f6
	
	#addi	$sp, $sp, -4
	#sw	$ra, 0($sp)
	#jal	printRsqr
	#lw 	$ra, 0($sp)
	#addi	$sp, $sp, 4
	
	c.eq.d	$f8, $f4
	bc1t	end_sqrt
	
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	checkAccuracy
	lw 	$ra, 0($sp)
	addi	$sp, $sp, 4
	
	c.lt.d	$f8, $f4
	bc1f	bigger
	b	smaller

	
	
checkAccuracy: # $f16 = 0.0001 , #f8 = current R2 $f4 = input number
	
	sub.d	$f18, $f8, $f4
	abs.d	$f18, $f18
	c.le.d	$f18, $f16
	bc1t	end_sqrt
	
	#addi	$sp, $sp, -4
	#sw	$ra, 0($sp)
	#jal	printDelta
	#lw 	$ra, 0($sp)
	#addi	$sp, $sp, 4
	
	jr $ra
	
	
bigger:	# if R^2 > num look in the lower section 	
	mov.d 	$f14, $f6
	b	sqrt2
	 
smaller:
	mov.d	$f2, $f6
	b	sqrt2

end_sqrt:
	
	#li $v0, 4
	#la $a0, msg2
	#syscall
	
	mov.d	$f12, $f6
	#printd
	lw 	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr $ra

printRsqr:

	li $v0, 4
	la $a0, msg3
	syscall
		
	mov.d	$f12, $f8
	printd
	
	
	li $v0, 4
	la $a0, nl
	syscall
	
	jr $ra	
	
printDelta:

	li $v0, 4
	la $a0, msg4
	syscall
	
	mov.d	$f12, $f18
	printd
	
	
	li $v0, 4
	la $a0, nl
	syscall	
	
	jr $ra

