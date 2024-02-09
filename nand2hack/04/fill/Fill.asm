// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

// Put your code here.
  @addr
  @n

(MAIN)
  @8192
  D=A
  @n
  M=D // n = 8192 (number of registers to set)
  @SCREEN
  D=A
  @addr
  M=D // addr = 16384 (screen's base address)  
  @KBD
  D=M
  @WHITESCREEN
  D;JEQ
  @BLACKSCREEN
  0;JMP

(WHITESCREEN)
  @n
  D=M 
  @MAIN
  D;JEQ
  @addr
  A=M
  M=0
  @addr
  M=M+1
  @n
  M=M-1
  @WHITESCREEN
  0;JMP
  
(BLACKSCREEN)
  @n
  D=M 
  @MAIN
  D;JEQ
  @addr
  A=M
  M=-1
  @addr
  M=M+1
  @n
  M=M-1
  @BLACKSCREEN
  0;JMP


  
  
