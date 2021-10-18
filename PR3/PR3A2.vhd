library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;
entity reg is
generic( wordSize: natural := 4);
port(
	clock: in bit;
	reset: in bit;
	load:  in bit;
	d:	   in bit_vector(wordSize-1 downto 0);
	q:	   out bit_vector(wordSize - 1 downto 0)
);
end reg;

architecture rtl of reg is
begin
process(clock, reset)
begin
	if reset = '1' then
		q <= (others => '0');
	elsif clock = '1' and clock'event then
		if load = '1' then
			q <= d;
		end if;
	end if;
end process;
end architecture;

library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity regfile is
	generic(
		regn: natural := 32;
		wordSize: natural := 64
	);
	port(
		clock:	  		in bit;
		reset:	  		in bit;
		regWrite: 		in bit;
		rr1, rr2, wr:   in bit_vector(natural(ceil(log2(real(regn))))- 1 downto 0);
		d:				in bit_vector(wordSize - 1 downto 0);
		q1, q2:			out bit_vector(wordSize - 1 downto 0)
	);
end regfile;

architecture rfa of regfile is
	component reg is
		port (
			clock: in bit;
			reset: in bit;
			load:  in bit;
			d:	   in bit_vector(wordSize-1 downto 0);
			q:	   out bit_vector(wordSize - 1 downto 0)
		);
	end component;
type saida is array (0 to regn-1) of bit_vector(wordSize -1 downto 0);
type entrada is array (0 to regn-1) of bit_vector(wordSize -1 downto 0);

signal reg_saida : saida;
signal reg_entrada : entrada;
signal  nulo : bit_vector(wordSize - 1 downto 0);
begin
	nulo <= (others => '0');
    reg_entrada(to_integer(unsigned(wr))) <= d;
	bank_register: for x in regn-1 downto 0 generate
		is_last: if x = regn - 1 generate
			last_register: reg port map(clock, reset, regWrite, reg_entrada(x), nulo);
		end generate;
    my_register: reg port map(clock, reset, regWrite, reg_entrada(x), reg_saida(x));
	end generate;
q1 <= (reg_saida(to_integer(unsigned(rr1))));
q2 <= (reg_saida(to_integer(unsigned(rr2))));
end architecture;