-- Francisco Javier Blzquez Martnez ~ frblazqu@ucm.es
--
-- Double degree in Mathematics-Computer engineering.
-- Complutense university, Madrid.
--
-- Description: 
-- Test for 4x4bit multiplier designed from an ASM description.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TestbenchMul is
end TestbenchMul;

architecture Behavioral of TestbenchMul is
	
	-- Components we are going to test:
	component mul_sec is
	port(
		rst:   in std_logic;
	   clk:   in std_logic;
		ini: in std_logic;						
		op1:   in std_logic_vector(3 downto 0);
		op2:   in std_logic_vector(3 downto 0);
		HxResult1: out std_logic_vector(6 downto 0);
		HxResult2: out std_logic_vector(6 downto 0);
		result : out std_logic_vector(7 downto 0);
		done:     out std_logic
	);
	end component;
	
	-- Signals needed (input):
	signal rst: std_logic := '0';
	signal clk: std_logic := '0';
	signal ini: std_logic := '0';
	signal A: std_logic_vector(3 downto 0) := (others=>'0');
	signal B: std_logic_vector(3 downto 0) := (others=>'0');
	
	-- Signals needed (output):
	signal Z: std_logic_vector(7 downto 0);
	signal fin: std_logic; 
begin
	
	mul: mul_sec port map
	(
		rst => rst,
		clk => clk,
		ini => ini,
		op1   => A,
		op2   => B,
		HxResult1 => open,
		HxResult2 => open,
		result => Z,
		done => fin
	);
	
	process
	begin
			
		if(clk='1') then 
			clk<='0';
		else
			clk<='1';
		end if;
		
		wait for 30 ns;
		
	end process;
	
	
	-- Test cases:
	process
	begin
	
	rst <= '1';
	wait for 200 ns;
	
	rst <= '0';
	ini <= '1';
	wait for 60 ns;

	ini <= '0';
	A <= "0000";
	B <= "0000";
	ini <= '1';
	wait for 2000 ns; 
	
	ini <= '0';
	A <= "0001";
	B <= "0001";
	ini <= '1';

	wait for 2000 ns;
	
	ini <= '0';
	A <= "0001"; 
	B <= "0010";
	ini <= '1';
	wait for 2000 ns;
	
	ini <= '0';
	A <= "0001";
	B <= "1000";
	ini <= '1';
	wait for 2000 ns;

	ini <= '0';
	A <= "1000";
	B <= "0010";
	ini <= '1';
	wait for 2000 ns;
	
	ini <= '0';
	A <= "1010";
	B <= "0101";
	ini <= '1';
	wait for 2000 ns;
	
	ini <= '0';
	A <= "1111";
	B <= "1111";
	ini <= '1';
	wait for 2000 ns;
	
	wait;
	
	end process;

end Behavioral;

