# LEXATHON in MIUPS
# Amanda Truong, Mai Tran, Patrick Deng, Sterling Meyers

.data
	welcome:	.asciiz "Welcome to Lexathon!\n"
	decide:		.asciiz "Enter '1' to start game or '0' for how to play \n"
	
	ins1:		.asciiz "INSTRUCTIONS: \n"
	ins2:		.asciiz "You must find as many words of four or more letters as possible in the allocated time \n"
	ins3:		.asciiz "Each word must contain the central letter and no letter can be used twice \n"
	ins4: 		.asciiz "You start each game with 60 seconds and you get 20 more seconds for each word found \n"
	ins5:		.asciiz "Game ends when you either run out of time or hit 0 to give up\n"
	ending:		.asciiz "Thank you for playing Lexathon! Goodbye!"
	loading:	.asciiz "Loading... Please wait!"
	
	path:		.asciiz	"dictionary2.txt"	#file path to dictionary
	path9:		.asciiz	"dictionary9.txt"
	buffer: 	.space	500000	#dictionary buffer
	buffer9:	.space 100000	#nineword dictionary buffer
	errorMessage: 	.ascii	"Valid dictionary not found!"

	baseMatrix:	.space 21	#3x3 output
	bufferWord9:	.space 13	#for holding one 9 letter word to print with
	modMatrix:	.space 13	#keeps track of used letters by each word
	solutions:	.space 20000	#solutions in the game given 3x3 grid
	bufferWord:	.space 13	#for holding one word to print with
	
	promptUser:		.asciiz "\n Enter your word or type '0' to give up: "
	success1:		.asciiz "\n You have found "
	success2:		.asciiz " word(s) out of "
	success3:		.asciiz " words \n"	
	input:			.space 10
	tooShort:		.asciiz " Word must be at least 4 letters long\n"
	notMiddle:		.asciiz " You must include the central letter\n"
	invalidWords:		.asciiz " Sorry you entered an invalid word\n"
	duplicate:		.asciiz " You have already entered this word\n"
	runTime:		.asciiz " You ran out of time!"
	correctWords:		.space 20000
	buffering:		.space 12

	notFound:	.asciiz "Unfound: "
	timerPrompt:    	.asciiz "\nTime starts now! "
	remainingTime:		.asciiz " Time: "
	youScored:		.asciiz "Your final score is: "
	wordsPerMin:		.asciiz "Words per minute: "
	line:			.asciiz "\n"
	
	
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
		beq $v0, 1, startGame
		
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
	
startGame:	jal	LoadDictionary	#load dictionary
		jal	ReadLine	#read dictionary lines to buffer
		jal	LoadDict9	#load dictionary9
		jal	ReadLine9	#read dictionary9 lines to buffer9
		
		jal	RandomWord9	#obtain address of random 9 letter word in dictionary			
		
WordSelect:	lb	$a0, buffer9 ($t0)	#first char of word offset from beginning of dictionary9 on memory
		add	$a1, $t0, $zero	
		#arguments are 1st char of word and location of word with respect to the buffer
		jal	WordLoader9
		
		jal	Scrambler 	#scramble word!
		jal	GridFormatter	#format the word into a 3x3 grid string	
		
		li $v0, 4
		la $a0, loading
		syscall
		
		li $v0, 4
		la $a0, line
		syscall

#find the answers!
FindSolutions:	li	$s0, 32		#&
		li	$s1, 10
		li	$s4, 4
		lb	$s2, bufferWord9($s4)	#store center character 
		li	$s3, 42		#*
		add	$s5, $zero, $zero	#word count
		li	$t2, 10
		li	$t3, 32
		
		add	$t0, $zero, $zero	#location in the buffer = 0
		add	$t5, $zero, $zero	#location in solutions = 0
		add	$t7, $zero, $zero	#first letter of first word at 0
		#loop through dictionary buffer
		#s0= &, s1 = length, s2 = center
		#t0 = position dict, t1= position matrix, t2 = dict letter, t3 = matrix letter,  
		#t4 = number of matches, t5 = position solutions, t6 = letter count, t7 = beginning of word pointer
DictLoop:	beq	$t2, $zero, begin	#thru dict, each word we go through this loop
		add	$t4, $zero, $zero	#letter matches = 0
		add	$t6, $zero, $zero	#letter count = 0
		addi	$sp, $sp, -8
		sw	$t0, 0 ($sp)
		sw	$t1, 4 ($sp)
		jal	LoadModMatrix	#refresh the grid	#PROBABLY REMOVE THIS AND USE ONLY ONE LOAD PER GAME INSTEAD
		lw	$t0, 0 ($sp)
		lw	$t1, 4 ($sp)
		addi	$sp, $sp, 8
		
		add	$t0, $t7, $zero		#load t7 to t0 at beginning of word
		li	$t2, 10
LetterLoop:	#loop through letters in the word, each word letter we go through this loop	
		lb	$t2, buffer($t0)
		beq	$t2, $s0, LetterExit	#when & encountered, exit to next word
		beq	$t2, $zero, LetterExit	#when reach nullchat, exit 
		add	$t1, $zero, $zero	#location in the matrix = 0
MatrixLoop:	#loop through letters in the modmatrix, each MATRIX letter we iterate
		beq	$t1, $s1, MatrixExit
		lb	$t3, modMatrix($t1)
		
		bne	$t2, $t3, MatrixJump
		beq	$t2, $zero, MatrixJump
		sb	$s3, modMatrix($t1)
		addi	$t4, $t4, 1
		add	$t1, $t1, 1
		j	MatrixExit
		
MatrixJump:	addi	$t1, $t1, 1
		j	MatrixLoop	#NEXT MATRIX LETTER
				
MatrixExit:	addi	$t0, $t0, 1	#increment dict location
		addi	$t6, $t6, 1	#incrememnt num letters
		j 	LetterLoop	#NEXT WORD LETTER
		
LetterExit:	bne	$t6, $t4, ExitSolution	#if matches =/= word length go to next word
		

#check center
CheckCenter:	lb	$t2, modMatrix ($s4)	#store center character 
		bne	$t2, $s3, ExitSolution	#if 5th letter of matrix is not matched, exit to next word
		
#Solution Array
AddSolution:	addi	$s5, $s5, 1	#increment word count
		add	$t0, $zero, $t7		#get beginning of word position
		add	$t6, $zero, $zero	#NEW t6 for now
LoopSolution:	beq	$t6, $s1, ExitSolution	#when numpasses = 10 exit
		lb	$t2, buffer($t0)
		sb	$t2, solutions($t5)
		
		addi	$t0, $t0, 1
		addi	$t6, $t6, 1
		addi	$t5, $t5, 1
		j 	LoopSolution
				
ExitSolution:	addi	$t7, $t7, 10
		
		j	DictLoop	#NEXT WORD

																						

#subroutine	
Error:		li $v0, 4
		la $a0, errorMessage
		syscall	
		j Exit
#endfunc	
		
#function
LoadDictionary:	li 	$v0, 13		#open
		la 	$a0, path
		li 	$a1, 0
		li	$a2, 0
		syscall
		
		#move
		add 	$s0, $v0, $zero	#save fd to s0
		add	$s7, $zero, $zero	#initialize s7 to 0
		slt 	$t0, $v0, $zero
		bne 	$t0, $zero, Error	#if file not found, fd < 0
		jr	$ra
#end func								
	
#subroutine	
ReadLine:	li 	$v0, 14 		#read
		add	$a0, $s0, $zero	#pass fd as argument for file to read
		la 	$a1, buffer ($s7)	
		li 	$a2, 500000
		syscall
	
ReadExit:	jr	$ra
#endfunc	

#subroutine
LoadDict9:	li 	$v0, 13		#open dictionary9letterwords
		la 	$a0, path9
		li 	$a1, 0
		li	$a2, 0
		syscall
		
		#move
		add 	$s0, $v0, $zero	#save fd to s0
		add	$s7, $zero, $zero	#initialize s7 to 0
		slt 	$t0, $v0, $zero
		bne 	$t0, $zero, Error	#if file not found, fd < 0
		jr	$ra
#endfunc


#subroutine
ReadLine9:	li 	$v0, 14 		#read
		add	$a0, $s0, $zero	#pass fd as argument for file to read
		la 	$a1, buffer9($s7)	
		li 	$a2, 80000	#each word is 10 ASCII chars long
		syscall
		
Read9Exit:	jr	$ra
#exit
#subroutine	
RandomWord9:	li	$v0, 41	#random number generator
		syscall
		addi	$t1, $zero, 7695	#there are 16688 9-letter words in the dictionary
		divu	$a0, $t1	#divide number by size
		mfhi	$t0	#remainder = new num'
		li	$t1, 10
		multu	$t0, $t1
		mflo	$t0
		jr	$ra
#endfunc

#function		
WordLoader9:	add	$t0, $a0, $zero
		add	$t1, $zero, $a1
		add	$t2, $zero, $zero
		li	$s1, 32
		li	$s2, 9
WordLoop9:	beq	$t0, $s1, WordExit9
		beq	$t2, $s2, WordExit9
		lb	$t0, buffer9($t1)
		sb	$t0, bufferWord9($t2)
		addi	$t1, $t1, 1
		addi	$t2, $t2, 1
		j	WordLoop9
		
WordExit9:	add	$t0, $zero, $zero
		addi	$t3, $zero, 10
		sb	$t3, bufferWord9($t2)
		addi	$t2, $t2, 1
		sb	$t0, bufferWord9($t2)
		jr	$ra
#endfunc			

#function
WordLoader:	add	$t0, $a0, $zero
		add	$t1, $zero, $a1
		add	$t2, $zero, $zero
		li	$s1, 32
		li	$s2, 9
WordLoop:	beq	$t0, $s1, WordExit
		beq	$t2, $s2, WordExit
		lb	$t0, buffer($t1)
		sb	$t0, bufferWord($t2)
		addi	$t1, $t1, 1
		addi	$t2, $t2, 1
		j	WordLoop
		
WordExit:	add	$t0, $zero, $zero
		sb	$t0, bufferWord($t1)
		jr	$ra
#endfunc

#subroutine
Scrambler:	li	$s0, 7	#max number of passes
		add	$s1, $zero, $zero	#initial number of passes
ScrambleLoop:	beq	$s1, $s0, ExitScrambler
		
		li	$v0, 41	#random number generator
		syscall
		addi	$t3, $zero, 5	#5 positions, 0 to 4
		divu	$a0, $t3	#divide number by size
		mfhi	$t3	#remainder = new num'


		li	$v0, 41	#random number generator
		syscall
		addi	$t4, $zero, 4	#4 positions, add 5 later
		divu	$a0, $t4	#divide number by size
		mfhi	$t4	#remainder = new num'
		addi	$t4, $t4, 5	#positions 5 to 8
		
		lb	$t0, bufferWord9($t3)
		lb	$t1, bufferWord9($t4)
		sb	$t0, bufferWord9($t4)
		sb	$t1, bufferWord9($t3)
		
		addi	$s1, $s1, 1
		j	ScrambleLoop
ExitScrambler:	jr	$ra	
#endfunc	

#subroutine
GridFormatter:	add	$t0, $zero, $zero
		add	$t1, $zero, $zero
		li	$s1, 10	#newline
		li	$s2, 9	#stop after 9 iterations
		li	$s3, 32	#store space
		li	$s4, 3	#to 2nd line
		li	$s5, 6	#to 3rd line
		
		
GridLoop:	beq	$t0, $s2, ExitFormatter	#every 3 letters, new line instead that is, 6 positions.
		lb	$t2, bufferWord9($t0)
		sb	$t2, baseMatrix ($t1)
		addi	$t1, $t1, 1
		sb	$s3, baseMatrix($t1)
		addi	$t1, $t1, 1
		addi	$t0, $t0, 1
		beq	$t0, $s4, NewLine
		beq	$t0, $s5, NewLine
		j GridLoop
NewLine:	sb	$s1, baseMatrix($t1)	
		addi	$t1, $t1, 1	
		j GridLoop 	
ExitFormatter:	sb	$zero, baseMatrix($t1)
		jr	$ra
#endfunc


#function		
PrintGrid:	#code to print out 3x3	
		li	$v0, 4
		la	$a0, baseMatrix
		syscall
		
		jr	$ra
#end func

#function
LoadModMatrix:	li	$t0, 32
		add	$t1, $zero, $zero 
LoopMod:	beq	$t0, $zero, ExitModMatrix
		lb	$t0, bufferWord9($t1)
		sb	$t0, modMatrix($t1)
		addi	$t1, $t1, 1
		j 	LoopMod
ExitModMatrix:	jr 	$ra
#endfunc


begin:
	li $s1, 0 #initialize number of correct words found
	li $s3, 0
	li $s4, 0
	li $s7, 0
	li $s6, 0 #to hold the index of the array
	li $t0, 0
	

initial:
	li $t3, 60 # $t6 = 60 second limit for the timer
	jal initialize_timer #initialize ONCE
	li $s0, 0
	
prompt:


	# initialize registers
	li $t6, 0
	li $t7, 0
	
	jal PrintGrid
	
	#prompt user to enter a word
	li $v0, 4
	la $a0, promptUser
	syscall
	
	#collect user input and store in input
	li $v0, 8
	la $a0, input
	li $a1, 10
	syscall
	
	### print remaining time
	jal countdown_timer
	
	
	la $a0, input
	lb $t1, 0($a0)
	#go to printScore if user entered 0
	beq $t1, 48, GameOver
	

	#check if the entered word contains at least 4 characters
	jal checkLength
	
	#make user input lower case letters
	jal LowerCase
	
	#check for middle character
	jal checkMiddle
	#format input into the same format with correctWords and solutions array
	jal format
	#check if the word has already been used
	jal checkDuplicate
	#check if the entered word is a valid English word
	li $t0, 10
	multu $s5, $t0
	mflo $s3
	jal checkValid
	#store the correct word into an array
	jal storeCorrect
	
	
	#print success message

	jal add_bonus_time # add 20 seconds to timer
	
	li $v0, 4
	la $a0, success1
	syscall
	
	li $v0, 1
	move $a0, $s1 #$s1 hold the number of correct words
	syscall
	
	li $v0, 4
	la $a0, success2
	syscall
	
	######
	li $v0, 1
	move $a0, $s5
	syscall
	#####
	li $v0, 4
	la $a0, success3
	syscall
	
	j prompt


# TIMER 
	# $t6 is 60 second limit t3
	# $t5 = beginning time  t4
	# $t7 = end time  t6
	# $t9 = difference between times t7
	# $t4 = 1000 s0
	
	add_bonus_time:
	addi $t3, $t3, 20 # add 20 seconds per correct word
	jr $ra
	

	initialize_timer:
	li $v0, 30 # beginning of GAME
	syscall 
	
	add $t4, $t4, $a0 # $t4 contains total number of milliseconds before
	jr $ra	
    
	countdown_timer: # $t3 contains 60 second limit
 	li $v0, 30
  	syscall
  	
    	add $t6, $t6, $a0 # stores second time into $t6
	
	sub $t7, $t6, $t4 # subtract the two times $t7 contains difference
	
	li $t6, 0 # reset $t6
	
	
	
	li $v0, 1
    	li $s0, 1000 
    	div $t7, $t7, $s0 # concert milliseconds into seconds
    	
    	add $t6, $t6, $t3 # $t6 contains max time
    	move $t8, $t6
    	
	sub $t3, $t3, $t7 # subtract from timer
	
	li $s0, 0
	ble $t3, $s0, outOfTime
	
	# Time:
	li $v0, 4
	la $a0, line
	syscall
	
	li $v0, 4
	la $a0, remainingTime
	syscall
	
	li $v0, 1
	move $a0, $t3
    	syscall
    	
    	li $v0, 4
    	la $a0, line
    	syscall
    	
    	li $t3, 0 	
	add $t3, $t3, $t6 # set $t3 to its max time
	li $t6, 0 # reset $t6
    	
    	
    	jr $ra

# check if the word entered is at least 4 letters

checkLength:
	
	li $s3, 0 #to hold the word length
	
	getLength: # to get the word length
		lb $t1, 0($a0)
		beq $t1, $zero, check
		addi $s3, $s3, 1
		addi $a0, $a0, 1 
		j getLength
	
	check: # check if it has at least 4 letters
		li $t1, 1
		sub $s3, $s3, $t1
		
		slti $t2, $s3, 4
		beq $t2, $zero, exitLength
		#display error message
		li $v0, 4
		la $a0, tooShort
		syscall
		
		j prompt
	
exitLength:
	jr $ra


########

LowerCase: 
	la $a0, input
	makeLower:
		lb $t0, 0($a0) #$t0 holds current char
		beq $t0, $zero, Low #end of input
		blt  $t0, 96, convert #char is upper, go convert to lower
		addi $a0, $a0, 1
		j makeLower
	convert:
		addi $t0, $t0, 32
		sb $t0, 0($a0)
		addi $a0, $a0, 1
		j makeLower
Low:
	
	jr $ra
#########



# Check for the middle character of the matrix	
checkMiddle:
	la $a0, input
	centerLetter: 
		lb $t0, 0($a0) #loop through all letters in input
		beq $t0, $zero, notCenter
		beq $t0, $s2, finishMiddle #$s2 stores the center letter of basicMatrix
		addi $a0, $a0, 1
		j centerLetter
	notCenter: # display error message if the center letter is not included
		li $v0, 4
		la $a0, notMiddle
		syscall
		j prompt
finishMiddle:
	jr $ra		

# add spaces to user's input until it is 10-char long and store in buffering 
format:
	la $a0, input
	li $a1, 0
	storeInBuffer:
	lb $t0, 0($a0)
	beq $t0, 42, addSpace
	sb $t0, buffering($a1)
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	j storeInBuffer
	
addSpace:
	bgt $a1, 9, exitFormat
	li $t1, 32
	sb $t1, buffering($a1)
	addi $a1, $a1, 1
	j addSpace

exitFormat:
	jr $ra
###########
checkDuplicate: #check if the entered word has already been entered
	li $s7, 0 #to hold index of correctWords array
	move $s4, $s7
	
	nextWord:
	move $s7, $s4
	beq $s7, $s6, exitDuplicate
	addi $s4, $s4, 10
	li $a0, 0 # to hold index of buffering
	
	compare:
	beq $a0, 10, Used
	lb $t0, buffering($a0)
	lb $t1, correctWords($s7)
	bne $t0, $t1, nextWord
	addi $a0, $a0, 1
	addi $s7, $s7, 1
	j compare
	
Used:	#display the error message if the word has already been used
	li $v0, 4
	la $a0, duplicate
	syscall
	
	j prompt
	
exitDuplicate:
	jr $ra
	
###########
checkValid: #check if the word entered if a valid English word
	li $s7, 0 #to hold index of solutions array
	move $s4, $s7
	
	next:
	move $s7, $s4 #$s4 to hold the index of the first character of a word in solutions array
	beq $s7, $s3, NotValid #$s3 holds the number of total elements in solutions array
	addi $s4, $s4, 10 #move to the next word in solutions array
	li $a0, 0 # to hold index of buffering
	
	compareValid:
	beq $a0, 10, exitValid #a word is valid after 10 passes
	lb $t0, buffering($a0)
	lb $t1, solutions($s7)
	bne $t0, $t1, next #compare each character
	addi $a0, $a0, 1
	addi $s7, $s7, 1
	j compareValid
	
NotValid: #display error message if it is not a valid English word
	li $v0, 4
	la $a0, invalidWords
	syscall
	
	j prompt
	
exitValid:
	jr $ra
###########
#store all correct words tha player has found in correctWords array
storeCorrect:
	li $a0, 0
	
	storeWordLoop:
	lb $t0, buffering($a0)
	bgt $a0, 9, finishStore
	sb $t0, correctWords($s6)
	addi $a0, $a0, 1
	addi $s6, $s6, 1
	j storeWordLoop
	
finishStore:
	#display all the words found
	li $v0, 4
	la $a0, correctWords
	syscall
	
	#increase the number of words found by 1
	addi $s1, $s1, 1
	jr $ra

outOfTime:
		li $v0, 4
		la $a0, runTime
		syscall
		
GameOver:	# display all possible solutions
		li $v0, 4
		la $a0, line
		syscall
		
		li $v0, 4
		la $a0, notFound
		syscall
		
		addi	$t5, $t5, 1
		sb	$zero, solutions($t5)
		li	$v0, 4
		la	$a0, solutions
		syscall	
		
		# words per min calculation
		
		li $v0, 4
		la $a0, line
		syscall
		
		li $v0, 4 # "Words per min: "
		la $a0, wordsPerMin
		syscall
		
		
		# words per min... needs total words / (total time/60) = ______
		div $t4, $t8, 60 
statsOutput:
		div $t2, $s1, $t4
		
		li $v0, 1 # outputs words per min
		move $a0, $t2
		syscall
		
		li $v0, 4 # skip line
		la $a0, line
		syscall
		
		# Final score calculation
		
		li $v0, 4 # "Your final score is: "
		la $a0, youScored
		syscall
		
		mult $s1, $t2 # Final score = total number of words found * words per minute
		mflo $s1
		
		li $v0, 1 # display final score
		move $a0, $s1
		syscall
		
		li $v0, 4 # skip line
		la $a0, line
		syscall
		
		
		li $v0, 4 # "Good luck next time! Goodbye!"
		la $a0, ending
		syscall
		
		
				
Exit:	#exit the program 
		li $v0, 10
		syscall	
		

