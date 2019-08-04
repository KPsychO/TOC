library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mul_sec is
	port(
		rst:   in std_logic;
	   clk:   in std_logic;
		ini: in std_logic;						
		op1:   in std_logic_vector(3 downto 0);
		op2:   in std_logic_vector(3 downto 0);
		HxResult1: out std_logic_vector(6 downto 0);
		HxResult2: out std_logic_vector(6 downto 0);
		result : out std_logic_vector(7 downto 0);
		done:     out std_logic;
		auxxx : out std_logic_vector(1 downto 0)
	);
end mul_sec;

architecture Behavioral of mul_sec is

	component conv_7seg
		Port (
			x	: in std_logic_vector(3 downto 0);
			display : out std_logic_vector(6 downto 0)
		);
	end component;
	
	component debouncer
		port(
			rst: IN std_logic;
			clk: IN std_logic;
			x: IN std_logic;
			xDeb: OUT std_logic;
			xDebFallingEdge: OUT std_logic;
			xDebRisingEdge: OUT std_logic
		);
	end component;
	
signal iniDebounced: std_logic;
signal res: std_logic_vector(7 downto 0);
signal aux : std_logic_vector(7 downto 0);
signal s_op1 : std_logic_vector(7 downto 0);
signal s_op2 : std_logic_vector(3 downto 0);
signal con1 : std_logic_vector(3 downto 0);
signal con2 : std_logic_vector(3 downto 0);

type STATE is (S0,idle,S2);
signal actualState, nextState: STATE := S0;

begin

i_debouncer: debouncer 
	port map(
		rst  => rst,
		clk  => clk,
		x    => ini,
		xDeb => iniDebounced
	);
	
i_conv1: conv_7seg 
	port map(
		x       => res(3 downto 0),
		display => HxResult1
	);

i_conv2: conv_7seg 
	port map(
		x       => res(7 downto 4),
		display => HxResult2
	);

p_exec:process (clk)

begin

	if (clk'event and clk = '1') then
	
		if rst = '0' then
		
			actualState <= S0;
			
		else
		
			actualState <= nextState;
			
		end if;
		
	end if;
	
end process;

p_states:process(actualState, iniDebounced, s_op1, s_op2, op1, op2, res)  -- Usar iniDebounced en la puta fpga
begin
	result <= res;  -- kkk
case actualState is

	when S0 =>
		done <= '1';
		if(iniDebounced = '1') then  -- Usar iniDebounced en la puta fpga
		
			s_op1 <= "0000" & op1;
			s_op2 <= op2;
			res <= "00000000";
			result <= res;  -- kkk
			
			nextState <= idle;
			
		else 
		
			result <= res;  -- kkk
			nextState <= S0;
			
		end if;

	when idle =>
done <= '0';
		result <= res;  -- kkk
		
		if (s_op2 = "0000") then
			
			
			nextstate <= S0;
			
		else
		
			nextstate <= s2;
			
		end if;
		
	when S2 =>
done <= '0';
		result <= res;  -- kkk
		
		if (s_op2(0) = '1') then
						
			res <= std_logic_vector(unsigned(res) + unsigned(s_op1));
			s_op1 <= (s_op1(6 downto 0) & "0");
			s_op2 <= ("0" & s_op2(3 downto 1));
			nextState <= idle;
			
		else
		
			s_op1 <= (s_op1(6 downto 0) & "0");
			s_op2 <= ("0" & s_op2(3 downto 1));

			nextState <= idle;
						
		end if;

	when others => null;
		
end case;

end process;


p_statasdfasdfes:process(actualState)  -- Usar iniDebounced en la puta fpga
begin

case actualState is
	when S0 =>
	auxxx <="00";
	when idle =>
		auxxx <="01";
	when S2 =>
		auxxx <="10";
	when others =>
		auxxx <="11";
		
end case;

end process;
	
end Behavioral;