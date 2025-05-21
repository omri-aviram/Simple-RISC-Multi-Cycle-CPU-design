library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;

entity top is
generic( m:	 												integer:=16; -- ITCM input size
		 n:	 												integer:=16; -- DTCM input output size
		 Dwidth:											integer:=16; -- DTCM input output size
		 Awidth:											integer:=6;
		 offset_size:										integer:=8;
		 dept:   											integer:=64;
		 OPC_size:									 		integer:=4;
		 Reg_size: 											integer:=4

);
port(	rst, ena, clk: 										in std_logic;	-- Data to/from TB
		ITCM_tb_wr, DTCM_tb_wr, TBactive:								in std_logic;
		ITCM_tb_addr_in,DTCM_tb_addr_in,DTCM_tb_addr_out:	in std_logic_vector(Awidth-1 downto 0); 
		ITCM_tb_in:											in std_logic_vector(m-1 downto 0); -- ITCM Data_in
		DTCM_tb_in:											in std_logic_vector(n-1 downto 0); -- DTCM Data_in  (initial)
		DTCM_tb_out:										out std_logic_vector(n-1 downto 0); -- DTCM Data_out  (final)
		done_FSM:											out std_logic
		
);		
end top;

architecture behav of top is

--DataPath signals
signal	 PCin , Ain:							std_logic;
signal	 PCsel:									std_logic_vector(1 downto 0);
signal	 ALUFN:									std_logic_vector(3 downto 0);
signal	 RFaddr_wr, RFaddr_rd:					std_logic_vector(1 downto 0);
signal	 IRin:		 							std_logic;
signal	 RFin:									std_logic;
signal	 Imm1_in, Imm2_in, RFout:				std_logic;
signal	 st, ld, mov, done, add, sub,jmp,jc,
		 jnc,and_OPC, or_OPC, xor_OPC,shl,shr,
		 j1,j2:   								std_logic;
signal	 Cflag, Zflag, Nflag:				    std_logic;

--control signals
signal	 DTCM_addr_out,DTCM_addr_in,DTCM_out:	std_logic;
signal	 DTCM_wr, DTCM_addr_sel:				std_logic; 



begin
	
--Control generic map(Dwidth,Awidth,dept)port map(rst,ena,clk,mov_i,done_i,and_i,or_i,xor_i,
--jnc_i,jc_i,jmp_i,sub_i,add_i,Nflag_i,Zflag_i,Cflag_i,ld_i,st_i,shl,shr,j1,j2,DTCM_wr_o,DTCM_addr_out_o,DTCM_addr_in_o,DTCM_out_o,
--DTCM_addr_sel, Ain_o, RFin_o,RFout_o,IRin_o,PCin_o, Imm1_in_o,Imm2_in_o,ALUFN,RFaddr_wr, RFaddr_rd, PCsel_o,done_FSM);
Control_Ports: Control generic map(Dwidth,Awidth,dept)port map(rst,ena,clk,mov,done,and_OPC,or_OPC,xor_OPC,
						jnc,jc,jmp,sub,add,Nflag,Zflag,Cflag,ld,st,shl,shr,j1,j2,DTCM_wr,DTCM_addr_out,DTCM_addr_in,DTCM_out,
						DTCM_addr_sel,Ain, RFin,RFout,IRin,PCin,Imm1_in,Imm2_in,ALUFN,RFaddr_wr, RFaddr_rd, PCsel,done_FSM);

-- Datapath generic map (Dwidth , Awidth,offset_size,dept,OPC_size,Reg_size) Port map (clk, rst,PCin , Ain,PCsel,ALUFN,ITCM_tb_wr,
--ITCM_tb_in,ITCM_tb_addr_in,DTCM_wr, DTCM_tb_wr, DTCM_addr_sel, TBactive,DTCM_tb_in,DTCM_tb_addr_in, DTCM_tb_addr_out,RFaddr_wr, RFaddr_rd,IRin,RFin,Imm1_in, Imm2_in, RFout, DTCM_out,
--DTCM_addr_out,DTCM_addr_in,DTCM_tb_out,st, ld, mov, done, add, sub,jmp,jc,jnc, and_OPC, or_OPC, xor_OPC,,shl,shr,j1,j2,Cflag, Zflag, Nflag);

DataPath_Ports: Datapath generic map (Dwidth , Awidth, offset_size,dept ,OPC_size,Reg_size) Port map (clk, rst,PCin , Ain,PCsel,ALUFN,ITCM_tb_wr,
				ITCM_tb_in,ITCM_tb_addr_in,DTCM_wr, DTCM_tb_wr,DTCM_addr_sel, TBactive,DTCM_tb_in,DTCM_tb_addr_in, DTCM_tb_addr_out,RFaddr_wr, RFaddr_rd,IRin,RFin,Imm1_in, Imm2_in, RFout, DTCM_out,
				DTCM_addr_out,DTCM_addr_in,DTCM_tb_out,st, ld, mov, done, add, sub,jmp,jc,jnc, and_OPC, or_OPC, xor_OPC,shl,shr,j1,j2,Cflag, Zflag, Nflag);
end behav;