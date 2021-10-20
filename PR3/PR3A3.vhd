----------------------------------------------------------------------------------------------------------------------
--Reg
----------------------------------------------------------------------------------------------------------------------
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


----------------------------------------------------------------------------------------------------------------------
--Regfile
----------------------------------------------------------------------------------------------------------------------
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
		generic( wordSize: natural := 4);
		port(
			clock: in bit;
			reset: in bit;
			load:  in bit;
			d:	   in bit_vector(wordSize-1 downto 0);
			q:	   out bit_vector(wordSize - 1 downto 0)
		);
		end component;
type saida is array (0 to regn-1) of bit_vector(wordSize -1 downto 0);
type load_tipo is array (0 to (2**natural(ceil(log2(real(regn)))) - 1)) of bit;
signal reg_saida : saida;
signal  nulo : bit_vector(wordSize - 1 downto 0);
signal load_aux: load_tipo;
begin
	nulo <= (others => '0');
	bank_register: for x in regn-2 downto 0 generate
	load_aux(x) <= '1' when x = to_integer(unsigned(wr)) and regWrite = '1' and reset = '0' else '0';
    my_register: reg generic map(wordSize) port map(clock, reset, load_aux(x), d, reg_saida(x));
	end generate;
reg_saida(regn - 1) <= nulo;
q1 <= (reg_saida(to_integer(unsigned(rr1))));
q2 <= (reg_saida(to_integer(unsigned(rr2))));
end architecture;

----------------------------------------------------------------------------------------------------------------------
-- Somador
----------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;
entity adder is
generic( wordSize: natural := 4);
port(
	clock: 		in bit;
	reset: 		in bit;
	load:  		in bit;
	oper1:	    in bit_vector(wordSize-1 downto 0);
	oper2:	    in bit_vector(wordSize-1 downto 0);
	dest:	    out bit_vector(wordSize - 1 downto 0)
);
end adder;

architecture sum of adder is
begin
process(clock, reset)
begin
	if reset = '1' then
		dest <= (others => '0');
	elsif clock = '1' and clock'event then
		if load = '1' then
			dest <= bit_vector(signed(signed(oper1) + signed(oper2)));
		end if;
	end if;
end process;
end architecture;

----------------------------------------------------------------------------------------------------------------------
-- Subtrator
----------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;
entity subtrator is
generic( wordSize: natural := 4);
port(
	clock: 	   in bit;
	reset: 	   in bit;
	load:  	   in bit;
	oper1:	   in bit_vector(wordSize-1 downto 0);
	oper2:	   in bit_vector(wordSize-1 downto 0);
	dest:	   out bit_vector(wordSize - 1 downto 0)
);
end subtrator;

architecture difference of subtrator is
begin
process(clock, reset)
begin
	if reset = '1' then
		dest <= (others => '0');
	elsif clock = '1' and clock'event then
		if load = '1' then
			dest <= bit_vector(signed(signed(oper1) - signed(oper2)));
		end if;
	end if;
end process;
end architecture;
----------------------------------------------------------------------------------------------------------------------
--! Calculadora
----------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity calc is
	port(
		clock:			in bit;
		reset:			in bit;
		instruction:	in bit_vector(16 downto 0);
		q1:				out bit_vector(15 downto 0)
	);
end calc;

architecture operations of calc is

--Declaracao dos componentes
component reg is
	generic( wordSize: natural := 4);
	port(
		clock: in bit;
		reset: in bit;
		load:  in bit;
		d:	   in bit_vector(wordSize-1 downto 0);
		q:	   out bit_vector(wordSize - 1 downto 0)
	);
end component;
component regfile is
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
end component;

component adder is
	generic( wordSize: natural := 4);
	port(
		clock: 		in bit;
		reset: 		in bit;
		load:		in bit;
		oper1:	    in bit_vector(wordSize-1 downto 0);
		oper2:	    in bit_vector(wordSize-1 downto 0);
		dest:	    out bit_vector(wordSize - 1 downto 0)
	);
end component;

component subtrator is
	generic( wordSize: natural := 4);
	port(
		clock: 	   in bit;
		reset:     in bit;
		load:  	   in bit;
		oper1:	   in bit_vector(wordSize-1 downto 0);
		oper2:	   in bit_vector(wordSize-1 downto 0);
		dest:	   out bit_vector(wordSize - 1 downto 0)
	);
end component;

type mem_reg is array (0 to 31) of bit_vector(15 downto 0);

--Sinais internos

signal opcode : bit_vector(1 downto 0);
signal end_oper1, end_oper2, end_dest, inst_oper2: bit_vector(4 downto 0);
signal imediato, v_oper2, v_oper1, v_dest, v_destA, v_destB, v_destAi, v_destBi, q1_aux, q2_aux: bit_vector(15 downto 0);
signal ADD, SUB, ADDI, SUBI, load_r, load_a, load_s: bit;
signal reg_signal : mem_reg;

begin

--Decodificar formato das instrucoes

opcode 	   <= instruction(16 downto 15);
inst_oper2  <= instruction(14 downto 10);
end_oper1  <= instruction(9 downto 5);
end_dest   <= instruction(4 downto 0);

--MUX simples

ADD  <= '1' when opcode = "00" else '0';
ADDI <= '1' when opcode = "01" else '0';
SUB  <= '1' when opcode = "10" else '0';
SUBI <= '1' when opcode = "11" else '0';
--Tratando imediato
imediato  <= bit_vector(resize(signed(inst_oper2) , 16 ));
end_oper2 <=  instruction(14 downto 10) when ADD = '1' or SUB = '1';
v_oper2 <= q2_aux when ADD = '1' or SUB = '1' else
		   imediato when ADDI = '1' or SUBI = '1';
--Setando os valores dos operadores
v_oper1 <= q1_aux;
v_dest  <= v_destA when ADD = '1' else v_destAi when ADDI = '1' else v_destB when SUB = '1' else v_destBi when SUBI = '1';

load_a  <= '1' when ADD = '1' or ADDI = '1' else '0';
load_s  <= '1' when SUB = '1' or SUBI = '1' else '0';
load_r  <= '1' when load_A = '1' or load_S = '1' else '0';

--Mapeamento dos componentes

add_comp: adder generic map(16) port map(clock, reset, ADD, q1_aux, q2_aux, v_destA);
addI_comp: adder generic map(16) port map(clock, reset, ADDI, q1_aux, imediato, v_destAi);

sub_comp: subtrator generic map(16) port map(clock, reset, SUB, q1_aux, q2_aux, v_destB);
subI_comp: subtrator generic map(16) port map(clock, reset, SUBI, q1_aux, imediato, v_destBi);

all_registers: regfile generic map(32, 16) port map(clock, reset, load_r, end_oper1, end_oper2, end_dest, v_dest, q1_aux, q2_aux);

q1 <= v_oper1;
end architecture;