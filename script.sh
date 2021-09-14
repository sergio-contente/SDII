ghdl -a ep1.vhd
ghdl -a testbench.vhd
ghdl -e counter16
ghdl -r counter16 --vcd=simul.vcd
