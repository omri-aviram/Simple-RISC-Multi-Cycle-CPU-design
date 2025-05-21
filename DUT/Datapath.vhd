library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.aux_package.all;
--------------------------------------------------------------
-- Datapath generic map (Dwidth , Awidth,offset_size,dept,OPC_size,Reg_size) Port map (clk, rst,PCin , Ain,PCsel,ALUFN,ITCM_tb_wr,
--ITCM_tb_in,ITCM_tb_addr_in,DTCM_wr, DTCM_tb_wr, DTCM_addr_sel, TBactive,DTCM_tb_in,DTCM_tb_addr_in, DTCM_tb_addr_out,RFaddr_wr, 
--RFaddr_rd,IRin,RFin,Imm1_in, Imm2_in, RFout, DTCM_out,
--DTCM_addr_out,DTCM_addr_in,DTCM_tb_out,st, ld, mov, done, add, sub,jmp,jc,jnc, and_OPC, or_OPC, xor_OPC,shl,shr,j1,j2,Cflag, Zflag, Nflag);
entity Datapath is
	 
generic(Dwidth:			integer:=16;
		Awidth:			integer:=6;
		offset_size:	integer:=8;
		dept :	  		integer:=64;
		OPC_size: 		integer:=4;
		Reg_size: 		integer:=4
		);
		 
Port(clk, rst:										in std_logic;
	 --control signals					
	 PCin , Ain:									in std_logic;
	 PCsel:											in std_logic_vector(1 downto 0);
	 ALUFN:											in std_logic_vector(3 downto 0);
	 -- ProgMem signals					
	 ITCM_tb_wr: 									in std_logic;
	 ITCM_tb_in:									in std_logic_vector(Dwidth-1 downto 0);
	 ITCM_tb_addr_in:								in std_logic_vector(Awidth-1 downto 0);
	 --DataMem signals
	 DTCM_wr, DTCM_tb_wr,DTCM_addr_sel, TBactive:	in std_logic;--enables signals
	 DTCM_tb_in:									in std_logic_vector(Dwidth-1 downto 0);
	 DTCM_tb_addr_in, DTCM_tb_addr_out:				in std_logic_vector(Awidth-1 downto 0);
	 --IR signals					
	 RFaddr_wr, RFaddr_rd:							in std_logic_vector(1 downto 0);
	 IRin:		 									in std_logic;
	 --RF signals			
	 RFin:											in std_logic;
	 --BUS_B		
	 --tristates signals		
	 Imm1_in, Imm2_in, RFout, DTCM_out, 		
	 DTCM_addr_out,DTCM_addr_in:					in std_logic;
	 -- outputs			
	 DTCM_tb_out:									out std_logic_vector(Dwidth-1 downto 0);
	 st, ld, mov, done, add, sub,jmp,jc,jnc,
	 and_OPC, or_OPC, xor_OPC,shl,shr,j1,j2:   		out std_logic;
	 Cflag, Zflag, Nflag:				    		out std_logic
	 );

end Datapath;
--------------------------------------------------------------
architecture rtb of Datapath is	

signal PCout:											std_logic_vector(Awidth-1 downto 0);
signal RDataOut_ProgMem: 								std_logic_vector(Dwidth-1 downto 0);
signal IR_Imm8:											std_logic_vector(7 downto 0);
signal IR_Imm4:											std_logic_vector(3 downto 0);
signal R_OPC:											std_logic_vector(OPC_size-1 downto 0);
signal IRaddr_wr,IRaddr_rd:								std_logic_vector(Reg_size-1 downto 0);
signal W_BUS_A:											std_logic_vector(Dwidth-1 downto 0);
signal RegA2ALU:										std_logic_vector(Dwidth-1 downto 0);
signal W_DataMem_BUS_B,extended_imm1, extended_imm2:	std_logic_vector(Dwidth-1 downto 0);
signal W_BUS_B:											std_logic_vector(Dwidth-1 downto 0);
signal W_DataOut_DataMem:								std_logic_vector(Dwidth-1 downto 0);
signal Q_Waddr_DataMem,W_Waddr_DataMem:					std_logic_vector(Awidth-1 downto 0);
signal Q_Raddr_DataMem,W_Raddr_DataMem:					std_logic_vector(Awidth-1 downto 0);
signal RFdataR:											std_logic_vector(Dwidth-1 downto 0);
signal dataInDatamem:									std_logic_vector(Dwidth-1 downto 0);
signal writeAddrDataMem:								std_logic_vector(Awidth-1 downto 0);
signal readAddrDataMem:						 			std_logic_vector(Awidth-1 downto 0);
signal A_BUS_2_Latch:						 			std_logic_vector(Awidth-1 downto 0);
signal wren_DataMem:									std_logic;



begin -- Architecture



--Program Memory wiring
--ProgMem generic map (Dwidth, Awidth, dept) port map (clk, ITCM_tb_wr, ITCM_tb_in, ITCM_tb_addr_in, readAddrProgMem => PCout, RProgMemData => RDataOut_ProgMem);
ProgMem_L1: ProgMem generic map (Dwidth, Awidth, dept) port map (clk, ITCM_tb_wr, ITCM_tb_in, ITCM_tb_addr_in, PCout, RDataOut_ProgMem);

--Data Memory wiring
--dataMem generic(Dwidth, Awidth, dept) ports(	clk,memEn, WmemData, WmemAddr,RmemAddr, RmemData)
DataMemPorts: dataMem generic map (Dwidth, Awidth, dept) port map (clk, wren_DataMem, dataInDatamem, writeAddrDataMem, readAddrDataMem, W_DataOut_DataMem);

--PC wiring
--PCarchitecture generic map(Awidth,offset_size,dept)port map(clk :in,PCin:in,IRin_offset:in
-- PCsel:in ,PCout:out  )
PC_L1 : PCarchitecture generic map(Awidth,offset_size,dept)port map (clk, PCin, IR_Imm8, PCsel, PCout); 


--IR wiring
--IR generic map(Dwidth,Awidth,OPC_size,Reg_size)Port map(DataOut_i,RFaddr_rd,RFaddr_wr,IRin,OPC_o,IRaddr_rd, IRaddr_wr,Imm4_o,Imm8_o);
IR_L1: IR generic map(Dwidth,Awidth,OPC_size,Reg_size)Port map(RDataOut_ProgMem,RFaddr_rd,RFaddr_wr,IRin,R_OPC,IRaddr_rd, IRaddr_wr,IR_Imm4,IR_Imm8);

--OPCdecoder generic map( OPC_size) port map(OPC, st, ld, mov, done, add, sub, jmp, jc, jnc, and_OPC, or_OPC, xor_OPC,shl,shr,j1,j2);
 OPCdecoder_L1: OPCdecoder generic map (OPC_size) port map (R_OPC,st, ld, mov, done, add, sub, jmp, jc, jnc,and_OPC, or_OPC, xor_OPC,shl,shr,j1,j2);
 
 --RF wiring
 -- RF generic map(Dwidth,Awidth) port map (clk,rst,WregEn =>RFin ,WregData=>W_BUS_A,WregAddr=>W_IRaddr,RregAddr=>W_IRaddr,RregData=>RFdataR);
 RF_L1: RF generic map(Dwidth,Reg_size) port map (clk,rst,RFin,W_BUS_A,IRaddr_wr,IRaddr_rd,RFdataR);

 -- ALU wiring
 --ALU generic map( Dwidth,Awidth) port map(A =>RegA2ALU,B => W_BUS_B,ALUFN,C =>W_BUS_A,Cflag, Zflag, Nflag);
 ALU_L1 : ALU generic map(Dwidth,Awidth) port map(RegA2ALU,W_BUS_B,ALUFN,W_BUS_A,Cflag, Zflag, Nflag);




-------------------------  DataFlow Architecrture -------------------------

extended_imm1 <= SXT(IR_Imm8, Dwidth);
extended_imm2 <= SXT(IR_Imm4, Dwidth);

--DFF generic map( Dwidth) port map(clk, en,rst, D,Q);
Reg_A : DFF generic map(Dwidth) port map(clk, Ain,rst,W_BUS_A,RegA2ALU);

--DLatch generic map(Dwidth) port map(en,rst,D,Q);
DTCM_addrout: DLatch generic map(Awidth) port map(DTCM_addr_in,rst,W_Waddr_DataMem,Q_Waddr_DataMem);

DTCM_addrin: DLatch generic map(Awidth) port map(DTCM_addr_out,rst,W_Raddr_DataMem,Q_Raddr_DataMem);


--        BidirPin generic map(Dwidth) port map (Dout,en,Din,IOpin);
Imm1_tri: 		BidirPin generic map(Dwidth) port map (extended_imm1,Imm1_in,open,W_BUS_B);

Imm2_tri: 		BidirPin generic map(Dwidth) port map (extended_imm2,Imm2_in,open,W_BUS_B);

RF_tri:   		BidirPin generic map(Dwidth) port map (RFdataR,RFout,open,W_BUS_B);

DataMEM_tri:    BidirPin generic map(Dwidth) port map (W_DataOut_DataMem,DTCM_out,W_DataMem_BUS_B,W_BUS_B);



--Imm1_tri: BidirPin generic map(Dwidth) port map (extended_imm1,Imm1_in,W_ALU_B,W_BUS_B);

--Imm2_tri: BidirPin generic map(Dwidth) port map (extended_imm2,Imm2_in,W_ALU_B,W_BUS_B);

--RF_tri:   BidirPin generic map(Dwidth) port map (RFdataR,RFout,W_ALU_B,W_BUS_B);

--DataMEM_tri:   BidirPin generic map(Dwidth) port map (W_DataOut_DataMem,DTCM_out,W_ALU_B,W_BUS_B);

-------------------------  MUXs to DataMem ------------------------- 
DTCM_tb_out 		<= 	W_DataOut_DataMem; -- same wire

W_Waddr_DataMem 	<= 	W_BUS_B(Awidth-1 downto 0)	when DTCM_addr_sel = '1' else W_BUS_A(Awidth-1 downto 0); -- addr write MUXs 
W_Raddr_DataMem 	<= 	W_BUS_B(Awidth-1 downto 0) 	when DTCM_addr_sel = '1' else W_BUS_A(Awidth-1 downto 0); -- addr read MUXs


wren_DataMem 		<= 	DTCM_tb_wr 			    	when 	TBactive = '1' 	 else 	 	DTCM_wr;
readAddrDataMem	    <=	DTCM_tb_addr_out			when	TBactive = '1'	 else	 	Q_Raddr_DataMem;
writeAddrDataMem	<=	DTCM_tb_addr_in	   			when	TBactive = '1'	 else		Q_Waddr_DataMem ;
dataInDatamem 		<= 	DTCM_tb_in					when	TBactive = '1' 	 else		W_DataMem_BUS_B ;
		





end rtb;