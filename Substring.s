.data

#Static arrays used to store the two string inputs
str1: .space 1000 # reserve a 100-byte memory block
substr1: .space 500 # reserve a 50-byte memory block
#String literals

printstr1: .asciiz "Enter a string: "
printstr2: .asciiz "Enter the substring: "
printstr3: .asciiz "# of substring occurrence(s) found: "

#Allocate additional memory here, if necessary
.text
.globl main

#The buffer values for string inputs have been increased, and functions return values into v1 instead of v0 to avoid syscall issues
main:

    li, $v0, 4 #to print prompt#1
    la $a0, printstr1
    syscall

    li, $v0, 8 #input the main string
    la $a0, str1
    li $a1, 100 
    syscall

    li, $v0, 4 #print prompt #2
    la $a0, printstr2
    syscall
    li, $v0, 8 #input the substring
    la $a0, substr1
    li $a1, 100
    syscall

    li, $v0, 4 #Const part of Output
    la $a0, printstr3
    syscall
    la $a0, str1 #load the address of str1 to $a0
    la $a1, substr1 #load the address of substr1 to $a1

    #---DEBUG-PRINT LENGTH OF STRING---
    #jal strlen 
    #add $a0, $v1, $0
    #li $v0, 1
    #syscall
    #----------------------------------

    #no temporaries to be stored

    jal substring_count #procedure call from main
    add $a0, $v1, $zero #return value copied to $a0

    li, $v0, 1 #print integer
    syscall

    li, $v0, 10 #clean exit
    syscall

#---Returns length of null terminated string---
#a0 = base address of target string
#v1 = return value of strlen
strlen: 

    #push saved temps, args, and ra onto stack
    addi $sp, $sp, -32
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $s6, 24($sp)
    sw $s7, 28($sp)

    addi $sp, $sp, -16
    sw $a0, 12($sp)
    sw $a1, 8($sp)
    sw $a2, 4($sp)
    sw $ra, 0($sp)

    li $s0, 0 #s0 = length of string
    add $s1, $a0, 0 #s1 = address of current character in string

    strlenLoop:

        lb $t0, 0($s1) #loads current character into t0

        beq $t0, 10, exitstrlenLoop #if t3 = 10 (NEW LINE char when user hits enter key), exit
        addi $s0, $s0, 1 #s0++, len++
        add $s1, $s1, 1 #s1++, base address++
        j strlenLoop #repeat loop

    exitstrlenLoop:

    add $v1, $s0, 0 #return value into v1

    #pop saved temps, args, and ra off of stack into appropriate registers
    lw $ra, 0($sp)
    lw $a2, 4($sp)
    lw $a1, 8($sp)
    lw $a0, 12($sp)
    addi $sp, $sp, 16

    lw $s7, 28($sp)
    lw $s6, 24($sp)
    lw $s5, 20($sp)
    lw $s4, 16($sp)
    lw $s3, 12($sp)
    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 32

    jr $ra #return to caller

#---Determines the frequency of a substring in a larger string---
#a0 = string
#a1 = substring
#v1 = return value
substring_count:
    
    #push saved temps, args, and ra onto stack
    addi $sp, $sp, -32
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $s6, 24($sp)
    sw $s7, 28($sp)

    addi $sp, $sp, -16
    sw $a0, 12($sp)
    sw $a1, 8($sp)
    sw $a2, 4($sp)
    sw $ra, 0($sp)

    li $s0, 0 #s0 = matches = 0

    add $s1, $a0, 0 #s1 = address of current char in string
    add $s2, $a1, 0 #s2 = address of current char in substring

    #(addi $a0, $s1, 0) -target string is already in a0
    #no temps to be stored
    jal strlen #calls strlen function
    addi $s3, $v1, 0 #s3 = string.length

    addi $a0, $s2, 0 #puts substring address in a0 for strlen function
    #no temps to be stored
    jal strlen #calls strlen function
    addi $s4, $v1, 0 #stores sub.length in s4

    #---DEBUG-PRINT LENGTH OF STRING AND SUB---
    #li $v0, 1
    #addi $a0, $s3, 0
    #syscall

    #addi $a0, $s4, 0
    #syscall
    #-----------------------------------------

    #both str.length (s3) and sub.length (s4) must be greater than 0
    beq $s3, $zero, substring_count_exit
    beq $s4, $zero, substring_count_exit

    #we can also jump to exit if sub.length (s4) > str.length (s3)
    bgt $s4, $s3, substring_count_exit

    #we have valid string and substring
    li $s5, 0 #i , count iterations of outer loop
    sub $t0, $s3, $s4 #str.length - sub.length
    addi $s7, $t0, 1 #str.length-sub.length+1 = iterations = number of times needed to iterate through outer loop

    string_loop: #loops through string in search of substrings

        bge $s5, $s7, string_exit_loop #break when i >= iterations

        li $t0, 0 #count number of chars in common
        li $s6, 0 #j , count iterations of inner loop

        substring_loop:

            bge $s6, $s4, exit_substring_loop #breaks if j >= sub.length

            add $t1, $s5, $s6 #offset for string char (i+j)
            add $t2, $s1, $t1 #address of string char (address + (i+j))
            lb $t3, 0($t2) #curr string char

            add $t4, $s2, $s6 #address of substring char (address + j)
            lb $t5, 0($t4) #curr substring char

            if_chars_equal:

                bne $t3, $t5, exit_if_chars_equal #if sub[j] == str[strIdx]
                addi $t0, $t0, 1 #count++

            exit_if_chars_equal:

            addi $s6, $s6, 1 #j++

            j substring_loop #jump back to top of inner loop
        
        exit_substring_loop:

        if_count_equals_sublen: #if count == sub.length, then we found a complete instance of the substring

            bne $t0, $s4, exit_if_count_equals_sublen #if count == sub.length
            addi $s0, $s0, 1 #count++

        exit_if_count_equals_sublen:

        addi $s5, $s5, 1 #i++

        j string_loop #jump back to top of outer loop

    string_exit_loop:

    substring_count_exit:

    addi $v1, $s0, 0 #moves count into v1 for return

    #pop saved temps, args, and ra off of stack into appropriate registers
    lw $ra, 0($sp)
    lw $a2, 4($sp)
    lw $a1, 8($sp)
    lw $a0, 12($sp)
    addi $sp, $sp, 16

    lw $s7, 28($sp)
    lw $s6, 24($sp)
    lw $s5, 20($sp)
    lw $s4, 16($sp)
    lw $s3, 12($sp)
    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 32

    jr $ra #return to caller




