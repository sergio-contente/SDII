library ieee;
use ieee.numeric_bit.all;
--Registrador de 8 bits (guarda A ou B)
entity registerOp8 is
	port (
	  clock, reset  : in bit;						  -- Controle global: clock e reset
	  en      : in bit;                       -- Enable para carregar input
	  parallel_in   : in bit_vector(7 downto 0);   -- Input dado ao registrador
	  parallel_out  : out bit_vector(7 downto 0)    -- Conteúdo do registrador
	);
  end entity;
  
  architecture arch_reg8 of registerOp8 is
	signal internal: bit_vector(7 downto 0);
	  begin
	  
	  process(clock, reset)
	  begin
		  if reset = '1' then
			  internal <= (others => '0');
		
		  elsif clock'event and clock='1' then
			  if en = '1' then 
			  	internal <= parallel_in;
			  end if;
		end if;
	  end process;
  
	  parallel_out <= bit_vector(internal);
  
  end arch_reg8;

  ---Registrador de 9 bits para guardar e atualizar nSums
library ieee;
use ieee.numeric_bit.all;
  entity registerOp9 is
	port (
	  clock, reset  : in bit;						  -- Controle global: clock e reset
	  en     : in bit;                       -- Enable para carregar input					  -- Enables para somar e subtrair
	  parallel_in   : in bit_vector(8 downto 0);   -- Input dado ao registrador
	  parallel_out  : out bit_vector(8 downto 0)    -- Conteúdo do registrador
	);
  end entity;
  
  architecture arch_reg9 of registerOp9 is
	  signal internal: bit_vector(8 downto 0);
	  begin
	  
	  process(clock, reset)
	  begin
		  if reset = '1' then
			  internal <= (others => '0');
		  
		  elsif clock'event and clock='1' then
			  if en = '1' then internal <= (parallel_in);
			  end if;
		end if;
	  end process;
  
	  parallel_out <= bit_vector(internal);
  
  end arch_reg9;
library ieee;
use ieee.numeric_bit.all;
  entity registerOp16 is
	port (
	  clock, reset  : in bit;						  -- Controle global: clock e reset
	  en			: in bit;						  -- Enables para somar e subtrair
	  parallel_in   : in bit_vector(15 downto 0);   -- Input dado ao registrador
	  parallel_out  : out bit_vector(15 downto 0)    -- Conteúdo do registrador
	);
  end entity;
  
  architecture arch_reg16 of registerOp16 is
	  signal internal: bit_vector(15 downto 0);

	  begin
	  
	  process(clock, reset)
	  begin
		  if reset = '1' then
			  internal <= (others => '0');
		  
		  elsif clock'event and clock='1' then
			  if en = '1' then internal <= parallel_in;
			  end if;
		end if;
	  end process;
  
	  parallel_out <= bit_vector(internal);
  
  end arch_reg16;
--UC (Unity Control)
library ieee;
use ieee.numeric_bit.all;
entity UCmmc is
	port(
        reset, clock           : in bit;  -- SINAIS UNIVERSAIS
        inicia, isDiff, isLess, isZero : in bit;  -- SINAL DE CONDICAO
        updateA, updateB,updateS, sumA, sumB, sumS : out bit; -- SINAL DE CONTROLE
        x, initValues, fim     		: out bit -- SINAL DE CONTROLE    
    );
end UCmmc;

architecture arch_uc of UCmmc is
 	-- DECLARACAO DE SINAIS DE ESTADO
 type state_type is (Start, test_a_b, mA_maior_mB, mA_menor_mB, a_igl_b, zero); 
 signal state, next_state : state_type;
 begin

 
 	-- PROCESS PARA TRANSICAO DE ESTADOS
 fsm : process (reset, clock)
 begin

	 if reset = '1' then
		 state <= Start;
	 
	 elsif clock'event and clock='1' then 
		 state <= next_state;

	end if;
 end process;
 	-- CIRCUITO COMBINATORIO PARA DETERMINAR next_state
next_state <=
	Start        when (state = Start) and (inicia = '0') else
	Start		 when (state = zero) else
	Start 		 when (state = a_igl_b) else
	test_a_b	 when (state = Start) and (inicia = '1') else
	
	mA_maior_mB  when (state = test_a_b) and (isLess = '0') and (isDiff = '0') else
	mA_menor_mB  when (state = test_a_b) and (isLess = '1') and (isDiff = '0') else
	a_igl_b      when (state = test_a_b) and (isDiff = '0') else

	test_a_b when  state = mA_maior_mB and isDiff = '1' else
	test_a_b when  state = mA_menor_mB and isDiff = '1' else

	zero when (state = test_a_b) and isZero = '1' else

	Start when (state = test_a_b) and (reset ='1') else
	Start when (state = a_igl_b) and (reset ='1') else
	Start when (state = mA_maior_mB) and (reset ='1') else
	Start when (state = Start) and (reset ='1') else
	Start when (state = zero) and (reset ='1') else 
	Start when (state = ma_menor_mb) and (reset ='1');

	-- COMPORTAMENTO DOS SINAIS DE CONTROLE
	initValues <= '1' when state = Start else '0';

	updateA	   <= '1' when (state = Start or (state = mA_menor_mB)) else '0';
	updateB    <= '1' when (state = Start or (state = mA_maior_mB)) else '0';
	updateS	   <= '1' when ((state = mA_maior_mB or (state = mA_menor_mB and isDiff = '1'))) else '0';

	sumA	   <= '1' when state = mA_menor_mB and isDiff = '1' else '0';
	sumB 	   <= '1' when state = mA_maior_mB and isDiff = '1' else '0';
	sumS	   <= '1' when state = mA_menor_mB or state = mA_menor_mB else '0';

	x  		   <= '1' when (state = a_igl_b) or (state = zero) else '0';
	fim 	   <= '1' when (state = a_igl_b) or (state = zero) else '0';
	initValues <= '1' when (state = Start) else '0';

end arch_uc;

--FD (Fluxo de Dados)
library ieee;
use ieee.numeric_bit.all;
entity FDmmc is
	port(
		reset, clock          		     : in bit;   -- CONTROLE GLOBAL
        A, B			    			 : in bit_vector(7 downto 0);
        nSomas				     		 : out bit_vector(8 downto 0);
		MMC						 		 : out bit_vector(15 downto 0);
		updateA, updateB, updateS, sumA, sumB, sumS	 : in bit;   -- SINAIS DE CONTROLE
	    x, initValues								 : in bit;
        isDiff, isLess, isZero			 : out bit   -- SINAIS DE CONDICAO
	);
end FDmmc;
architecture arch_fd of FDmmc is
	-- DECLARACAO DOS COMPONENTES
	component registerOp8 is
		port (
			clock, reset  : in bit;						   -- Controle global: clock e reset
			en      : in bit;                        -- Enable para carregar input
			parallel_in   : in bit_vector(7 downto 0);     -- Input dado ao registrador
			parallel_out  : out bit_vector(7 downto 0)    -- Conteúdo do registrador
		);
	  end component;

	  component registerOp9 is
		port (
			clock, reset  : in bit;						  -- Controle global: clock e reset
			en      : in bit;                       -- Enable para carregar input			
			parallel_in   : in bit_vector(8 downto 0);    -- Input dado ao registrador
			parallel_out  : out bit_vector(8 downto 0)    -- Conteúdo do registrador
		);
	  end component;

	  component registerOp16 is
		port (
			clock, reset  : in bit;						  -- Controle global: clock e reset
			en		: in bit;					  -- Enables para somar e subtrair
			parallel_in   : in bit_vector(15 downto 0);    -- Input dado ao registrador
			parallel_out  : out bit_vector(15 downto 0)    -- Conteúdo do registrador
		);
	  end component;
	 
	   -- DECLARACAO DOS SINAIS INTERNOS

	   signal AA, BB: 	bit_vector(15 downto 0);
	   signal mA, mB:	bit_vector(7 downto 0);
	   signal mmA, mmB: bit_vector(15 downto 0);
	   signal SSoma, nSomas_reg:	bit_vector(8 downto 0);
	   signal enable: bit;

	   begin
	   -- MAPEAMENTO DOS COMPONENTES
		Areg: registerOp8 port map(clock, reset, initValues, A, mA);
		Breg: registerOp8 port map(clock, reset, initValues, B, mB);

		mAreg: registerOp16 port map(clock, reset, updateA, mmA, AA);
		mBreg: registerOp16 port map(clock, reset, updateB, mmB, BB);
		
		SomaFim: registerOp9 port map(clock, enable, updateS, SSoma, nSomas_reg);
		regMMC: registerOp16 port map(x, '0', x, AA, mmc);


		 -- COMPORTAMENTO DOS SINAIS INTERNOS

		enable <= '1' when (initValues = '1') else '0';
		SSoma <=  "000000000" when   (x ='1') else bit_vector(unsigned(nSomas_reg) + 1);
		nSomas <= nSomas_reg;
		
		mmA <= ("00000000" & A) when (sumA = '0') else bit_vector(unsigned(AA) + unsigned("00000000"&mA));
		mmB <= ("00000000" & B) when (sumB = '0') else bit_vector(unsigned(BB) + unsigned("00000000"&mB));
		 -- COMPORTAMENTO DOS SINAIS DE CONDICAO
		 isDiff <= '1' when (AA /= BB) else '0';
		 isLess <= '1' when (AA < BB) else '0';
		 isZero <= '1' when (A = "00000000") or (B = "00000000") else '0';
		 -- COMPORTAMENTO DO SINAL DE SAIDA DEPENDENTE DO SINAL DE CONDICAO
end arch_fd;
library ieee;
use ieee.numeric_bit.all;
entity xmmc is
	port (
		reset, clock: in bit;
		inicia: in bit;
		A,B:	in bit_vector(7 downto 0);
		fim:	out bit;
		nSomas:	out bit_vector(8 downto 0);
		MMC:	out bit_vector(15 downto 0)
	);
end xmmc;

architecture archMMC of xmmc is
-- Declaracao de componentes
component mmc_uc is
	port(
        reset, clock           : in bit;  -- SINAIS UNIVERSAIS
        inicia, isDiff, isLess, isZero : in bit;  -- SINAL DE CONDICAO
        updateA, updateB,updateS, sumA, sumB, sumS : out bit; -- SINAL DE CONTROLE
        x, initValues, fim     		: out bit -- SINAL DE CONTROLE     
    );
end component;

component mmc_fd is
	port(
		reset, clock          		     : in bit;   -- CONTROLE GLOBAL
        A, B			    			 : in bit_vector(7 downto 0);
        nSomas				     		 : out bit_vector(8 downto 0);
		MMC						 		 : out bit_vector(15 downto 0);
		updateA, updateB, updateS, sumA, sumB, sumS	 : in bit;   -- SINAIS DE CONTROLE
	    x, initValues								 : in bit;
        isDiff, isLess, isZero			 : out bit   -- SINAIS DE CONDICAO
	);
end component;

--Declaração de sinais internos
signal  updateA, updateB, updateS, sumA, sumB, sumS, isDiff, isLess, isZero, x, initValues: bit;
signal clock_n: bit; 
begin

--Mapeamento dos componentes
	xUC: mmc_uc port map(reset,clock, inicia, isDiff, isLess, isZero, updateA, updateB, updateS, sumA, sumB, sumS, x, initValues, fim);
	xFD: mmc_fd port map(reset, clock_n, A, B, nSomas, MMC, updateA, updateB, updateS, sumA, sumB, sumS, x, initValues, isDiff, isLess, isZero);
--Sinais internos
	clock_n <= not(clock);
end architecture;