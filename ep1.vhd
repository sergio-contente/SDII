library ieee;
use ieee.numeric_bit.all;
--Registrador de 8 bits (guarda A ou B)
entity registerOp8 is
	port (
	  clock, reset  : in bit;						  -- Controle global: clock e reset
	  enableIn      : in bit;                       -- Enable para carregar input
	  parallel_in   : in bit_vector(7 downto 0);   -- Input dado ao registrador
	  parallel_out  : out bit_vector(7 downto 0)    -- Conteúdo do registrador
	);
  end entity;
  
  architecture arch_reg8 of registerOp8 is
	signal internal: bit_vector(7 downto 0)
	  begin
	  
	  process(clock, reset)
	  begin
		  if reset = '1' then
			  internal <= (others => '0');
		
		  elsif clock'event and clock='1' then
			  if enableIn = '1' then 
			  	internal <= parallel_in;
			  end if;
		end if;
	  end process;
  
	  parallel_out <= bit_vector(internal);
  
  end arch_reg8;

  ---Registrador de 9 bits para guardar e atualizar nSums
  entity registerOp9 is
	port (
	  clock, reset  : in bit;						  -- Controle global: clock e reset
	  enableIn      : in bit;                       -- Enable para carregar input
	  enAdd			: in bit;						  -- Enables para somar e subtrair
	  parallel_in   : in bit_vector(8 downto 0);   -- Input dado ao registrador
	  parallel_out  : out bit_vector(8 downto 0)    -- Conteúdo do registrador
	);
  end entity;
  
  architecture arch_reg9 of registerOp9 is
	  signal internal: unsigned(8 downto 0);
	  constant unit_vec: unsigned(8 downto 0) := "000000001";
	  begin
	  
	  process(clock, reset)
	  begin
		  if reset = '1' then
			  internal <= (others => '0');
		  
		  elsif clock'event and clock='1' then
			  if enableIn = '1' then internal <= unsigned(parallel_in);
			  elsif enAdd = '1' then internal <= internal + unit_vec;
			  end if;
		end if;
	  end process;
  
	  parallel_out <= bit_vector(internal);
  
  end arch_reg9;

  entity registerOp16 is
	port (
	  clock, reset  : in bit;						  -- Controle global: clock e reset
	  enAdd			: in bit;						  -- Enables para somar e subtrair
	  previous_in	: in bit_vector(15 downto 0)
	  parallel_in   : in bit_vector(15 downto 0);   -- Input dado ao registrador
	  parallel_out  : out bit_vector(15 downto 0)    -- Conteúdo do registrador
	);
  end entity;
  
  architecture arch_reg16 of registerOp16 is
	  signal internal: unsigned(15 downto 0);

	  begin
	  
	  process(clock, reset)
	  begin
		  if reset = '1' then
			  internal <= (others => '0');
		  
		  elsif clock'event and clock='1' then
			  if enAdd = '1' then internal <= parallel_in + previous_in;
			  end if;
		end if;
	  end process;
  
	  parallel_out <= bit_vector(internal);
  
  end arch_reg16;

--UC (Unity Control)
entity UCmmc is
	port(
        reset, clock           : in bit;  -- SINAIS UNIVERSAIS
        inicia, isDiff, isLess : in bit;  -- SINAL DE CONDICAO
        updateA, updateB, sumA, sumB : out bit; -- SINAL DE CONTROLE
        fim, x     		: out bit; -- SINAL DE CONTROLE
        reset_FD               : out bit  -- SINAL DE CONTROLE, RESET         
    );
end UCmmc;

architecture arch_uc of UCmmc is
 	-- DECLARACAO DE SINAIS DE ESTADO
 type state_type is (Start, test_a_b, mA_maior_mB, mB_maior_mA, A_igl_B); 
 signal state, next_state : state_type := Start;
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
	test_a_b	 when (state = Start) and (inicia = '1') else
	
	mA_maior_mB  when (state = test_a_b) 	 and (isLess = '1') and (isDiff = '0') else
	mB_maior_mA  when  (state = test_a_b) 	 and (isLess = '0') and (isDiff = '0') else
	a_igl_b      when (state = test_a_b) and (isDiff = '0') else

	test_a_b when  state = mA_maior_mB else
	test_a_b when  state = mB_maior_mA;

	-- COMPORTAMENTO DOS SINAIS DE CONTROLE
	updateA	   <= '1' when (state = Start or state = mA_maior_mB) else '0';
	updateB    <= '1' when (state = Start or state = mB_maior_mA) else '0';

	sumA	   <= '1' when state = mA_maior_mB else '0';
	sumB 	   <= '1' when state = mB_maior_mA else '0';

	fim 	   <= '1' when (state = a_igl_b) else '0';
	x  		   <= '1' when (state = a_igl_b) else '0';
	reset_FD <= '1' when (reset = '1') else '0';
end arch_uc;

--FD (Fluxo de Dados)
entity FDmmc is
	port(
		reset, clock          		     : in bit;   -- CONTROLE GLOBAL
        inicia			      		     : in bit;
        A, B       			 			 : in bit_vector(7 downto 0);
        nSomas				     		 : out bit_vector(8 downto 0);
		MMC						 		 : out bit_vector(15 downto 0)
		updateA, updateB, sumA, sumB 	 : in bit;   -- SINAIS DE CONTROLE
	    x								 : in bit;
        isDiff, isLess 					 : out bit   -- SINAIS DE CONDICAO
	);
end FDmmc;
architecture arch_fd of FDmmc is
	-- DECLARACAO DOS COMPONENTES
	component registerOp8 is
		port (
			clock, reset  : in bit;						   -- Controle global: clock e reset
			enableIn      : in bit;                        -- Enable para carregar input
			parallel_in   : in bit_vector(7 downto 0);     -- Input dado ao registrador
			parallel_out  : out bit_vector(15 downto 0)    -- Conteúdo do registrador
		);
	  end component;


	  component registerOp9 is
		port (
			clock, reset  : in bit;						  -- Controle global: clock e reset
			enableIn      : in bit;                       -- Enable para carregar input
			enAdd		  : in bit;						  -- Enables para somar e subtrair
			parallel_in   : in bit_vector(8 downto 0);    -- Input dado ao registrador
			parallel_out  : out bit_vector(8 downto 0)    -- Conteúdo do registrador
		);
	  end component;

	  component registerOp16 is
		port (
			clock, reset  : in bit;						  -- Controle global: clock e reset
			enAdd			: in bit;					  -- Enables para somar e subtrair
			previous_in	: in bit_vector(15 downto 0)
			parallel_in   : in bit_vector(15 downto 0);    -- Input dado ao registrador
			parallel_out  : out bit_vector(15 downto 0)    -- Conteúdo do registrador
		);
	  end component;

	   -- DECLARACAO DOS SINAIS INTERNOS

	   signal AA, BB: 	bit_vector(15 downto 0);
	   signal mA, mB:	bit_vector(15 downto 0);
	   signal mmA, mmB: bit_vector(15 downto 0);
	   signal nSomas_s:	bit_vector(8 downto 0);
	   const soma: unsigned(8 downto 0) := "000000001"; 

	   -- MAPEAMENTO DOS COMPONENTES
		Areg: registerOp8 port map(clock, '0', updateA, A, AA);
		Breg: registerOp8 port map(clock, '0', updateB, B, BB);

		mAreg: registerOp16 port map(clock, '0', sumA, mA, mmA);
		mBreg: registerOp16 port map(clock, '0', sumB, mB, mmB);

		nSomasreg: registerOp9 port map(clock, '0', sumA or sumB, SSoma, nSomas_s);
		SomaFim: registerOp9 port map(clock, '0', x, nSomas_s, nSomas);
		regMMC: registerOp16 port map(clock, '0', x, sumA,mmc);

		 -- COMPORTAMENTO DOS SINAIS INTERNOS
		 mA <= '0000000' & AA when (sumA = '0') else
		 		bit_vector((unsigned(mA) + unsigned(AA)));

		 mB <= '0000000' & B when (sumB = '0') else
		 		bit_vector((unsigned(mB) + unsigned(BB)));	
		SSoma <= '000000000' when (inicia = '1') else
				 bit_vector(unsigned(SSoma) + soma) when (sumA or sumB);
				 
		
		 -- COMPORTAMENTO DOS SINAIS DE CONDICAO
		 isDiff <= '1' when (mA /= mB) else '0';
		 isLess <= '1' when (mA < mB) else '0';
		 -- COMPORTAMENTO DO SINAL DE SAIDA DEPENDENTE DO SINAL DE CONDICAO
end arch_fd;
entity mmc is
	port (
		reset, clock: in bit;
		inicia: in bit;
		A,B:	in bit_vector(7 downto 0);
		fim:	out bit;
		nSomas:	out bit_vector(8 downto 0);
		MMC:	out bit_vector(15 downto 0)
	);
end mmc;

architecture archMMC of mmc is
-- Declaracao de componentes
component mmc_uc is
	port(
        reset, clock           : in bit;  -- SINAIS UNIVERSAIS
        inicia, isDiff, isLess : in bit;  -- SINAL DE CONDICAO
        updateA, updateB, sumA, sumB : out bit; -- SINAL DE CONTROLE
        fim, x     		: out bit -- SINAL DE CONTROLE       
    );
end component;

component mmc_fd is
	port(
		reset, clock          		     : in bit;   -- CONTROLE GLOBAL
        inicia			      		     : in bit;
        A, B       			 			 : in bit_vector(7 downto 0);
        nSomas				     		 : out bit_vector(8 downto 0);
		MMC						 		 : out bit_vector(15 downto 0)
		updateA, updateB, sumA, sumB 	 : in bit;   -- SINAIS DE CONTROLE
	    x								 : in bit;
        isDiff, isLess 					 : out bit   -- SINAIS DE CONDICAO
	);
end component;

--Declaração de sinais internos
signal  updateA, updateB, sumA, sumB, isDiff, isLess, x: bit;
signal clock_n: bit; 
begin

--Mapeamento dos componentes
	xUC: mmc_uc port map(reset,clock, inicia, isDiff, isLess, updateA, updateB, sumA, sumB, fim, x);
	xFD: mmc_fd port map(reset, clock, inicia, A, B, nSomas, MMC, updateA, updateB, sumA, sumB, x, isDiff, isLess);
--Sinais internos
	clock_n <= not(clock);
end architecture;