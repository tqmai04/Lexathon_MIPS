#Amanda Truong, Mai Tran, Patrick Deng, Sterling Meyers
#CS 3340l.001
#Nguyen
#Semester Team Project: Lexathon

#s6 = time s7 = score
		.data
	start:		.asciiz		#start prompt
	guide:		.asciiz		#how to play
	input:		.asciiz		#input string
	path:		.asciiz	"dictionary2.txt"	#file path to dictionary
	path9:		.asciiz	"dictionary9.txt"
	buffer: 	.space	1800000	#dictionary buffer
	buffer9:	.space	200000	#nineword dictionary buffer
	errorMessage: 	.ascii	"Valid dictionary not found!"
	inputPrompt:	.asciiz	"Your word: "
	baseMatrix:	.space 21	#3x3 output
	bufferWord9:	.space 12	#for holding one 9 letter word to print with
	modMatrix:	.space 12	#keeps track of used letters by each word
	solutions:	.space 20000	#solutions in the game given 3x3 grid
	bufferWord:	.space 12	#for holding one word to print with
	
				#found words out of total words
				#timer
				#words per minute
				
		.text
	main:	jal	LoadDictionary	#load dictionary
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
		jal	PrintGrid	

#find the answers!
FindSolutions:	li	$s0, 36		#&
		li	$s1, 10
		li	$s2, 4	
		li	$s3, 42		#*
		
		li	$t2, 10
		li	$t3, 32
		
		add	$t0, $zero, $zero	#location in the buffer = 0
		add	$t5, $zero, $zero	#location in solutions = 0
		add	$t7, $zero, $zero	#first letter of first word at 0
		#loop through dictionary buffer
		#s0= &, s1 = length, s2 = center
		#t0 = position dict, t1= position matrix, t2 = dict letter, t3 = matrix letter,  
		#t4 = number of matches, t5 = position solutions, t6 = beginning of word pointer
DictLoop:	beq	$t2, $zero, StartGame	#thru dict, each word we go through this loop
		add	$t4, $zero, $zero	#letter matches = 0
		add	$t6, $zero, $zero	#letter count = 0
		jal	LoadModMatrix		#refresh the grid
		add	$t0, $t7, $zero		#load t7 to t0 at beginning of word
		add	$t5, $s3, $zero		#load t8 to t5 at beginning of solution entry
LetterLoop:	#loop through letters in the word, each word letter we go through this loop	
		beq	$t2, $s0, LetterExit	#when passes = 10, exit to next word
		lb	$t2, buffer($t0)
		add	$t1, $zero, $zero	#location in the matrix = 0
MatrixLoop:	#loop through letters in the modmatrix, each MATRIX letter we iterate
		beq	$t1, $s1, MatrixExit
		lb	$t3, modMatrix($t1)
		
		bne	$t2, $t3, MatrixJump
		sb	$s3, modMatrix($t1)
		addi	$t4, $t4, 1
		
MatrixJump:	addi	$t1, $t1, 1
		j	MatrixLoop	#NEXT MATRIX LETTER
				
MatrixExit:	addi	$t0, $t0, 1	#increment dict location
		addi	$t6, $t6, 1	#incrememnt num letters
		j 	LetterLoop	#NEXT WORD LETTER
		
LetterExit:	bne	$t6, $t4, ExitSolution	#if matches =/= word length go to next word

#check center
CheckCenter:	lb	$t3, modMatrix ($s2)
		bne	$t3, $s3, ExitSolution	#if 5th letter of matrix is not matched, exit to next word
		
#Solution Array
AddSolution:	add	$t0, $zero, $t7		#get beginning of word position
LoopSolution:	beq	$t2, $s0, ExitSolution
		lb	$t2, buffer($t0)
		sb	$t2, solutions($t5)
		
		addi	$t0, $t0, 1
		addi	$t5, $t5, 1
		j 	LoopSolution
		
ExitSolution:	sb	$t2, solutions($t5)
		addi	$s3, $s3, 10
		addi	$t7, $t7, 10
		j	DictLoop	#NEXT WORD
		






#############################################MAIN GAME ################################################################

StartGame:	#initialize time, letters, etc.		
		#addi	$s6, $zero, 60
		#add	$s5, $zero, $zero	
		addi	$t5, $t5, 1
		sb	$zero, solutions($t5)
		li	$v0, 4
		la	$a0, solutions
		syscall	
###########################
GameFrame:	beq	$s6, $zero, GameOver	#s6 storing the time
		#how do I decrement time ;_;
		jal	PrintScoreTime
		jal	FoundWords
		jal 	PrintGrid
		jal	UserPrompt
		jal	CheckString
		j GameFrame
		
#function
UserPrompt:	li	$v0, 4
		la	$a0, inputPrompt
		syscall
		li	$v0, 8
		#arguments
		syscall
		jr	$ra
#endfunc
	
						
CheckString:	
			


		
		
Check:		#time
	
	
		
		#start screen prompt (how to play or start?)
	
		#choode 9 random letters, find all possible words length 4 that could be formed with the 5th letter in dictionary
		
		#load 9 letters
		
		#prompt input: check for presence of fifth letter
		
PrintScoreTime:		

FoundWords:
				
GameOver:	j Exit

				

##############################################SUBROUTINES##############################################################																								
Exit:		li $v0, 10
		syscall	
		
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
		li 	$a2, 10		#each word is 10 ASCII chars long
		syscall
	
		lb	$t0, buffer ($s7)
		addi	$s7, $s7, 10	#increment 1 bytes
		beq 	$t0, $zero, ReadExit	#stop reading and go to dict9 read if null char
		j 	ReadLine
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
		li 	$a2, 10		#each word is 10 ASCII chars long
		syscall
		lb	$t0, buffer9($s7)
		addi	$s7, $s7, 10	#increment 10 bytes
		beq 	$t0, $zero, Read9Exit	#if character read is null, stop reading 
		j ReadLine9
Read9Exit:	jr	$ra
#exit
#subroutine	
RandomWord9:	li	$v0, 41	#random number generator
		syscall
		addi	$t1, $zero, 16688	#there are 16688 9-letter words in the dictionary
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
		li	$s1, 38
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
		li	$s1, 38
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
ExitFormatter:	jr	$ra
#endfunc


#function		
PrintGrid:	sb	$zero, baseMatrix($t1)
		#code to print out 3x3	
		li	$v0, 4
		la	$a0, baseMatrix
		syscall
		
		jr	$ra
#end func

#function
LoadModMatrix:	li	$t0, 36
		add	$t1, $zero, $zero 
LoopMod:	beq	$t0, $zero, ExitModMatrix
		lb	$t0, bufferWord9($t1)
		sb	$t0, modMatrix($t1)
		addi	$t1, $t1, 1
		j 	LoopMod
ExitModMatrix:	jr 	$ra
#endfunc




