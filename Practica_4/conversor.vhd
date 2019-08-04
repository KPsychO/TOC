library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity conversor is

	port(
		x : in std_logic_vector(7 downto 0);
		a : out std_logic_vector(3 downto 0);
		b : out std_logic_vector(3 downto 0)
	);

end conversor;

architecture Behavioral of conversor is

	signal sx : integer;
	signal sa : integer;
	signal sb : integer;

begin

	p_exec : process(x, sx, sa, sb)
	
	begin
	
		sx <= to_integer(unsigned(x));
		
		sa <= sx / 10;
		sb <= sx mod 10;
		
		a <= std_logic_vector(to_unsigned(sa, a'length));
		b <= std_logic_vector(to_unsigned(sb, b'length));

	end process;

end Behavioral;