WA_RF = 
WV = 
mnem_list  = ['add' , 'mul' , 'div' , 'imul', 
              'idiv', 'sw'  , 'lw'  , 'wjr' , 'beq' ]
opcod_list = ['1000', '0000', '0100', '0010', 
              '0110', '1110', '1100', '1011', '1001']
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
        com_list.append(format(int(list[1][1:]), '0' + WA_RF + 'b')) 
            if com_list[0] != '1110' and com_list[0] != '1100'
                com_list.append(format(int(reg[1:]), '0' + WA_RF + 'b'))     
        com_list.append(format(int(line[3], 16), '0' + WV + 'b'))
f_read.close()