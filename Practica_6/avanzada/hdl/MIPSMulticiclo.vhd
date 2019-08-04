library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity MIPSMulticiclo is
	port( 
		clk		: in  std_logic;
		rst_n		: in  std_logic;
		SWPlacaExtendida : in std_logic_vector(3 downto 0);
		SWPlacaSuperior  : in std_logic_vector(3 downto 0);
		displayD	: out std_logic_vector(6 downto 0);
		displayI	: out std_logic_vector(6 downto 0);
		modo		: in 	std_logic;
		siguiente: in 	std_logic;
		displayS : out std_logic_vector(6 downto 0)
	);
end MIPSMulticiclo;

architecture MIPSMulticicloArch of MIPSMulticiclo is

	component unidadDeControl is
		port( 
			clk		: in  std_logic;
			rst_n		: in  std_logic;
			control	: out std_logic_vector(21 downto 0);
			Zero		: in  std_logic;
			ra_leo	: in std_logic;
			Apar		: in 	std_logic;		-- GUARRADA PARA ACABAR, DEBERIA ESTAR EN ALU
			op			: in  std_logic_vector(5 downto 0);
			modo		: in  std_logic;
			siguiente: in  std_logic
		);
	end component;

	component rutaDeDatos is
		port( 
			clk		: in  std_logic;
			rst_n		: in  std_logic;
			SWPlacaExtendida : in std_logic_vector(3 downto 0);
			SWPlacaSuperior  : in std_logic_vector(3 downto 0);
			control	: in  std_logic_vector(21 downto 0);
			Zero		: out std_logic;
			ra_leo	: out std_logic;
			Apar		: out std_logic;		-- GUARRADA PARA ACABAR, DEBERIA ESTAR EN ALU
			op			: out std_logic_vector(5 downto 0);
			busRT		: out std_logic_vector(31 downto 0);
			PCout		: out std_logic_vector(31 downto 0)
		);
	end component;
	
	component DCM_100MHz_10MHz
		port ( CLKIN_IN  : in    std_logic; 
				 CLKDV_OUT : out   std_logic; 
				 CLK0_OUT  : out   std_logic);
	end component;
  
	component conv_7seg
		Port (x : in  STD_LOGIC_VECTOR (3 downto 0);
				display : out  STD_LOGIC_VECTOR (6 downto 0));
	end component;

	component debouncer
	  GENERIC(
		 FREQ   : natural := 10000;  	-- frecuencia de operacion en KHz
		 BOUNCE : natural := 100  		-- tiempo de rebote en ms
	  );
	  PORT (
		 rst: IN std_logic;
		 clk: IN std_logic;
		 x: IN std_logic;
		 xDeb: OUT std_logic;
		 xDebFallingEdge: OUT std_logic;
		 xDebRisingEdge: OUT std_logic
	  );
	END component;
  
   signal clk_10MHz : std_logic;
	signal control : std_logic_vector(21 downto 0);
	signal Zero	: std_logic;
	signal ra_leo : std_logic;
	signal Apar : std_logic;
	signal op : std_logic_vector(5 downto 0);
	signal busRT : std_logic_vector(31 downto 0);
	signal PC : std_logic_vector(31 downto 0);
	signal PCDecrementado : std_logic_vector(31 downto 0);
	signal siguienteDebouncer : std_logic;

begin

	reloj : DCM_100MHz_10MHz port map (CLKIN_IN => clk, CLKDV_OUT=> clk_10MHz, CLK0_OUT => open);

	eliminadorRebotesModo : debouncer port map(rst => rst_n, clk => clk_10MHz, x => siguiente, xDeb => open, xDebFallingEdge => open, xDebRisingEdge => siguienteDebouncer);
	
	UC : unidadDeControl port map(clk => clk_10MHz, rst_n => rst_n, control => control, Zero => Zero, ra_leo => ra_leo, Apar => Apar, op => op, modo => modo, siguiente => siguienteDebouncer);
		
	RD: rutaDeDatos port map(clk => clk_10MHz, rst_n => rst_n,SWPlacaSuperior => SWPlacaSuperior, SWPlacaExtendida=> SWPlacaExtendida, control => control, Zero => Zero, ra_leo => ra_leo, Apar => Apar, op => op, busRT => busRT, PCout => PC);

	displayIzquierdo: conv_7seg port map( x => busRT(7 downto 4), display =>  displayI);

	displayDerecho: conv_7seg port map( x => busRT(3 downto 0), display =>  displayD);
	
	PCDecrementado <= std_logic_vector(to_unsigned(to_integer(unsigned(PC(31 downto 2))) - 1, 32));
	
	displaySuperior: conv_7seg port map( x => PCDecrementado(3 downto 0), display =>  displayS);

end MIPSMulticicloArch;