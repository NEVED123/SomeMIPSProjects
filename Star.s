#Deven Mallamo 

#Creates a star pattern given a character and a number
#Example:
# Enter a symbol: $
# Enter a number: 4
#    $
#   $ $
#  $ $ $
# $ $ $ $

.data

enterSymbol: .asciiz "Enter a symbol: " #initialize symbol prompt
enterNum: .asciiz "Enter a number: " #initialize number prompt

.text
.globl main

main:

    #PRINT SYMBOL PROMPT
    li $v0, 4  #print string syscall code
    la $a0, enterSymbol #loads the symbol prompt into a0 register
    syscall #performs the system call

    #INPUT SYMBOL
    li  $v0, 12   #syscall for input string
    syscall #performs input

    add $s0, $0, $v0 #loads value into $s0

    #PRINT LINE BREAK
    li $v0, 11 #syscall code for print char
    li $a0, 10 #loads ASCII code for line break in a0
    syscall #performs print

    #PRINT NUMBER PROMPT
    li $v0, 4  #print string syscall code
    la  $a0, enterNum #loads the symbol prompt into a0 register
    syscall #performs the system call

    #INPUT NUMBER
    li  $v0, 5 #syscall code for input integer
    syscall #syscall for input integer
    add $s1, $0, $v0 #stores integer value into s0 register

    li, $v0, 11 #set v0 to print char mode for rest of program

    addi $s2, $0, 1 #initial value of i = 1
    addi $s1, $s1, 1 #n++; (useful for loop condition)

LoopRow: #We do not need to check if number input is less than one, it is assumed to be 1 or greater
    
    #i = s2, n = s1, symbol = s0, numSpaces = s3, j = $s4

    slt $t0, $s2, $s1 #if i less than n + 1 ~ i less than or equal to n (meaning we should continue), t0 = 1
    beq $t0, $zero, Exit #if t0 = 0, then we are done with the loop and are ready to exit

    sub $s3, $s1, $s2 #numSpaces = n-i
    addi $s4, $zero, 1 #initialize j = 1

    LoopLine: #loop for each line of the triangle

        slt $t1, $s1, $s4 #if n<j, t0 = 1, we are done with the loop
        bne $t1, $zero, ExitLoopLine #if t0 = 0, we are done and can move on from this loop

        slt $t2, $s3, $s4 #if numSpaces less than j+1 ~ numSpaces less than or equal to j, t2 = 1 and we move to If block
        bne $t2, $zero, Else #if t2 = 0, then we move to else block

        If: #if we need to type a space

            li $a0, 32 #load space character into a0
            syscall #print space
            j ExitConditional #move past the else block to the rest of code

        Else: #else - we need to type a symbol

            add $a0, $zero, $s0 #load symbol into a0
            syscall #print symbol
            li $a0, 32 #load space into a0
            syscall #print space

        ExitConditional: #exit the if/else statement

            addi $s4, $s4, 1 #increments j
            j LoopLine #jump to top of loop

    ExitLoopLine: #exit point of inner loop

        addi $s2, $s2, 1 #i++;

        li $a0, 10 #load line break char into a0
        syscall #print line break
    
        j LoopRow #returns to top of main loop

Exit: #system ending code

    li, $v0, 10    #system call for exiting program
    syscall    #syscall to exit 