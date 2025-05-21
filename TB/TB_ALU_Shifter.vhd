library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use IEEE.std_logic_textio.all;
USE work.aux_package.all;





entity TB_ALU_SHIIT is

		constant m:	 		  		integer:=16;-- ITCM input size
		constant n:	 		  		integer:=16;-- DTCM input output size
		constant Dwidth:	  		integer:=16;
		constant Awidth:	  		integer:=6;
		constant offset_size: 		integer:=8;
		constant OPC_size: 	  		integer:=4;
		constant Reg_size: 	  		integer:=4;
		constant dept:	 	  		integer:=64;
		constant ROWmax : 			integer := 29;
		constant progMemLocation: 	string(1 to 79) :=
		"C:\Users\talad\OneDrive\CPU Architecture lab\Lab3\our_lab3\Ex1\bin\ITCMinit.txt";
		constant dataMemLocationRead: 	string(1 to 79) :=
		"C:\Users\talad\OneDrive\CPU Architecture lab\Lab3\our_lab3\Ex1\bin\DTCMinit.txt";
		constant dataMemLocationWrite: 	string(1 to 82) :=
		"C:\Users\talad\OneDrive\CPU Architecture lab\Lab3\our_lab3\Ex1\bin\DTCMcontent.txt";
end TB_ALU_SHIIT;

architecture rtb of TB_ALU_SHIIT is
		signal rst, ena, clk: 					std_logic;	
		signal A_input, B_input:				std_logic_vector(Dwidth-1 downto 0);
		signal ALUFN:							std_logic_vector(3 downto 0);
		signal C_output:						std_logic_vector(Dwidth-1 downto 0);
		signal Cflag, Zflag, Nflag:				std_logic;
		
	begin

--component ALU generic map( Dwidth,Awidth) port map(A,B,ALUFN,C ,Cflag, Zflag, Nflag);
ALU_PORTS: ALU generic map( Dwidth,Awidth) port map(A_input,B_input,ALUFN,C_output,Cflag, Zflag, Nflag);

-----------  clock  --------------
gen_clk : process
    begin
	clk <= '0';
	wait for 50 ns;
	clk <= not clk;
	wait for 50 ns;
    end process;

----------- Rst  ------------------
gen_rst : process
        begin
		  rst <='1','0' after 100 ns;
		  wait;
        end process;	


---------------------------------------
tb_A_B : process
        begin
		  A_input <= (others => '1');
		  B_input <= (others => '0');
		  wait for 100 ns;
		  for i in 0 to 40 loop
			A_input <= A_input-10;
			B_input <= B_input+1;
			wait for 100 ns;
		  end loop;
		  wait;
        end process;
		 
		
		tb_ALUFN : process
        begin
		  ALUFN <= "0110"; --shl
		  wait for 1500 ns;
		  ALUFN <= "0110"; -- shr
		  wait for 1500 ns;
		  wait;
        end process;
end architecture rtb;
