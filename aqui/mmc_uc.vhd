library ieee;
use ieee.numeric_bit.all;
entity mmc_uc is 
    port(
        reset,clock,diferente,menor_fd,inicia,igual_0: in bit;
        loadA,loadB,loadS,en_sumA,en_sumB,en_soma,fim,init,signal1: out bit
    );
end mmc_uc;
-- VERIFICAR DE RESET SERIA UM ESTADO
architecture fsm of mmc_uc is 
    type state is (espera,a_igual_b, a_maior_b,a_menor_b,tes_a_b,a_b_0); -- Estados
    signal next_state, current_state : state; 
begin
    process(clock,reset)
    begin
        if reset = '1' then
            current_state <= espera;
        elsif (clock'event and clock ='1') then
            current_state <= next_state;
        end if;
    end process;
    -- Estado inicio
 next_state <= 
                  espera when (current_state = espera) and (inicia = '0') else --ok
                  tes_a_b when (current_state = espera) and (inicia = '1') else --ok
                  a_b_0   when (current_state = tes_a_b) and (igual_0='1') else
                  espera when (current_state = a_b_0) else
                  a_igual_b when (current_state = tes_a_b) and (diferente = '0') else
                  espera when (current_state = a_igual_b) else
                  a_maior_b when (current_state = tes_a_b) and (diferente = '1') and (menor_fd = '0') else
                  tes_a_b when (current_state = a_maior_b) and (diferente ='1') else
                  tes_a_b when (current_state = a_menor_b) and (diferente ='1') else
                  a_menor_b when (current_state = tes_a_b) and (diferente = '1') and (menor_fd = '1') else

                --RESETS
                  espera when (current_state = tes_a_b) and (reset ='1') else
                  espera when (current_state = a_igual_b) and (reset ='1') else
                  espera when (current_state = a_maior_b) and (reset ='1') else
                  espera when (current_state = espera) and (reset ='1') else
                  espera when (current_state = a_b_0) and (reset ='1') else 
                  espera when (current_state = a_menor_b) and (reset ='1');


    loadA <= '1' when (current_state = espera) or (current_state = a_menor_b) else '0';--Habilita a escrita nos registrador de A 
    loadB <= '1' when (current_state = espera) or (current_state = a_maior_b) else '0';--Habilita a escrita nos registrador de B
    loadS <= '1' when ( (current_state = a_maior_b) or (current_state= a_menor_b) ) and (diferente = '1') else '0';
    en_sumA <= '1' when (current_state = a_menor_b) and (diferente ='1')  else '0' ; -- Habilita a soma a = a + ma 
    en_sumB <= '1' when (current_state = a_maior_b) and (diferente ='1') else '0' ; -- Habilita a soma b = b + mb
    en_soma <= '1' when ((current_state = a_maior_b) or (current_state = a_menor_b)) else '0';--Habilita a soma nSoma = nSoma + 1 
    fim <= '1' when (current_state = a_igual_b) or (current_state = a_b_0) else '0';
    signal1 <= '1' when (current_state = a_igual_b) or (current_state = a_b_0) else '0';
    init <= '1' when (current_state = espera) else '0';
end architecture;
