library ieee;
use ieee.numeric_bit.all;
entity mmc_fd is 
    port(
        reset,clock,loadA,loadB,loadS, en_sumA,en_sumB,en_soma,init,signal1,fim: in bit; 
        a_en,b_en:    in bit_vector(7 downto 0);
        nSomas: out bit_vector(8 downto 0);
        mmc: out bit_vector(15 downto 0);
        diferente,menor_fd,igual_0: out bit
    );
end entity;

architecture dataflow of mmc_fd is
--Registrador de 8 bits
component reg_gen is
    generic(
      tamanho : natural
      );
    port (
          clock, reset : in bit;
          load : in bit;
          parallel_in : in bit_vector(tamanho-1 downto 0);
          parallel_out : out bit_vector(tamanho-1 downto 0)
          );
end component;

--Sinais u,sados
signal a,b : bit_vector(15 downto 0) ;
signal a_in,b_in : bit_vector(15 downto 0);
signal ma : bit_vector(7 downto 0) ;
signal mb : bit_vector(7 downto 0) ;
signal nSomas_s : bit_vector(8 downto 0) ;
signal nSomas_out : bit_vector(8 downto 0) ;
signal resetnSoma,hab_mmc,aux : bit;
-- Instaciação dos componentes
begin
 
  reg1: reg_gen generic map(8) port map(clock,reset,init,a_en,ma);
  reg2: reg_gen generic map(8) port map(clock,reset,init,b_en,mb);
  reg3: reg_gen generic map(16) port map(clock,reset,loadA,a_in,a);
  reg4: reg_gen generic map(16) port map(clock,reset,loadB,b_in,b);
  reg5: reg_gen generic map(16) port map(signal1,'0',signal1,a,mmc);
  reg6: reg_gen generic map(9) port map(clock,resetnSoma,loadS,nSomas_s,nSomas_out); -- Qual valor de nSomas_s ? 


a_in <= ("00000000"&a_en) when (en_sumA='0') else bit_vector(unsigned(a) + unsigned("00000000"&ma));
b_in <= ("00000000"&b_en) when (en_sumB='0') else bit_vector(unsigned(b) + unsigned("00000000"&mb));
nSomas_s <= "000000000" when   (signal1 ='1') else bit_vector(unsigned(nSomas_out) + 1);
resetnSoma <= '1' when (init ='1') else '0';
nSomas <= nSomas_out; 
--nSomas <= nSomas_out;
--Sinais de condição da Unidade de Controle     
diferente <= '1' when (a/=b) else '0';
menor_fd <= '1' when (a<b) else '0';
--igual_0 <= '1' when (a="0000000000000000") or (b="0000000000000000") else '0';
igual_0 <= '1' when (a_en="00000000") or (b_en="00000000") else '0';

end architecture; 
