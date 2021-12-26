# Sistemas Digitais II - PCS3225

Consiste na compilação dos diversos Exercícios Programas abordados ao longo da disciplina PCS3225. Nota-se que a linguagem VHDL é o foco da matéria e, para usuários de Linux, cabe criar um Shell Script a fim de executar comandos para o debugging/depuração do código e entendimento do comportamento dos sinais dentro do circuito virtual.
Uma estrutura clássica para realizar de forma mais automática é a seguinte:
```
ghdl -a your_design.vhd
ghdl -a your_testbench.vhd
ghdl -e testbench_entity
ghdl -r testbench_entity --vcd=simul.vcd
```

Por fim, a disciplina contribui para entender diretamente como processadores são projetados e fabricados no mundo moderno.
