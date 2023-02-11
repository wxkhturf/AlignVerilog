vlib work
vmap work work

vlog -work ./work ../rtl/*.v
#vlog -work ./work ../rtl/*.txt
vlog -work ./work ./*.v



vsim -t ns  -voptargs=+acc work.tb
view signals wave 

