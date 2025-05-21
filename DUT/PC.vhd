library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--------------------------------------------------------------
entity PCarchitecture is
generic( Awidth: 	  	integer:=6;
		 offset_size: 	integer:=8;
		 dept:	 	  	integer:=64);
		 
port(	clk, PCin:				in std_logic;
		IRin_offset:			in std_logic_vector(offset_size-1 downto 0);
		PCsel:					in std_logic_vector(1 downto 0);
		PCout:					out std_logic_vector(Awidth-1 downto 0)
		
);
end PCarchitecture;


--PCarchitecture generic map(Awidth,offset_size,dept)port map(clk :in,PCin:in,IRin_offset:in
-- PCsel:in ,PCout:out  )

--------------------------------------------------------------
architecture behav of PCarchitecture is
	signal CurrPC, NextPC,OFFSET_checking: 	 std_logic_vector(Awidth-1 downto 0);
	signal PC_INC ,PC_WITH_OFFSET : std_logic_vector(Awidth-1 downto 0);

	
begin 
--------- NextPC_architecture
	
PC_INC <= CurrPC + 1 ;
PC_WITH_OFFSET <= CurrPC + 1 + SXT(IRin_offset,Awidth) ;


with PCsel select
				NextPC 	<= 	PC_INC when "00", -- PC+1
							PC_WITH_OFFSET when "01", -- PC+1+IR<7...0>
							(others=>'0') when others;-- reset PC
							





PC_box: process(clk) begin
		if rising_edge(clk) then
			if PCin = '1' then
				CurrPC <= NextPC;
			else 
				CurrPC <= CurrPC;
			end if;
		end if;
end process;

PCout <= CurrPC ;


end behav;






		