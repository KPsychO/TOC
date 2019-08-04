library IEEE;
use IEEE.std_logic_1164.all;

entity rutaDeDatos is
	port( 
		clk		: in  std_logic;
		rst_n		: in  std_logic;
		SWPlacaExtendida : in std_logic_vector(3 downto 0);
		SWPlacaSuperior  : in std_logic_vector(3 downto 0);
		control	: in  std_logic_vector(19 downto 0);
		Zero		: out std_logic;
		op			: out std_logic_vector(5 downto 0);
		busRT		: out std_logic_vector(31 downto 0);
		PCout		: out std_logic_vector(31 downto 0)
	);
end rutaDeDatos;

architecture rutaDeDatosArch of rutaDeDatos is

	component registro
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
	end component;
	
	component multiplexor2a1
		generic(
			bits_entradas: positive := 32
		); 
		port( 
			entrada0	: in  std_logic_vector(bits_entradas-1 downto 0); 
			entrada1	: in  std_logic_vector(bits_entradas-1 downto 0); 
			seleccion: in  std_logic; 
			salida	: out std_logic_vector(bits_entradas-1 downto 0)  
		); 
	end component; 

	component multiplexor4a1 
		generic(
			bits_entradas: positive := 32
		); 
		port( 
			entrada0	: in  std_logic_vector(bits_entradas-1 downto 0);
			entrada1	: in  std_logic_vector(bits_entradas-1 downto 0);
			entrada2	: in  std_logic_vector(bits_entradas-1 downto 0);
			entrada3	: in  std_logic_vector(bits_entradas-1 downto 0);
			seleccion: in  std_logic_vector(1 downto 0); 
			salida	: out std_logic_vector(bits_entradas-1 downto 0)  
		); 
	end component;

	component memoria is
		port( 
			clk		: in  std_logic;
			ADDR		: in  std_logic_vector(31 downto 0 );
			MemWrite	: in  std_logic;
			MemRead	: in  std_logic;
			DW			: in  std_logic_vector(31 downto 0 );
			DR			: out std_logic_vector(31 downto 0 ) 
		);
	end component;	
  
  
	component bancoDeRegistros
		port( 
			clk		: in  std_logic;
			rst_n		: in  std_logic;
			RA			: in  std_logic_vector(4 downto 0);
			RB			: in  std_logic_vector(4 downto 0);
			RegWrite	: in  std_logic;
			RW			: in  std_logic_vector(4 downto 0);
			busW		: in  std_logic_vector(31 downto 0);
			busA		: out std_logic_vector(31 downto 0);
			busB		: out std_logic_vector(31 downto 0);
			busRT		: out std_logic_vector(31 downto 0)
		);
	end component;  
  
	component ALU
		port( 		
			A			: in  std_logic_vector(31 downto 0);
			B			: in  std_logic_vector(31 downto 0);
			ALUop		: in  std_logic_vector(1 downto 0);
			funct		: in  std_logic_vector(5 downto 0);
			Zero		: out std_logic;
			R			: out std_logic_vector(31 downto 0)
		);
	end component;  
	
	
  component multiplexor8a1 is
     generic(
    bits_entradas: positive := 32
  ); 
  port( 
    entrada0  : in  std_logic_vector(bits_entradas-1 downto 0);
    entrada1  : in  std_logic_vector(bits_entradas-1 downto 0);
    entrada2  : in  std_logic_vector(bits_entradas-1 downto 0);
    entrada3  : in  std_logic_vector(bits_entradas-1 downto 0);
    entrada4  : in  std_logic_vector(bits_entradas-1 downto 0);
    entrada5  : in  std_logic_vector(bits_entradas-1 downto 0);
    entrada6  : in  std_logic_vector(bits_entradas-1 downto 0);
    entrada7  : in  std_logic_vector(bits_entradas-1 downto 0);
    seleccion : in  std_logic_vector(2 downto 0); 
    salida  : out std_logic_vector(bits_entradas-1 downto 0)  
  ); 
  end component;

  
  signal control_aux : std_logic_vector(19 downto 0);
  alias PCWrite	: std_logic is control_aux(0);
  alias IorD 		: std_logic is control_aux(1);
  alias MemWrite	: std_logic is control_aux(2);
  alias MemRead 	: std_logic is control_aux(3);
  alias IRWrite 	: std_logic is control_aux(4);
  alias RegDst 	: std_logic is control_aux(5);
  --alias MemtoReg 	: std_logic is control_aux(6);
  alias MemtoReg 	: std_logic_vector(1 downto 0) is control_aux(7 downto 6);
  alias RegWrite 	: std_logic is control_aux(8);
  alias AWrite 	: std_logic is control_aux(9);
  alias BWrite 	: std_logic is control_aux(10);  
  alias ALUScrA 	: std_logic_vector(1 downto 0) is control_aux(12 downto 11);
  alias ALUScrB 	: std_logic_vector(2 downto 0) is control_aux(15 downto 13);
  alias OutWrite 	: std_logic is control_aux(16);
  alias ALUop 		: std_logic_vector(1 downto 0) is control_aux(18 downto 17);
  alias SelPC 		: std_logic is control_aux(19);
  
  
  signal salidaALU : std_logic_vector(31 downto 0);
  signal PC : std_logic_vector(31 downto 0);
  signal ALUOut : std_logic_vector(31 downto 0);
  signal ADDR : std_logic_vector(31 downto 0);
  signal A : std_logic_vector(31 downto 0);
  signal B : std_logic_vector(31 downto 0);
  signal salidaMem : std_logic_vector(31 downto 0);
  signal IR : std_logic_vector(31 downto 0);
  signal OPA : std_logic_vector(31 downto 0);
  signal OPB : std_logic_vector(31 downto 0);
  signal RW : std_logic_vector(4 downto 0);
  signal busW : std_logic_vector(31 downto 0);
  signal signo_extendido : std_logic_vector(31 downto 0);
  signal desplazado : std_logic_vector(31 downto 0);
  signal salidaBancoRegA : std_logic_vector(31 downto 0);
  signal salidaBancoRegb : std_logic_vector(31 downto 0);
  signal signo_extendido_swpe : std_logic_vector(31 downto 0);
  signal signo_extendido_swps : std_logic_vector(31 downto 0);
  signal toPC : std_logic_vector(31 downto 0);
  
  signal dir : std_logic_vector(31 downto 0);
  --SWPlacaExtendida
  --SWPlacaSuperior
  --signal aux1 : std_logic_vector(2 downto 0);
  --signal aux2 : std_logic_vector(1 downto 0);
  --signal aux3 : std_logic_vector(1 downto 0);
  --signal SelPC : std_logic;
begin
	--aux1 <= "0"&ALUScrB;
	--aux2 <= "0"&ALUScrA;
	--aux3 <="0"&MemtoReg;
	--SelPC <= '0';
	dir <= "000000" & IR(25 downto 0);
	PCout <= PC;
 	control_aux <= control;
	op <= IR(31 downto 26);

	reg_PC : registro port map(clk => clk, rst_n => rst_n, load => PCWrite, din => toPC, dout => PC);

	mux_IorD : multiplexor2a1 port map(entrada0 => PC, entrada1 => ALUOut, seleccion => IorD, salida => ADDR); 

	mem : memoria port map(clk => clk, ADDR => ADDR, MemWrite => MemWrite, MemRead => MemRead, DW => B, DR => salidaMem);
	
	reg_IR : registro port map(clk => clk, rst_n => rst_n, load => IRWrite, din => salidaMem, dout => IR);
	
	mux_RW : multiplexor2a1 generic map (bits_entradas => 5) port map(entrada0 => IR(20 downto 16), entrada1 => IR(15 downto 11), seleccion => RegDst, salida => RW);
	
	mux_MDR : multiplexor4a1 port map(entrada0 => ALUout, entrada1 => salidaMem, entrada2=>signo_extendido_swps, entrada3 =>signo_extendido_swpe, seleccion => MemtoReg, salida => busW);
	
	mux_PC : multiplexor2a1 port map(entrada0 => salidaALU, entrada1 => dir, seleccion => SelPC, salida => toPC); 
	
	-- Extension de signo
	signo_extendido(15 downto 0) <= IR(15 downto 0);
	signo_extendido(31 downto 16) <= x"FFFF" when (IR(15) = '1') else x"0000";
	signo_extendido_swpe(3 downto 0) <= SWPlacaExtendida;
	signo_extendido_swpe(31 downto 4) <= x"FFFFFFF" when (SWPlacaExtendida(3) = '1') else x"0000000";
	signo_extendido_swps(3 downto 0) <= SWPlacaSuperior;
	signo_extendido_swps(31 downto 4) <= x"FFFFFFF" when (SWPlacaSuperior(3) = '1') else x"0000000";
	
	-- <<2
	desplazado <= signo_extendido(29 downto 0)&"00";
		
	banco_registros: bancoDeRegistros port map(clk => clk, rst_n => rst_n, RA => IR(25 downto 21), RB => IR(20 downto 16), RegWrite => RegWrite, RW => RW, busW => busW, busA => salidaBancoRegA, busB => salidaBancoRegB, busRT => busRT);
	
	reg_A : registro port map(clk => clk, rst_n => rst_n, load => AWrite, din => salidaBancoRegA, dout => A);
	
	reg_B : registro port map(clk => clk, rst_n => rst_n, load => BWrite, din => salidaBancoRegB, dout => B);
	
	mux_opA : multiplexor4a1 port map(entrada0 => PC, entrada1 => A, entrada2 => x"00000000", entrada3 => x"00000000", seleccion => ALUScrA, salida => OPA);
	
	mux_opB : multiplexor8a1 port map(entrada0 => B, entrada1 => x"00000004", entrada2 => signo_extendido, entrada3 => desplazado, entrada4 => x"00000000", entrada5 => x"00000000", entrada6 => x"00000000", entrada7 => x"00000000", seleccion => ALUScrB, salida => OPB); 
	
	ALU_i : ALU port map(A => OPA, B => OPB, ALUop => ALUop, funct => IR(5 downto 0), Zero => Zero, R => salidaALU);
	
	reg_ALUout : registro port map(clk => clk, rst_n => rst_n, load => OutWrite, din => salidaALU, dout => ALUout);

end rutaDeDatosArch;