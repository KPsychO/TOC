library ieee;
use ieee.std_logic_1164.all;

entity lock is

	port (
		key : in std_logic_vector(7 downto 0);
		btn	: in std_logic;
		rst	: in std_logic;
		clk_in : in std_logic;
		dsp	: out std_logic_vector(6 downto 0);
		s_state	: out std_logic_vector(2 downto 0);
		s_next_state : out std_logic_vector(2 downto 0);
		s_status : out std_logic_vector(3 downto 0)

	);
	
end lock;

architecture arch of lock is

	type states is (ini_st, three_st, two_st, one_st, fin_st);
	signal current_state, next_state : states;
	
	signal s_key	: std_logic_vector (7 downto 0);
	signal s_tries	: std_logic_vector (3 downto 0);
	signal s_btn_deb : std_logic;
	signal s_clk	: std_logic;
	signal s_clk_div : std_logic;
	
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
	
	component divisor is
	
		port (
		
			rst 		: in std_logic;
			clk_100mhz	: in std_logic;
			clk_1hz	: out std_logic
		
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
		
	i_divisor : divisor
	
		port map (
		
			rst => rst,
			clk_100mhz => clk_in,
			clk_1hz => s_clk_div
		
		);
		
		-- DESCOMENTAR PARA IGNORAR DIVISOR {
		
	s_clk <= clk_in;
	
		-- }
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
		
	p_parp : process (s_clk_div) -- s_status no es una señal síncrona, da error:
	
									-- ERROR:Xst:827 - "E:/Toc-p2-EXTENDIDA/lock.vhd" line 133: Signal s_status cannot be synthesized, bad synchronous description. The description style you are using to describe a synchronous element (register, memory, etc.) is not supported in the current software release.

		begin
		
			case current_state is
			
				when ini_st =>
				
					s_status <= "0000";
					
				when others =>
				
					if rising_edge(s_clk_div) then
					
						s_status <= "1111";
						
					else
					
						s_status <= "0000";
						
					end if;
					
			end case;
		
		end process p_parp;
		
	p_next_state : process (current_state, btn, key, s_key)
	
		begin
			
			case current_state is
			
				when ini_st =>
				
					s_state <= "000";
					s_tries <= "1010";
					
					if (key = s_key) then
					
						s_next_state <= "000";
						
					else
					
						s_next_state <= "001";
						
					end if;
					
					if (s_btn_deb = '1') then
					
						next_state <= three_st;
						
					else
					
						next_state <= current_state;
						
					end if;
					
				when three_st =>
				
					s_state <= "001";
					s_tries <= "0011";
					
					if (key = s_key) then
					
						s_next_state <= "000";
						
					else
					
						s_next_state <= "010";
						
					end if;
					
					if (s_btn_deb = '1' and s_key = key) then
					
						next_state <= ini_st;
						
					elsif (s_btn_deb = '1') then
					
						next_state <= two_st;
						
					else
					
						next_state <= current_state;
						
					end if;
					
				when two_st =>
				
					s_state <= "010";
					s_tries <= "0010";
					
					if (key = s_key) then
					
						s_next_state <= "000";
						
					else
					
						s_next_state <= "011";
						
					end if;
					
					if (s_btn_deb = '1' and s_key = key) then
					
						next_state <= ini_st;
						
					elsif (s_btn_deb = '1') then
					
						next_state <= one_st;
						
					else
					
						next_state <= current_state;
						
					end if;
					
				when one_st =>
				
					s_state <= "011";
					s_tries <= "0001";
					
					if (key = s_key) then
					
						s_next_state <= "000";
						
					else
					
						s_next_state <= "100";
						
					end if;
					
					if (s_btn_deb = '1' and s_key = key) then
					
						next_state <= ini_st;
						
					elsif (s_btn_deb = '1') then
					
						next_state <= fin_st;
						
					else
					
						next_state <= current_state;
						
					end if;
					
				when fin_st =>
				
					s_state <= "100";
					s_next_state <= "100";
					s_tries <= "1000";
					next_state <= current_state;
					
				when others =>
				
					s_tries <= "0000";
					next_state <= ini_st;
					
			end case;
			
		end process p_next_state;
		
end architecture arch;