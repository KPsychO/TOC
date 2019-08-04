library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity BlockRam is
  port (
    clka, wea, ena : in  STD_LOGIC;
    addra          : in  STD_LOGIC_VECTOR (8  downto 0);
    dina           : in  STD_LOGIC_VECTOR (31 downto 0);
    douta          : out STD_LOGIC_VECTOR (31 downto 0)
  );
end BlockRam;

architecture Behavioral of BlockRam is

  type ram_type is array (0 to 511) of std_logic_vector (31 downto 0);
  signal ram : ram_type :=
    (          --
    x"40030007",--         mv R3, #7 		          									  	0x00000000	0100 0000 0000 0011 0000000000000111
    x"18840003",-- WHILE:  bleo R3, END                                 0x00000004  0001 1000 1000 0100 0000000000000011
    x"48640000",--         mv R4, R3 		                  							0x00000008	0100 1000 0110 0100 0000000000000000
    x"A8640000",--         ctz R3, R4                                   0x0000000C  101010 00011 00100 0000000000000000
    x"08000004",--         jmp WHILE																	  0x00000010	0000 10 00000 00000 0000000000000100
    x"08000014",-- END:     jmp END                                     0x00000014  000010 00000 00000 0000000000010100

	others => x"00000000"
	
    );
begin

  process( clka )
  begin
    if rising_edge(clka) then
      if ena = '1' then
        if wea = '1' then
          ram(to_integer(unsigned(addra))) <= dina;
          douta <= dina;
        else
          douta <= ram(to_integer(unsigned(addra)));
        end if;
      end if;
    end if;
  end process;
  
end Behavioral;

