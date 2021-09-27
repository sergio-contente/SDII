ghdl -a pr1.vhd
ghdl -a testbench_Pr1_v6.vhd
ghdl -e testbench
ghdl -r testbench --vcd=simul.vcd
