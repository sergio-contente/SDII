library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_bit.all;

entity testbench is
end testbench;

architecture tb_arch of testbench is
    
    component mmc is
        port(
            reset, clock: in bit;
            inicia: in bit;
            A,B: in bit_vector(7 downto 0);
            fim: out bit;
            nSomas: out bit_vector(8 downto 0);
            MMC: out bit_vector(15 downto 0)
        );
    end component;

    signal reset_in, inicia_in: bit;
    signal a_in, b_in: bit_vector(7 downto 0);
    signal MMC_out: bit_vector(15 downto 0);
    signal nSomas_out: bit_vector(8 downto 0);
    signal fim_out: bit;

    constant clock_period: time := 2 ns;
    signal clock_in: bit := '0';
    signal simulando: bit := '0';

begin
    DUT: mmc
    port map (reset_in, clock_in, inicia_in, a_in, b_in, fim_out, nSomas_out, MMC_out);

    clock_in <= (simulando and (not clock_in)) after clock_period/2;

    stimulus: process is
        type test_record is record
            reset, inicia: bit;
            A, B: bit_vector(7 downto 0);
            fim: bit;
            nSomas: bit_vector(8 downto 0);
            MMC: bit_vector(15 downto 0);
			str : string(1 to 5);
        end record;
    
        type test_array is array (natural range <>) of test_record;
        constant tests: test_array :=
        (('1', '1', "00000000", "00000000", '1', "000000000", "0000000000000000", "00/00"),
        ('0', '1', "00001100", "00010000", '1', "000000101", "0000000000110000", "12/16"),
        ('0', '1', "00011000", "00000000", '1', "000000000", "0000000000000000", "24/00"),
        ('0', '1', "00000011", "00000111", '1', "000001000", "0000000000010101", "03/07")
        );
        
        begin
            assert false report "Test start." severity note;
            simulando <= '1';
        
        for k in tests'range loop
            reset_in <= tests(k).reset;
            inicia_in <= tests(k).inicia;
            a_in <= tests(k).A;
            b_in <= tests(k).B;
            
            wait for 2 ns;
            
            reset_in <= '0';
            
            wait for 2 ns;
            
            inicia_in <= '0';
            
            wait until (fim_out = '1');

            wait for 1.5 ns;

            assert (tests(k).fim = fim_out)
                report "Fail:fim" & tests(k).str severity error;
            assert (tests(k).nSomas = nSomas_out)
                report "Fail:nSomas" & tests(k).str severity error;
            assert (tests(k).MMC = MMC_out)
                report "Fail:MMC" & tests(k).str severity error;
                
             wait for 5 ns;
        end loop;

        assert false report "Test finished." severity note;
        simulando <= '0';
        wait;
    end process;
end architecture;
