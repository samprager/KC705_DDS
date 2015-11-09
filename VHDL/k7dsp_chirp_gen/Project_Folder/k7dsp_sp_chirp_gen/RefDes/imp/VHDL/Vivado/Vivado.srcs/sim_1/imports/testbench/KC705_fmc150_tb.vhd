-------------------------------------------------------------------------------------
-- FILE NAME : KC705_fmc150_tb.vhd
--
-- AUTHOR    : Luc Langlois
--
-- COMPANY   : Avnet
--
-- UNITS     : Entity       - KC705_fmc150_tb
--             architecture - KC705_fmc150_tb_beh
--
-- LANGUAGE  : VHDL
--
-- Target Device: 7K325t-2ffg900
-- Tool versions: ISE® Design Suite: System Edition 13.3 / build O.76
--
-------------------------------------------------------------------------------------
-- Library declarations
library ieee;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_misc.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_1164.all;
library unisim;
  use unisim.vcomponents.all;
library work;

entity KC705_fmc150_tb is
end KC705_fmc150_tb;

architecture KC705_fmc150_tb_beh of KC705_fmc150_tb is

----------------------------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------------------------
constant SYSCLK_PERIOD : time := 5.000 ns; -- Period of the system clock on the KC705 (Freq=200MHz)
constant DACCLK_PERIOD : time := 4.069 ns; -- Period of the DAC clock on the FMC150 (Freq=245.76MHz)
-- constant ADCCLK_PERIOD : time := 16.276 ns; -- Period of the ADC clock on the FMC150 (Freq=61.44MHz)
constant ADCCLK_PERIOD : time := 4.069 ns; -- Period of the ADC clock on the FMC150 (Freq=245.76MHz)

constant ADC_PATTERN_DELAY : time := 3.5 ns; 

constant SW_OFF : std_logic := '0';
constant SW_ON  : std_logic := '1';

----------------------------------------------------------------------------------------------------
-- Component declaration
----------------------------------------------------------------------------------------------------
component KC705_fmc150 is
generic (
  MAX_PATTERN_CNT : integer := 1000 -- value of 15000 = approx 1 sec for ramp of length 2^14 samples @ 245.76 MSPS
);
port (

  --KC705 Resources
  cpu_reset        : in    std_logic;
  sysclk_p         : in    std_logic;
  sysclk_n         : in    std_logic;
  gpio_led         : out   std_logic_vector(7 downto 0);
  gpio_dip_sw      : in    std_logic_vector(7 downto 0);
  gpio_led_c       : out   std_logic;
  gpio_led_e       : out   std_logic;
  gpio_led_n       : out   std_logic;
  gpio_led_s       : out   std_logic;
  gpio_led_w       : out   std_logic;
  gpio_sw_c        : in    std_logic;
  gpio_sw_e        : in    std_logic;
  gpio_sw_n        : in    std_logic;
  gpio_sw_s        : in    std_logic;
  gpio_sw_w        : in    std_logic;

  --Clock/Data connection to ADC on FMC150
  clk_ab_p         : in    std_logic;
  clk_ab_n         : in    std_logic;
  cha_p            : in    std_logic_vector(6 downto 0);
  cha_n            : in    std_logic_vector(6 downto 0);
  chb_p            : in    std_logic_vector(6 downto 0);
  chb_n            : in    std_logic_vector(6 downto 0);

  --Clock/Data connection to DAC on FMC150
  dac_dclk_p       : out   std_logic;
  dac_dclk_n       : out   std_logic;
  dac_data_p       : out   std_logic_vector(7 downto 0);
  dac_data_n       : out   std_logic_vector(7 downto 0);
  dac_frame_p      : out   std_logic;
  dac_frame_n      : out   std_logic;
  txenable         : out   std_logic;

  --Clock/Trigger connection to FMC150
 -- clk_to_fpga_p    : in    std_logic;
 -- clk_to_fpga_n    : in    std_logic;
  --ext_trigger_p    : in    std_logic;
  --ext_trigger_n    : in    std_logic;

  --Serial Peripheral Interface (SPI)
  spi_sclk         : out   std_logic;
  spi_sdata        : out   std_logic;
  adc_n_en         : out   std_logic;
  adc_sdo          : in    std_logic;
  adc_reset        : out   std_logic;

  cdce_n_en        : out   std_logic;
  cdce_sdo         : in    std_logic;
  cdce_n_reset     : out   std_logic;
  cdce_n_pd        : out   std_logic;
  ref_en           : out   std_logic;
  pll_status       : in    std_logic;

  dac_n_en         : out   std_logic;
  dac_sdo          : in    std_logic;

  mon_n_en         : out   std_logic;
  mon_sdo          : in    std_logic;
  mon_n_reset      : out   std_logic;
  mon_n_int        : in    std_logic;

  --FMC Present status
  prsnt_m2c_l      : in    std_logic

);
end component KC705_fmc150;

----------------------------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------------------------
signal cpu_reset     : std_logic := '1';
signal ADC_reset     : std_logic := '1';
signal sysclk_p      : std_logic := '0';
signal sysclk_n      : std_logic := '1';

--signal clk_to_fpga_p : std_logic := '0';
--signal clk_to_fpga_n : std_logic := '1';

signal adc_data_edge	: std_logic := '1';
signal clk_ab_p      : std_logic := '1';
signal clk_ab_n      : std_logic := '0';
signal cha_p         : std_logic_vector(6 downto 0) := (others => '0');
signal cha_n         : std_logic_vector(6 downto 0) := (others => '1');
signal chb_p         : std_logic_vector(6 downto 0) := (others => '0');
signal chb_n         : std_logic_vector(6 downto 0) := (others => '1');

signal dac_frame_p	: std_logic;
signal dac_data_p		: std_logic_vector(7 downto 0);
signal dac_data_i		: std_logic_vector(15 downto 0);
signal dac_data_q		: std_logic_vector(15 downto 0);

signal gpio_dip_sw   : std_logic_vector(7 downto 0);
signal gpio_sw_c     : std_logic := '0';

signal ramp, ramp_prev : std_logic_vector(13 downto 0) := (others => '0');

----------------------------------------------------------------------------------------------------
-- Begin
----------------------------------------------------------------------------------------------------
begin

----------------------------------------------------------------------------------------------------
-- Mode of operation is set through DIP Switches
-- Enable digital mode
----------------------------------------------------------------------------------------------------
gpio_dip_sw(0) <= SW_ON;  -- digital mode ON => DUC output drives DDC input
--gpio_dip_sw(0) <= SW_OFF;	-- digital mode OFF => ADC output drives DDC input
gpio_dip_sw(1) <= SW_OFF;	-- ON for ADC driven from test pattern / OFF for DAC -> ADC loopback in testbench
gpio_dip_sw(2) <= SW_OFF;
gpio_dip_sw(3) <= SW_OFF;
gpio_dip_sw(4) <= SW_OFF;
gpio_dip_sw(5) <= SW_OFF;
gpio_dip_sw(6) <= SW_OFF;
gpio_dip_sw(7) <= SW_OFF;

----------------------------------------------------------------------------------------------------
-- Trigger impulse response
----------------------------------------------------------------------------------------------------

process
begin

	gpio_sw_c <= '0';
	cpu_reset <= '0';
	ADC_reset <= '0';

	wait for 100 ns;
  
	cpu_reset <= '1';
	ADC_reset <= '1';
	wait for 10 ns;
	cpu_reset <= '0';
	wait for ADC_PATTERN_DELAY;
	ADC_reset <= '0';
  
	wait for 5 us;

	gpio_sw_c <= '1';
	wait for 1 us;
	gpio_sw_c <= '0';
	
	wait for 15 us;

	gpio_sw_c <= '1';
	wait for 1 us;
	gpio_sw_c <= '0';

  wait;

end process;

----------------------------------------------------------------------------------------------------
-- Generate clock signals
----------------------------------------------------------------------------------------------------
-- cpu_reset <= '0' after 10 ns;

sysclk_p <= not sysclk_p after SYSCLK_PERIOD / 2;
sysclk_n <= not sysclk_n after SYSCLK_PERIOD / 2;

--clk_to_fpga_p <= not clk_to_fpga_p after DACCLK_PERIOD / 2;
--clk_to_fpga_n <= not clk_to_fpga_n after DACCLK_PERIOD / 2;

adc_data_edge <= not adc_data_edge after ADCCLK_PERIOD / 2;

process	-- ADS62P49 output clock edges are centered on data
	begin
	wait for ADCCLK_PERIOD/4;
	clk_ab_p <= '0';
	clk_ab_n <= '1';
	
	wait for ADCCLK_PERIOD/2;
	clk_ab_p <= '1';
	clk_ab_n <= '0';
	
	wait for ADCCLK_PERIOD/4;
end process;

----------------------------------------------------------------------------------------------------
-- Generate ADC data as ADS62P49 ramp test-pattern (register 0x75 (ch B), 0x62 (ch A) = 0000_0004)
-- NOTE: when 'digital_mode' = '1' (controlled from gpio_dip_sw(0)), impulse is generated up through DUC and looped back down through DUC
--       ... data converters are disconnected from DUC/DCC, so ADC data capture of ramp can be tested independently in ISIM simulation
----------------------------------------------------------------------------------------------------
process(adc_data_edge)
begin
  if rising_edge(adc_data_edge) then
    -- Increment ramp value
	 if ADC_reset = '1' then
		ramp <= (others => '0');
		ramp_prev <= (others => '0');
	 else
		if ramp < "00000011111111" then
			ramp <= ramp + 1; -- ADS62P49 in test mode ramp pattern (register 0x62 , 0x75 = 0000_0004) has length 2^14, but make length 2^8 for simulation purposes
		else
			ramp <= (others => '0');
		end if;
		ramp_prev <= ramp;
    -- Output even bits
      cha_p <= ramp(12) & ramp(10) & ramp(08) & ramp(06) & ramp(04) & ramp(02) & ramp(00);
      cha_n <= not (ramp(12) & ramp(10) & ramp(08) & ramp(06) & ramp(04) & ramp(02) & ramp(00));
      chb_p <= ramp(12) & ramp(10) & ramp(08) & ramp(06) & ramp(04) & ramp(02) & ramp(00);
      chb_n <= not (ramp(12) & ramp(10) & ramp(08) & ramp(06) & ramp(04) & ramp(02) & ramp(00));
	 end if;
  elsif (falling_edge(adc_data_edge)) then
	if ADC_reset = '0' then
	    -- Output odd bits
      cha_p <= ramp_prev(13) & ramp_prev(11) & ramp_prev(09) & ramp_prev(07) & ramp_prev(05) & ramp_prev(03) & ramp_prev(01);
      cha_n <= not (ramp_prev(13) & ramp_prev(11) & ramp_prev(09) & ramp_prev(07) & ramp_prev(05) & ramp_prev(03) & ramp_prev(01));
      chb_p <= ramp_prev(13) & ramp_prev(11) & ramp_prev(09) & ramp_prev(07) & ramp_prev(05) & ramp_prev(03) & ramp_prev(01);
      chb_n <= not (ramp_prev(13) & ramp_prev(11) & ramp_prev(09) & ramp_prev(07) & ramp_prev(05) & ramp_prev(03) & ramp_prev(01));
	end if;
  end if;
end process;

----------------------------------------------------------------------------------------------------
-- De-mux DAC digital data from OSERDES
----------------------------------------------------------------------------------------------------
--process(clk_ab_p)
--begin
--    if (rising_edge(clk_ab_p)) then
--		dac_data(7 downto 0) <= dac_data_p;
--		dac_data_r <= dac_data;
--	 elsif (falling_edge(clk_ab_p)) then
--		dac_data(15 downto 8) <= dac_data_p;
--	end if;
--end process;

----------------------------------------------------------------------------------------------------
-- Unit under test: FPGA on KC705
----------------------------------------------------------------------------------------------------
uut: KC705_fmc150
generic map (
  MAX_PATTERN_CNT => 1
)
port map (
  cpu_reset        => cpu_reset,
  sysclk_p         => sysclk_p,
  sysclk_n         => sysclk_n,
  gpio_led         => open,
  gpio_dip_sw      => gpio_dip_sw,
  gpio_led_c       => open,
  gpio_led_e       => open,
  gpio_led_n       => open,
  gpio_led_s       => open,
  gpio_led_w       => open,
  gpio_sw_c        => gpio_sw_c,
  gpio_sw_e        => '0',
  gpio_sw_n        => '0',
  gpio_sw_s        => '0',
  gpio_sw_w        => '0',
  clk_ab_p         => clk_ab_p,
  clk_ab_n         => clk_ab_n,
  cha_p            => cha_p,
  cha_n            => cha_n,
  chb_p            => chb_p,
  chb_n            => chb_n,
  dac_dclk_p       => open,
  dac_dclk_n       => open,
  dac_data_p       => dac_data_p,
  dac_data_n       => open,
  dac_frame_p      => dac_frame_p,
  dac_frame_n      => open,
  txenable         => open,
  --clk_to_fpga_p    => clk_to_fpga_p,
  --clk_to_fpga_n    => clk_to_fpga_n,
  --ext_trigger_p    => '0',
  --ext_trigger_n    => '1',
  spi_sclk         => open,
  spi_sdata        => open,
  adc_n_en         => open,
  adc_sdo          => 'Z',
  adc_reset        => open,
  cdce_n_en        => open,
  cdce_sdo         => 'Z',
  cdce_n_reset     => open,
  cdce_n_pd        => open,
  ref_en           => open,
  pll_status       => '1',
  dac_n_en         => open,
  dac_sdo          => 'Z',
  mon_n_en         => open,
  mon_sdo          => 'Z',
  mon_n_reset      => open,
  mon_n_int        => '1',
  prsnt_m2c_l      => '0'

);

----------------------------------------------------------------------------------------------------
-- End
----------------------------------------------------------------------------------------------------
end KC705_fmc150_tb_beh;
