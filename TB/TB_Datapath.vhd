library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use IEEE.std_logic_textio.all;
USE work.aux_package.all;

entity TB_Datapath is

		constant m:	 		  		integer:=16;-- ITCM input size
		constant n:	 		  		integer:=16;-- DTCM input output size
		constant Dwidth:	  		integer:=16;
		constant Awidth:	  		integer:=6;
		constant offset_size: 		integer:=8;
		constant OPC_size: 	  		integer:=4;
		constant Reg_size: 	  		integer:=4;
		constant dept:	 	  		integer:=64;
		
		constant progMem_Datapath: 	string(1 to 64) :=
		"C:\omri\project\VHDL LAB\LAB 2025\LAB3\pre LAB3\ITCMDatapath.txt";
		constant dataMem_Datapath : string(1 to 67) :=
		"C:\omri\project\VHDL LAB\LAB 2025\LAB3\pre LAB3\DTCMDatapathtxt.txt";
		constant dataMemRes_Datapath: 	string(1 to 63) :=
		"C:\omri\project\VHDL LAB\LAB 2025\LAB3\pre LAB3\DTCMcontent.txt";
end TB_Datapath;


architecture rtb of TB_Datapath is
	
	

	 signal clk, rst:										std_logic;
	  --control signals					
	 signal PCin , Ain:										std_logic;
	 signal PCsel:											std_logic_vector(1 downto 0);
	 signal ALUFN:											std_logic_vector(3 downto 0);
	  -- ProgMem signals					
	 signal ITCM_tb_wr: 									std_logic;
	 signal ITCM_tb_in:										std_logic_vector(Dwidth-1 downto 0);
	 signal ITCM_tb_addr_in:								std_logic_vector(Awidth-1 downto 0);
	  --DataMem signals
	 signal DTCM_wr, DTCM_tb_wr,DTCM_addr_sel, TBactive:	std_logic;--enables signals
	 signal DTCM_tb_in:										std_logic_vector(Dwidth-1 downto 0);
	 signal DTCM_tb_addr_in, DTCM_tb_addr_out:				std_logic_vector(Awidth-1 downto 0);
	  --IR signals					
	 signal RFaddr_wr, RFaddr_rd:						     std_logic_vector(1 downto 0);
	 signal IRin:		 									std_logic;
	  --RF signals			
	 signal RFin:											std_logic;
	 --BUS_B		
	 --tristates signals		
	 signal Imm1_in, Imm2_in, RFout, DTCM_out, 		
			DTCM_addr_out,DTCM_addr_in:						std_logic;
	  -- outputs			
	 signal DTCM_tb_out:									std_logic_vector(Dwidth-1 downto 0);
	 signal st, ld, mov, done, add, sub,jmp, 		
			jc,jnc, and_OPC, or_OPC, xor_OPC:	    		std_logic;
	 signal Cflag, Zflag, Nflag:				    		std_logic;
	 signal done_FSMProgMemIn, done_FSMDataMemIn:			std_logic;
	 signal done_FSM,C_last_instruction:										std_logic;
	 

-----------------------------------------------------------------------
-------------   assembly program code for this test bench  ------------
-----------------------------------------------------------------------
--data segment:
--arr 	dc16 20,11,2
--Swp_arr ds16 3
--
--code segment:											;   	 -instruction code :
--mov  r1,0 		; addr of arr first index of arr			 -		 0XC100	
--mov  r2,5 		; addr of Swp_arr last index of Swp_arr		 -		 0XC205
--mov	 r3,3 		; uper bound								 -		 0XC303	
--mov  r4,0 		; index										 -		 0XC400	
--mov  r5,1 		; adding to index r4 					 	 -		 0XC501
--ld   r7,0(r1)		;get arr value in r1 place to r7			 -   	 0XD710
--st   r7,0(r2)     ; stor r7 in r2 place in swp_arr			 -	     0XE720
--add  r1,r1,r5   	; inc r1 index 								 -		 0X0115
--sub  r2,r2,r5   	; dec r2 index								 -		 0X1225
--add  r4,r4,r5		; inc r4 loop index							 - 	 	 0X0445
--sub  r10,r4,r3  	; chck if r4 < r3 ?							 -		 0X1A43
--jlo  -7        	 ; yes jump eles continue   				 -		 0X90F9
--done 				; done										 -	 	 0XF000


begin
 Datapath_L1:Datapath generic map (Dwidth , Awidth,offset_size,dept,OPC_size,Reg_size) Port map (clk, rst,PCin , Ain,PCsel,ALUFN,ITCM_tb_wr,
ITCM_tb_in,ITCM_tb_addr_in,DTCM_wr, DTCM_tb_wr, DTCM_addr_sel, TBactive,DTCM_tb_in,DTCM_tb_addr_in, DTCM_tb_addr_out,RFaddr_wr, 
RFaddr_rd,IRin,RFin,Imm1_in, Imm2_in, RFout, DTCM_out,
DTCM_addr_out,DTCM_addr_in,DTCM_tb_out,st, ld, mov, done, add, sub,jmp,jc,jnc, and_OPC, or_OPC, xor_OPC,Cflag, Zflag, Nflag);





---------------------------
gen_clk : process
    begin
	clk <= '0';
	wait for 50 ns;
	clk <= not clk;
	wait for 50 ns;
    end process;

-----------------------------
gen_rst : process
        begin
		  rst <='1','0' after 100 ns;
		  wait;
        end process;	
	
gen_TB : process
		begin
			wait for 100 ns;
			TBactive <= '1';
			wait until done_FSMProgMemIn = '1' and done_FSMDataMemIn = '1';
			TBactive <= '0';
			wait until done_FSM = '1';
			TBactive <= '1';
			--ena      <= '0';
			
			wait; 
		end process;


------------------------------------ Read ProgMem  ------------------------------------
LoadFileProgMem: process
	file inProgMemFile: text open read_mode is progMem_Datapath;
	
	variable TempAddrsses:		std_logic_vector(Awidth-1 downto 0);
	variable L: 				line;
	variable linetomem:			std_logic_vector(Dwidth-1 downto 0);
	variable good:				boolean;
	
begin
	
	TempAddrsses := (others => '0');
	while not endfile (inProgMemFile) loop
		readline (inProgMemFile, L);
		hread(L, linetomem, good);
		next when not good;
		ITCM_tb_wr <= '1'; -- memEn_progMem =>ITCM_tb_wr
		ITCM_tb_addr_in <= TempAddrsses; -- WProgMemAddr => ITCM_tb_addr_in
		ITCM_tb_in <= linetomem;-- ITCM_tb_in => DTCM_tb_in
		wait until rising_edge(clk);
		TempAddrsses := TempAddrsses +1;
	end loop;
	ITCM_tb_wr <= '0';
	done_FSMProgMemIn <= '1';
	file_close(inProgMemFile);
	wait;
end process;

---------------read DataMem
LoadFileDataMem: process
	file inDataMemFile: text open read_mode is dataMem_Datapath;
	
	variable TempAddrsses:		std_logic_vector(Awidth-1 downto 0);
	variable L: 				line;
	variable linetomem:			std_logic_vector(Dwidth-1 downto 0);
	variable good:				boolean;
	
begin
	TempAddrsses := (others => '0');
	while not endfile (inDataMemFile) loop
		readline (inDataMemFile, L);
		hread(L, linetomem, good);
		next when not good; 
		DTCM_tb_wr <= '1';-- memEn_dataMem -> DTCM_tb_wr
		DTCM_tb_addr_in <= TempAddrsses; -- WDataMemAddr-> DTCM_tb_addr_in
		DTCM_tb_in <= linetomem;  -- WDataMemData -> DTCM_tb_in
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		TempAddrsses := TempAddrsses +1;
	end loop;
	DTCM_tb_wr <= '0';
	done_FSMDataMemIn <= '1';
	file_close(inDataMemFile);
	wait;
end process;



----/////////////////////////  write DataMem  /////////////////////////
writeFileDataMem: process
	file outDataMemFile: text open write_mode is dataMemRes_Datapath;
	
	variable TempAddrsses:		std_logic_vector(Awidth-1 downto 0);
	variable L: 				line;
	variable linetomem:			std_logic_vector(Dwidth-1 downto 0);
	variable unknown_line:		std_logic_vector(Dwidth-1 downto 0):=(others =>'X') ;
	variable good:				boolean;
	variable counter:			integer;
	
begin
	wait until done_FSM='1'; --comes from controlש
	TempAddrsses := (others => '0');
	counter := 0;
	while counter < dept loop
		DTCM_tb_addr_out <= TempAddrsses; --RDataMemAddr -> DTCM_tb_addr_out
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		linetomem := DTCM_tb_out;     -- RDataMemData -> DTCM_tb_out
		if linetomem = unknown_line then  -- mem_done comes from memory entity
			exit ;
		end if;
		hwrite(L, linetomem);
		writeline(outDataMemFile, L);
		wait until rising_edge(clk);
		--wait until rising_edge(clk);
		TempAddrsses := TempAddrsses +1;
		counter := counter +1;
	end loop;
	file_close(outDataMemFile);
	wait;
end process;




------------ Start the test bench ------------- 



TB_start:	process
			begin
				wait until done_FSMProgMemIn='1' and done_FSMDataMemIn='1';
--//////////////////////////// reset ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr						<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain							<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; -- RFaddr_wr unaffected
				RFaddr_rd					<=	"00"; -- RFaddr_rd unaffected
				IRin						<=	'0';
				PCin						<=	'1';
				PCsel 						<= 	"10";      -- PC = 0 inital state 
				Imm1_in						<=	'0';
				Imm2_in						<=	'0';
				done_FSM    				<=	'0';
				
				C_last_instruction			<= 	'0';
				rst							<=   '1';
--//////////////////////////// Fetch 0XC100  mov  r1,0 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain							<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 						<= 	"00"; 
				Imm1_in						<=	'0';
				Imm2_in						<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now
					rst						<=   '0';
--//////////////////////////// Decode 0XC100  mov  r1,0 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; --C=B
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
				C_last_instruction			<= 	'0';
				Ain					    <=	'0'; 
				RFin					    <=	'1'; -- writing to reg
				RFout					    <=	'0';
				RFaddr_wr 				    <=	"00"; -- writing to R[ra]
				RFaddr_rd				    <=	"00"; 
				Imm1_in				    <=	'1'; -- Imm1 => ALU_B => ALU_C => RF
				PCin					    <=	'1';


--//////////////////////////// Fetch 0XC205  mov  r2,5 ////////////////////////////////////////////
			
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now
--//////////////////////////// Decode 0XC205  mov  r2,5 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; --C=B
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
				C_last_instruction			<= 	'0';
				Ain						<=	'0'; 
				RFin						<=	'1'; -- writing to reg
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; -- writing to R[ra]
				RFaddr_rd					<=	"00"; 
				Imm1_in					<=	'1'; -- Imm1 => ALU_B => ALU_C => RF
				PCin						<=	'1';

--//////////////////////////// Fetch 0XC303  mov	 r3,3 ////////////////////////////////////////////
				wait until clk'event and clk='1';

				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now
--//////////////////////////// Decode 0XC303  mov	 r3,3 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; --C=B
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
				C_last_instruction			<= 	'0';
				Ain						<=	'0'; 
				RFin						<=	'1'; -- writing to reg
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; -- writing to R[ra]
				RFaddr_rd					<=	"00"; 
				Imm1_in					<=	'1'; -- Imm1 => ALU_B => ALU_C => RF
				PCin						<=	'1';

--//////////////////////////// Fetch 0XC400  mov  r4,0 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now
--//////////////////////////// Decode 0XC400  mov  r4,0 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; --C=B
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
				C_last_instruction			<= 	'0';
				Ain						<=	'0'; 
				RFin						<=	'1'; -- writing to reg
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; -- writing to R[ra]
				RFaddr_rd					<=	"00"; 
				Imm1_in					<=	'1'; -- Imm1 => ALU_B => ALU_C => RF
				PCin						<=	'1';

--//////////////////////////// Fetch 0XC501  mov  r5,1 ////////////////////////////////////////////
			
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now
				
--//////////////////////////// Decode 0XC501  mov  r5,1 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; --C=B
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
				C_last_instruction			<= 	'0';
				Ain						<=	'0'; 
				RFin						<=	'1'; -- writing to reg
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; -- writing to R[ra]
				RFaddr_rd					<=	"00"; 
				Imm1_in					<=	'1'; -- Imm1 => ALU_B => ALU_C => RF
				PCin						<=	'1';
---------------------------------   first iteration -------------------------------------------


--//////////////////////////// Fetch 0XD710  ld   r7,0(r1) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now
--//////////////////////////// Decode 0XD710  ld   r7,0(r1) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; --C=B
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
				C_last_instruction			<= 	'0';
				Ain						<=	'1'; -- writing to A
				RFin			    		<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFout						<=	'1';   --getting R[rb]
				RFaddr_rd					<=	"01";  --getting R[rb]
				Imm1_in					<=	'0'; 
				PCin						<=	'0';
--//////////////////////////// Execute1_I 0XD710 ld   r7,0(r1) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0000"; -- summing C = imm2+R[rb]
				Ain						<=	'0';
				DTCM_addr_in				<=  '0';
				DTCM_addr_out				<=  '1'; -- Sending Mem[Imm2+R[rb] to BUS B on the next cycle
				RFin						<=	'0'; --writing to R[ra]
				RFout						<=	'0'; 
				RFaddr_wr 					<=	"00"; -- writing to R[ra]
				RFaddr_rd					<=	"00"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'0';
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'1'; -- summing imm2+R[rb]
				done_FSM					<=	'0';

--//////////////////////////// Execute2_I 0XD710 ld   r7,0(r1) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_out					<=  '1'; -- releasing Mem[Imm2+R[rb] =>BUS B
				ALUFN						<=	"1111"; -- C = B
				RFin						<=	'1';   --Ra<=M[R[rb]+imm2]	
				RFout						<=	'0'; 
				PCin						<=	'1';  --getting next instruction
				DTCM_addr_in				<=  '0';
				DTCM_addr_out				<=  '0'; 
				Ain						<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00"; 
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0'; 
				done_FSM					<=	'0';
--//////////////////////////// Fetch 0XE720  st   r7,0(r2) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain							<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 						<= 	"00"; 
				Imm1_in						<=	'0';
				Imm2_in						<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now
--//////////////////////////// Decode 0XE720  st   r7,0(r2) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr						<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; --C=B
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm2_in						<=	'0';
				done_FSM					<=	'0';
				C_last_instruction			<= 	'0';
				Ain							<=	'1'; -- writing to A
				RFin			    		<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFout						<=	'1';   --getting R[rb]
				RFaddr_rd					<=	"01";  --getting R[rb]
				Imm1_in						<=	'0'; 
				PCin						<=	'0';


--//////////////////////////// Execute1_I 0XE720 st   r7,0(r2) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr						<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0000"; -- summing C = imm2+R[rb]
				Ain							<=	'0';
				DTCM_addr_in				<=  '1';
				DTCM_addr_out				<=  '0'; -- Sending Mem[Imm2+R[rb] to BUS B on the next cycle
				RFin						<=	'0'; --writing to R[ra]
				RFout						<=	'0'; 
				RFaddr_wr 					<=	"00"; -- writing to R[ra]
				RFaddr_rd					<=	"00"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'0';
				PCsel						<=	"00";
				Imm1_in						<=	'0'; 
				Imm2_in						<=	'1'; -- summing imm2+R[rb]
				done_FSM					<=	'0';

--//////////////////////////// Execute2_I 0XE720 st   r7,0(r2) ////////////////////////////////////////////
				wait until clk'event and clk ='1';
				DTCM_wr						<=  '1';
				DTCM_out					<=  '0'; 
				ALUFN						<=	"1110"; 
				RFin						<=	'0';   	
				RFout						<=	'1'; 
				PCin						<=	'1';  
				DTCM_addr_in				<=  '0'; 
				DTCM_addr_out				<=  '0';
				Ain							<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00"; 
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm1_in						<=	'0'; 
				Imm2_in						<=	'0'; 
				done_FSM					<=	'0';

--//////////////////////////// Fetch 0X0115  add  r1,r1,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now

--//////////////////////////// Decode 0X0115  add  r1,r1,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; -- C = B 
				Ain						<=	'1'; --regA = rb
				RFin						<=	'0';
				RFout						<=	'1'; --getting R[rb]
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"01"; --getting R[rb]
				IRin						<=	'0';  
				PCin						<=	'0'; 
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	'0';
--//////////////////////////// Execute1_R 0X0115  add  r1,r1,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0000"; --add
				Ain						<=	'0'; 
				RFin						<=	'1';  -- writing R[ra] =rb (function) rc
				RFout						<=	'1'; --getting R[rc]
				RFaddr_wr 					<=	"00"; -- writing R[ra] =rb (function) rc
				RFaddr_rd					<=	"10"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'1'; --getting next instruction
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
--//////////////////////////// Fetch 0X0225  sub  r2,r2,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now

--//////////////////////////// Decode 0X0225  sub  r2,r2,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; -- C = B 
				Ain						<=	'1'; --regA = rb
				RFin						<=	'0';
				RFout						<=	'1'; --getting R[rb]
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"01"; --getting R[rb]
				IRin						<=	'0';  
				PCin						<=	'0'; 
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	'0';
--//////////////////////////// Execute1_R 0X0225  sub  r2,r2,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0001"; --sub
				Ain						<=	'0'; 
				RFin						<=	'1';  -- writing R[ra] =rb (function) rc
				RFout						<=	'1'; --getting R[rc]
				RFaddr_wr 					<=	"00"; -- writing R[ra] =rb (function) rc
				RFaddr_rd					<=	"10"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'1'; --getting next instruction
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
--//////////////////////////// Fetch 0X0445 add  r4,r4,r5 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now

--//////////////////////////// Decode 0X0445  add  r4,r4,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; -- C = B 
				Ain						<=	'1'; --regA = rb
				RFin						<=	'0';
				RFout						<=	'1'; --getting R[rb]
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"01"; --getting R[rb]
				IRin						<=	'0';  
				PCin						<=	'0'; 
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	'0';
--//////////////////////////// Execute1_R 0X0445  add  r4,r4,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0000"; --add
				Ain						<=	'0'; 
				RFin						<=	'1';  -- writing R[ra] =rb (function) rc
				RFout						<=	'1'; --getting R[rc]
				RFaddr_wr 					<=	"00"; -- writing R[ra] =rb (function) rc
				RFaddr_rd					<=	"10"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'1'; --getting next instruction
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
--//////////////////////////// Fetch 0X1A43  sub  r10,r4,r3////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now

--//////////////////////////// Decode 0X1A43  sub  r10,r4,r3////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; -- C = B 
				Ain						<=	'1'; --regA = rb
				RFin						<=	'0';
				RFout						<=	'1'; --getting R[rb]
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"01"; --getting R[rb]
				IRin						<=	'0';  
				PCin						<=	'0'; 
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	'0';
--//////////////////////////// Execute1_R 0X1A43  sub  r10,r4,r3////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0001"; --sub
				Ain						<=	'0'; 
				RFin						<=	'1';  -- writing R[ra] =rb (function) rc
				RFout						<=	'1'; --getting R[rc]
				RFaddr_wr 					<=	"00"; -- writing R[ra] =rb (function) rc
				RFaddr_rd					<=	"10"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'1'; --getting next instruction
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0';
				done_FSM					<=	'0';

--//////////////////////////// Fetch 0X90F9 jlo  -7 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now
--//////////////////////////// Decode 0X90F9 jlo -7 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110"; --unaffected
				Ain						<=	'0'; 
				RFin						<=	'0'; 
				RFout						<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00"; 
				IRin						<=	'0'; 
				PCsel						<=	"01"; 
				C_last_instruction			<= '0';
				PCin						<=	'1'; --getting next instruction 
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
---------------------------------   secand iteration -------------------------------------------


--//////////////////////////// Fetch 0XD710  ld   r7,0(r1) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now
--//////////////////////////// Decode 0XD710  ld   r7,0(r1) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; --C=B
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
				C_last_instruction			<= 	'0';
				Ain						<=	'1'; -- writing to A
				RFin			    		<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFout						<=	'1';   --getting R[rb]
				RFaddr_rd					<=	"01";  --getting R[rb]
				Imm1_in					<=	'0'; 
				PCin						<=	'0';
--//////////////////////////// Execute1_I 0XD710 ld   r7,0(r1) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0000"; -- summing C = imm2+R[rb]
				Ain						<=	'0';
				DTCM_addr_in				<=  '0';
				DTCM_addr_out				<=  '1'; -- Sending Mem[Imm2+R[rb] to BUS B on the next cycle
				RFin						<=	'0'; --writing to R[ra]
				RFout						<=	'0'; 
				RFaddr_wr 					<=	"00"; -- writing to R[ra]
				RFaddr_rd					<=	"00"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'0';
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'1'; -- summing imm2+R[rb]
				done_FSM					<=	'0';

--//////////////////////////// Execute2_I 0XD710 ld   r7,0(r1) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_out					<=  '1'; -- releasing Mem[Imm2+R[rb] =>BUS B
				ALUFN						<=	"1111"; -- C = B
				RFin						<=	'1';   --Ra<=M[R[rb]+imm2]	
				RFout						<=	'0'; 
				PCin						<=	'1';  --getting next instruction
				DTCM_addr_in				<=  '0';
				DTCM_addr_out				<=  '0'; 
				Ain						<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00"; 
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0'; 
				done_FSM					<=	'0';
--//////////////////////////// Fetch 0XE720  st   r7,0(r2) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain							<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 						<= 	"00"; 
				Imm1_in						<=	'0';
				Imm2_in						<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now
--//////////////////////////// Decode 0XE720  st   r7,0(r2) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr						<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; --C=B
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm2_in						<=	'0';
				done_FSM					<=	'0';
				C_last_instruction			<= 	'0';
				Ain							<=	'1'; -- writing to A
				RFin			    		<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFout						<=	'1';   --getting R[rb]
				RFaddr_rd					<=	"01";  --getting R[rb]
				Imm1_in						<=	'0'; 
				PCin						<=	'0';


--//////////////////////////// Execute1_I 0XE720 st   r7,0(r2) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr						<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0000"; -- summing C = imm2+R[rb]
				Ain							<=	'0';
				DTCM_addr_in				<=  '1';
				DTCM_addr_out				<=  '0'; -- Sending Mem[Imm2+R[rb] to BUS B on the next cycle
				RFin						<=	'0'; --writing to R[ra]
				RFout						<=	'0'; 
				RFaddr_wr 					<=	"00"; -- writing to R[ra]
				RFaddr_rd					<=	"00"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'0';
				PCsel						<=	"00";
				Imm1_in						<=	'0'; 
				Imm2_in						<=	'1'; -- summing imm2+R[rb]
				done_FSM					<=	'0';

--//////////////////////////// Execute2_I 0XE720 st   r7,0(r2) ////////////////////////////////////////////
				wait until clk'event and clk ='1';
				DTCM_wr						<=  '1';
				DTCM_out					<=  '0'; 
				ALUFN						<=	"1110"; 
				RFin						<=	'0';   	
				RFout						<=	'1'; 
				PCin						<=	'1';  
				DTCM_addr_in				<=  '0'; 
				DTCM_addr_out				<=  '0';
				Ain							<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00"; 
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm1_in						<=	'0'; 
				Imm2_in						<=	'0'; 
				done_FSM					<=	'0';

--//////////////////////////// Fetch 0X0115  add  r1,r1,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now

--//////////////////////////// Decode 0X0115  add  r1,r1,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; -- C = B 
				Ain						<=	'1'; --regA = rb
				RFin						<=	'0';
				RFout						<=	'1'; --getting R[rb]
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"01"; --getting R[rb]
				IRin						<=	'0';  
				PCin						<=	'0'; 
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	'0';
--//////////////////////////// Execute1_R 0X0115  add  r1,r1,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0000"; --add
				Ain						<=	'0'; 
				RFin						<=	'1';  -- writing R[ra] =rb (function) rc
				RFout						<=	'1'; --getting R[rc]
				RFaddr_wr 					<=	"00"; -- writing R[ra] =rb (function) rc
				RFaddr_rd					<=	"10"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'1'; --getting next instruction
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
--//////////////////////////// Fetch 0X0225  sub  r2,r2,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now

--//////////////////////////// Decode 0X0225  sub  r2,r2,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; -- C = B 
				Ain						<=	'1'; --regA = rb
				RFin						<=	'0';
				RFout						<=	'1'; --getting R[rb]
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"01"; --getting R[rb]
				IRin						<=	'0';  
				PCin						<=	'0'; 
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	'0';
--//////////////////////////// Execute1_R 0X0225  sub  r2,r2,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0001"; --sub
				Ain						<=	'0'; 
				RFin						<=	'1';  -- writing R[ra] =rb (function) rc
				RFout						<=	'1'; --getting R[rc]
				RFaddr_wr 					<=	"00"; -- writing R[ra] =rb (function) rc
				RFaddr_rd					<=	"10"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'1'; --getting next instruction
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
--//////////////////////////// Fetch 0X0445 add  r4,r4,r5 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now

--//////////////////////////// Decode 0X0445  add  r4,r4,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; -- C = B 
				Ain						<=	'1'; --regA = rb
				RFin						<=	'0';
				RFout						<=	'1'; --getting R[rb]
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"01"; --getting R[rb]
				IRin						<=	'0';  
				PCin						<=	'0'; 
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	'0';
--//////////////////////////// Execute1_R 0X0445  add  r4,r4,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0000"; --add
				Ain						<=	'0'; 
				RFin						<=	'1';  -- writing R[ra] =rb (function) rc
				RFout						<=	'1'; --getting R[rc]
				RFaddr_wr 					<=	"00"; -- writing R[ra] =rb (function) rc
				RFaddr_rd					<=	"10"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'1'; --getting next instruction
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
--//////////////////////////// Fetch 0X1A43  sub  r10,r4,r3////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now

--//////////////////////////// Decode 0X1A43  sub  r10,r4,r3////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; -- C = B 
				Ain						<=	'1'; --regA = rb
				RFin						<=	'0';
				RFout						<=	'1'; --getting R[rb]
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"01"; --getting R[rb]
				IRin						<=	'0';  
				PCin						<=	'0'; 
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	'0';
--//////////////////////////// Execute1_R 0X1A43  sub  r10,r4,r3////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0001"; --sub
				Ain						<=	'0'; 
				RFin						<=	'1';  -- writing R[ra] =rb (function) rc
				RFout						<=	'1'; --getting R[rc]
				RFaddr_wr 					<=	"00"; -- writing R[ra] =rb (function) rc
				RFaddr_rd					<=	"10"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'1'; --getting next instruction
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0';
				done_FSM					<=	'0';

--//////////////////////////// Fetch 0X90F9 jlo  -7 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now
--//////////////////////////// Decode 0X90F9 jlo -7 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110"; --unaffected
				Ain						<=	'0'; 
				RFin						<=	'0'; 
				RFout						<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00"; 
				IRin						<=	'0'; 
				PCsel						<=	"01"; 
				C_last_instruction			<= '0';
				PCin						<=	'1'; --getting next instruction 
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
				
---------------------------------   Third iteration -------------------------------------------


--//////////////////////////// Fetch 0XD710  ld   r7,0(r1) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now
--//////////////////////////// Decode 0XD710  ld   r7,0(r1) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; --C=B
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
				C_last_instruction			<= 	'0';
				Ain						<=	'1'; -- writing to A
				RFin			    		<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFout						<=	'1';   --getting R[rb]
				RFaddr_rd					<=	"01";  --getting R[rb]
				Imm1_in					<=	'0'; 
				PCin						<=	'0';
--//////////////////////////// Execute1_I 0XD710 ld   r7,0(r1) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0000"; -- summing C = imm2+R[rb]
				Ain						<=	'0';
				DTCM_addr_in				<=  '0';
				DTCM_addr_out				<=  '1'; -- Sending Mem[Imm2+R[rb] to BUS B on the next cycle
				RFin						<=	'0'; --writing to R[ra]
				RFout						<=	'0'; 
				RFaddr_wr 					<=	"00"; -- writing to R[ra]
				RFaddr_rd					<=	"00"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'0';
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'1'; -- summing imm2+R[rb]
				done_FSM					<=	'0';

--//////////////////////////// Execute2_I 0XD710 ld   r7,0(r1) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_out					<=  '1'; -- releasing Mem[Imm2+R[rb] =>BUS B
				ALUFN						<=	"1111"; -- C = B
				RFin						<=	'1';   --Ra<=M[R[rb]+imm2]	
				RFout						<=	'0'; 
				PCin						<=	'1';  --getting next instruction
				DTCM_addr_in				<=  '0';
				DTCM_addr_out				<=  '0'; 
				Ain						<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00"; 
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0'; 
				done_FSM					<=	'0';
--//////////////////////////// Fetch 0XE720  st   r7,0(r2) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain							<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 						<= 	"00"; 
				Imm1_in						<=	'0';
				Imm2_in						<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now
--//////////////////////////// Decode 0XE720  st   r7,0(r2) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr						<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; --C=B
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm2_in						<=	'0';
				done_FSM					<=	'0';
				C_last_instruction			<= 	'0';
				Ain							<=	'1'; -- writing to A
				RFin			    		<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFout						<=	'1';   --getting R[rb]
				RFaddr_rd					<=	"01";  --getting R[rb]
				Imm1_in						<=	'0'; 
				PCin						<=	'0';


--//////////////////////////// Execute1_I 0XE720 st   r7,0(r2) ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr						<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0000"; -- summing C = imm2+R[rb]
				Ain							<=	'0';
				DTCM_addr_in				<=  '1';
				DTCM_addr_out				<=  '0'; -- Sending Mem[Imm2+R[rb] to BUS B on the next cycle
				RFin						<=	'0'; --writing to R[ra]
				RFout						<=	'0'; 
				RFaddr_wr 					<=	"00"; -- writing to R[ra]
				RFaddr_rd					<=	"00"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'0';
				PCsel						<=	"00";
				Imm1_in						<=	'0'; 
				Imm2_in						<=	'1'; -- summing imm2+R[rb]
				done_FSM					<=	'0';

--//////////////////////////// Execute2_I 0XE720 st   r7,0(r2) ////////////////////////////////////////////
				wait until clk'event and clk ='1';
				DTCM_wr						<=  '1';
				DTCM_out					<=  '0'; 
				ALUFN						<=	"1110"; 
				RFin						<=	'0';   	
				RFout						<=	'1'; 
				PCin						<=	'1';  
				DTCM_addr_in				<=  '0'; 
				DTCM_addr_out				<=  '0';
				Ain							<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00"; 
				IRin						<=	'0'; 
				PCsel						<=	"00";
				Imm1_in						<=	'0'; 
				Imm2_in						<=	'0'; 
				done_FSM					<=	'0';

--//////////////////////////// Fetch 0X0115  add  r1,r1,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now

--//////////////////////////// Decode 0X0115  add  r1,r1,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; -- C = B 
				Ain						<=	'1'; --regA = rb
				RFin						<=	'0';
				RFout						<=	'1'; --getting R[rb]
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"01"; --getting R[rb]
				IRin						<=	'0';  
				PCin						<=	'0'; 
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	'0';
--//////////////////////////// Execute1_R 0X0115  add  r1,r1,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0000"; --add
				Ain						<=	'0'; 
				RFin						<=	'1';  -- writing R[ra] =rb (function) rc
				RFout						<=	'1'; --getting R[rc]
				RFaddr_wr 					<=	"00"; -- writing R[ra] =rb (function) rc
				RFaddr_rd					<=	"10"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'1'; --getting next instruction
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
--//////////////////////////// Fetch 0X0225  sub  r2,r2,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now

--//////////////////////////// Decode 0X0225  sub  r2,r2,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; -- C = B 
				Ain						<=	'1'; --regA = rb
				RFin						<=	'0';
				RFout						<=	'1'; --getting R[rb]
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"01"; --getting R[rb]
				IRin						<=	'0';  
				PCin						<=	'0'; 
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	'0';
--//////////////////////////// Execute1_R 0X0225  sub  r2,r2,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0001"; --sub
				Ain						<=	'0'; 
				RFin						<=	'1';  -- writing R[ra] =rb (function) rc
				RFout						<=	'1'; --getting R[rc]
				RFaddr_wr 					<=	"00"; -- writing R[ra] =rb (function) rc
				RFaddr_rd					<=	"10"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'1'; --getting next instruction
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
--//////////////////////////// Fetch 0X0445 add  r4,r4,r5 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now

--//////////////////////////// Decode 0X0445  add  r4,r4,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; -- C = B 
				Ain						<=	'1'; --regA = rb
				RFin						<=	'0';
				RFout						<=	'1'; --getting R[rb]
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"01"; --getting R[rb]
				IRin						<=	'0';  
				PCin						<=	'0'; 
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	'0';
--//////////////////////////// Execute1_R 0X0445  add  r4,r4,r5////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0000"; --add
				Ain						<=	'0'; 
				RFin						<=	'1';  -- writing R[ra] =rb (function) rc
				RFout						<=	'1'; --getting R[rc]
				RFaddr_wr 					<=	"00"; -- writing R[ra] =rb (function) rc
				RFaddr_rd					<=	"10"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'1'; --getting next instruction
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0';
				done_FSM					<=	'0';
--//////////////////////////// Fetch 0X1A43  sub  r10,r4,r3////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now

--//////////////////////////// Decode 0X1A43  sub  r10,r4,r3////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1111"; -- C = B 
				Ain						<=	'1'; --regA = rb
				RFin						<=	'0';
				RFout						<=	'1'; --getting R[rb]
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"01"; --getting R[rb]
				IRin						<=	'0';  
				PCin						<=	'0'; 
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	'0';
--//////////////////////////// Execute1_R 0X1A43  sub  r10,r4,r3////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				ALUFN						<=	"0001"; --sub
				Ain						<=	'0'; 
				RFin						<=	'1';  -- writing R[ra] =rb (function) rc
				RFout						<=	'1'; --getting R[rc]
				RFaddr_wr 					<=	"00"; -- writing R[ra] =rb (function) rc
				RFaddr_rd					<=	"10"; --getting R[rc]
				IRin						<=	'0'; 
				PCin						<=	'1'; --getting next instruction
				PCsel						<=	"00";
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0';
				done_FSM					<=	'0';

--//////////////////////////// Fetch 0X90F9 jlo  -7 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr 					<= 	'0' ;
				DTCM_addr_out				<= 	'0' ;
				DTCM_addr_in				<= 	'0' ;
				DTCM_out					<= 	'0' ;
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110";	-- ALU output unaffected
				Ain						<=	'0';
				RFin						<=	'0';
				RFout						<=	'0';
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00";
				IRin						<=	'1'; -- open IR 
				PCin						<=	'0'; -- close PC
				PCsel 					<= 	"00"; 
				Imm1_in					<=	'0';
				Imm2_in					<=	'0';
				done_FSM    				<=	'0';
				C_last_instruction			<= 	Cflag; -- if we had flag LAST cycle we need to insert it now
--//////////////////////////// Decode 0X90F9 jlo -7 ////////////////////////////////////////////
				wait until clk'event and clk='1';
				DTCM_wr					<=  '0';
				DTCM_addr_out				<=  '0';
				DTCM_addr_in				<=  '0';
				DTCM_out					<=  '0';
				DTCM_addr_sel				<= 	'0' ;
				ALUFN						<=	"1110"; --unaffected
				Ain						<=	'0'; 
				RFin						<=	'0'; 
				RFout						<=	'0'; 
				RFaddr_wr 					<=	"00"; 
				RFaddr_rd					<=	"00"; 
				IRin						<=	'0'; 
				PCsel						<=	"01"; 
				C_last_instruction			<= '0';
				PCin						<=	'1'; --getting next instruction 
				Imm1_in					<=	'0'; 
				Imm2_in					<=	'0';
				done_FSM					<=	'0';

--//////////////////////////// Decode done ////////////////////////////////////////////
				wait until clk'event and clk='1';
				done_FSM					<=	'1';
				PCsel						<=	"00";
				PCin						<=  '1'; 


end process;
































end rtb;

