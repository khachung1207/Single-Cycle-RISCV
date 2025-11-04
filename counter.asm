# Take address of Switch
li x1, 0x1E00          # Switch address

# Take address of LEDR
li x7, 0x1C00

# Take address of HEX
li x10, 0x1C08

# check bit
li x2, 1

# counter_reg
li x5, 0

check_switch:
    lw x3, 0(x1)
    and x4, x3, x2
    # li x4, 1
    beq x4, x2, count
    j check_switch

count:
    sw x5, 0(x7)
    #lw x8, 0(x7)
    sw x5, 0(x10)
    #lw x9, 0(x10)
    addi x5, x5, 1
    # continue check switch
    lw x3, 0(x1)
    and x4, x3, x2
    beq x4, x2, count
    j check_switch
    
#stop:
   #sw x5, 0(x7)
   #lw x8, 0(x7)
   #sw x5, 0(x10)
   #lw x9, 0(x10)
   #j check_switch