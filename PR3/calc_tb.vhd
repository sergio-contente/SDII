library ieee;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.numeric_bit.all;
entity calc_tb is
end calc_tb;

architecture tb of calc_tb is
	component calc is
		port(
			clock:       in bit;
			reset:       in bit;
			instruction: in bit_vector(16 downto 0);
			q1:          out bit_vector(15 downto 0)
		);
	end component;
	
	signal clock_in: bit := '0';
	signal reset_in: bit;
	signal instruction_in: bit_vector(16 downto 0);
	signal q1_out: bit_vector(15 downto 0);
	
	constant clockPeriod: time := 2 ns; -- periodo do clock
	signal simulando : bit := '0';
begin
	DUT: calc port map(clock_in, reset_in, instruction_in, q1_out);
	clock_in <= (simulando and (not clock_in)) after clockPeriod/2;
	
	estimulos: process is
		type pattern_type is record 
			reset        : bit;
			opcode  : bit_vector(1 downto 0);
			oper2, oper1, dest: bit_vector(4 downto 0);
			q1           : bit_vector(15 downto 0); 
		end record;
		
		type pattern_array is array (natural range <>) of pattern_type;
		constant patterns: pattern_array := 
	   -- rst   opc   oper2    oper1    dest           q1  
		(('0', "01", "00010", "00001", "00001", "0000000000000010"), -- 00
		 ('0', "01", "00100", "00011", "00011", "0000000000000100"), -- 01
		 ('0', "00", "00011", "00001", "00000", "0000000000000010"), -- 02
		 ('0', "10", "00001", "00000", "00010", "0000000000000110"), -- 03
		 ('0', "01", "00000", "00010", "00010", "0000000000000100"), -- 04
		 ('0', "11", "00011", "00000", "00100", "0000000000000110"), -- 05
		 ('0', "01", "00000", "00100", "00100", "0000000000000011"), -- 06
		 ('0', "01", "11011", "00000", "00101", "0000000000000110"), -- 07
		 ('0', "01", "00000", "00101", "00101", "0000000000000001"), -- 08
		 ('0', "11", "11011", "00010", "00110", "0000000000000100"), -- 09
		 ('0', "01", "00000", "00110", "00110", "0000000000001001"), -- 10
		 ('1', "00", "11011", "00010", "00001", "0000000000000000")); -- 11
	begin
		assert false report "Testes iniciados" severity note;
		simulando <= '1'; -- Habilita clock
		
		for i in patterns'range loop
			reset_in       <= patterns(i).reset;
			instruction_in <= patterns(i).opcode & patterns(i).oper2 & patterns(i).oper1 & patterns(i).dest;
			
			wait for clockPeriod;
			
			assert q1_out = patterns(i).q1
			report "Erro no sinal q1 do teste " & integer'image(i)  
			severity error;
		end loop;
		assert false report "Testes concluidos" severity note;
		simulando <= '0'; -- Desabilita clock		
		wait;  -- para a execução do simulador, caso contrário este process é reexecutado indefinidamente.
	end process;
end architecture;