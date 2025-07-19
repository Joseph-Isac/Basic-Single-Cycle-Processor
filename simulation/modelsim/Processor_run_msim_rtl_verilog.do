transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/josep/OneDrive/Desktop/Quartus/MIPS_Single_Cycle_Processor {C:/Users/josep/OneDrive/Desktop/Quartus/MIPS_Single_Cycle_Processor/Processor.v}

vlog -vlog01compat -work work +incdir+C:/Users/josep/OneDrive/Desktop/Quartus/MIPS_Single_Cycle_Processor {C:/Users/josep/OneDrive/Desktop/Quartus/MIPS_Single_Cycle_Processor/Processor_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  Processor_tb

add wave *
view structure
view signals
run -all
