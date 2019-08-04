library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
  port (
    rst             : in  std_logic;
    clk             : in  std_logic;
    x               : in  std_logic;
    xdeb            : out std_logic;
    xdebfallingedge : out std_logic;
    xdebrisingedge  : out std_logic
    );
end debouncer;

architecture debouncerarch of debouncer is

  signal xsyncanterior : std_logic;
  signal xsync         : std_logic;

  -- espera 50 ms para un reloj a 100 mhz
  constant timeout : unsigned (22 downto 0) := "10011000100101101000000";
  signal count     : unsigned (22 downto 0);

  type states is (waitingpression, pressiondebouncing, waitingdepression, depressiondebouncing);
  signal state, next_state    : states;
  signal starttimer, timerend : std_logic;

begin

  synchronizer :
  process (rst, clk)
    variable aux1 : std_logic;
  begin
    if (rst = '0') then
      xsyncanterior <= '1';
      xsync         <= '1';
    elsif (rising_edge(clk)) then
      xsync         <= xsyncanterior;
      xsyncanterior <= x;
    end if;
  end process synchronizer;

  timer :
  process (rst, clk)
  begin
    if (rst = '0') then
      count <= (others => '0');
    elsif (rising_edge(clk)) then
      if (starttimer = '1') then
        count <= (others => '0');
      elsif (timerend = '0') then
        count <= count + 1;
      end if;
    end if;
  end process timer;

  timerend <= '1' when (count = timeout) else '0';

  cu_sync :
  process (rst, clk)
  begin
    if (rst = '0') then
      state <= waitingpression;
    elsif (rising_edge(clk)) then
      state <= next_state;
    end if;
  end process cu_sync;

  cu_comb :
  process (state, xsync, timerend)
  begin

    xdeb            <= '1';
    xdebfallingedge <= '0';
    xdebrisingedge  <= '0';
    starttimer      <= '0';
    next_state      <= state;

    case state is

      when waitingpression =>
        if (xsync = '0') then
          xdebfallingedge <= '1';
          starttimer      <= '1';
          next_state      <= pressiondebouncing;
        end if;

      when pressiondebouncing =>
        xdeb <= '0';
        if (timerend = '1') then
          next_state <= waitingdepression;
        end if;

      when waitingdepression =>
        xdeb <= '0';
        if (xsync = '1') then
          xdebrisingedge <= '1';
          starttimer     <= '1';
          next_state     <= depressiondebouncing;
        end if;

      when depressiondebouncing =>
        if (timerend = '1') then
          next_state <= waitingpression;
        end if;

    end case;
  end process cu_comb;


end debouncerarch;
