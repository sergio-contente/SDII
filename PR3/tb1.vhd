library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_bit.all;

entity testbench is
end testbench;

architecture arch_tb of testbench is

    component reg is 
    generic (wordSize: natural := 4);
    port (
        clock: in bit;
        reset: in bit;
        load: in bit;
        d: in bit_vector(wordSize-1 downto 0);
        q: out bit_vector(wordSize-1 downto 0)
    );
end component;
    
    constant ws_in: natural := 5; 
    signal q_in: bit_vector(ws_in-1 downto 0);
    signal d_out: bit_vector(ws_in-1 downto 0);
    constant clockPeriod : time := 2 ns;
    signal clock_in: bit := '0';
    signal reset_in, load_in: bit;
    signal simulando: bit := '0';
    
begin

	DUT: reg
    generic map (ws_in)
    port map (clock_in, reset_in, load_in, q_in, d_out);
    

    clock_in <= (simulando and (not clock_in)) after clockPeriod/2;

    stimulus: process is

		type test_record is record
  			q: bit_vector(ws_in-1 downto 0);
            load: bit;
  			d: bit_vector(ws_in-1 downto 0);
			str : string(1 to 2);
		end record;


		type tests_array is array (natural range <>) of test_record;
		constant tests : tests_array :=

      (("00001", '1', "00001", "01"), 
       ("00010", '1', "00010", "02"), 
       ("01000", '0', "00010", "03"), 
       ("11111", '1', "11111", "04")  
           );
           
		begin 
			assert false report "Test start." severity note;
			simulando <= '1';
    
		for k in tests'range loop
            assert false report tests(0).str severity note;
			

            wait for clockPeriod;
			q_in <= tests(k).q;
            load_in <= tests(k).load;
            wait for 1*clockPeriod;
            
          assert (tests(k).d = d_out)
                report "Fail:d" & tests(k).str severity error;


		end loop;

		assert false report "Test done." severity note;
		simulando <= '0';
		wait;
	end process;
end architecture;