library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--------------------------------------------------------------
--Control generic map(Dwidth,Awidth,dept)port map(rst,ena,clk,mov_i,done_i,and_i,or_i,xor_i,
--jnc_i,jc_i,jmp_i,sub_i,add_i,Nflag_i,Zflag_i,Cflag_i,ld_i,st_i,shl,shr,j1,j2,DTCM_wr_o,DTCM_addr_out_o,DTCM_addr_in_o,DTCM_out_o,
--DTCM_addr_sel, Ain_o, RFin_o,RFout_o,IRin_o,PCin_o, Imm1_in_o,Imm2_in_o,ALUFN,RFaddr_wr, RFaddr_rd, PCsel_o,done_FSM);
entity Control is
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
		RFaddr_wr, RFaddr_rd, PCsel_o:											out std_logic_vector(1 downto 0);
		--TB output				
		done_FSM:																	out std_logic
);		
end Control;


architecture behav of Control is
	type state is (Fetch,Decode,Execute1_R,Execute1_I,Execute2_I,Reset);
	signal current_state , next_state:	state ;
	signal C_last_instruction:			std_logic;
begin
	
	state_gen : process(clk,rst,ena)
	begin
		if(rst = '1') then 
			current_state <= reset ;
				
		elsif (clk'event and clk='1') then
			if(ena ='1') then 
				current_state <= next_state ; 
			else
				current_state <= current_state ; 
			end if;
		end if;
	end process;
	

	Control_Unit_gen : process(current_state)
	begin 
		case current_state is
			when Reset =>
				-- reset
				DTCM_wr_o 					<= 	'0' ;
				DTCM_addr_out_o				<= 	'0' ;
				DTCM_addr_in_o				<= 	'0' ;
				DTCM_out_o					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain_o						<=	'0';
				RFin_o						<=	'0';
				RFout_o						<=	'0';
				RFaddr_wr 					<=	"00"; -- RFaddr_wr unaffected
				RFaddr_rd					<=	"00"; -- RFaddr_rd unaffected
				IRin_o						<=	'0';
				PCin_o						<=	'1';
				PCsel_o 					<= 	"10";      -- PC = 0 inital state 
				Imm1_in_o					<=	'0';
				Imm2_in_o					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	'0';
				next_state					<=	Fetch;
----------------------------------------------------------------------------------				
			when Fetch =>
			-- Fetch
				DTCM_wr_o 					<= 	'0' ;
				DTCM_addr_out_o				<= 	'0' ;
				DTCM_addr_in_o				<= 	'0' ;
				DTCM_out_o					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain_o						<=	'0';
				RFin_o						<=	'0';
				RFout_o						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin_o						<=	'1'; -- open IR 
				PCin_o						<=	'0'; -- close PC
				PCsel_o 					<= 	"00"; 
				Imm1_in_o					<=	'0';
				Imm2_in_o					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag_i; -- if we had flag LAST cycle we need to insert it now
				next_state					<=	Decode;
-----------------------------------------------------------------------------
			-- Decode
			when Decode =>
			-- R-Type
			if (add_i = '1') or (sub_i = '1') or (and_i = '1') or (or_i = '1') or (xor_i = '1') or (shl='1') or (shr='1') then
				DTCM_wr_o 					<= 	'0' ;
				DTCM_addr_out_o				<= 	'0' ;
				DTCM_addr_in_o				<= 	'0' ;
				DTCM_out_o					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; -- C = B 
				Ain_o						<=	'1'; --regA = rb
				RFin_o						<=	'0';
				RFout_o						<=	'1'; --getting R[rb]
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"01"; --getting R[rb]
				IRin_o						<=	'0';  
				PCin_o						<=	'0'; 
				PCsel_o 					<= 	"00"; 
				Imm1_in_o					<=	'0';
				Imm2_in_o					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	'0';
				next_state					<=	Execute1_R;
			-- J-Type
			elsif (jmp_i = '1') or (jc_i = '1') or (jnc_i = '1') then
				DTCM_wr_o					<=  '0';
				DTCM_addr_out_o				<=  '0';
				DTCM_addr_in_o				<=  '0';
				DTCM_out_o					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110"; --unaffected
				Ain_o						<=	'0'; 
				RFin_o						<=	'0'; 
				RFout_o						<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00"; 
				IRin_o						<=	'0'; 
				if (jmp_i = '1') or (jc_i = '1' and C_last_instruction = '1') or (jnc_i = '1' and C_last_instruction = '0') then
					PCsel_o					<=	"01"; 
					C_last_instruction		<= '0';
				else 
					PCsel_o					<=	"00"; 
					C_last_instruction		<= '0';
				end if;
				PCin_o						<=	'1'; --getting next instruction 
				Imm1_in_o					<=	'0'; 
				Imm2_in_o					<=	'0';
				done_FSM					<=	'0';
				next_state					<= 	Fetch;
			-- I-Type
			-- Decode
			elsif (mov_i = '1') or (ld_i = '1') or (st_i = '1') then
				DTCM_wr_o					<=  '0';
				DTCM_addr_out_o				<=  '0';
				DTCM_addr_in_o				<=  '0';
				DTCM_out_o					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; --C=B
				IRin_o						<=	'0'; 
				PCsel_o						<=	"00";
				Imm2_in_o					<=	'0';
				done_FSM					<=	'0';
				C_last_instruction			<= 	'0';
				if (mov_i = '1') then
					Ain_o					<=	'0'; 
					RFin_o					<=	'1'; -- writing to reg
					RFout_o					<=	'0';
					RFaddr_wr 				<=	"00"; -- writing to R[ra]
					RFaddr_rd				<=	"00"; 
					Imm1_in_o				<=	'1'; -- Imm1 => ALU_B => ALU_C => RF
					PCin_o					<=	'1';
					next_state				<= 	Fetch;
				elsif (ld_i = '1') or (st_i = '1') then
					Ain_o					<=	'1'; -- writing to A
					RFin_o			    	<=	'0'; 
					RFaddr_wr 				<=	"00"; 
					RFout_o					<=	'1';   --getting R[rb]
					RFaddr_rd				<=	"01";  --getting R[rb]
					Imm1_in_o				<=	'0'; 
					PCin_o					<=	'0';
					next_state				<= 	Execute1_I;
				end if;
			elsif (done_i = '1') then
				done_FSM					<=	'1';
				PCsel_o						<=	"00";
				PCin_o						<=  '1'; 
				next_state					<= 	Fetch;
			else 			
				next_state					<= 	Fetch;
			end if;
----------------------------------------------------------------------------------					
			when Execute1_R =>
				
				-- R-Type 
				DTCM_wr_o					<=  '0';
				DTCM_addr_out_o				<=  '0';
				DTCM_addr_in_o				<=  '0';
				DTCM_out_o					<=  '0';
				if 		add_i = '1' then	
					ALUFN					<=	"0000"; --add
				elsif 	sub_i = '1' then	
					ALUFN					<=	"0001"; --sub
				elsif 	and_i = '1' then	
					ALUFN					<=	"0010"; --and
				elsif 	or_i  = '1' then	
					ALUFN					<=	"0011"; --or
				elsif 	xor_i = '1' then	
					ALUFN					<=	"0100"; --xor
				elsif 	shl = '1' then	
					ALUFN					<=	"0101"; --shl
				elsif 	shr = '1' then	
					ALUFN					<=	"0110"; --shr
				end if;	
				Ain_o						<=	'0'; 
				RFin_o						<=	'1';  -- writing R[ra] =rb (function) rc
				RFout_o						<=	'1'; --getting R[rc]
				RFaddr_wr 					<=	"00"; -- writing R[ra] =rb (function) rc
				RFaddr_rd					<=	"10"; --getting R[rc]
				IRin_o						<=	'0'; 
				PCin_o						<=	'1'; --getting next instruction
				PCsel_o						<=	"00";
				Imm1_in_o					<=	'0'; 
				Imm2_in_o					<=	'0';
				done_FSM					<=	'0';
				next_state					<= 	Fetch;
----------------------------------------------------------------------------------					

				
			when Execute1_I =>
			-- I-Type 
			--load
				DTCM_wr_o					<=  '0';
				DTCM_out_o					<=  '0';
				ALUFN						<=	"0000"; -- summing C = imm2+R[rb]
				Ain_o						<=	'0'; 
				if ld_i = '1' then	
					DTCM_addr_in_o			<=  '0';
					DTCM_addr_out_o			<=  '1'; -- Sending Mem[Imm2+R[rb] to BUS B on the next cycle
				else 
					DTCM_addr_in_o			<=  '1'; --  writing to Mem[Imm2+R[rb]] on the next cycle
					DTCM_addr_out_o			<=  '0';
				end if;
				RFin_o						<=	'0'; --writing to R[ra]
				RFout_o						<=	'0'; 
				RFaddr_wr 					<=	"00"; -- writing to R[ra]
				RFaddr_rd					<=	"00"; --getting R[rc]
				IRin_o						<=	'0'; 
				PCin_o						<=	'0';
				PCsel_o						<=	"00";
				Imm1_in_o					<=	'0'; 
				Imm2_in_o					<=	'1'; -- summing imm2+R[rb]
				done_FSM					<=	'0';
				next_state					<= 	Execute2_I;
----------------------------------------------------------------------------------					
			when Execute2_I =>
			-- I-Type
				if (ld_i ='1') then
					DTCM_wr_o				<=  '0';
					DTCM_out_o				<=  '1'; -- releasing Mem[Imm2+R[rb] =>BUS B
					ALUFN					<=	"1111"; -- C = B
					RFin_o					<=	'1';   --Ra<=M[R[rb]+imm2]	
					RFout_o					<=	'0'; 
					PCin_o					<=	'1';  --getting next instruction
					next_state				<= 	Fetch;
				else
					DTCM_wr_o				<=  '1'; -- enabling write to Mem
					DTCM_out_o				<=  '0';
					ALUFN					<=	"1110"; -- unafffectd (we write to DataMem)
					RFin_o					<=	'0'; 
					RFout_o					<=	'1'; 
					PCin_o					<=	'1'; --getting next instruction
					next_state				<= 	Fetch;
				end if;
				DTCM_addr_in_o				<=  '0';
				DTCM_addr_out_o				<=  '0'; 
				Ain_o						<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00"; 
				IRin_o						<=	'0'; 
				PCsel_o						<=	"00";
				Imm1_in_o					<=	'0'; 
				Imm2_in_o					<=	'0'; 
				done_FSM					<=	'0';
----------------------------------------------------------------------------------

			end case;	
	end process;







end behav;


