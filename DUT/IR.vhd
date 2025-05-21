library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--------------------------------------------------------------
entity IR is
	 
generic(Dwidth: integer:=16;
		Awidth: integer:=6;
		OPC_size: integer:=4;
		Reg_size: integer:=4
		);
		 
Port(DataOut_i:				in std_logic_vector(Dwidth-1 downto 0);
	 RFaddr_rd, RFaddr_wr:	in std_logic_vector(1 downto 0);
	 IRin:		 			in std_logic;
	 OPC_o:					out std_logic_vector(OPC_size-1 downto 0);
	 IRaddr_rd, IRaddr_wr:	out std_logic_vector(Reg_size-1 downto 0);
	 Imm4_o:				out std_logic_vector(3 downto 0);
	 Imm8_o:				out std_logic_vector(7 downto 0)
);

end IR;
--------------------------------------------------------------
architecture behav of IR is


signal IR_value:				std_logic_vector(Dwidth-1 downto 0); 
alias  rc is IR_value			(Reg_size-1 downto 0); -- setting the opc part
alias  rb is IR_value			(2*Reg_size-1 downto Reg_size); -- setting the ra part
alias  ra is IR_value			(3*Reg_size-1 downto 2*Reg_size); -- setting the rb part
alias  OPC is IR_value			(OPC_size+3*Reg_size-1 downto OPC_size+2*Reg_size); -- setting the rc part
alias  Imm4 is IR_value			(4-1 downto 0); -- setting the imm4 part
alias  Imm8 is IR_value			(8-1 downto 0); -- setting the imm8 part

begin
	OPC_o <= OPC;
	IR_value <= DataOut_i when IRin = '1' else unaffected;
	with RFaddr_rd select
		 IRaddr_rd <= ra when "00",
					rb when "01",
					rc when "10",
					unaffected when others;
	with RFaddr_wr select
		 IRaddr_wr <= ra when "00",
					rb when "01",
					rc when "10",
					unaffected when others;
					
	Imm4_o <= Imm4;
	Imm8_o <= Imm8;
	
end behav;