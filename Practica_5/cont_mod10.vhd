library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cont_mod10 is
 port(
  rst: in std_logic;
  clk: in std_logic;
  enable : in std_logic;
  leds : out std_logic_vector(3 downto 0)
 );
end cont_mod10;

architecture behavioral of cont_mod10 is
 
 signal num: std_logic_vector(3 downto 0);
 
 begin
 
 contar : process(rst, clk) 
  begin 
   if rst = '1' then 
    num <= (others => '0');
   elsif rising_edge(clk) then 
    if enable = '1' then
		
		 if num = "1001" then
		  num <= (others => '0');
		 else 
			num <= std_logic_vector(unsigned(num)+1);
		 end if;
	  
	end if;
	
   end if;
  end process contar;
 
 leds <= num;
 
end architecture behavioral;