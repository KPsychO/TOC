library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity divider is
    port (
		rst: in std_logic;
		clk_in: in std_logic; 	-- fpga clock
		clk_out: out std_logic; -- main clock used in slots.vhd
		clk_out_a: out std_logic; 
		clk_out_b: out std_logic
    );
end divider;

architecture divider_arch of divider is
 signal cont: std_logic_vector(25 downto 0);
 signal cont_a: std_logic_vector(25 downto 0);
 signal cont_b: std_logic_vector(25 downto 0);
 signal clk_aux: std_logic;
 signal clk_aux_a: std_logic;
 signal clk_aux_b: std_logic;
  
  begin

 
clk_out<=clk_aux;
clk_out_a<=clk_aux_a;
clk_out_b<=clk_aux_b;

  convert : process(rst, clk_in)
  begin
    if (rst='1') then
	 
      cont<= (others=>'0');
		cont_a<= (others=>'0');
		cont_b<= (others=>'0');
      clk_aux<='0';
		clk_aux_a<='0';
		clk_aux_b<='0';
		
    elsif(clk_in'event and clk_in='1') then
	
      if (cont="11111111111111111111111111") then 
		
      	clk_aux <= not clk_aux;
        cont<= (others=>'0');
		  
      else
		
        cont <= cont+'1';
	    clk_aux<=clk_aux;
		 
      end if;
	  
	   if (cont_a="111111000110010000000") then 
		
      	clk_aux_a <= not clk_aux;
        cont_a<= (others=>'0');
		  
      else
		
        cont_a <= cont_a+'1';
	    clk_aux_a<=clk_aux;
		 
      end if;
		
		if (cont_b="111101000010010000000") then 
		
      	clk_aux_b <= not clk_aux;
        cont_b <= (others=>'0');
		  
      else
		
        cont_b <= cont+'1';
	    clk_aux_b<=clk_aux;
		 
      end if;
	  
    end if;
  end process convert;

end divider_arch;


--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
--
--entity divider is
--    port (
--		rst: in std_logic;
--		clk_in: in std_logic; 	-- fpga clock
--		clk_out: out std_logic; -- main clock used in slots.vhd
--		clk_out_a: out std_logic; 
--		clk_out_b: out std_logic
--    );
--end divider;
--
--architecture divider_arch of divider is
-- signal cont: std_logic_vector(25 downto 0);
-- signal clk_aux: std_logic;
--  
--  begin
--
-- 
--clk_out<=clk_aux;
--
--  convert : process(rst, clk_in)
--  begin
--    if (rst='1') then
--	 
--      cont<= (others=>'0');
--      clk_aux<='0';
--		
--    elsif(clk_in'event and clk_in='1') then
--	
--      if (cont="11111111111111111111111111") then 
--		
--      	clk_aux <= not clk_aux;
--        cont<= (others=>'0');
--		  
--      else
--		
--        cont <= cont+'1';
--	    clk_aux<=clk_aux;
--		 
--      end if;
--	  
--	  if cont = "00000000000001111111111111" then 
--	  
--	   clk_out_a <= not clk_aux;
--		
--	  elsif cont="11111111111111111111111111" then 
--	  
--	   clk_out_a <= not clk_aux;
--		
--	  else 
--	  
--	   clk_out_a <= clk_aux;
--		
--	  end if;
--	  
--	  if cont = "00000000000000000011111111" then 
--	  
--	   clk_out_b <= not clk_aux;
--		
--	  elsif cont="00000000000011111111111111" then 
--	  
--	   clk_out_b <= not clk_aux;
--		
--	  elsif cont="00000011111111111111111111" then 
--	  
--	   clk_out_b <= not clk_aux;
--		
--	  elsif cont="11111111111111111111111111" then 
--	  
--	   clk_out_b <= not clk_aux;
--		
--	  else 
--	  
--	   clk_out_b <= clk_aux;
--		
--	  end if;
--	  
--    end if;
--  end process convert;
--
--end divider_arch;
