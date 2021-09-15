library ieee;
use ieee.numeric_bit.all;

entity mmc is
    port(
        reset,clock : in bit;
        inicia: in bit;
        A,B : in bit_vector(7 downto 0);
        fim : out bit;
        nSomas : out bit_vector(8 downto 0);
        MMC : out bit_vector (15 downto 0)
    );
end entity;

architecture structural of mmc is
    component mmc_uc is 
    port(
        reset,clock,diferente,menor_fd,inicia,igual_0: in bit;
        loadA,loadB,loadS,en_sumA,en_sumB,en_soma,fim,init,signal1: out bit
    );
    end component;
    component mmc_fd is 
    port(
        reset,clock,loadA,loadB,loadS, en_sumA,en_sumB,en_soma,init,signal1,fim: in bit; 
        a_en,b_en:    in bit_vector(7 downto 0);
        nSomas: out bit_vector(8 downto 0);
        mmc: out bit_vector(15 downto 0);
        diferente,menor_fd,igual_0: out bit
    );
    end component;
    signal loadA,loadB,loadS,en_soma,en_suma,en_sumb,signal1,init,fim_s,igual_0: bit;
    signal diferente,menor_fd: bit;
    signal clock_n : bit;
begin
    clock_n <= not(clock);
    uc : mmc_uc port map(reset,clock_n,diferente,menor_fd,inicia,igual_0,loadA,loadB,loadS,en_sumA,en_sumB,en_soma,fim,init,signal1);
    fd : mmc_fd port map(reset,clock,loadA,loadB,loadS,en_sumA,en_sumB,en_soma,init,signal1,fim_s,A,B,nSomas,MMC,diferente,menor_fd,igual_0);
end architecture;
