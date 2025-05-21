library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-----------------------------------------------------------------
entity DFF is
	generic( Dwidth: integer:=16 );
	port(   clk,en,rst:			in 		std_logic;
			D: 					in 		std_logic_vector(Dwidth-1 downto 0);
			Q:					out		std_logic_vector(Dwidth-1 downto 0)
			);
end DFF;

architecture sync of DFF is

begin 
	process(clk, rst)
	begin
		if (rst ='1') then
			Q <= (others =>'0');
		elsif (rising_edge(clk)) then
			if (en ='1') then
				Q <= D;
			else 
			 Q <= (others =>'0');
			end if;
		end if;
	end process;
	
end sync;

