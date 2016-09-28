# File:		printer.asm
# Author:	Tommy Bohde (txb2164)
#
# Description:	Concepts of Computer Systems (CSCI-250) Project
#		This program contains globally defined functions to print
#		to the screen. Intended for use by sudoku.asm.

# Global Definitions
PRINT_INT    = 1	# arg for syscall to print an int
PRINT_STRING = 4	# arg for syscall to print a string
.globl print_banner
.globl print_text_initial
.globl print_text_final
.globl print_err_input
.globl print_err_puzzle
.globl print_err_fatal
.globl print_board

.data
.align 2

# C-string literals to be used by the main routine
banner_border:	.asciiz "**************\n"
banner_string:	.asciiz "**  SUDOKU  **\n"
text_initial:	.asciiz "Initial Puzzle\n"
text_final:	.asciiz "Final Puzzle\n"
board_row_sep:	.asciiz "+-----+-----+\n"
char_pipe:	.asciiz "|"
char_space:	.asciiz " "
char_newline:	.asciiz "\n"
err_input:	.asciiz "ERROR: bad input value, Sudoku terminating\n"
err_impossible:	.asciiz "Impossible Puzzle\n"
err_program:	.asciiz "Fatal program error!\n"

########## Program Code ##########
.text
.align 2

##########
# description:	prints the sudoku banner
# arguments:	none
# returns:	none
##########
print_banner:
	la	$v0, PRINT_STRING	# set to syscall value for print_string
	la	$a0, char_newline
	syscall				# print blank line
	la	$a0, banner_border	
	syscall				# print banner top
	la	$a0, banner_string
	syscall				# print banner string
	la	$a0, banner_border	
	syscall				# print banner bottom
	la	$a0, char_newline
	syscall				# print blank line
	jr	$ra			# return

##########
# description:	prints the "Initial Puzzle" text header
# arguments:	none
# returns:	none
##########
print_text_initial:
	la	$v0, PRINT_STRING	# set to syscall value for print_string
	la	$a0, text_initial	
	syscall				# print initial puzzle text
	la	$a0, char_newline
	syscall				# print blank line
	jr	$ra

##########
# description:	prints the "Final Puzzle" text header
# arguments:	none
# returns:	none
##########
print_text_final:
	la	$v0, PRINT_STRING	# set to syscall value for print_string
	la	$a0, text_final
	syscall				# print final puzzle text
	la	$a0, char_newline
	syscall				# print blank line
	jr	$ra

##########
# description:	prints the error in the event of invalid input
# arguments:	none
# returns:	none
##########
print_err_input:
	la	$v0, PRINT_STRING	# set to syscall value for print_string
	la	$a0, err_input
	syscall				# print input error string
	jr	$ra			# return

##########
# description:	prints the error in the event of an impossible puzzle
# arguments:	none
# returns:	none
##########
print_err_puzzle:
	la	$v0, PRINT_STRING	# set to syscall value for print_string
	la	$a0, err_impossible
	syscall				# print impossible puzzle string
	jr	$ra			# return
	
##########
# description:	prints the error in the event of a fatal program error
# arguments:	none
# returns:	none
##########
print_err_fatal:
	la	$v0, PRINT_STRING	# set to syscall value for print_string
	la	$a0, err_program
	syscall				# print impossible puzzle string
	jr	$ra			# return

##########
# description:	prints the board
# arguments:	a0 - pointer to the first element of the array of values
# returns:	none
##########
print_board:
	addi	$sp, $sp, -20
	sw	$s4, 16($sp)		# push s4 to stack
	sw	$s3, 12($sp)		# push s3 to stack
	sw	$s2, 8($sp)		# push s2 to stack
	sw	$s1, 4($sp)		# push s1 to stack
	sw	$s0, 0($sp)		# push s0 to stack

	li	$t0, 3			# used in comparisons
	li	$t1, 36			# used in comparisons

	move	$s0, $a0		# move pointer to s0
	la	$v0, PRINT_STRING	# set to syscall value for print_string
	la	$a0, board_row_sep
	syscall				# print top of board
	
	move	$s1, $zero		# set section counter to 0
	move	$s3, $zero		# set line counter to 0
	move	$s4, $zero		# set array position counter to 0
print_sec:
	addi	$s1, $s1, 1		# increment section counter
	beq	$s1, $t0, print_line_end# print the end of the line if necessary
	move	$s2, $zero		# set value counter to 0
	la	$v0, PRINT_STRING	# set to syscall value for print_string
	la	$a0, char_pipe
	syscall				# print a pipe
print_value:
	lw	$a0, 0($s0)		# put the current value into t0
	beq	$a0, $zero, is_empty	# branch if no value
	la	$v0, PRINT_INT		# set to syscall value for print_int
	syscall				# print the value
	j	value_printed
is_empty:
	la	$v0, PRINT_STRING	# set to syscall value for print_string
	la	$a0, char_space
	syscall				# print a space
value_printed:
	addi	$s0, $s0, 4		# increment array pointer
	addi	$s4, $s4, 1		# increment array position counter
	addi	$s2, $s2, 1		# increment value counter
	beq	$s2, $t0, print_sec	# begin new section if necessary
	la	$v0, PRINT_STRING	
	la	$a0, char_space
	syscall				# otherwise, print a space 
	j	print_value		# and iterate again

# subroutine to print the end of a line ("|\n") and row seperator when necessary
print_line_end:
	la	$v0, PRINT_STRING	# set to syscall value for print_string
	la	$a0, char_pipe
	syscall				# print a pipe
	la	$a0, char_newline
	syscall				# print a newline
	addi	$s3, $s3, 1		# increment line counter
	rem	$t9, $s3, 2		# t9 = s3 % 2
	bne	$t9, $zero, skip_sep	# skip the line seperator if not needed
	la	$a0, board_row_sep
	syscall				# print board row seperator
	beq	$s4, $t1, board_printed	# branch to end if all values printed
skip_sep:
	move	$s1, $zero		# reset section counter
	j	print_sec		# begin a new section
	
# subroutine to print the bottom padding blank line and return when completed
board_printed:
	la	$v0, PRINT_STRING	# set to syscall value for print_string
	la	$a0, char_newline
	syscall				# print a newline
	
	lw	$s4, 16($sp)		# pop s4 from stack
	lw	$s3, 12($sp)		# pop s3 from stack
	lw	$s2, 8($sp)		# pop s2 from stack
	lw	$s1, 4($sp)		# pop s1 from stack
	lw	$s0, 0($sp)		# pop s0 from stack
	addi	$sp, $sp, 20
	jr	$ra			# return
