library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-----------------------------------------------------------------
entity DLatch is
	generic( Dwidth: integer:=16 );
	port(   en,rst:			in 		std_logic;
			D: 				in 		std_logic_vector(Dwidth-1 downto 0);
			Q:				out		std_logic_vector(Dwidth-1 downto 0)
			);
end DLatch;

architecture sync of DLatch is

begin 
	process(en, rst,D)
	begin
		if (rst ='1') then
			Q <= (others =>'0');
		elsif (en ='1') then
			Q <= D;
		end if;
	end process;
	
end sync;

