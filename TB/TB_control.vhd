library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;




entity tb_control is
constant	Dwidth: integer:=16;
constant	Awidth: integer:=6;
constant	dept:   integer:=64;
end tb_control;
architecture tb of tb_control is
signal		rst, ena, clk: 																 std_logic;
signal		mov_i, done_i, and_i, or_i, xor_i, jnc_i, jc_i, jmp_i, sub_i, add_i,
			Nflag_i, Zflag_i, Cflag_i, ld_i, st_i :										 std_logic;
signal		DTCM_wr_o, DTCM_addr_out_o, DTCM_addr_in_o, DTCM_out_o,DTCM_addr_sel,
			Ain_o, RFin_o, RFout_o, IRin_o,PCin_o, Imm1_in_o, Imm2_in_o:				 std_logic;
signal		ALUFN:																		 std_logic_vector(3 downto 0);
signal		RFaddr_wr, RFaddr_rd, PCsel_o:											     std_logic_vector(1 downto 0);		
signal		done_FSM:																	 std_logic;







--Control generic map(Dwidth,Awidth,dept)port map(rst,ena,clk,mov_i,done_i,and_i,or_i,xor_i,
--jnc_i,jc_i,jmp_i,sub_i,add_i,Nflag_i,Zflag_i,Cflag_i,ld_i,st_i,DTCM_wr_o,DTCM_addr_out_o,DTCM_addr_in_o,DTCM_out_o,
--DTCM_addr_sel, Ain_o, RFin_o,RFout_o,IRin_o,PCin_o, Imm1_in_o,Imm2_in_o,ALUFN,RFaddr_wr, RFaddr_rd, PCsel_o,done_FSM);


begin	
Control_L0: Control generic map(Dwidth,Awidth,dept)port map(rst,ena,clk,mov_i,done_i,and_i,or_i,xor_i,
				jnc_i,jc_i,jmp_i,sub_i,add_i,Nflag_i,Zflag_i,Cflag_i,ld_i,st_i,DTCM_wr_o,DTCM_addr_out_o,DTCM_addr_in_o,DTCM_out_o,
				DTCM_addr_sel, Ain_o, RFin_o,RFout_o,IRin_o,PCin_o, Imm1_in_o,Imm2_in_o,ALUFN,RFaddr_wr, RFaddr_rd, PCsel_o,done_FSM);

		ena <= '1' when done_FSM = '0' else '0';
		
		
		rst_p : process
        begin
		  rst <='1', '0' after 100 ns;  --for now
		  wait;
        end process; 
		
		gen_clk : process
        begin
		  clk <= '0';
		  wait for 50 ns;
		  clk <= not clk;
		  wait for 50 ns;
        end process;
		
		add_i_test_i: process
		begin 
			add_i <='0', '1' after 100 ns, '0' after 400 ns;
			wait;
		end process;
		
		sub_i_test_i: process
		begin 
			sub_i <= '0', '1' after 400 ns, '0' after 700 ns;
			wait;
		end process;
	
		and_i_test_i: process
		begin 
			and_i <= '0', '1' after 700 ns, '0' after 1000 ns;
			wait;
		end process;
		
		sub_i_test_i2: process
		begin 
			sub_i <= '0', '1' after 1000 ns, '0' after 1300 ns;
			wait;
		end process;
	
		jmp_i_test_i: process
		begin 
			jmp_i <= '0', '1' after 1300 ns, '0' after 1500 ns;
			wait;
		end process;
	
		jc_i_test_i: process
		begin 
			jc_i <= '0', '1' after 1500 ns, '0' after 1700 ns;
			Cflag_i <= '0', '1' after 1000 ns, '0' after 1700 ns;
			wait;
		end process;
		
		mov_i_test_i: process
		begin 
			mov_i <= '0', '1' after 1700 ns, '0' after 1900 ns;
			wait;
		end process;
		
		ld_i_test_i: process
		begin 
			ld_i <= '0', '1' after 1900 ns, '0' after 2300 ns;
			wait;
		end process;
		
		st_i_test_i: process
		begin 
			st_i <= '0', '1' after 2300 ns, '0' after 2700 ns;
			wait;
		end process;
		
		done_i_test_i: process
		begin 
			done_i <= '0', '1' after 2700 ns, '0' after 3700 ns;
			wait;
		end process;


end tb;



























