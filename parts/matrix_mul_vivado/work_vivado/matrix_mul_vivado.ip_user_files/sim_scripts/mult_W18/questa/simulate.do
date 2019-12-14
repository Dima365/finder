onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib mult_W18_opt

do {wave.do}

view wave
view structure
view signals

do {mult_W18.udo}

run -all

quit -force
