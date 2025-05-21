library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--------------------------------------------------------------
entity OPCdecoder is
generic( OPC_size: integer:=4);
		 
port(	OPC:										in std_logic_vector(OPC_size-1 downto 0);
		st, ld, mov, done, add, sub, jmp, jc, jnc, 
		and_OPC, or_OPC, xor_OPC,shl,shr,j1,j2:		out std_logic	
		
);
end OPCdecoder;
--------------------------------------------------------------
architecture behav of OPCdecoder is

begin add 		<= '1' 	when OPC = "0000" else '0';
	  sub 		<= '1' 	when OPC = "0001" else '0';
	  and_OPC	<= '1'	when OPC = "0010" else '0';
	  or_OPC	<= '1' 	when OPC = "0011" else '0';
	  xor_OPC	<= '1'	when OPC = "0100" else '0';
	  shl		<= '1'	when OPC = "0101" else '0';
	  shr		<= '1'	when OPC = "0110" else '0';
	  jmp 		<= '1'	when OPC = "0111" else '0';
	  jc		<= '1' 	when OPC = "1000" else '0';
	  jnc		<= '1'	when OPC = "1001" else '0';
	  j1		<= '1'	when OPC = "1010" else '0';
	  j2		<= '1'	when OPC = "1011" else '0';
	  mov 		<= '1'	when OPC = "1100" else '0';
	  ld 		<= '1' 	when OPC = "1101" else '0';
	  st 		<= '1' 	when OPC = "1110" else '0';
	  done 		<= '1' 	when OPC = "1111" else '0';
end behav;
	  
	  