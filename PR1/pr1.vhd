-- Registrador de 16 bits
entity reg16 is
	port(
		clock, reset: in  bit;
		load:         in  bit;
		parallel_in:  in  bit_vector(15 downto 0);
		parallel_out: out bit_vector(15 downto 0)
	);
  end entity;
  
  architecture arch_reg16 of reg16 is
	begin
		process(clock, reset)
		begin
			if reset = '1' then -- reset assincrono
				parallel_out <= (others => '0'); -- "000000"
			elsif (clock'event and clock='1') then
				if load = '1' then
				  parallel_out <= parallel_in;
				end if;
			end if; 
		end process;
  end architecture;
		--Registrador de 8 bits--
entity reg8 is 
port(
	clock, reset: in  bit;
	load:         in  bit;
	parallel_in:  in  bit_vector(7 downto 0);
	parallel_out: out bit_vector(7 downto 0)
);
end entity;

architecture arch_reg8 of reg8 is
begin
	process(clock, reset)
	begin
		if reset = '1' then -- reset assincrono
			parallel_out <= (others => '0'); -- "000000"
		elsif (clock'event and clock='1') then
			if load = '1' then
				parallel_out <= parallel_in;
			end if;
		end if; 
	end process;
end architecture;
		--Registrador de 9 bits--
entity reg9 is 
port(
	clock, reset: in  bit;
	load:         in  bit;
	parallel_in:  in  bit_vector(8 downto 0);
	parallel_out: out bit_vector(8 downto 0)
);
end entity;

architecture arch_reg9 of reg9 is
begin
	process(clock, reset)
	begin
		if reset = '1' then -- reset assincrono
			parallel_out <= (others => '0'); -- "000000"
		elsif (clock'event and clock='1') then
			if load = '1' then
				parallel_out <= parallel_in;
			end if;
		end if; 
	end process;
end architecture;

library ieee;
use ieee.numeric_bit.all;
entity UCmmc is 
	port(
		reset,clock,isDiff,isLess,inicia,isZero: in bit;
		updateA,updateB,updateS,sumA,sumB,enable_soma,fim,initValues,x: out bit
	);
end UCmmc;
-- VERIFICAR DE RESET SERIA UM ESTADO
architecture arch_uc of UCmmc is 
	type state is (Start,a_igl_b, mA_maior_mB,mA_menor_mB,test_a_b,zero); -- Estados
	signal next_state, current_state : state; 
begin
	process(clock,reset)
	begin
		if reset = '1' then
			current_state <= Start;
		elsif (clock'event and clock ='1') then
			current_state <= next_state;
		end if;
	end process;
	-- Estado inicio
next_state <= 
				Start when (current_state = Start) and (inicia = '0') else --ok
				test_a_b when (current_state = Start) and (inicia = '1') else --ok
				zero   when (current_state = test_a_b) and (isZero='1') else
				Start when (current_state = zero) else
				a_igl_b when (current_state = test_a_b) and (isDiff = '0') else
				Start when (current_state = a_igl_b) else
				mA_maior_mB when (current_state = test_a_b) and (isDiff = '1') and (isLess = '0') else
				test_a_b when (current_state = mA_maior_mB) and (isDiff ='1') else
				test_a_b when (current_state = mA_menor_mB) and (isDiff ='1') else
				mA_menor_mB when (current_state = test_a_b) and (isDiff = '1') and (isLess = '1') else

				--RESETS
				Start when (current_state = test_a_b) and (reset ='1') else
				Start when (current_state = a_igl_b) and (reset ='1') else
				Start when (current_state = mA_maior_mB) and (reset ='1') else
				Start when (current_state = Start) and (reset ='1') else
				Start when (current_state = zero) and (reset ='1') else 
				Start when (current_state = mA_menor_mB) and (reset ='1');


	updateA <= '1' when (current_state = Start) or (current_state = mA_menor_mB) else '0';--Habilita a escrita nos registrador de A 
	updateB <= '1' when (current_state = Start) or (current_state = mA_maior_mB) else '0';--Habilita a escrita nos registrador de B
	updateS <= '1' when ( (current_state = mA_maior_mB) or (current_state= mA_menor_mB) ) and (isDiff = '1') else '0';
	sumA <= '1' when (current_state = mA_menor_mB) and (isDiff ='1')  else '0' ; -- Habilita a soma a = a + ma 
	sumB <= '1' when (current_state = mA_maior_mB) and (isDiff ='1') else '0' ; -- Habilita a soma b = b + mb
	enable_soma <= '1' when ((current_state = mA_maior_mB) or (current_state = mA_menor_mB)) else '0';--Habilita a soma nSoma = nSoma + 1 
	fim <= '1' when (current_state = a_igl_b) or (current_state = zero) else '0';
	x <= '1' when (current_state = a_igl_b) or (current_state = zero) else '0';
	initValues <= '1' when (current_state = Start) else '0';
end architecture;

library ieee;
use ieee.numeric_bit.all;
entity FDmmc is 
	port(
		reset,clock,updateA,updateB,updateS, sumA,sumB,enable_soma,initValues,x,fim: in bit; 
		A,B:    in bit_vector(7 downto 0);
		nSomas: out bit_vector(8 downto 0);
		mmc: out bit_vector(15 downto 0);
		isDiff,isLess,isZero: out bit
	);
end entity;

architecture arch_fd of FDmmc is
		--Declaracao das components--

		--Registrador de 16 bits--
component reg16 is
	port(
		clock, reset: in  bit;
		load:         in  bit;
		parallel_in:  in  bit_vector(15 downto 0);
		parallel_out: out bit_vector(15 downto 0)
	);
  end component;
		--Registrador de 8 bits--
component reg8 is 
port(
	clock, reset: in  bit;
	load:         in  bit;
	parallel_in:  in  bit_vector(7 downto 0);
	parallel_out: out bit_vector(7 downto 0)
);
end component;
		--Registrador de 9 bits--
component reg9 is 
port(
	clock, reset: in  bit;
	load:         in  bit;
	parallel_in:  in  bit_vector(8 downto 0);
	parallel_out: out bit_vector(8 downto 0)
);
end component;

		--Sinais internos--
signal AA,BB : bit_vector(15 downto 0) ;
signal mmA,mmB : bit_vector(15 downto 0);
signal ma : bit_vector(7 downto 0) ;
signal mb : bit_vector(7 downto 0) ;
signal SSoma : bit_vector(8 downto 0) ;
signal nSomas_reg : bit_vector(8 downto 0) ;
signal reset_soma : bit;
		-- Mapeamento das components--
begin

reg1: reg8 port map(clock,reset,initValues,A,ma);
reg2: reg8 port map(clock,reset,initValues,B,mb);
reg3: reg16 port map(clock,reset,updateA,mmA,AA);
reg4: reg16 port map(clock,reset,updateB,mmB,BB);
reg5: reg16 port map(x,'0',x,AA,mmc);
reg6: reg9 port map(clock,reset_soma,updateS,SSoma,nSomas_reg);


mmA <= ("00000000"&A) when (sumA='0') else bit_vector(unsigned(AA) + unsigned("00000000"&ma));
mmB <= ("00000000"&B) when (sumB='0') else bit_vector(unsigned(BB) + unsigned("00000000"&mb));
SSoma <= "000000000" when   (x ='1') else bit_vector(unsigned(nSomas_reg) + 1);
reset_soma <= '1' when (initValues ='1') else '0';
nSomas <= nSomas_reg; 

		--Sinais de condição-- 
isDiff <= '1' when (AA/=BB) else '0';
isLess <= '1' when (AA<BB) else '0';
isZero <= '1' when (A="00000000") or (B="00000000") else '0';

end architecture; 
  

library ieee;
use ieee.numeric_bit.all;
		--MMC--
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

architecture mmc_arch of mmc is
	--Component UC --
    component UCmmc is 
    port(
        reset,clock,isDiff,isLess,inicia,isZero: in bit;
        updateA,updateB,updateS,sumA,sumB,enable_soma,fim,initValues,x: out bit
    );
    end component;
	--Component FD--
    component FDmmc is 
    port(
        reset,clock,updateA,updateB,updateS, sumA,sumB,enable_soma,initValues,x,fim: in bit; 
        A,B:    in bit_vector(7 downto 0);
        nSomas: out bit_vector(8 downto 0);
        mmc: out bit_vector(15 downto 0);
        isDiff,isLess,isZero: out bit
    );
    end component;
	--Sinais internos--
    signal updateA,updateB,updateS,enable_soma,sumA,sumB,x,initValues,fim_s,isZero: bit;
    signal isDiff,isLess: bit;
    signal clock_n : bit;
begin
	--Clock para UC--
    clock_n <= not(clock);
    uc : UCmmc port map(reset,clock_n,isDiff,isLess,inicia,isZero,updateA,updateB,updateS,sumA,sumB,enable_soma,fim,initValues,x);
    fd : FDmmc port map(reset,clock,updateA,updateB,updateS,sumA,sumB,enable_soma,initValues,x,fim_s,A,B,nSomas,MMC,isDiff,isLess,isZero);
end architecture;
