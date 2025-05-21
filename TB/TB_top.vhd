library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use IEEE.std_logic_textio.all;
USE work.aux_package.all;





entity TB_top is

		constant m:	 		  		integer:=16;-- ITCM input size
		constant n:	 		  		integer:=16;-- DTCM input output size
		constant Dwidth:	  		integer:=16;
		constant Awidth:	  		integer:=6;
		constant offset_size: 		integer:=8;
		constant OPC_size: 	  		integer:=4;
		constant Reg_size: 	  		integer:=4;
		constant dept:	 	  		integer:=64;
		constant progMemLocation: 	string(1 to 79) :=
		"C:\Users\talad\OneDrive\CPU Architecture lab\Lab3\our_lab3\Ex1\bin\ITCMinit.txt";
		constant dataMemLocationRead: 	string(1 to 79) :=
		"C:\Users\talad\OneDrive\CPU Architecture lab\Lab3\our_lab3\Ex1\bin\DTCMinit.txt";
		constant dataMemLocationWrite: 	string(1 to 82) :=
		"C:\Users\talad\OneDrive\CPU Architecture lab\Lab3\our_lab3\Ex1\bin\DTCMcontent.txt";
end TB_top;

architecture rtb of TB_top is

		signal rst, ena, clk: 												 std_logic;	-- Data to/from TB
		signal ITCM_tb_wr, DTCM_tb_wr, TBactive:							 std_logic;
		signal ITCM_tb_addr_in,DTCM_tb_addr_in,DTCM_tb_addr_out:			 std_logic_vector(Awidth-1 downto 0); 
		signal ITCM_tb_in:													 std_logic_vector(m-1 downto 0); -- ITCM Data_in
		signal DTCM_tb_in:													 std_logic_vector(n-1 downto 0); -- DTCM Data_in  (initial)
		signal DTCM_tb_out:													 std_logic_vector(n-1 downto 0); -- DTCM Data_out  (final)
		signal done_FSM:													 std_logic ;
--          TB signal'
		signal done_FSMProgMemIn ,done_FSMDataMemIn:						 std_logic := '0' ;
	
-- top generic map (m,n,Dwidth,Awidth,offset_size,OPC_size,Reg_size,dept)port map(rst ,ena ,clk ,ITCM_tb_wr ,DTCM_tb_wr ,TBactive ,ITCM_tb_addr_in ,DTCM_tb_addr_in ,DTCM_tb_addr_out ,ITCM_tb_in ,DTCM_tb_in ,DTCM_tb_out ,done_FSM);
	
	
	begin

top_L1 :top generic map (m,n,Dwidth,Awidth,offset_size,OPC_size,Reg_size,dept)port map(rst ,ena ,clk ,ITCM_tb_wr ,DTCM_tb_wr ,TBactive ,ITCM_tb_addr_in ,DTCM_tb_addr_in ,DTCM_tb_addr_out ,ITCM_tb_in ,DTCM_tb_in ,DTCM_tb_out ,done_FSM);

-----------  clock  --------------
gen_clk : process
    begin
	clk <= '0';
	wait for 50 ns;
	clk <= not clk;
	wait for 50 ns;
    end process;

----------- Rst  ------------------
gen_rst : process
        begin
		  rst <='1','0' after 100 ns;
		  wait;
        end process;	
	
----------- TB TBactive & Enable  ------------------	
gen_TB : process
		begin
			wait for 100 ns;
			TBactive <= '1';
			ena      <= '0';
			wait until done_FSMProgMemIn = '1' and done_FSMDataMemIn = '1';
			TBactive <= '0';
			ena      <= '1';
			wait until done_FSM = '1';
			TBactive <= '1';
			--ena      <= '0';
			
			wait; 
		end process;	


------------------------------------ Read ProgMem  ------------------------------------
LoadFileProgMem: process
	file inProgMemFile: text open read_mode is progMemLocation;
	
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
	file inDataMemFile: text open read_mode is dataMemLocationRead;
	
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

----/////////////////////////  write DataMem  --/////////////////////////
writeFileDataMem: process
	file outDataMemFile: text open write_mode is dataMemLocationWrite;
	
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











end rtb;









