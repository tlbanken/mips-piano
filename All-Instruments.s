.data
DISPLAY: .space  16384
.data
instr_prompt: .asciiz "\n\n Enter Instrument number: "

.text
main:
	li $v0, 4
    la $a0, instr_prompt
    syscall
	
	li $v0, 5
	syscall
	move $s1, $v0
	
END_OF_DISPLAY:

start:
	jal	drawPiano	# initialize the piano gui

	lui     $t0, 0xffff
	
	addi    $t8, $zero,1
	sll     $t8, $zero,20    # LOOP_COUNT = 2^20

	add	$s7, $zero, $zero	# zero out s7 (octave scale +12 . . .)
	add	$s6, $zero, $zero	# zero out s6 (octave scale +1 . . .)

OUTER_LOOP:
	lw      $t1, 0($t0)      # read control register
	andi    $t1, $t1,0x1     # mask off all but bit 0 (the 'ready' bit)

.data
NOT_READY_MSG: .asciiz "Ready bit is zero, looping until I find something else...\n"
.text
	bne     $t1,$zero, READY

	# print_str(NOT_READY_MSG)
	addi    $v0, $zero,4
	la      $a0, NOT_READY_MSG
	syscall

NOT_READY_LOOP:
	lw      $t1, 0($t0)      # read control register
	andi    $t1, $t1,0x1     # mask off all but bit 0 (the 'ready' bit)
	beq     $t1,$zero, NOT_READY_LOOP

READY:
	# read the actual typed character
	lw      $t1, 4($t0)

	# print_int(t1)
	addi    $v0, $zero,1
	add     $a0, $t1,$zero
	syscall

	# print_chr(' ')
	addi    $v0, $zero,11
	addi    $a0, $zero,' '
	syscall
	
	# print_chr(t1)
	addi    $v0, $zero,11
	add     $a0, $t1,$zero
	syscall

	# print_chr('\n')
	addi    $v0, $zero,11
	addi    $a0, $zero,'\n'
	syscall

.data
OCT_MSG:		.asciiz "Octave Scale: "
.text
	# special keys for changing octave scale
	beq	$t1, '<', OCT_DOWN
	beq	$t1, ',', OCT_DOWN
	beq	$t1, '.', OCT_UP
	beq	$t1, '>', OCT_UP

	j	CHECK_NOTE

# handle changing octave offsets and capping octave limits
OCT_UP:
	addi	$s6, $s6, 1
	addi	$s7, $s7, 12
	slti	$t7, $s7, 24
	beq	$t7, $zero, CAP_OCT
	j	END_NOTES
CAP_OCT:
	addi	$s7, $s7, -12
	addi	$s6, $s6, -1
	j	END_NOTES
OCT_DOWN:
	addi	$s6, $s6, -1
	addi	$s7, $s7, -12
	slti	$t7, $s7, -24
	bne	$t7, $zero, FLOOR_OCT
	j	END_NOTES
FLOOR_OCT:
	addi	$s6, $s6, 1
	addi	$s7, $s7, 12
	j	END_NOTES

	# check which note was played
CHECK_NOTE:
	beq $t1, 'Z', main
	beq	$t1, 'q', Eb3
	beq	$t1, 'a', E3
	beq	$t1, 's', F3
	beq	$t1, 'e', Gb3
	beq	$t1, 'd', G3
	beq	$t1, 'r', Ab3
	beq	$t1, 'f', A3
	beq	$t1, 't', Bb3
	beq	$t1, 'g', B3
	beq	$t1, 'h', C4
	beq	$t1, 'u', Db4
	beq	$t1, 'j', D4
	beq	$t1, 'i', Eb4
	beq	$t1, 'k', E4
	beq	$t1, 'l', F4
	beq	$t1, 'p', Gb4
	beq	$t1, ';', G4
	beq	$t1, '[', Ab4
	beq	$t1, 39, A4	# ascii val for '
	beq	$t1, ']', Bb4
	beq	$t1, 92, B4	# ascii val for \
	beq	$t1, 'H', C5
	beq	$t1, 'U', Db5
	beq	$t1, 'J', D5
	beq	$t1, 'I', Eb5
	beq	$t1, 'K', E5
	beq	$t1, 'L', F5
	beq	$t1, 'P', Gb5
	beq	$t1, ':', G5
	beq	$t1, '{', Ab5
	beq	$t1, '"', A5
	beq	$t1, '}', Bb5
	beq	$t1, '|', B5

	# duplicate notes for consistency with shift
	beq	$t1, 'Q', Eb4
	beq	$t1, 'A', E4
	beq	$t1, 'S', F4
	beq	$t1, 'E', Gb4
	beq	$t1, 'D', G4
	beq	$t1, 'R', Ab4
	beq	$t1, 'F', A4
	beq	$t1, 'T', Bb4
	beq	$t1, 'G', B4

	j	END_NOTES
	
.data
Eb3_MSG:	.asciiz "Eb3\n"
E3_MSG:		.asciiz "E3\n"
F3_MSG:		.asciiz "F3\n"
Gb3_MSG:	.asciiz "Gb3\n"
G3_MSG:		.asciiz "G3\n"
Ab3_MSG:	.asciiz "Ab3\n"
A3_MSG:		.asciiz "A3\n"
Bb3_MSG:	.asciiz "Bb3\n"
B3_MSG:		.asciiz "B3\n"
C4_MSG:		.asciiz "C4\n"
Db4_MSG:	.asciiz "Db4\n"
D4_MSG:		.asciiz "D4\n"
Eb4_MSG:	.asciiz "Eb4\n"
E4_MSG:		.asciiz "E4\n"
F4_MSG:		.asciiz "F4\n"
Gb4_MSG:	.asciiz "Gb4\n"
G4_MSG:		.asciiz "G4\n"
Ab4_MSG:	.asciiz "Ab4\n"
A4_MSG:		.asciiz "A4\n"
Bb4_MSG:	.asciiz "Bb4\n"
B4_MSG:		.asciiz "B4\n"
C5_MSG:		.asciiz "C5\n"
Db5_MSG:	.asciiz "Db5\n"
D5_MSG:		.asciiz "D4\n"
Eb5_MSG:	.asciiz "Eb5\n"
E5_MSG:		.asciiz "E5\n"
F5_MSG:		.asciiz "F5\n"
Gb5_MSG:	.asciiz "Gb5\n"
G5_MSG:		.asciiz "G5\n"
Ab5_MSG:	.asciiz "Ab5\n"
A5_MSG:		.asciiz "A5\n"
Bb5_MSG:	.asciiz "Bb5\n"
B5_MSG:		.asciiz "B5\n"

.text
	# MIDI out syscall
	# $v0 = 31
	# $a0 = pitch (0-127)
	# $a1 = duration in milliseconds
	# $a2 = instrument (0-127)
	# $a3 = volume (0-127)

Eb3: # 51
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 1852
	addi	$t4, $zero, 0x800000
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, Eb3_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 51
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, 0
	sw	$t4, 0($s0)

	j	END_NOTES
E3: # 52
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2112
	addi	$t4, $zero, 0x800000
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, E3_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 52
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
F3: # 53
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2116
	addi	$t4, $zero, 0xCC0000
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, F3_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 53
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
Gb3: # 54
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 1864
	addi	$t4, $zero, 0xFFD700
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, Gb3_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 54
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, 0
	sw	$t4, 0($s0)

	j	END_NOTES
G3: # 55
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2124
	addi	$t4, $zero, 0x80000
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, G3_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 55
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
Ab3: # 56
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 1872
	addi	$t4, $zero, 0x800000
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, Ab3_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 56
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, 0
	sw	$t4, 0($s0)

	j	END_NOTES
A3: # 57
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2132
	addi	$t4, $zero, 0xCC0000
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, A3_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 57
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
Bb3: # 58
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 1880
	addi	$t4, $zero, 0xFFA500
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, Bb3_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 58
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, 0
	sw	$t4, 0($s0)

	j	END_NOTES
B3: # 59
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2140
	addi	$t4, $zero, 0xDAA520
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, B3_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 59
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
C4: # 60
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2144
	addi	$t4, $zero, 0xFFD700
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, C4_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 60
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
Db4: # 61
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 1892
	addi	$t4, $zero, 0xFFFF00
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, Db4_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 61
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, 0
	sw	$t4, 0($s0)

	j	END_NOTES
D4: # 62
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2152
	addi	$t4, $zero, 0xF7DE38
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, D4_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 62
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
Eb4: # 63
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 1900
	addi	$t4, $zero, 0xC7B22B
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, Eb4_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 63
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, 0
	sw	$t4, 0($s0)

	j	END_NOTES
E4: # 64
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2160
	addi	$t4, $zero, 0xA8C72B
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, E4_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 64
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
F4: # 65
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2164
	addi	$t4, $zero, 0xADFF2F
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, F4_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 65
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
Gb4: # 66
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 1912
	addi	$t4, $zero, 0x00FF00
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, Gb4_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 66
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, 0
	sw	$t4, 0($s0)

	j	END_NOTES
G4: # 67
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2172
	addi	$t4, $zero, 0x228B22
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, G4_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 67
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
Ab4: # 68
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 1920
	addi	$t4, $zero, 0x20B2AA
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, Ab4_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 68
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, 0
	sw	$t4, 0($s0)

	j	END_NOTES
A4: # 69
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2180
	addi	$t4, $zero, 0x008B8B
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, A4_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 69
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
Bb4: # 70
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 1928
	addi	$t4, $zero, 0x00CED1
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, Bb4_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 70
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, 0
	sw	$t4, 0($s0)

	j	END_NOTES
B4: # 71
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2188
	addi	$t4, $zero, 0x4682B4
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, B4_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 71
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
C5: # 72
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2192
	addi	$t4, $zero, 0x6B8E23
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, C5_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 72
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
Db5: # 73
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 1940
	addi	$t4, $zero, 0x6495ED
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, Db5_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 73
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, 0
	sw	$t4, 0($s0)

	j	END_NOTES
D5: # 74
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2200
	addi	$t4, $zero, 0x00BFFF
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, D5_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 74
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
Eb5: # 75
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 1948
	addi	$t4, $zero, 0x00FFFF
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, Eb5_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 75
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, 0
	sw	$t4, 0($s0)

	j	END_NOTES
E5: # 76
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2208
	addi	$t4, $zero, 0x38D8F7
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, E5_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 76
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
F5: # 77
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2212
	addi	$t4, $zero, 0x8A2BE2
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, F5_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 77
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
Gb5: # 78
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 1960
	addi	$t4, $zero, 0x483D8B
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, Gb5_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 78
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, 0
	sw	$t4, 0($s0)

	j	END_NOTES
G5: # 79
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2220
	addi	$t4, $zero, 0xFF00FF
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, G5_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 79
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
Ab5: # 80
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 1968
	addi	$t4, $zero, 0xFFEFD5
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, Ab5_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 80
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, 0
	sw	$t4, 0($s0)

	j	END_NOTES
A5: # 81
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2228
	addi	$t4, $zero, 0xC329E2
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, A5_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 81
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES
Bb5: # 82
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 1976
	addi	$t4, $zero, 0xA907CA
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, Bb5_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 82
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, 0
	sw	$t4, 0($s0)

	j	END_NOTES
B5: # 83
	# highlight key red
	la	$s0, DISPLAY
	addi	$s0, $s0, 2236
	addi	$t4, $zero, 0x680E7A
	sw	$t4, 0($s0)

	# print out note name
	addi	$v0, $zero, 4
	la	$a0, B5_MSG
	syscall

	# play note
	addi	$v0, $zero, 31
	addi	$a0, $s7, 83
	addi	$a1, $zero, 500
	add 	$a2, $zero, $s1
	addi	$a3, $zero, 127
	syscall

	# sleep for 50 miliseconds
	addi	$v0, $zero, 32
	addi	$a0, $zero, 50
	syscall

	# turn back to original color
	addi	$t4, $zero, -1
	sw	$t4, 0($s0)

	j	END_NOTES

END_NOTES:
	# print("Octave scale: %d", oct_scale);
	addi	$v0, $zero, 4
	la	$a0, OCT_MSG
	syscall

	addi	$v0, $zero, 1
	add	$a0, $zero, $s6
	syscall

	addi	$v0, $zero, 11
	addi	$a0, $zero, '\n'
	syscall
	
DELAY_LOOP:
	addi    $t2, $zero,0      # i=0
	slt     $t3, $t2,$t8      # i < LOOP_COUNT
	beq     $t3,$zero, DELAY_DONE

	addi    $t2, $t2,1        # i++
	j       DELAY_LOOP
	
DELAY_DONE:
	j       OUTER_LOOP



#---------------------------------------------------------------------------
# drawPiano()
#
# Draws the initial piano gui.
#
# assumes a 16x64 display.  To set this up, do the following steps:
#    - Tools->Bitmap Display
#    - Set "Unit width/height in pixels" to 16
#    - Set "Display width" to 1024
#    - Set "Display height" to 256
#    - Set "Base Address for display" to static data
#    - Click "Connect to MIPS" *after* the rest are set
#---------------------------------------------------------------------------
.text
drawPiano:
	# prologue
	addiu	$sp, $sp, -24
	sw	$fp, 0($sp)
	sw	$ra, 4($sp)
	addiu	$fp, $sp, 24

	# store sX
	addiu	$sp, $sp, -4
	sw	$s0, 0($sp)

	la	$s0, DISPLAY
	addi	$t0, $zero, 0
	addi	$t1, $zero, 0xC0C0C0
DRAW_INIT_LOOP:
	slti	$t7, $t0, 4096
	beq	$t7, $zero, END_DRAW_INIT_LOOP

	sw	$t1, 0($s0)

	addi	$s0, $s0, 4
	addi	$t0, $t0, 1
	j	DRAW_INIT_LOOP
END_DRAW_INIT_LOOP:

	# body
	# la      $t0, DISPLAY
	# addi    $t1, $zero,-1
	# sw      $t1, 0($t0)       # row 0, col 0
	# sw      $t1, 512($t0)     # row 2, col 0
	
	# la      $t2, END_OF_DISPLAY
	# lui     $t3, 0xff
	# sw      $t3, -4($t2)      # row 63, col 6

	# xx white keys @2048 offset by 16 words
	la	$s0, DISPLAY
	addi	$s0, $s0, 2112
	addi	$t0, $zero, 0

	# white
	addi	$t1, $zero, -1
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

DRAW_WHITE_LOOP:
	slti	$t7, $t0, 2
	beq	$t7, $zero, END_DRAW_WHITE_LOOP

	# white
	addi	$t1, $zero, -1
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty
	addi	$s0, $s0, 4

	# white
	addi	$t1, $zero, -1
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty
	addi	$s0, $s0, 4

	# white
	addi	$t1, $zero, -1
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty
	addi	$s0, $s0, 4

	# white
	addi	$t1, $zero, -1
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# white
	addi	$t1, $zero, -1
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty
	addi	$s0, $s0, 4

	# white
	addi	$t1, $zero, -1
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty
	addi	$s0, $s0, 4

	# white
	addi	$t1, $zero, -1
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	addi	$t0, $t0, 1
	j	DRAW_WHITE_LOOP
END_DRAW_WHITE_LOOP:
	# white
	addi	$t1, $zero, -1
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty
	addi	$s0, $s0, 4

	# white
	addi	$t1, $zero, -1
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty
	addi	$s0, $s0, 4

	# white
	addi	$t1, $zero, -1
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty
	addi	$s0, $s0, 4

	# white
	addi	$t1, $zero, -1
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# 19 black keys @1792 offset by 15 words
	la	$s0, DISPLAY
	# addi	$s0, $s0, 3860
	addi	$s0, $s0, 1852
	addi	$t0, $zero, 0

	# black key
	addi	$t1, $zero, 0
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty x2
	addi	$s0, $s0, 8

DRAW_BLACK_LOOP:
	slti	$t7, $t0, 2
	beq	$t7, $zero, END_DRAW_BLACK_LOOP

	# black
	addi	$t1, $zero, 0
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty
	addi	$s0, $s0, 4

	# black
	addi	$t1, $zero, 0
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty
	addi	$s0, $s0, 4

	# black
	addi	$t1, $zero, 0
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty
	addi	$s0, $s0, 4

	# empty
	addi	$s0, $s0, 4

	# black
	addi	$t1, $zero, 0
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty
	addi	$s0, $s0, 4

	# black
	addi	$t1, $zero, 0
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty x2
	addi	$s0, $s0, 8

	addi	$t0, $t0, 1
	j	DRAW_BLACK_LOOP
END_DRAW_BLACK_LOOP:
	# black
	addi	$t1, $zero, 0
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty
	addi	$s0, $s0, 4

	# black
	addi	$t1, $zero, 0
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# empty
	addi	$s0, $s0, 4

	# black
	addi	$t1, $zero, 0
	sw	$t1, 0($s0)
	addi	$s0, $s0, 4

	# restore sX
	lw	$s0, 0($sp)
	addiu	$sp, $sp, 4

	# epilogue
	lw	$fp, 0($sp)
	lw	$ra, 4($sp)
	addiu	$sp, $sp, 24
	jr	$ra