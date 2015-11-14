# LEXATHON in MIUPS
# Amanda Truong, Mai Tran, Patrick Deng, Sterling Meyers

.data
	welcome:	.asciiz "Welcome to Lexathon!\n"
	decide:		.asciiz "Enter any key to start game or '0' for how to play \n"
	
	ending:		.asciiz "Enter any key to start a new game or '0' to exit \n"
	ins1:		.asciiz "INSTRUCTIONS: \n"
	ins2:		.asciiz "You must find as many words of four or more letters as possible in the allocated time \n"
	ins3:		.asciiz "Each word must contain the central letter and no letter can be used twice \n"
	ins4: 		.asciiz "You start each game with 60 seconds and you get 20 more seconds for each word found \n"
	ins5:		.asciiz "Game ends when you either run out of time or hit 0 to give up\n"

.text
.globl main



	main:
		#display welcome message
		li $v0, 4
		la $a0, welcome
		syscall
		
	request:
		#ask user to enter 0 or 1
		li $v0, 4
		la $a0, decide
		syscall
		
		#read user's input
		li $v0, 5
		syscall
		
		#go to instructions if user entered 0
		beq $v0, $zero, instructions 
	GameOver:	
		li $v0, 4
		la $a0, ending
		syscall
		
		li $v0, 5
		syscall
		
		#bne $v0, $zero, startGame
		
		j Exit
				
	Exit:	
		li $v0, 10
		syscall
		
	instructions:
		#print instructions
		li $v0, 4
		la $a0, ins1
		syscall
		
		la $a0, ins2
		syscall
		
		la $a0, ins3
		syscall
		
		la $a0, ins4
		syscall
		
		la $a0, ins5
		syscall
		
		j request