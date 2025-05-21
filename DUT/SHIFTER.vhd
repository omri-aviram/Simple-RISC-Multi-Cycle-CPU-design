LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;  -- Use numeric_std for modern arithmetic and type conversions
USE work.aux_package.all;  -- Assuming aux_package contains necessary utilities


---------------------------------------------------------
--Shifter GENERIC map (n) PORT map(Y_in, X_in,op,Nflag_o,Cflag_o,Zflag_o,result);

entity Shifter IS
  GENERIC (n : INTEGER := 16);
  PORT (
    Y_in, X_in   				: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
    op           				: IN STD_LOGIC_VECTOR (3 DOWNTO 0); -- op code in ALUFN (ALU FANE IN )
    Nflag_o, Cflag_o, Zflag_o	: OUT STD_LOGIC;
    result        				: OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0)
  );
END Shifter;
---------------------------------------------------------

ARCHITECTURE data_calc OF Shifter IS

subtype Line_n IS std_logic_vector (n-1 DOWNTO 0);
type    matrix_k_n IS ARRAY (4-1 DOWNTO 0) OF Line_n;
signal Result_Left , Result_Right              : matrix_k_n ;
signal Carry_vec_right, Carry_vec_left		   : STD_LOGIC_VECTOR(4-1 DOWNTO 0 ); 
signal Zero_vec 		 					   : STD_LOGIC_VECTOR(n-1 DOWNTO 0 ); 
signal result_temp 		 					   : STD_LOGIC_VECTOR(n-1 DOWNTO 0 ); 



BEGIN

Zero_vec <= (others =>'0');
	
----------------   left shift Logic	------------------

Result_Left(0)(0) <= Y_in(0) when X_in(0) = '0' else '0' ;
Result_Left(0)(n-1 DOWNTO 1) <= Y_in(n-1 DOWNTO 1) when X_in(0) = '0' else Y_in(n-2 DOWNTO 0);
Carry_vec_left(0)   <= '0' when X_in(0) = '0' else Y_in(n-1) ;

left_shift : for stage in 1 to 4-1 generate 
			Result_Left(stage)(2**stage-1 DOWNTO 0) <= Result_Left(stage-1)(2**stage-1 DOWNTO 0) when X_in(stage) = '0' else (others =>'0') ;
			Result_Left(stage)(n-1 DOWNTO 2**stage) <= Result_Left(stage-1)(n-1 DOWNTO 2**stage) when X_in(stage) = '0' else Result_Left(stage-1)(n-1-2**stage DOWNTO 0);
			Carry_vec_left(stage) <= Carry_vec_left(stage-1) when X_in(stage) = '0' else Result_Left(stage-1)(n-2**stage);
end generate;

----------------   right shift Logic	------------------

Result_Right(0)(n-1) <= Y_in(n-1) when X_in(0) = '0' else '0' ;
Result_Right(0)(n-2 DOWNTO 0) <= Y_in(n-2 DOWNTO 0) when X_in(0) = '0' else Y_in(n-1 DOWNTO 1);
Carry_vec_right(0)   <= '0' when X_in(0) = '0' else Y_in(0) ;



Right_shift : for stage in 1 to 4-1 generate 
			Result_Right(stage)(n-1 DOWNTO n-2**stage) <= Result_Right(stage-1)(n-1 DOWNTO n-2**stage) when X_in(stage) = '0' 
														 else (others =>'0') ;
														 
			Result_Right(stage)(n-1-2**stage DOWNTO 0) <= Result_Right(stage-1)(n-1-2**stage DOWNTO 0) when X_in(stage) = '0' 
														 else Result_Right(stage-1)(n-1 DOWNTO 2**stage);
														 
			Carry_vec_right(stage) <= Carry_vec_right(stage-1) when X_in(stage) = '0' else Result_Right(stage-1)(2**(stage)-1);
end generate;

	with op select 
				result_temp <= Result_Left(4-1)    when "0101" ,
							   Result_Right(4-1)   when "0110" ,
							  (others =>'0') when others ;	
	
	with op select 
				Cflag_o <= Carry_vec_left(4-1)   when "0101" ,
						   Carry_vec_right(4-1)  when "0110" ,
						   '0' 					 when others ;	
						   
Zflag_o <= '1' when (result_temp = Zero_vec) else '0';
Nflag_o <= result_temp(n-1); -- last bit tells if the output is positive/ negetive
result  <= result_temp when unsigned(X_in) < 16 else Zero_vec;

END data_calc;



