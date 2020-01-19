WA_RF = 
WV = 
mnem_list  = ['add' , 'and' , 'or'  , 'not' , 'mul' , 'div' , 'addi', 
              'shfl', 'shfr', 'beq' , 'jmp' , 'sw'  , 'lw'  , 'nop' ]

opcod_list = ['0000', '0001', '0010', '0011', '0100', '0101', '0110',
              '0111', '1000', '1001', '1010', '1011', '1100', '1101']

file_read  = input()
f_read     = open(file_read)
file_write = input()
f_write    = open(file_write, 'wt')

i = 0
com_list  = []
for line in f_read:
    if mnem_list.count(line[0]) == 0:
        f_write.write('error: unidentified command' + '\n')
        exit(0)             
    else:
        com_list.append(opcod_list[mnem_list.index(line[0])])
        if com_list.append
        com_list.append(format(int(list[1][1:]), '0' + WA_RF + 'b')) 
            if com_list[0] != '1110' and com_list[0] != '1100'
                com_list.append(format(int(reg[1:]), '0' + WA_RF + 'b'))     
        com_list.append(format(int(line[3], 16), '0' + WV + 'b'))
f_read.close()