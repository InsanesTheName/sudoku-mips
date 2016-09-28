# File:		solver.asm
# Author:	Tommy Bohde (txb2164)
#
# Description:	Concepts of Computer Systems (CSCI-250) Project
#		This program contains globally defined functions to 
#		brute-force solve a 6x6 sudoku puzzle.

# Global Definitions
.globl solve_puzzle
.globl print_err_fatal
.globl puzzle

.data
.align 2

# indexes of values in a given row
row_1:	.word  0,  1,  2,  3,  4,  5
row_2:	.word  6,  7,  8,  9, 10, 11
row_3:	.word 12, 13, 14, 15, 16, 17
row_4:	.word 18, 19, 20, 21, 22, 23
row_5:	.word 24, 25, 26, 27, 28, 29
row_6:	.word 30, 31, 32, 33, 34, 35

# indexes of values in a given column
col_1:	.word 0,  6, 12, 18, 24, 30
col_2:	.word 1,  7, 13, 19, 25, 31
col_3:	.word 2,  8, 14, 20, 26, 32
col_4:	.word 3,  9, 15, 21, 27, 33
col_5:	.word 4, 10, 16, 22, 28, 34
col_6:	.word 5, 11, 17, 23, 29, 35

# indexes of values in a given box
box_1:	.word  0,  1,  2,  6,  7,  8
box_2:	.word  3,  4,  5,  9, 10, 11
box_3:	.word 12, 13, 14, 18, 19, 20
box_4:	.word 15, 16, 17, 21, 22, 23
box_5:	.word 24, 25, 26, 30, 31, 32
box_6:	.word 27, 28, 29, 33, 34, 35

column:	.word 0
row:	.word 0

########## Program Code ##########
.text
.align 2

##########
# description:	solves the puzzle using a brute-force backtracking algorithm
# arguments:	a0 - pointer to the array of values (the puzzle)
#		a1 - pointer to the array of readonly flags (parallel to puzzle)
# returns:	none
##########
solve_puzzle:
	# push all necessary registers to stack (just to be safe)
	addi	$sp, $sp, -36
	sw	$ra, 32($sp)		# push ra to stack
	sw	$s7, 28($sp)		# push s7 to stack
	sw	$s6, 24($sp)		# push s6 to stack
	sw	$s5, 20($sp)		# push s5 to stack
	sw	$s4, 16($sp)		# push s4 to stack
	sw	$s3, 12($sp)		# push s3 to stack
	sw	$s2,  8($sp)		# push s2 to stack
	sw	$s1,  4($sp)		# push s1 to stack
	sw	$s0,  0($sp)		# push s0 to stack

	move	$s0, $a0		# copy puzzle pointer to s0
	move	$s1, $a1		# copy readonly flag pointer to s1
	move	$s2, $zero		# current cell number (0-35)
	li	$s3, 1			# number to test
solving_loop:
	lw	$t0, 0($s1)		# load readonly flag into t0 
	bne	$t0, $zero, skip_cell
	move	$a0, $zero
	move	$a0, $s2		# set arg 1 to index to test
	move	$a1, $s3		# set arg 2 to value to test
	jal	is_valid		# check if the value is valid	
	bne	$v0, $zero, wasnt_valid	# if not, change path appropriately
	j	advance_cell
wasnt_valid:
	addi	$s3, $s3, 1		# increment number to test
	slti	$t9, $s3, 7		# t9 = s3 < 7
	beq	$t9, $zero, backtrack	
	j	solving_loop		# try a higher value

backtrack:
	lw	$t9, 0($s1)		# read the readonly flag from memory
	bne	$t9, $zero, skip_zeroing# if readonly, skip zeroing the cell
	sw	$zero, 0($s0)
skip_zeroing:
	addi	$s0, $s0, -4		# decrement puzzle pointer
	addi	$s1, $s1, -4		# decrement readonly flag pointer
	addi	$s2, $s2, -1		# decrement cell number
	slt	$t9, $s2, $zero
	bne	$t9, $zero, no_solution	# change execution if unsolvable
	lw	$s3, 0($s0)		# read the current value from memory
	lw	$t9, 0($s1)		# read the readonly flag from memory
	bne	$t9, $zero, backtrack	# backtrack again if readonly
	j	wasnt_valid		# iterate again

advance_cell:
	sw	$s3, 0($s0)		# store the current value to memory
skip_cell:
	addi	$s0, $s0, 4		# increment puzzle pointer
	addi	$s1, $s1, 4		# increment readonly flag pointer
	addi	$s2, $s2, 1		# increment cell number
	li	$s3, 1			# reset number to test
	li	$t9, 36
	beq	$s2, $t9, solution_found# change execution if solution is found
	j	solving_loop		# iterate again

##########
# description:	checks a digit to see if it's valid in its place in the puzzle
# arguments:	a0 - the index to check
#		a1 - the value to check
# returns:	v0 - 0 if valid, -1 if invalid
##########
is_valid:
	# push all necessary registers to stack (just to be safe)
	addi	$sp, $sp, -36
	sw	$ra, 32($sp)		# push ra to stack
	sw	$s7, 28($sp)		# push s7 to stack
	sw	$s6, 24($sp)		# push s6 to stack
	sw	$s5, 20($sp)		# push s5 to stack
	sw	$s4, 16($sp)		# push s4 to stack
	sw	$s3, 12($sp)		# push s3 to stack
	sw	$s2,  8($sp)		# push s2 to stack
	sw	$s1,  4($sp)		# push s1 to stack
	sw	$s0,  0($sp)		# push s0 to stack

	move	$v0, $zero		# valid until proven otherwise

# column checking code
check_column:				# label for readability/clarity only!
	rem	$t0, $a0, 6		# get the column number (index % 6)
	li	$t1, 1			# load int values for comparisons
	li	$t2, 2
	li	$t3, 3
	li	$t4, 4
	li	$t5, 5
	beq	$t0, $zero, load_col1
	beq	$t0, $t1, load_col2
	beq	$t0, $t2, load_col3
	beq	$t0, $t3, load_col4
	beq	$t0, $t4, load_col5
	beq	$t0, $t5, load_col6
load_col1:
	la	$s0, col_1
	j	col_loaded
load_col2:
	la	$s0, col_2
	j	col_loaded
load_col3:
	la	$s0, col_3
	j	col_loaded
load_col4:
	la	$s0, col_4
	j	col_loaded
load_col5:
	la	$s0, col_5
	j	col_loaded
load_col6:
	la	$s0, col_6
	j	col_loaded

col_loaded:
	sw	$t0, column		# store the column number for reference
	move	$s1, $zero		# loop counter
col_loop:
	lw	$t0, 0($s0)		# get the cell number
	mul	$t1, $t0, 4		# multiply by 4 and ...
	la	$t2, puzzle
	add	$t1, $t1, $t2		# calculate cell's address
	lw	$t0, 0($t1)		# get the value
	slt	$t7, $t0, $a1		# t7 = t0 < a1
	sle	$t8, $t0, $a1		# t7 = t0 <= a1
	xor	$t9, $t7, $t8		# t9 = t7 XOR t8 (1 if equal!)
	bne	$t9, $zero, invalid
	addi	$s0, $s0, 4		# increment value pointer
	addi	$s1, $s1, 1		# increment loop counter
	li	$t9, 6			# end of loop comparator
	beq	$s1, $t9, check_row	# loop has finished w/o finding invalid
	j	col_loop		# otherwise iterate again

# row checking code
check_row:
	move	$t0, $a0		# temporary index
	move	$t7, $zero		# row counter
row_find_loop:
	addi	$t0, $t0, -6
	slt	$t9, $t0, $zero		# t9 = t0 < 0
	li	$t8, 1			# comparator
	beq	$t9, $t8, row_found
	addi	$t7, $t7, 1		# increment row counter
	j	row_find_loop		# iterate again
row_found:
	li	$t1, 1			# load int values for comparisons
	li	$t2, 2
	li	$t3, 3
	li	$t4, 4
	li	$t5, 5
	beq	$t7, $zero, load_row1
	beq	$t7, $t1, load_row2
	beq	$t7, $t2, load_row3
	beq	$t7, $t3, load_row4
	beq	$t7, $t4, load_row5
	beq	$t7, $t5, load_row6
load_row1:
	la	$s0, row_1	
	j	row_loaded
load_row2:
	la	$s0, row_2
	j	row_loaded
load_row3:
	la	$s0, row_3
	j	row_loaded
load_row4:
	la	$s0, row_4
	j	row_loaded
load_row5:
	la	$s0, row_5
	j	row_loaded
load_row6:
	la	$s0, row_6
	j	row_loaded

row_loaded:
	sw	$t7, row		# store the row number for reference
	move	$s1, $zero		# loop counter
row_loop:
	lw	$t0, 0($s0)		# get the cell number
	mul	$t1, $t0, 4		# multiply by 4 and ...
	la	$t2, puzzle
	add	$t1, $t1, $t2		# calculate cell's address
	lw	$t0, 0($t1)		# get the value
	slt	$t7, $t0, $a1		# t7 = t0 < a1
	sle	$t8, $t0, $a1		# t7 = t0 <= a1
	xor	$t9, $t7, $t8		# t9 = t7 XOR t8 (1 if equal!)
	bne	$t9, $zero, invalid
	addi	$s0, $s0, 4		# increment value pointer
	addi	$s1, $s1, 1		# increment loop counter
	li	$t9, 6			# end of loop comparator
	beq	$s1, $t9, check_box	# loop has finished w/o finding invalid
	j	row_loop		# otherwise iterate again

# box checking code
check_box:
	lw	$t0, column		# get column
	lw	$t1, row		# get row
	li	$t9, 1			# comparator
	slti	$t2, $t0, 3		# t2 == 1 if boxcol 1, 0 if boxcol 2
	slti	$t3, $t1, 2		# t3 == 1 if boxrow 1, 0 if 2 or 3
	slti	$t4, $t1, 4		# t4 == 1 if boxrow 1 or 2, 0 if 3
	and	$t5, $t2, $t3		# t5 = t2 && t3
	beq	$t5, $t9, load_box1
	and	$t5, $t2, $t4		# t5 = t2 && t4
	beq	$t5, $t9, load_box3
	beq	$t2, $t9, load_box5
	or	$t5, $t3, $t4		# t2 = t3 || t4 (0 if box 6)
	beq	$t5, $zero, load_box6
	beq	$t3, $t9, load_box2	
	beq	$t4, $t9, load_box4	# alternatively, j load_box4
	jal	print_err_fatal		# this should be unreachable
	li	$v0, 10			# load syscall value for exit
	syscall				# exit the program
load_box1:
	la	$s0, box_1	
	j	box_loaded
load_box2:
	la	$s0, box_2
	j	box_loaded
load_box3:
	la	$s0, box_3
	j	box_loaded
load_box4:
	la	$s0, box_4
	j	box_loaded
load_box5:
	la	$s0, box_5
	j	box_loaded
load_box6:
	la	$s0, box_6
	j	box_loaded

box_loaded:
	move	$s1, $zero		# loop counter
box_loop:
	lw	$t0, 0($s0)		# get the cell number
	mul	$t1, $t0, 4		# multiply by 4 and ...
	la	$t2, puzzle
	add	$t1, $t1, $t2		# calculate cell's address
	lw	$t0, 0($t1)		# get the value
	slt	$t7, $t0, $a1		# t7 = t0 < a1
	sle	$t8, $t0, $a1		# t7 = t0 <= a1
	xor	$t9, $t7, $t8		# t9 = t7 XOR t8 (1 if equal!)
	bne	$t9, $zero, invalid
	addi	$s0, $s0, 4		# increment value pointer
	addi	$s1, $s1, 1		# increment loop counter
	li	$t9, 6			# end of loop comparator
	beq	$s1, $t9, valid		# loop has finished w/o finding invalid
	j	box_loop		# otherwise iterate again

# execution moves here if the value given (a1) cannot go in the cell given (a0)
invalid:
	li	$v0, -1			# set v0 to indicate invalid value

# execution jumps here if no conflicts for the value given (a1) are found
valid:
	# pop all registers from stack
	lw	$ra, 32($sp)		# pop ra from stack
	lw	$s7, 28($sp)		# pop s7 from stack
	lw	$s6, 24($sp)		# pop s6 from stack
	lw	$s5, 20($sp)		# pop s5 from stack
	lw	$s4, 16($sp)		# pop s4 from stack
	lw	$s3, 12($sp)		# pop s3 from stack
	lw	$s2,  8($sp)		# pop s2 from stack
	lw	$s1,  4($sp)		# pop s1 from stack
	lw	$s0,  0($sp)		# pop s0 from stack
	addi	$sp, $sp, 36
	jr	$ra			# return

# exection moves here if there is found to be no solution to the given puzzle
no_solution:
	li	$v0, -1
	j	solved

# execution moves here when the complete solution is found
solution_found:
	li	$v0, 0
	j	solved

solved:
	# pop all registers from stack
	lw	$ra, 32($sp)		# pop ra from stack
	lw	$s7, 28($sp)		# pop s7 from stack
	lw	$s6, 24($sp)		# pop s6 from stack
	lw	$s5, 20($sp)		# pop s5 from stack
	lw	$s4, 16($sp)		# pop s4 from stack
	lw	$s3, 12($sp)		# pop s3 from stack
	lw	$s2,  8($sp)		# pop s2 from stack
	lw	$s1,  4($sp)		# pop s1 from stack
	lw	$s0,  0($sp)		# pop s0 from stack
	addi	$sp, $sp, 36

	jr	$ra			# return
