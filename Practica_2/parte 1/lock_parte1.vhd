library ieee;
use ieee.std_logic_1164.all;

entity lock is

	port (
		key : in std_logic_vector(7 downto 0);
		btn	: in std_logic;
		rst	: in std_logic;
		clk_in : in std_logic;
		dsp	: out std_logic_vector(6 downto 0);
		led	: out std_logic_vector(9 downto 0)
	);
	
end lock;

architecture arch of lock is

	type states is (ini_st, three_st, two_st, one_st, fin_st);
	signal current_state, next_state : states;
	
	signal s_key	: std_logic_vector (7 downto 0);
	signal s_tries	: std_logic_vector (3 downto 0);
	signal s_btn_deb : std_logic;
	signal s_clk	: std_logic;
	
	component conv_7seg is
	
		port (
		
			x 		: in  std_logic_vector (3 downto 0);
			display	: out std_logic_vector (6 downto 0)
		
		);
	
	end component;
   
	component debouncer is
	
		port (
		
			rst             : in  std_logic;
			clk             : in  std_logic;
			x               : in  std_logic;
			xDeb            : out std_logic;
			xDebFallingEdge : out std_logic;
			xDebRisingEdge  : out std_logic
			
		);
		
	end component;
	
begin

	i_conv_7seg : conv_7seg 
	
		port map (
		
			x 			=> s_tries,
			display 	=> dsp
		
		);
		
	i_debouncer : debouncer 
	
		port map (
		
		   rst => rst,
			x => btn,
			clk => clk_in,
			xDebFallingEdge => s_btn_deb
		
		);
		
	s_clk <= clk_in;
	p_reg : process (s_clk, rst)
	
		begin
		
			if (rst = '0') then
				
				s_key <= "00000000";
				current_state <= ini_st;
				
			else
			
				if rising_edge(s_clk) then
					
					current_state <= next_state;
					
					if s_btn_deb = '1' and current_state = ini_st then
					
						s_key <= key;
					
					end if;
					
				end if;
				
			end if;
			
		end process p_reg;
		
	p_next_state : process (current_state, btn, key, s_key)
	
		begin
			
			case current_state is
			
				when ini_st =>
				
					led <= "1111111111";
					s_tries <= "1010";
					
					if (s_btn_deb = '1') then
					
						next_state <= three_st;
						
					else
					
						next_state <= current_state;
						
					end if;
					
				when three_st =>
				
					led <= "0000000000";
					s_tries <= "0011";
					
					if (s_btn_deb = '1' and s_key = key) then
					
						next_state <= ini_st;
						
					elsif (s_btn_deb = '1') then
					
						next_state <= two_st;
						
					else
					
						next_state <= current_state;
						
					end if;
					
				when two_st =>
				
					led <= "0000000000";
					s_tries <= "0010";
					
					if (s_btn_deb = '1' and s_key = key) then
					
						next_state <= ini_st;
						
					elsif (s_btn_deb = '1') then
					
						next_state <= one_st;
						
					else
					
						next_state <= current_state;
						
					end if;
					
				when one_st =>
				
					led <= "0000000000";
					s_tries <= "0001";
					
					if (s_btn_deb = '1' and s_key = key) then
					
						next_state <= ini_st;
						
					elsif (s_btn_deb = '1') then
					
						next_state <= fin_st;
						
					else
					
						next_state <= current_state;
						
					end if;
					
				when fin_st =>
				
					led <= "0000000000";
					s_tries <= "1000";
					next_state <= current_state;
					
				when others =>
				
					s_tries <= "0000";
					led <= "1111111111";
					next_state <= ini_st;
					
			end case;
			
		end process p_next_state;
		
end architecture arch;