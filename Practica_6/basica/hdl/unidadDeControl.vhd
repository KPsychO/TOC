library IEEE;
use IEEE.std_logic_1164.all;

entity unidadDeControl is
	port( 
		clk		: in  std_logic;
		rst_n		: in  std_logic;
		control	: out std_logic_vector(19 downto 0);
		Zero		: in  std_logic;
		op			: in  std_logic_vector(5 downto 0);
		modo		: in  std_logic;
		siguiente: in  std_logic		
	);
end unidadDeControl;

architecture unidadDeControlArch of unidadDeControl is

  signal control_aux : std_logic_vector(19 downto 0);
  alias PCWrite	: std_logic is control_aux(0);
  alias IorD 		: std_logic is control_aux(1);
  alias MemWrite	: std_logic is control_aux(2);
  alias MemRead 	: std_logic is control_aux(3);
  alias IRWrite 	: std_logic is control_aux(4);
  alias RegDst 	: std_logic is control_aux(5);
  
  alias MemtoReg 	: std_logic_vector(1 downto 0) is control_aux(7 downto 6);
  alias RegWrite 	: std_logic is control_aux(8);
  alias AWrite 	: std_logic is control_aux(9);
  alias BWrite 	: std_logic is control_aux(10);  
  alias ALUScrA 	: std_logic_vector(1 downto 0) is control_aux(12 downto 11);
  alias ALUScrB 	: std_logic_vector(2 downto 0) is control_aux(15 downto 13);
  alias OutWrite 	: std_logic is control_aux(16);
  alias ALUop 		: std_logic_vector(1 downto 0) is control_aux(18 downto 17);
  alias SelPC 		: std_logic is control_aux(19);
  
  
  TYPE states IS (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19);
  SIGNAL currentState, nextState: states;

begin

	control <= control_aux;

  stateGen:
  PROCESS (currentState, op , zero, modo, siguiente)
  BEGIN

    nextState <= currentState;
	 control_aux <= (OTHERS=>'0');
		  
    CASE currentState IS
		
		WHEN S0 =>
			PCWrite <= '1';
			MemRead <= '1';
			ALUScrB <= "001";
			nextState <= S1;
			
		WHEN S1 =>
			IRWrite <= '1';
			if (modo = '0' or (modo = '1' and siguiente = '1')) then
				nextState <= S2;
			end if;
			
		WHEN S2 =>
			AWrite <= '1';
			BWrite <= '1';
			if (op = "000000") then -- tipo-R
				nextState <= S8;
			elsif (op = "100011") then -- lw
				nextState <= S3;
			elsif (op = "101011") then -- sw
				nextState <= S6;
			elsif (op = "000100") then --beq
				nextState <= S10;
				
			elsif (op = "010000") then --mv inmed
				nextState <= S12;
			elsif (op = "010010") then --mv reg
				nextState <= S14;
			elsif (op = "000010") then --jump dir
				nextState <= S16;
			elsif (op = "010001") then --load inmed
				nextState <= S17;
			end if;
		
		WHEN S3 =>
			ALUScrA <= "01";
			ALUScrB <= "010";
			OutWrite <= '1';
			nextState <= S4;
			
		WHEN S4 =>
			MemRead <= '1';
			IorD <= '1';
			nextState <= S5;
		
		WHEN S5 =>
			MemtoReg <= "01";
			RegWrite <= '1';
			nextState <= S0;
		
		WHEN S6 =>
			ALUScrA <= "01";
			ALUScrB <= "010";
			OutWrite <= '1';
			nextState <= S7;
			
		WHEN S7 =>
			MemWrite <= '1';
			IorD <= '1';
			nextState <= S0;
		
		WHEN S8 =>
			ALUScrA <= "01";
			ALUOp <= "10";
			OutWrite <= '1';
			nextState <= S9;
		
		WHEN S9 =>
			RegDst <= '1';
			RegWrite <= '1';
			nextState <= S0;
			
		WHEN S10 =>
			ALUScrA <= "01";
			ALUOp <= "01";
			if (Zero = '0') then
				nextState <= S0;
			else
				nextState <= S11;
			end if;
			
		WHEN S11 =>
			PCWrite <= '1';
			ALUScrB <= "011";
			nextState <= S0;
		
		-- mv rt, #inmed
		
		WHEN S12 =>
			ALUScrA <= "10";
			ALUScrB <= "010";
			ALUOp <= "00";
			OutWrite <= '1';
			nextState <= S13;	
			
		WHEN S13 =>
			RegWrite <= '1';
			nextState <= S0;
			
		-- mv rt, rs
    
		WHEN S14 =>
			ALUScrA <= "01";
			ALUScrB <= "100";
			ALUOp <= "00";
			OutWrite <= '1';
			nextState <= S15;
		
		WHEN S15 =>
			RegWrite <= '1';
			nextState <= S0;
		
		-- j dir
		
		WHEN S16 =>
			SelPC <= '1';
			PCWrite <='1';
			nextState <= S0;	
			
		-- lsw rt, #inmed
		
		WHEN S17 =>
			ALUScrA <= "10";
			ALUScrB <= "010";
			if (Zero = '0') then
				nextState <= S18;
			else
				nextState <= S19;
			end if;
			
		WHEN S18 =>
			Memtoreg <= "10";
			RegWrite <= '1';
			nextState <= S0;	
			
		WHEN S19 =>
			Memtoreg <= "11";
			RegWrite <= '1';
			nextState <= S0;	
			
    END CASE;
  END PROCESS stateGen;

  state:
  PROCESS (rst_n, clk)
  BEGIN
	 IF (rst_n = '0') THEN
		currentState <= S0;
    ELSIF RISING_EDGE(clk) THEN
		currentState <= nextState;
    END IF;
  END PROCESS state;

end unidadDeControlArch;