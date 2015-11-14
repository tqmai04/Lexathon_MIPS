promptUser:		.asciiz"\n Enter your word or type '0' to give up: "
success1:		.asciiz"\n You have found "
success2:		.asciiz" words out of "
success3:		.asciiz" words"	
input:			.asciiz"         "
test:
	#prompt user to enter a word
	li $v0, 4
	la $a0, promptUser
	syscall
	
	#collect user input and store in input
	li $v0, 8
	la $a0, input
	li $a1, 10
	syscall
	
	li $t0, 0
	lb $t1, input($t0)
	
	#go to printScore if user entered 0
	beq $t1, $zero, printScore
	
	#check for middle character
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal checkMiddle
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	#check if the entered word contains at least 4 characters
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal checkLength
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	#check if the entered word is a valid English word
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal checkValid
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	#check if the word has already been used
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal checkDuplicate
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	#store the correct word
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal storeCorrect
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	#print success message
	li $v0, 4
	la $a0, success1
	syscall
	
	li $v0, 1
	move $a0, $s7 #$s7 hold the number of correct words
	syscall
	
	li $v0, 4
	la $a0, success2
	syscall
	
	######
	
	li $v0, 4
	la $a0, success3
	syscall
	
	j test
	
	
checkMiddle:

checkLength:

checkValid:
	
checkDuplicate:

storeCorrect:
	
	
