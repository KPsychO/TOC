--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:15:59 12/18/2018
-- Design Name:   
-- Module Name:   F:/TOC Practica 6/MIPSMulticiclo/tb.vhd
-- Project Name:  MIPSMulticiclo
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MIPSMulticiclo
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb IS
END tb;
 
ARCHITECTURE behavior OF tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MIPSMulticiclo
    PORT(
         clk : IN  std_logic;
         rst_n : IN  std_logic;
         SWPlacaExtendida : IN  std_logic_vector(3 downto 0);
         SWPlacaSuperior : IN  std_logic_vector(3 downto 0);
         modo : IN  std_logic;
         siguiente : IN  std_logic;
         displayD : OUT  std_logic_vector(6 downto 0);
         displayI : OUT  std_logic_vector(6 downto 0);
         displayS : OUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst_n : std_logic := '0';
   signal SWPlacaExtendida : std_logic_vector(3 downto 0) := (others => '0');
   signal SWPlacaSuperior : std_logic_vector(3 downto 0) := (others => '0');
   signal modo : std_logic := '0';
   signal siguiente : std_logic := '0';

 	--Outputs
   signal displayD : std_logic_vector(6 downto 0);
   signal displayI : std_logic_vector(6 downto 0);
   signal displayS : std_logic_vector(6 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MIPSMulticiclo PORT MAP (
          clk => clk,
          rst_n => rst_n,
          SWPlacaExtendida => SWPlacaExtendida,
          SWPlacaSuperior => SWPlacaSuperior,
          displayD => displayD,
          displayI => displayI,
          modo => modo,
          siguiente => siguiente,
          displayS => displayS
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		SWPlacaSuperior <= "0000";
		SWPlacaExtendida <= "0000";
		modo <= '0'	;
		rst_n <= '0';
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		
		rst_n <= '1';

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
