WA_RF = '4'
WV    = '16'
WA_MEM_SIGN = str(int(WA_RF) + int(WV))
WIDTH_JDATA = str(2*int(WA_RF) + int(WV))
mnem_list  = ['add' , 'and' , 'or'  , 'not' , 'mul' , 'div' , 'adi',  'shfl', 
              'shfr', 'beq' , 'jmp' , 'sw'  , 'lw'  , 'nop' , 'slt',  'sub' ]

opcod_list = ['0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', 
              '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111']

type_r   = ['add' , 'and' , 'or'  , 'not', 'mul', 'div', 'slt', 'sub']
type_i   = ['adi' , 'shfl', 'shfr']
type_mem = ['sw'  , 'lw'  ]
type_if  = ['beq' ]
type_j   = ['jmp' ]
 
 

file_read  = 'cod.txt' #input()
f_read     = open(file_read)
i = 0
mark_list = []
addr_list = [] 
for line in f_read:
    if line.find(':') != -1:
        print(line)
        line = line.split()
        mark_list.append(line[0])
        print(mark_list)
        addr_list.append(i)
    else:
        i = i + 1
f_read.close()

f_read     = open(file_read)
file_write = '../sim/mach.txt' #input()
f_write    = open(file_write, 'wt')



for line in f_read:
    i = 0
    line = line.split()
    com_list  = []
    print(line)
    if mark_list.count(line[0]) != 0:
        continue 
    elif mnem_list.count(line[0]) == 0:
        f_write.write('error: unidentified command' + '\n')
        exit(0)             
    else:
        com_list.append(opcod_list[mnem_list.index(line[0])])
        if type_r.count(line[0]) != 0:
            com_list.append(format(int(line[1][1:],16), '0' + WA_RF + 'b'))
            com_list.append(format(int(line[2][1:],16), '0' + WA_RF + 'b'))
            com_list.append(format(int(line[3], 16),    '0' + WV    + 'b'))
        elif type_i.count(line[0]) != 0:
            com_list.append(format(int(line[1][1:],16), '0' + WA_RF + 'b'))
            com_list.append(format(int('0',16),         '0' + WA_RF + 'b'))
            com_list.append(format(int(line[2],16),     '0' + WV    + 'b'))
        elif type_mem.count(line[0]) != 0:
            com_list.append(format(int(line[1][1:],16), '0' + WA_RF + 'b'))
            com_list.append(format(int(line[2],16),     '0' + WA_MEM_SIGN + 'b'))
        elif type_if.count(line[0]) != 0:
            com_list.append(format(int(line[1][1:],16), '0' + WA_RF + 'b'))
            com_list.append(format(int(line[2][1:],16), '0' + WA_RF + 'b'))
            jump = int(addr_list[mark_list.index(line[3] + ':')]) - i
            com_list.append(format(jump,'0' + WV + 'b')) 
        elif type_j.count(line[0]) != 0:
            com_list.append(format(int(addr_list[mark_list.index(line[1] + ':')]),'0'+WIDTH_JDATA+'b'))
        i = i + 1
        print(com_list)
        command  = ''.join(com_list) 
        f_write.write(format(int(command, 2), '07x') + '\n')
f_read.close()