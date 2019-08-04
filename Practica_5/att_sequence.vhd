library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity att_sequence is
 port(
  rst: in std_logic;
  clk: in std_logic;
  leds: out std_logic_vector(9 downto 0)
 );
end att_sequence;

architecture behavioral of att_sequence is

COMPONENT bram_seq
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
  );
END COMPONENT;
 
 signal tmp : std_logic_vector(4 downto 0);
 
 begin
 
 bram_att : bram_seq
  PORT MAP (
    clka => clk,
    wea => "0",
    addra => tmp,
    dina => "0000011111",
    douta => leds
  );
 
 process(clk,rst,tmp)
 begin
  if rst = '1' then
   tmp <= (others => '0');
  elsif rising_edge(clk) then 
   tmp <= tmp + '1';
  end if;
 end process;

end architecture behavioral;