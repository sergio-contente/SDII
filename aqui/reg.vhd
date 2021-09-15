
-- Registrador de 16 bits
entity reg_gen is
  generic(
    tamanho : natural
    );  
  port(
      clock, reset: in  bit;
      load:         in  bit;
      parallel_in:  in  bit_vector(tamanho-1 downto 0);
      parallel_out: out bit_vector(tamanho-1 downto 0)
  );
end entity;

architecture arch_reg of reg_gen is
  signal internal: bit_vector(tamanho-1 downto 0);
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
      --parallel_out <= internal;
end architecture;