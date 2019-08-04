library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity slots is
 port(
  rst: in std_logic;
  clk: in std_logic;
  ini : in std_logic;
  fin : in std_logic;
  dsp_a : out std_logic_vector(6 downto 0);
  dsp_b : out std_logic_vector(6 downto 0);
  leds: out std_logic_vector(9 downto 0)
 );
end slots;

architecture behavioral of slots is
 
 component divider 
  port( 
   rst: in std_logic;
   clk_in: in std_logic; -- reloj de entrada de la entity superior
   clk_out: out std_logic; -- reloj que se utililedsa en los process del programa principal
   clk_out_a: out std_logic; 
   clk_out_b: out std_logic
  );
 end component;

 component control_unit
  port (
  clk: in std_logic;
  rst: in std_logic;
  ini : in std_logic;
  fin : in std_logic;
  control_data : in std_logic_vector(1 downto 0);
  control:out std_logic_vector (6 downto 0)
  );
 end component;
 
 -- rst_n
 component data_path
  port (
  clk_1hleds: in std_logic;
  clk_a : in std_logic;
  clk_b : in std_logic;
  control : in std_logic_vector(6 downto 0);
  display_a : out std_logic_vector(6 downto 0);
  display_b : out std_logic_vector(6 downto 0);
  control_data : out std_logic_vector(1 downto 0);
  leds: out std_logic_vector(9 downto 0)
  );
 end component;
 
 component debouncer is
  port (
   rst : in  std_logic;
   clk : in  std_logic;
   x : in  std_logic;
   xdeb : out std_logic;
   xdebfallingedge : out std_logic;
   xdebrisingedge  : out std_logic
  );
 end component;
 
 signal button1, button2, xdebfallingedge_ini, xdebfallingedge_fin, xdebrisingedge1, xdebrisingedge2: std_logic;
 signal clk_1hleds, clk_a, clk_b : std_logic;
 signal control_link : std_logic_vector (6 downto 0);
 signal control_data_link : std_logic_vector (1 downto 0);
 signal rst_not : std_logic;
 
 begin
 rst_not <= not rst;
 
 ini_debouncer : debouncer 
  port map(
   rst => rst, 
   clk => clk, 
   x => ini, 
   xdeb => button1, 
   xdebfallingedge => xdebfallingedge_ini, 
   xdebrisingedge => xdebrisingedge1
  );
  
 fin_debouncer : debouncer 
  port map(
   rst => rst, 
   clk => clk, 
   x => fin, 
   xdeb => button2, 
   xdebfallingedge => xdebfallingedge_fin, 
   xdebrisingedge => xdebrisingedge2
  );
  
  
 div: divider port map( 
   rst => rst_not, 
   clk_in => clk, 
   clk_out => clk_1hleds, 
   clk_out_a => clk_a,  
   clk_out_b => clk_b
  );
  
 dp : data_path port map(
  clk_1hleds => clk_1hleds,
  clk_a => clk_a, 
  clk_b => clk_b, 
  control => control_link, 
  display_a => dsp_a, 
  display_b => dsp_b, 
  control_data => control_data_link, 
  leds => leds
 );
 
 cu : control_unit port map(
  clk => clk, 
  rst => rst_not, 
  ini => xdebfallingedge_ini, 
  fin => xdebfallingedge_fin, 
  control_data => control_data_link, 
  control => control_link
  );
 
end architecture behavioral;