// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// Put your code here.
  @R0
  D=M

  @i
  M=D // i = R0

  @sum
  M=0 // sum = 0

(LOOP)
  @i
  D=M
  @WRITE
  D;JEQ
  @i
  M=D-1 // i--

  // sum = sum + R1
  @R1
  D=M
  @sum
  M=D+M

  @LOOP
  0;JMP // loop

(WRITE)
  @sum
  D=M
  @R2
  M=D

(END)
  @END
  0;JMP
  
