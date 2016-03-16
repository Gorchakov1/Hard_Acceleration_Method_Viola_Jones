vlib work

vlog -sv ../rtl/defs.hv
vlog -sv ../rtl/delay_signal.sv

vlog -sv ../rtl/run_haar_classifier_cascade_sum.sv
vlog -sv ../rtl/rect_parser.sv
vlog -sv ../rtl/calk_sum.sv
vlog -sv ../rtl/rom_control.sv
vlog -sv ../rtl/sum_cascade.sv
vlog -sv ../rtl/word_parser.sv
vlog -sv ../rtl/result_classifier_control.sv

vlog -sv ../rtl/megafunctions/add_fp.v
vlog -sv ../rtl/megafunctions/comp_fp.v
vlog -sv ../rtl/megafunctions/int2float.v
vlog -sv ../rtl/megafunctions/mult_fp.v
vlog -sv ../rtl/megafunctions/ram.sv
vlog -sv ../rtl/megafunctions/rom.v


#vlog -sv /home/alwaus/altera/14.1/quartus/eda/sim_lib/altera_primitives.v
vlog -sv /home/alwaus/altera/14.1/quartus/eda/sim_lib/altera_mf.v
vlog -sv /home/alwaus/altera/14.1/quartus/eda/sim_lib/220model.v


#vlog -sv /home/alwaus/altera/14.1/quartus/eda/fv_lib/verilog/lpm_compare.vi
#vlog -sv /home/alwaus/altera/14.1/quartus/eda/fv_lib/verilog/lpm_add_sub.v
#vlog -sv /home/alwaus/altera/14.1/quartus/eda/fv_lib/verilog/lpm_mult.v
#vlog -sv /home/alwaus/altera/14.1/quartus/eda/fv_lib/verilog/pipeline_internal_fv.v
#vlog -sv /home/alwaus/altera/14.1/quartus/eda/fv_lib/verilog/mult_block.v
#vlog -sv /home/alwaus/altera/14.1/quartus/eda/fv_lib/verilog/addsub_block.v
#vlog -sv /home/alwaus/altera/14.1/quartus/eda/fv_lib/verilog/dffep.v



#vlog read_classifier_tb.sv
vlog run_haar_classifier_cascade_sum_tb.sv



ln -sf ../rtl/init_files/II.txt             II.txt
ln -sf ../rtl/init_files/classifier.mif     classifier.mif
ln -sf ../rtl/init_files/threshold_addr.txt threshold_addr.txt

#vsim -novopt read_classifier_tb
vsim -novopt run_haar_classifier_cascade_sum_tb
#add wave -position insertpoint sim:/read_classifier_tb/rom_ctrl/*
#add wave -position insertpoint sim:/read_classifier_tb/word/*
#add wave -position insertpoint sim:/read_classifier_tb/word/rect_p/*
#add wave -position insertpoint sim:/read_classifier_tb/cs/*
#add wave -position insertpoint sim:/read_classifier_tb/ss/*
#add wave -position insertpoint sim:/read_classifier_tb/ctrl/*

add wave -position insertpoint sim:/run_haar_classifier_cascade_sum_tb/run/rom_ctrl/*
add wave -position insertpoint sim:/run_haar_classifier_cascade_sum_tb/run/word/*
add wave -position insertpoint sim:/run_haar_classifier_cascade_sum_tb/run/word/rect_p/*
add wave -position insertpoint sim:/run_haar_classifier_cascade_sum_tb/run/cs/*
add wave -position insertpoint sim:/run_haar_classifier_cascade_sum_tb/run/ss/*
add wave -position insertpoint sim:/run_haar_classifier_cascade_sum_tb/run/ctrl/*


run 1000ns
