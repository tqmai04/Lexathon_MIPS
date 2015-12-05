This is a file documenting the features of the game Lexathon brought to you by Amanda Truong, Patrick Deng, Mai Tran, and Sterling Meyers!

The features of this implementation of Lexathon include:

1. A main menu that prompts the user for either a rule guide or the choice to start the game (0 or 1).

2. An input reader that allows the user any input, including one that causes game exit, and the input will be checked for whether or not it is correct length or invalid, includes center character of the grid generated, and is a valid word in a dictionary! Also gives the option for the user to the end the game at any time with a 0 input.

3. A timer that counts down from 60 initially, and adds 20 seconds for each correct word submitted by the user, ending the game at 0 seconds, and displaying the time with each submission.

4. A scorekeeping module that is printed at the end for timer that is calculated from words per minute and words found.
-----------------------------
Limitations:

1. The entirety of the "GUI" will be in the console in MARS.
2. The timer update is only shown on console with every submission attempt/at game over.
3. Some grid generations will only yield a single digit number of possible solutions arbitrarily. 
4. A small selection of common words do not appear in this dictionary, as not every variation of a root word is covered in it. EX: If "dancing" is there, "danced" might not be. 
5. Repeating the central letter many times in a string input may crash the program.
6. Entering multiple 0s counts as one 0 in the context of the program, and ends the game accordingly.