# File:		sudoku.asm
# Author:	Tommy Bohde (txb2164)
#
# Description:	Concepts of Computer Systems (CSCI-250) Project
#		This program solves a 6x6 sodoku puzzle.

# Global Definitions
READ_INT     = 5	# arg for syscall to read an int
READ_STRING  = 8	# arg for syscall to read a string
.globl print_banner
.globl print_text_initial
.globl print_text_final
.globl print_err_input
.globl print_err_puzzle
.globl print_board
.globl solve_puzzle
.globl puzzle

########## Data Segment ##########
.data
.align 2

# space for the puzzle (36 words/numbers)
puzzle:		.space 144
puzzle_ro:	.space 144

########## Program Code ##########
.text
.align 2
.globl main

##########
# Description:	Main program entry point
# Arguments:	none
# Returns:	none
##########
main:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)		# push ra to stack

	jal	print_banner		# print the banner
	
	la	$s0, puzzle		# create array pointer
	li	$s1, 0			# counter for input loop
	li	$s2, 36			# input loop terminating condition
	la	$s3, puzzle_ro		# create pointer for readonly flag array
	li	$t1, 1			# used to set readonly flags
	j	collect_input

# read values one by one and store them in memory
collect_input:
	la	$v0, READ_INT	
	syscall				# read the digit
	slt	$t8, $v0, $zero		# check the digit for negativity
	bne	$t8, $zero, error_input	
	addi	$t9, $v0, -6
	slt	$t8, $zero, $t9		# confirm positive validity
	bne	$t8, $zero, error_input
	sw	$v0, 0($s0)		# store the digit
	sw	$t1, 0($s3)		# turn readonly flag on (default)
	bne	$v0, $zero, not_zero	# skip next instruction if not zero
	sw	$zero, 0($s3)		# otherwise, turn readonly flag off
not_zero:
	addi	$s1, 1			# count the digit
	beq	$s1, $s2, rec_all	# branch if we're done
	addi	$s0, $s0, 4		# increment the value array pointer
	addi	$s3, $s3, 4		# increment the readonly array pointer
	j	collect_input		# and read another

# all input received
rec_all:
	jal	print_text_initial	# print the initial puzzle string
	la	$a0, puzzle		# point arg 1 to the puzzle value array
	la	$a1, puzzle_ro		# point arg 2 to readonly flag array
	jal	print_board		# print the board
	la	$a0, puzzle		# point arg 1 to the puzzle value array
	la	$a1, puzzle_ro		# point arg 2 to readonly flag array
	jal	solve_puzzle		# solve the puzzle!
	beq	$v0, $zero, success	# branch if solving was successful
	jal	print_err_puzzle	# print impossible puzzle text
	j	end

success:
	jal	print_text_final
	la	$a0, puzzle		# point arg 1 to the puzzle value array
	jal	print_board
	j	end

# execution moves here when it's time to terminate the program
end:
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4		# pop ra from stack
	jr	$ra			# end the program

# execution branches here when invalid input is received
error_input:
	jal	print_err_input
	j	end
