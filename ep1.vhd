library ieee;
use ieee.numeric_bit.all;
--Registrador de 8 bits que pode somar sua capacidade
entity registerOp8 is
	port (
	  clock, reset  : in bit;						  -- Controle global: clock e reset
	  enableIn      : in bit;                       -- Enable para carregar input
	  enAdd			: in bit;						  -- Enables para somar
	  parallel_in   : in bit_vector(7 downto 0);   -- Input dado ao registrador
	  parallel_out  : out bit_vector(7 downto 0)    -- Conteúdo do registrador
	);
  end entity;
  
  architecture arch_reg8 of registerOp8 is
	  signal internal, first_input: unsigned(7 downto 0);
	  begin
	  
	  process(clock, reset)
	  begin
		  if reset = '1' then
			  internal <= (others => '0');
		
		  elsif clock'event and clock='1' then
			  if enableIn = '1' then 
			  	internal <= unsigned(parallel_in);
				unit_vec <= internal;
			  elsif enAdd = '1' then internal <= internal + unit_vec;
			  end if;
		end if;
	  end process;
  
	  parallel_out <= bit_vector(internal);
  
  end arch_reg8;
--UC (Unity Control)
entity UCmmc is
	port(
        reset, clock           : in bit;  -- SINAIS UNIVERSAIS
        iniciar, isDiff, isLess : in bit;  -- SINAL DE CONDICAO
        initValues          : out bit; -- SINAL DE CONTROLE
        updateSumA, updateSumB : out bit; -- SINAL DE CONTROLE
        end_state         		: out bit; -- SINAL DE CONTROLE
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
	Start        when (state = Start) and (iniciar = '0') else
	test_a_b	 when (state = Start) and (iniciar = '1') else
	
	mA_maior_mB  when (state = test_a_b) 	 and (isLess = '1') and (isDiff = '0') else
	mB_maior_mA  when  (state = test_a_b) 	 and (isLess = '0') and (isDiff = '0') else
	
	a_igl_b      when (state = test_a_b) and (isDiff = '1');
	-- COMPORTAMENTO DOS SINAIS DE CONTROLE
	initValues <= '1' when ((state = Start) and (iniciar = '0')) or (state = A_igl_B)) else '0';
	updateSumA <= '1' when (state = mA_maior_mB) else '0';
	updateSumB <= '1' when (state = mB_maior_mA) else '0';
	end_state <= '1' when (state = a_igl_b) else '0';
	reset_FD <= '1' when (reset = '1') else '0';
	end arch_uc;

--FD (Fluxo de Dados)
entity FDmmc is
	port(
		reset, clock             : in bit; -- CONTROLE GLOBAL
        inicia			         : in bit;
        A, B       			 	 : in bit_vector(7 downto 0);
       	fim           			 : out bit;
        nSomas				     : out bit_vector(3 downto 0);
		updateSumA, updateSumB 	 : in bit; -- SINAIS DE CONTROLE
        initValues		         : in bit;  -- SINAL DE CONTROLE
        iniciar, isDiff, isLess  : out bit -- SINAIS DE CONDICAO
	);
end FDmmc;

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

end component;

component mmc_fd is

end component;

--Declaração de sinais internos

begin

--Mapeamento dos componentes

--Sinais internos

end architecture;