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