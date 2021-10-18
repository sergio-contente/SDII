library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity tb is
    --
end entity;

architecture testbench of tb is
    component regfile is
        generic (
            regn: natural := 32;
            wordSize: natural := 64
        );
    
        port (
            clock: in bit;
            reset: in bit;
            regWrite: in bit;
            rr1, rr2, wr: in bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
            d           : in bit_vector(wordSize-1 downto 0);
            q1, q2      : out bit_vector(wordSize-1 downto 0) 
        );
    end component;

    signal xRegN: natural := 4;
    signal xWrdS: natural := 8;
    signal clk_in, rst_in, wr_en: bit;
    signal r1_en, r2_en, read_who : bit_vector(natural(ceil(log2(real(xRegN))))-1 downto 0);
    signal d_in, q1_out, q2_out: bit_vector(xWrdS-1 downto 0);

    constant clockPeriod: time := 1 ns;
    signal keep_simulating: bit := '0';

begin
    clk_in <= (not clk_in) and keep_simulating after clockPeriod;

    DUT: regfile generic map (xRegN, xWrdS)
                 port map (clk_in, rst_in, wr_en, r1_en, r2_en, read_who, d_in, q1_out, q2_out);

    stimulus: process is
        type test_record is record
            -- Entradas
            reset, rWrite: bit;
            rr1, rr2, wr: bit_vector(natural(ceil(log2(real(xRegN))))-1 downto 0);
            d: bit_vector(xWrdS-1 downto 0);
            -- Saídas
            q1, q2: bit_vector(xWrdS-1 downto 0);
            msg: string (1 to 2);
        end record;

        type tests_array is array (natural range <>) of test_record;
        constant testes: tests_array :=
            --   rst  rW   rr1   rr2    wr       d          q1          q2       msg
            (
                ('1', '0', "00", "00", "00", "00000000", "00000000", "00000000", "T1"),    -- Reset 
                ('0', '1', "10", "00", "10", "00111100", "00111100", "00000000", "T2"),    -- Escrevemos "00111100" no reg 2 (terceiro)
                ('0', '0', "10", "01", "01", "01101010", "00111100", "00000000", "T3"),    -- Tentamos escrever com rW = '0'
                ('0', '1', "01", "11", "11", "11111111", "00000000", "00000000", "T4"),    -- Tentamos escrever no último reg
                ('0', '1', "01", "01", "01", "11111111", "11111111", "11111111", "T5"),    -- Escrevemos "11111111" no reg 1
                ('0', '1', "00", "01", "00", "00000001", "00000001", "11111111", "T6"),    -- Escrevemos "00000001" no reg 0
                ('0', '0', "10", "00", "00", "01010101", "00111100", "00000001", "T7"),    -- Idem T3
                ('1', '1', "01", "00", "00", "00000011", "00000000", "00000000", "T8")     -- Reset final
            );

        begin
            assert false report "Começou o teste" severity note;
            keep_simulating <= '1';

            for k in testes'range loop
                rst_in <= testes(k).reset;
                wr_en <= testes(k).rWrite;
                r1_en <= testes(k).rr1;
                r2_en <= testes(k).rr2;
                read_who <= testes(k).wr;
                d_in <= testes(k).d;

                wait until rising_edge(clk_in);     -- atualiza entradas dos registradores
                
                wait until falling_edge(clk_in);	-- estabiliza entradas
                
                assert (testes(k).q1 = q1_out) report "Erro: q1 no teste " & testes(k).msg severity error; 
                assert (testes(k).q2 = q2_out) report "Erro: q2 no teste " & testes(k).msg severity error;
            end loop;

        assert false report "Fim do teste" severity note;
        keep_simulating <= '0';

        wait;
    end process;
end architecture;