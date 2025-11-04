# Take address of HEX0, HEX1, HEX2, HEX3
li x10, 0x1C08

# Take address of HEX4, HEX5, HEX6, HEX7
li x11, 0x1C09

# Take address of LEDR
li x19, 0x1C00
li x20, 1

# Take address of Switch
li x21, 0x1E00

# Take address of Button
li x24, 0x1E04

# Input hex convert data
check_button:
lw x22, 0(x21)
sw x22, 0(x19)
lw x27, 0(x19)
lw x25, 0(x24)
and x26, x25, x20
beq x26, x20, check_button
j input_data

input_data:
lw x15, 0(x21)
sw x15, 0(x11)
lw x18, 0(x11)

li x1,0       # Starting value
#li x2, 256    # Reset value
addi x2, x15, 1

LOOP:
j DISPLAY
CONTINUE:
addi x1,x1,1
beq x1,x2, the_end
li x3,0
bge x2,x3,LOOP

DISPLAY:
li x3,10
bge x1,x3,TWO_DIGIT
addi x4,x1,0
j CONTINUE

TWO_DIGIT:
li x3,100
bge x1,x3,THREE_DIGIT
addi x9,x1,0
SMALL_LOOP:
addi x9,x9,-10
addi,x7,x7,+1
li x3,0
beq x9,x3,ONE_ZERO
bge x9,x3,SMALL_LOOP
addi x9,x9,10
addi x4,x9,0
addi x7,x7,-1
addi x5,x7,0
li x9,0     #Clear regiser
li x7,0     #Clear regiser
j CONTINUE

ONE_ZERO:
li x4,0
addi x5,x7,0
li x7,0     #Clear regiser
li x6,0     #Clear regiser
j CONTINUE


THREE_DIGIT:
addi x8,x1,0
SMALL_LOOP_1:
addi x8,x8,-100
addi,x7,x7,+1
li x3,0
beq x8,x3,TWO_ZERO
bge x8,x3,SMALL_LOOP_1
addi x8,x8,100
addi x7,x7,-1
addi x6,x7,0
addi x9,x8,0
li x8,0     #Clear regiser
li x7,0     #Clear regiser
j SMALL_LOOP

TWO_ZERO:
li x4,0
li x5,0
addi x6,x7,0
li x7,0     #Clear regiser
li x8,0     #Clear regiser
j CONTINUE


the_end:
slli x6, x6, 8
slli x5, x5, 4

addi x12, x4, 0
addi x13, x5, 0
addi x14, x6, 0

or x16, x14, x13
or x16, x16, x12

display:
sw x16, 0(x10)
lw x18, 0(x10)

halt: j halt