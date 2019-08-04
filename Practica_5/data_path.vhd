library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_path is
 port(
  clk_1hleds: in std_logic;
  clk_a : in std_logic;
  clk_b : in std_logic;
  control : in std_logic_vector(6 downto 0);
  display_a : out std_logic_vector(6 downto 0);
  display_b : out std_logic_vector(6 downto 0);
  control_data : out std_logic_vector(1 downto 0);
  leds: out std_logic_vector(9 downto 0)
 );
end data_path;

architecture behavioral of data_path is
 
COMPONENT bram
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
END COMPONENT;

 component cont_mod10
  port(
   rst: in std_logic;
   clk: in std_logic;
   enable : in std_logic;
   leds : out std_logic_vector(3 downto 0)
  );
 end component;
 
 component conv_7seg
  port (
   x : in  std_logic_vector (3 downto 0);
   display : out  std_logic_vector (6 downto 0)
  );
 end component;

 component att_sequence
  port ( 
   rst: in std_logic;
   clk: in std_logic;
   leds: out std_logic_vector(9 downto 0)
  );
 end component;
 
 component win_sequence
  port ( 
   rst: in std_logic;
   clk: in std_logic;
   leds: out std_logic_vector(9 downto 0)
  );
 end component;
 
 component def_sequence
  port ( 
   rst: in std_logic;
   clk: in std_logic;
   leds: out std_logic_vector(9 downto 0)
  );
 end component;
 
 signal defeat,attract,win : std_logic_vector(9 downto 0);
 
 signal out_cont_a,out_cont_b,out_cont_n, dsp_a_ram, dsp_b_ram : std_logic_vector(3 downto 0);
 
 signal control_aux : std_logic_vector(1 downto 0);
 
 signal error_s : std_logic_vector(3 downto 0) := "1101";
  
 alias cont_rst: std_logic is control(0); 
 alias cont_enable: std_logic is control(1);
 alias seq_rst : std_logic is control(2);
 alias seq_enable:  std_logic is control(3);
 alias mux_leds_A :  std_logic is control(4);
 alias mux_leds_B :  std_logic is control(5);
 alias rst_attract :  std_logic is control(6);
 
 begin
 control_data <= control_aux;
 
 bram_a : bram port map(

  clka		=> clk_a,
  wea			=> "0",
  addra   	=> out_cont_a,
  dina		=> error_s,
  douta		=> dsp_a_ram
 
 );
 
 bram_b : bram port map(

  clka		=> clk_b,
  wea			=> "0",
  addra  	=> out_cont_b,
  dina		=> error_s,
  douta		=> dsp_b_ram
 
 );
 
 cont_a : cont_mod10 port map(
  rst => cont_rst,
  clk => clk_a,
  enable => cont_enable,
  leds => out_cont_a
 );
 
 cont_b : cont_mod10 port map(
  rst => cont_rst,
  clk => clk_b,
  enable => cont_enable,
  leds => out_cont_b
 );
 
 cont_n : cont_mod10 port map(
  rst => seq_rst,
  clk => clk_1hleds,
  enable => seq_enable,
  leds => out_cont_n
 );
 
 process (out_cont_n)
 begin 
  if out_cont_n = "1001" then
   control_aux(0) <= '1';
  else 
   control_aux(0) <= '0';
  end if;
 end process;
 
 process (out_cont_a,out_cont_b)
 begin 
  if out_cont_a = out_cont_b then 
   control_aux(1) <= '1';
  else 
   control_aux(1) <= '0';
  end if;
 end process;
 
 
 conv_7seg_a : conv_7seg port map(
  x => dsp_a_ram,
  display => display_a
 );
 
 conv_7seg_b : conv_7seg port map(
  x => dsp_b_ram,
  display => display_b
 );
 
 at : att_sequence port map(
  rst => rst_attract,
  clk => clk_1hleds,
  leds => attract
 );
 
 vi : win_sequence port map(
  rst => seq_rst,
  clk => clk_1hleds,
  leds => win
 );
 
 de : def_sequence port map(
  rst => seq_rst,
  clk => clk_1hleds,
  leds => defeat
 );
 
 process(win,defeat,attract,control, mux_leds_A, mux_leds_B,clk_a,clk_b)
  begin
   if mux_leds_B = '0' and mux_leds_A = '0' then 
    leds <= "0000000000";
   elsif mux_leds_B = '1' and mux_leds_A = '1' then
    leds <= win;
   elsif mux_leds_B = '1' and mux_leds_A = '0' then 
    leds <= defeat;
   else 
    leds <= attract;
   end if;
 end process;
 
 
end architecture behavioral;