library IEEE;
use IEEE.std_logic_1164.all;

entity registro is
	generic(
		n : positive := 32
	);
	port( 
		clk	: in  std_logic;
		rst_n	: in  std_logic;
		load	: in  std_logic;
		din	: in  std_logic_vector( n-1 downto 0 );
		dout	: out std_logic_vector( n-1 downto 0 ) 
	);
end registro;

architecture registroArch of registro is
   
begin

	process(clk, rst_n)
	begin
		if (rst_n = '0') then
			dout <= (others => '0');
		elsif (clk'event and clk='1') then			
			if (load = '1') then
            dout <= din;
         end if;
		end if;
   end process;

end registroArch;