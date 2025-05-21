LIBRARY ieee;
USE ieee.std_logic_1164.all;


package aux_package is

--------------------------------------------------------------
component ProgMem is
generic( Dwidth: integer:=16;
		 Awidth: integer:=6;
		 dept:   integer:=64
		 );
port(	clk,memEn: in std_logic;	
		WmemData:	in std_logic_vector(Dwidth-1 downto 0);
		WmemAddr,RmemAddr:	
					in std_logic_vector(Awidth-1 downto 0);
		RmemData: 	out std_logic_vector(Dwidth-1 downto 0)
);
end component;
--------------------------------------------------------------
--dataMem generic(Dwidth, Awidth, dept) ports(	clk,memEn, WmemDatastd_logic_vector, WmemAddr,RmemAddr, RmemData);
component dataMem is
generic( Dwidth: integer:=16;
		 Awidth: integer:=6;
		 dept:   integer:=64);
port(	clk,memEn: in std_logic;	
		WmemData:	in std_logic_vector(Dwidth-1 downto 0);
		WmemAddr,RmemAddr:	
					in std_logic_vector(Awidth-1 downto 0);
		RmemData: 	out std_logic_vector(Dwidth-1 downto 0)
);
end component;
--------------------------------------------------------------
component FA IS
port (xi, yi, cin: IN std_logic;
			  s, cout: OUT std_logic);
END component;
--------------------------------------------------------------

--component ALU generic map( Dwidth,Awidth) port map(A,B,ALUFN,C ,Cflag, Zflag, Nflag);
component ALU is
generic( Dwidth: integer:=16;
		 Awidth: integer:=6);
port(	 A, B:					in std_logic_vector(Dwidth-1 downto 0);
		 ALUFN:					in std_logic_vector(3 downto 0);
		 C:						out std_logic_vector(Dwidth-1 downto 0);
		 Cflag, Zflag, Nflag:	out std_logic
);
end component;

--------------------------------------------------------------
--IR generic map(Dwidth,Awidth,OPC_size,Reg_size)Port map(DataOut_i,RFaddr_rd,RFaddr_wr,IRin,OPC_o,IRaddr_rd, IRaddr_wr,Imm4_o,Imm8_o);

component IR is
	 
generic(Dwidth: integer:=16;
		Awidth: integer:=6;
		OPC_size: integer:=4;
		Reg_size: integer:=4
		);
		 
Port(DataOut_i:				in std_logic_vector(Dwidth-1 downto 0);
	 RFaddr_rd,RFaddr_wr:	in std_logic_vector(1 downto 0);
	 IRin:		 			in std_logic;
	 OPC_o:					out std_logic_vector(OPC_size-1 downto 0);
	 IRaddr_rd, IRaddr_wr:	out std_logic_vector(Reg_size-1 downto 0);
	 Imm4_o:				out std_logic_vector(3 downto 0);
	 Imm8_o:				out std_logic_vector(7 downto 0)
);

end component;

--------------------------------------------------------------
--PCarchitecture generic map(Awidth,offset_size,dept)port map(clk :in,PCin:in,IRin_offset:in
-- PCsel:in ,PCout:out  )


component PCarchitecture is
generic( Awidth: integer:=6;
		 offset_size: integer:=8;
		 dept:	 integer:=64);
		 
port(	clk, PCin:				in std_logic;
		IRin_offset:			in std_logic_vector(offset_size-1 downto 0);
		PCsel:					in std_logic_vector(1 downto 0);
		PCout:					out std_logic_vector(Awidth-1 downto 0)
		
);
end component;
---------------------------------------------------------------
--OPCdecoder generic map( OPC_size) port map(OPC, st, ld, mov, done, add, sub, jmp, jc, jnc, and_OPC, or_OPC, xor_OPC,shl,shr,j1,j2);
component OPCdecoder is
generic( OPC_size: integer:=4);
		 
port(	OPC:										in std_logic_vector(OPC_size-1 downto 0);
		st, ld, mov, done, add, sub, jmp, jc, jnc, 
		and_OPC, or_OPC, xor_OPC,shl,shr,j1,j2:		out std_logic	
		
);
end component;
--------------------------------------------------------------
-- RF generic map(Dwidth,Awidth) port map (clk,rst,WregEn,WregData,WregAddr,RregAddr,RregData);

component RF is
generic( Dwidth: integer:=16;
		 Awidth: integer:=4);
port(	clk,rst,WregEn: in std_logic;	
		WregData:	in std_logic_vector(Dwidth-1 downto 0);
		WregAddr,RregAddr:	
					in std_logic_vector(Awidth-1 downto 0);
		RregData: 	out std_logic_vector(Dwidth-1 downto 0)
);
end component;
--------------------------------------------------------------
--DLatch generic map( Dwidth) port map(en,rst, D,Q);

component DLatch is
	generic( Dwidth: integer:=16 );
	port(   en,rst:			in 		std_logic;
			D: 				in 		std_logic_vector(Dwidth-1 downto 0);
			Q:				out		std_logic_vector(Dwidth-1 downto 0)
			);
end component;
--------------------------------------------------------------
--DFF generic map( Dwidth) port map(clk, en,rst, D,Q);
component DFF is
	generic( Dwidth: integer:=16 );
	port(   clk,en,rst:			in 		std_logic;
			D: 					in 		std_logic_vector(Dwidth-1 downto 0);
			Q:					out		std_logic_vector(Dwidth-1 downto 0)
			);
end component;

--------------------------------------------------------------
-- BidirPin generic map( width) port map (Dout,en,Din,IOpin);
component BidirPin is
	generic( width: integer:=16 );
	port(   Dout: 	in 		std_logic_vector(width-1 downto 0);
			en:		in 		std_logic;
			Din:	out		std_logic_vector(width-1 downto 0);
			IOpin: 	inout 	std_logic_vector(width-1 downto 0)
	);
end component;
---------------------------------------------------------
--Shifter GENERIC map (n,k) PORT map(Y_in, X_in,op,Nflag_o,Cflag_o,Zflag_o,result);

component Shifter IS
  GENERIC (n : INTEGER := 8);
  PORT (
    Y_in, X_in   				: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
    op           				: IN STD_LOGIC_VECTOR (3 DOWNTO 0); -- op code in ALUFN (ALU FANE IN )
    Nflag_o, Cflag_o, Zflag_o	: OUT STD_LOGIC;
    result        				: OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0)
  );
END component;
--------------------------------------------------------------
-- top generic map (m,n,Dwidth,Awidth,offset_size,OPC_size,Reg_size,dept)port map(rst ,ena ,clk ,ITCM_tb_wr ,DTCM_tb_wr ,TBactive ,ITCM_tb_addr_in ,DTCM_tb_addr_in ,DTCM_tb_addr_out ,ITCM_tb_in ,DTCM_tb_in ,DTCM_tb_out ,done_FSM);		
component top is
generic( m:	 												integer:=16; -- ITCM input size
		 n:	 												integer:=16; -- DTCM input output size
		 Dwidth:											integer:=16; -- DTCM input output size
		 Awidth:											integer:=6;
		 offset_size:										integer:=8;
		 OPC_size: 											integer:=4;
		 Reg_size: 											integer:=4;
		 dept:   											integer:=64);
		 
port(	rst, ena, clk: 										in std_logic;	-- Data to/from TB
		ITCM_tb_wr, DTCM_tb_wr, TBactive:					in std_logic;
		ITCM_tb_addr_in,DTCM_tb_addr_in,DTCM_tb_addr_out:	in std_logic_vector(Awidth-1 downto 0); 
		ITCM_tb_in:											in std_logic_vector(m-1 downto 0); -- ITCM Data_in
		DTCM_tb_in:											in std_logic_vector(n-1 downto 0); -- DTCM Data_in  (initial)
		DTCM_tb_out:										out std_logic_vector(n-1 downto 0); -- DTCM Data_out  (final)
		done_FSM:											out std_logic
		
);		
end component;

--------------------------------------------------------------
--Control generic map(Dwidth,Awidth,dept)port map(rst,ena,clk,mov_i,done_i,and_i,or_i,xor_i,
--jnc_i,jc_i,jmp_i,sub_i,add_i,Nflag_i,Zflag_i,Cflag_i,ld_i,st_i,shl,shr,j1,j2,DTCM_wr_o,DTCM_addr_out_o,DTCM_addr_in_o,DTCM_out_o,
--DTCM_addr_sel, Ain_o, RFin_o,RFout_o,IRin_o,PCin_o, Imm1_in_o,Imm2_in_o,ALUFN,RFaddr_wr, RFaddr_rd, PCsel_o,done_FSM);
component Control is
generic( Dwidth: integer:=16;
		 Awidth: integer:=6;
		 dept:   integer:=64);
port(	rst, ena, clk: 																in std_logic;	-- Data to/from TB
		--Decoder input
		mov_i, done_i, and_i, or_i, xor_i, jnc_i, jc_i, jmp_i, sub_i, add_i, 
		Nflag_i, Zflag_i, Cflag_i, ld_i, st_i,shl,shr,j1,j2:						in std_logic;
		--control signals output
		DTCM_wr_o, DTCM_addr_out_o, DTCM_addr_in_o, DTCM_out_o,DTCM_addr_sel, 
		Ain_o, RFin_o, RFout_o, IRin_o,PCin_o, Imm1_in_o, Imm2_in_o:				out std_logic;
		ALUFN:																		out std_logic_vector(3 downto 0);
		RFaddr_wr, RFaddr_rd, PCsel_o:												out std_logic_vector(1 downto 0);
		--TB output				
		done_FSM:																	out std_logic
);		
end component;
--------------------------------------------------------------
-- Datapath generic map (Dwidth , Awidth,offset_size,dept,OPC_size,Reg_size) Port map (clk, rst,PCin , Ain,PCsel,ALUFN,ITCM_tb_wr,
--ITCM_tb_in,ITCM_tb_addr_in,DTCM_wr, DTCM_tb_wr, DTCM_addr_sel, TBactive,DTCM_tb_in,DTCM_tb_addr_in, DTCM_tb_addr_out,RFaddr_wr, 
--RFaddr_rd,IRin,RFin,Imm1_in, Imm2_in, RFout, DTCM_out,
--DTCM_addr_out,DTCM_addr_in,DTCM_tb_out,st, ld, mov, done, add, sub,jmp,jc,jnc, and_OPC, or_OPC, xor_OPC,shl,shr,j1,j2,Cflag, Zflag, Nflag);
component Datapath is
	 
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

end component;

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

end aux_package;