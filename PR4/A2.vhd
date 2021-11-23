entity fulladder is
	port (
	  a, b, cin: in bit;
	  s, cout: out bit
	);
   end entity;
-------------------------------------------------------
architecture structural of fulladder is
signal axorb: bit;
begin
	axorb <= a xor b;
	s <= axorb xor cin;
	cout <= (axorb and cin) or (a and b);
end architecture;

entity alu1bit is
	port(
		a, b, less, cin: in bit;
		result, cout, set, overflow: out bit;
		ainvert, binvert: in bit;
		operation: in bit_vector(1 downto 0)
	);
end entity;
architecture alu1bit_arch of alu1bit is
component fulladder is
	port (
	  a, b, cin: in bit;
	  s, cout: out bit
	);
   end component;

signal sAND, sOR, ADD, SLT, notA, notB, operatorA, operatorB, soma, sCout: bit;

begin
	notA <= not(A);
	notB <= not(B);

	operatorA <= A when ainvert = '0' else notA;
	operatorB <= B when binvert = '0' else notB;

	sAND <= '1' when operation = "00" else '0';
	sOR  <= '1' when operation = "01" else '0';
	ADD  <= '1' when operation = "10" else '0';
	SLT  <= '1' when operation = "11" else '0';

	adder: fulladder port map(operatorA, operatorB, cin, soma, sCout);
	overflow <= cin xor sCout;
	cout <= sCout;
	set <= soma;
	result <= (operatorA or operatorB) when sOR = '1' else
			  (operatorA and operatorB) when sAND = '1' else
			  soma when ADD = '1' else
			  less when SLT = '1';




end architecture;
-----------------------------------
entity alu is
	generic(
		size : natural := 10 --bit size
	);
	port (
		A, B : in bit_vector(size-1 downto 0); --inputs
		F 	 : out bit_vector(size-1 downto 0); --output
		S    : in bit_vector(3 downto 0);	-- op selection
		Z	 : out bit; --zero flag
		Ov	 : out bit; --overflow flag
		Co	 : out bit -- carry out
	);
end entity alu;
architecture alu_arch of alu is
component fulladder is
	port (
		a, b, cin: in bit;
		s, cout: out bit
	);
	end component;
component alu1bit is
	port(
		a, b, less, cin: in bit;
		result, cout, set, overflow: out bit;
		ainvert, binvert: in bit;
		operation: in bit_vector(1 downto 0)
	);
end component;

signal sCin : bit_vector(size downto 0);
signal less, set, result, overflow, nulo : bit_vector(size - 1 downto 0);
signal sAND, sOR, soma, bit_subtrai, subtrai, SLT, sNor, inverteA, inverteB : bit; 
signal bit_operation : bit_vector(1 downto 0);
begin

sAND 	<= '1' when S = "0000" else '0';
sOR  	<= '1' when S = "0001" else '0';
soma 	<= '1' when S = "0010" else '0';
subtrai <= '1' when S = "0110" else '0';
SLT 	<= '1' when S = "0111" else '0';
sNor 	<= '1' when S = "1100" else '0';

bit_operation <= "00" when sAND = '1' or sNor = '1' else
		   "01" when sOr = '1' else
		   "10" when soma = '1' or subtrai = '1' else
		   "11" when slt = '1';

sCin(0) <= '1' when subtrai = '1' or sNor = '1' or SLT = '1' else '0';

inverteA <= '1' when sNor = '1' else '0';
inverteB <= '1' when sNor = '1' or subtrai  = '1' or SLT = '1' else '0';
nulo <= (others => '0');
bank_ula: for i in size-1 downto 0 generate
	less(i) <= set(size-1) when(i=0) else '0';
	ula_unity: alu1bit port map(
		A(i),
		B(i),
		less(i),
		sCin(i),
		result(i),
		sCin(i+1),
		set(i),
		overflow(i),
		inverteA,
		inverteB,
		bit_operation
	);
end generate;
F <= result;
Ov <= overflow(size - 1);
Z <= '1' when result = nulo else '0';
Co <= sCin(size);

end architecture;