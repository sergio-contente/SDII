entity register8 is
	port (
	  clock, reset : in bit;
	  load         : in bit;
	  parallel_in  : in bit_vector(7 downto 0);
	  parallel_out : out bit_vector(7 downto 0)
	);
  end entity;
  architecture arch_reg8 of register8 is
	signal internal : bit_vector(7 downto 0);
  begin
	process (clock, reset)
	begin
	  if reset = '1' then -- reset assincrono
		internal <= (others => '0'); -- "000000"
	  elsif (clock'event and clock = '1') then
		if load = '1' then
		  internal <= parallel_in;
		end if;
	  end if;
	end process;
	parallel_out <= internal;
  end architecture;
  
  entity register9 is
	port (
	  clock, reset : in bit;
	  load         : in bit;
	  parallel_in  : in bit_vector(8 downto 0);
	  parallel_out : out bit_vector(8 downto 0)
	);
  end entity;
  architecture arch_reg9 of register9 is
	signal internal : bit_vector(8 downto 0);
  begin
	process (clock, reset)
	begin
	  if reset = '1' then -- reset assincrono
		internal <= (others => '0'); -- "000000"
	  elsif (clock'event and clock = '1') then
		if load = '1' then
		  internal <= parallel_in;
		end if;
	  end if;
	end process;
	parallel_out <= internal;
  end architecture;
  
  entity register16 is
	port (
	  clock, reset : in bit;
	  load         : in bit;
	  parallel_in  : in bit_vector(15 downto 0);
	  parallel_out : out bit_vector(15 downto 0)
	);
  end entity;
  architecture arch_reg16 of register16 is
	signal internal : bit_vector(15 downto 0);
  begin
	process (clock, reset)
	begin
	  if reset = '1' then -- reset assincrono
		internal <= (others => '0'); -- "000000"
	  elsif (clock'event and clock = '1') then
		if load = '1' then
		  internal <= parallel_in;
		end if;
	  end if;
	end process;
	parallel_out <= internal;
  end architecture;
  --------------------------------------------------------------------
  entity UC is
	port (
	  clock, reset, iniciar : in bit;
	  -------Sinais de Status-------
	  a_maior_in, iguais, algumzero : in bit;
	  sa, sb, ss, salvar            : out bit;
	  fim                           : out bit
	);
  end entity;
  
  library ieee;
  use ieee.numeric_bit.all;
  entity FD is
	port (
	  clock, reset, sa, sb, ss, salvar : in bit;
	  a_maior_in, iguais, algumzero    : out bit;
	  mmc_out                          : out bit_vector(15 downto 0);
	  soma                             : out bit_vector(8 downto 0);
	  a_en, b_en                       : in bit_vector(7 downto 0)
	);
  end entity;
  
  architecture arc_UC of UC is
	type state is (espera, load, teste, a_maior_b, a_menor_b, final);
	signal next_state, current_state : state;
  begin
	process (clock, reset)
	begin
	  if reset = '1' then -- reset assincrono
		current_state <= espera;
	  elsif (clock'event and clock = '1') then
		current_state <= next_state;
	  end if;
	end process;
  
	next_state <=
	  load when current_state = espera and iniciar = '1' else
  
	  teste when (current_state = load or current_state = a_maior_b or current_state = a_menor_b) else
	  final when (algumzero = '1') and (current_state = teste) else
  
	  a_maior_b when (a_maior_in = '1' and iguais = '0') and current_state = teste else
	  a_menor_b when (a_maior_in = '0' and iguais = '0') and current_state = teste else
  
	  final;
  
	salvar <= '1' when current_state = load or current_state = espera else '0';
	sa     <= '1' when (current_state = a_menor_b or current_state = load) and algumzero = '0' else '0';
	sb     <= '1' when (current_state = a_maior_b or current_state = load) and algumzero = '0' else '0';
	ss     <= '1' when current_state = a_menor_b or current_state = a_maior_b else '0';
	fim    <= '1' when current_state = final else '0';
  end architecture;
  
  architecture arc_FD of FD is
	component register8 is
	  port (
		clock, reset : in bit;
		load         : in bit;
		parallel_in  : in bit_vector(7 downto 0);
		parallel_out : out bit_vector(7 downto 0)
	  );
	end component;
	component register9 is
	  port (
		clock, reset : in bit;
		load         : in bit;
		parallel_in  : in bit_vector(8 downto 0);
		parallel_out : out bit_vector(8 downto 0)
	  );
	end component;
	component register16 is
	  port (
		clock, reset : in bit;
		load         : in bit;
		parallel_in  : in bit_vector(15 downto 0);
		parallel_out : out bit_vector(15 downto 0)
	  );
	end component;
	signal a0, b0               : bit_vector(7 downto 0);
	signal ma, mb, ma_in, mb_in : bit_vector(15 downto 0);
	signal s, s_in              : bit_vector(8 downto 0);
	signal clock_n              : bit;
  begin
	clock_n <= (clock);
	regmA0  : register8 port map(clock_n, reset, salvar, a_en, a0);
	regmB0  : register8 port map(clock_n, reset, salvar, b_en, b0);
	regmA   : register16 port map(clock_n, reset, sa, ma_in, ma);
	regmB   : register16 port map(clock_n, reset, sb, mb_in, mb);
	regSoma : register9 port map(clock_n, reset, ss, s_in, s);
  
	ma_in      <= bit_vector(unsigned(ma) + unsigned(a0));
	mb_in      <= bit_vector(unsigned(mb) + unsigned(b0));
	s_in       <= bit_vector(unsigned(s) + 1);
	mmc_out    <= bit_vector(ma);
	a_maior_in <= '1' when unsigned(ma) > unsigned(mb) else '0';
	iguais     <= '1' when unsigned(ma) = unsigned(mb) else '0';
	algumzero  <= '1' when b0 = "00000000" or a0 = "00000000" else '0';
	soma       <= s;
  
  end architecture;
  
  entity mmc is
	port (
	  reset, clock : in bit;
	  inicia       : in bit;
	  A, B         : in bit_vector(7 downto 0);
	  fim          : out bit;
	  nSomas       : out bit_vector(8 downto 0);
	  MMC          : out bit_vector(15 downto 0)
	);
  end mmc;
  
  architecture arc_mmc of mmc is
	component UC is
	  port (
		clock, reset, iniciar : in bit;
		-------Sinais de Status-------
		--      h1      h2         h3
		a_maior_in, iguais, algumzero : in bit;
  
		--h4 h5  h6   h7
		sa, sb, ss, salvar : out bit;
		fim                : out bit
	  );
	end component;
  
	component FD is
	  port (
		clock, reset, sa, sb, ss, salvar : in bit;
		a_maior_in, iguais, algumzero    : out bit;
		mmc_out                          : out bit_vector(15 downto 0);
		soma                             : out bit_vector(8 downto 0);
		a_en, b_en                       : in bit_vector(7 downto 0)
	  );
	end component;
  
	signal h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13 : bit;
  begin
	xUC : UC port map(clock, reset, inicia, h1, h2, h3, h4, h5, h6, h7, fim);
	xFD : FD port map(clock, reset, h4, h5, h6, h7, h1, h2, h3, MMC, nSomas, A, B);
  end architecture;