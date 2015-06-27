----------------------------------------------------------------------------------
--    _____
--   /     \
--  /____   \____
-- / \===\   \==/
--/___\===\___\/  AVNET
--     \======/
--      \====/    
--
----------------------------------------------------------------------------------
-- This design is the property of Avnet.  Publication of this
-- design is not authorized without written consent from Avnet.
-- 
-- Any modifications that are made to the Source Code are 
-- done at the user's sole risk and will be unsupported.
--
-- Disclaimer:
--    Avnet, Inc. makes no warranty for the use of this code or design.
--    This code is provided  "As Is". Avnet, Inc assumes no responsibility for
--    any errors, which may appear in this code, nor does it make a commitment
--    to update the information contained herein. Avnet, Inc specifically
--    disclaims any implied warranties of fitness for a particular purpose.
--                     Copyright(c) 2010 Avnet, Inc.
--                             All rights reserved.
--
--
-- This copyright and support notice must be retained as part 
-- of this text at all times. 
--
-- Xilinx products are not intended for use in life support
-- appliances, devices, or systems. Use in such applications is
-- expressly prohibited.
--
----------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------
-- FILE NAME : KC705_fmc150.vhd
--
-- AUTHOR    : Luc Langlois
--
-- COMPANY   : Avnet
--
-- UNITS     : Entity       - KC705_fmc150
--             architecture - KC705_fmc150_syn
--
-- LANGUAGE  : VHDL
--
-- Target Device: 7K325t-2ffg900
-- Tool versions: Vivado 2012.4
--
-------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- This file is the toplevel code of DUC/DDC RTL Targetted Reference Design for Kintex-7 DSP Kit (KCV705 Rev 1.0 + FMC150 Rev 1.0 / 1.2):
--  * Physical interface to the ADCS62P49 14-bit dual ADC, 250 MSPS and DAC3283 dual-DAC 16-bit, 800 MSPS on the FMC150
--  *   ADS62P49 sampling rate = 245.76 Msps
--  *   DAC3283 sampling rate = 245.76 Msps, with 2X interpolation in DAC3283
--	 *   491.52 MHz system clock, for 2X over-clocking of fastest stage of DUC/DDC with input sampling rate of 245.76 MSPS
--  * Control block for configuring the FMC150 through SPI busses
--  * DUC/DDC module as user design
--
-- All reference designs for the Xilinx Kintex-7 DSP Kit are available from http://www.em.avnet.com\k7dspkit
--
-- For information on all Avnet development kits contact your local Avnet FAE, or visit the Avnet Design Resource Center: http://www.em.avnet.com/drc
-------------------------------------------------------------------------------------
-- Revisions
-- Luc Langlois \ Avnet
-- August 2011 : 
--		- Update to ISE 13.2
--		- Increased DUC output sampling rate to 245.76 MSPS to DAC3283 with 2X interpolation
--		- Increased ADC input sampling rate to 245.76 MSPS
--
-- Nov 4, 2011: 
--		- Update to ISE 13.3 build O.76 
--		- DUC_DDC module as user design
-- Nov 29, 2011:
--    - added trig1 to 'ila_baseband_out' connected to 'baseband_out_valid' for storage qualifier in Chipscope
--    - ... valid signal out of last stage of DDC (RRC FIR)
--    - ... enable storage qualifier in Chipscope to avoid 8X repeated samples (DDC downsamples total of 8X)
-- Dec 9, 2011:
--    - Ported to 13.4 O.87
--       - ADC iSERDES differential clock input ports back to true polarity from inverted in 13.3
--       - updated ADC iDelays
--       - updated ChipScope .CPJ project with 5-bit busses to display iDelay settings (ADC Ch A, Ch B, CLK) as read out of iDELAYE2
-- Dec 19, 2011:
--       - added ADC auto-calibration at reset-time, independant on both ADC channels A, B
--       -... changes to ADC_auto_calibration.vhd, fmc150_spi_ctrl.vhd
--
-- February 16, 2012 : updated to 491.52 MHz system clock, for 2X over-clocking of fastest stage with input sampling rate of 245.76 MSPS
--
-- Aug 19, 2012:
--       - Updated to Vivado 2012.2
--       - Updated ADC auto-calibration to fix intermittent ADC data-capture errors
--         - added reset pulse to iSERDES synchronous to 122_88_Mhz clock domain, simultaneous with pulse to update iDelay value from auto calibration
--         - changed clock to iDelay to 122.88 MHz, same as iserdes CLKDIV
--         - updated clock of 'Delay_update: process' to clk_122_88MHz, synchronous with iSerdes CLKDIV
--         - simplified ADC auto-calibration to generate pulse to iDelay 'CE' port thereby incrementing the delay value, as opposed to loading a 5-bit value
--         - ... the result is consistent ADC auto-calibration at power-on and system reset for error-free ADC data capture
--         - gpio_led(7) (the LED closest to SD card slot on KC705) should come 'ON' shortly after reset to indicate successful capture of ADC ramp test pattern
--         - user may verify by asserting pushbutton 'CPU_RST' on KC705
--
-- Nov 29 2012:
--		-Updated to Vivado 2012.4  
--		-Changed debug to Vivado Analayzer ILA2.0
--
---- June 4 2013:
--		-Updated to Vivado 2013.2  
--		-Changed debug to Vivado Analayzer ILA2.1 and VIO to Vivado v2.0
--      -upgraded FIR and complex multiplier IP
--      -Commented out black box in complex_mixer VHDL
--
--  July 20 2013:
--		- Complex multiplier outputs in DUC and DDC:
--          - IP lacks rounding function, so ...
--          - Added rounding to match MATLAB model
--
--  Aug 5 2013:
--		- ILA v3 and VIO v3 ports UPPERCASE to lowercase.
--      - Changed mmcms to single clock input.
--      - Modelsim globally Static chnage for CLKB, PROBE4, PROBE5
-------------------------------------------------------------------------------------
-- Library declarations
-------------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_misc.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_1164.all;
library unisim;
  use unisim.vcomponents.all;

-------------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------------
entity KC705_fmc150 is
generic (
  MAX_PATTERN_CNT : integer := 2000 -- value of 15000 = approx 1 sec for ramp of length 2^14 samples @ 245.76 MSPS
);
port (

  --KC705 Resources
  cpu_reset        : in    std_logic; -- CPU RST button, SW7 on KC705
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

  --Clock/Data connection to ADC on FMC150 (ADS62P49)
  clk_ab_p         : in    std_logic;
  clk_ab_n         : in    std_logic;
  cha_p            : in    std_logic_vector(6 downto 0);
  cha_n            : in    std_logic_vector(6 downto 0);
  chb_p            : in    std_logic_vector(6 downto 0);
  chb_n            : in    std_logic_vector(6 downto 0);

  --Clock/Data connection to DAC on FMC150 (DAC3283)
  dac_dclk_p       : out   std_logic;
  dac_dclk_n       : out   std_logic;
  dac_data_p       : out   std_logic_vector(7 downto 0);
  dac_data_n       : out   std_logic_vector(7 downto 0);
  dac_frame_p      : out   std_logic;
  dac_frame_n      : out   std_logic;
  txenable         : out   std_logic;

  --Clock/Trigger connection to FMC150
  --clk_to_fpga_p    : in    std_logic;
  --clk_to_fpga_n    : in    std_logic;
  --ext_trigger_p    : in    std_logic;
  --ext_trigger_n    : in    std_logic;

  --Serial Peripheral Interface (SPI)
  spi_sclk         : out   std_logic; -- Shared SPI clock line
  spi_sdata        : out   std_logic; -- Shared SPI sata line

  -- ADC specific signals
  adc_n_en         : out   std_logic; -- SPI chip select
  adc_sdo          : in    std_logic; -- SPI data out
  adc_reset        : out   std_logic; -- SPI reset

  -- CDCE specific signals
  cdce_n_en        : out   std_logic; -- SPI chip select
  cdce_sdo         : in    std_logic; -- SPI data out
  cdce_n_reset     : out   std_logic;
  cdce_n_pd        : out   std_logic;
  ref_en           : out   std_logic;
  pll_status       : in    std_logic;

  -- DAC specific signals
  dac_n_en         : out   std_logic; -- SPI chip select
  dac_sdo          : in    std_logic; -- SPI data out

  -- Monitoring specific signals
  mon_n_en         : out   std_logic; -- SPI chip select
  mon_sdo          : in    std_logic; -- SPI data out
  mon_n_reset      : out   std_logic;
  mon_n_int        : in    std_logic;

  --FMC Present status
  prsnt_m2c_l      : in    std_logic

);
end KC705_fmc150;

architecture KC705_fmc150_syn of KC705_fmc150 is

----------------------------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------------------------
constant CLK_IDELAY : integer := 0; -- Initial number of delay taps on ADC clock input
constant CHA_IDELAY : integer := 28; -- Initial number of delay taps on ADC data port A  -- error-free capture range measured between 25 ... 30
constant CHB_IDELAY : integer := 10; -- Initial number of delay taps on ADC data port B  -- error-free capture range measured between 0 ... 20

----------------------------------------------------------------------------------------------------
-- Component declaration
----------------------------------------------------------------------------------------------------
COMPONENT ila
  PORT (
    clk     : IN STD_LOGIC;
    probe0  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    probe1  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    probe2  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    probe3  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    probe4  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe5  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe6  : IN STD_LOGIC_VECTOR(13 DOWNTO 0)
  );
END COMPONENT;

--component icon_v1_06_a_0 is
--port (
--  control0 : inout std_logic_vector(35 downto 0)
----  control1 : inout std_logic_vector(35 downto 0);
----  control2 : inout std_logic_vector(35 downto 0);
----  control3 : inout std_logic_vector(35 downto 0)
--);
--end component icon_v1_06_a_0;

--component vio is
--port (
--  clk       : in    std_logic := 'X';
--  sync_in   : in    std_logic_vector(47 downto 0);
--  control   : inout std_logic_vector(35 downto 0);
--  sync_out  : out   std_logic_vector(67 downto 0)
--);
--end component vio;


COMPONENT vio
  PORT (
    clk : IN STD_LOGIC;
    probe_in0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    probe_in1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    probe_in2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    probe_in3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    probe_in4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out0 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    probe_out1 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    probe_out2 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    probe_out3 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    probe_out4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    probe_out5 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out6 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out7 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out8 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out9 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;
--
--component ila_dac is
--port (
--  clk     : in    std_logic := 'X';
--  trig0   : in    std_logic_vector(31 downto 0);
--  control : inout std_logic_vector(35 downto 0)
--);
--end component ila_dac;
--
--component ila_baseband_out is
--port (
--  clk     : in    std_logic := 'X';
--  trig0   : in    std_logic_vector(31 downto 0);
--  trig1   : in    std_logic_vector(0 downto 0);
--  control : inout std_logic_vector(35 downto 0)
--);
--end component ila_baseband_out;
component mmcm_adac is
port (
    -- Clock in ports
    clk_in1   : in  std_logic;
    -- Clock out ports
    clk_out1  : out std_logic;
    clk_out2  : out std_logic;
    clk_out3  : out std_logic;
    clk_out4  : out std_logic;
    -- Status and control signals
    reset     : in  std_logic;
    locked    : out std_logic
);
end component mmcm_adac;

component mmcm is
port (
    -- Clock in ports
    clk_in1   : in std_logic;
    -- Clock out ports
    clk_out1  : out std_logic;
    clk_out2  : out std_logic;
    -- Status and control signals
    reset     : in  std_logic;
    locked    : out std_logic
);
end component mmcm;

component fmc150_spi_ctrl is
port (
  -- VIO command interface
  odata            : out   std_logic_vector(31 downto 0);
  odata_valid      : out   std_logic;
  addr             : in    std_logic_vector(15 downto 0);
  idata            : in    std_logic_vector(31 downto 0);
  rd_n_wr          : in    std_logic;
  cdce72010_valid  : in    std_logic;
  ads62p49_valid   : in    std_logic;
  dac3283_valid    : in    std_logic;
  amc7823_valid    : in    std_logic;
  
  busy             : out   std_logic;
  
  external_clock   : in    std_logic;

  -- Global signals
  rst              : in    std_logic;
  clk              : in    std_logic;

  -- External signals
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

  prsnt_m2c_l      : in    std_logic;
  init_amc7823_done	 : out   std_logic
);
end component fmc150_spi_ctrl;

component DUC_DDC is

port (
	clock        			: in std_logic;
	clock1        			: in std_logic;
	clock2        			: in std_logic;
	reset           		: in std_logic;
	if_freq					: std_logic_vector(27 downto 0);
	baseband_in_i			: in std_logic_vector(15 downto 0);
	baseband_in_q			: in std_logic_vector(15 downto 0);
	baseband_in_valid		: in std_logic;
	if_in_i					: in std_logic_vector(15 downto 0);
	if_in_q					: in std_logic_vector(15 downto 0);
	if_in_valid				: in std_logic;

	if_out_i					: out std_logic_vector(15 downto 0);
	if_out_q					: out std_logic_vector(15 downto 0);
	if_out_valid			: out std_logic;
	baseband_out_i			: out std_logic_vector(15 downto 0);
	baseband_out_q			: out std_logic_vector(15 downto 0);
	baseband_out_valid	: out std_logic;

	duc_dcc_route_ctrl	: in std_logic_vector(2 downto 0);
	test_mode				: in std_logic;
	gpio_sw_c				: in std_logic
);
end component duc_ddc;

--component ila_adc_cali
--  port (
--    control : inout std_logic_vector(35 downto 0);
--    clk : in std_logic;
--    data : in std_logic_vector(23 downto 0);
--    trig0 : in std_logic_vector(13 downto 0);
--    trig1 : in std_logic_vector(0 to 0);
--    trig2 : in std_logic_vector(0 to 0);
--    trig3 : in std_logic_vector(0 to 0));
--end component;

component ADC_auto_calibration is
  generic (
    MAX_PATTERN_CNT : integer := 2000;   -- value of 15000 = approx 1 sec for ramp of length 2^14 samples @ 245.76 MSPS
    INIT_IDELAY : integer                -- Initial number of delay taps on ADC data port
   );
  Port ( reset                 : in  STD_LOGIC;
    clk                   : in  STD_LOGIC;
    ADC_calibration_start : in  STD_LOGIC;
    ADC_data              : in  STD_LOGIC_VECTOR (13 downto 0);
    re_mux_polarity       : out  STD_LOGIC;
    iDelay_INC            : out  STD_LOGIC;
    ADC_calibration_state : out  STD_LOGIC_VECTOR(2 downto 0);
    ADC_calibration_done  : out  BOOLEAN;
    ADC_calibration_good  : out  STD_LOGIC);

end component;

----------------------------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------------------------
signal vio_sync_in       : std_logic_vector(47 downto 0);
signal vio_control       : std_logic_vector(35 downto 0);
signal vio_sync_out      : std_logic_vector(67 downto 0);
signal vio_sync_out_prev : std_logic_vector(96 downto 0);
  -- Ensure the tools keep these signals for ChipScope
--attribute S: string;
--attribute S of vio_sync_in : signal is "TRUE";
--attribute S of vio_control : signal is "TRUE";
--attribute S of vio_sync_out : signal is "TRUE";
attribute keep: string;
--attribute keep of vio_sync_in : signal is "TRUE";
--attribute keep of vio_control : signal is "TRUE";
--attribute keep of vio_sync_out : signal is "TRUE";

signal clk_100Mhz        : std_logic;
signal clk_200Mhz        : std_logic;
signal mmcm_locked       : std_logic;

signal arst              : std_logic;
signal rst               : std_logic;

signal clk_ab_l          : std_logic;
signal clk_ab_dly        : std_logic;
signal clk_ab_i          : std_logic;

signal cha_ddr                     : std_logic_vector(6 downto 0);  -- Double Data Rate
signal cha_ddr_dly                 : std_logic_vector(6 downto 0);  -- Double Data Rate, Delayed
signal cha_sdr_sample1             : std_logic_vector(13 downto 0); -- Single Data Rate
signal cha_sdr_sample0             : std_logic_vector(13 downto 0); -- Single Data Rate

signal adc_dout_122_88_MSPS_valid  : std_logic; -- data_valid pulse accompanies re-clocked 122.88 MSPS data at 245.75 MHz towards SysGen GateWays IN
signal cha_sdr_sample1_re_clocked  : std_logic_vector(13 downto 0); -- Single Data Rate @ 122.88 MSPS, re-clocked at 245.75 MHz accompanied by data_valid pulse
signal cha_sdr_sample0_re_clocked  : std_logic_vector(13 downto 0); -- Single Data Rate @ 122.88 MSPS, re-clocked at 245.75 MHz accompanied by data_valid pulse
signal chb_sdr_sample1_re_clocked  : std_logic_vector(13 downto 0); -- Single Data Rate @ 122.88 MSPS, re-clocked at 245.75 MHz accompanied by data_valid pulse
signal chb_sdr_sample0_re_clocked  : std_logic_vector(13 downto 0); -- Single Data Rate @ 122.88 MSPS, re-clocked at 245.75 MHz accompanied by data_valid pulse

signal chb_ddr                     : std_logic_vector(6 downto 0);  -- Double Data Rate
signal chb_ddr_dly                 : std_logic_vector(6 downto 0);  -- Double Data Rate, Delayed
signal chb_sdr_sample1             : std_logic_vector(13 downto 0); -- Single Data Rate
signal chb_sdr_sample0             : std_logic_vector(13 downto 0); -- Single Data Rate

signal adc_dout_i_245_76_MSPS      : std_logic_vector(13 downto 0);
signal adc_dout_q_245_76_MSPS      : std_logic_vector(13 downto 0);
signal adc_dout_245_76_MSPS_valid  : std_logic;
signal clk_245_76MHz_count         : std_logic;
signal adc_dout_i, adc_dout_q      : std_logic_vector(15 downto 0);	-- ADC data re-mux'd to 245.76 MSPS in fabric, extended to 16-bit

signal iDelay_INC_cha    : std_logic;
signal iDelay_INC_cha_r  : std_logic;
signal iDelay_INC_chb    : std_logic;
signal iDelay_INC_chb_r  : std_logic;
signal idelay_LD_cha     : std_logic;
signal idelay_LD_chb     : std_logic;
signal delay_update_cha  : std_logic;
signal delay_update_chb  : std_logic;
signal delay_update_clk  : std_logic;
signal iserdes_rst_cha   : std_logic;
signal iserdes_rst_chb   : std_logic;
signal clk_cntvaluein    : std_logic_vector(4 downto 0);
signal clk_cntvaluein_update    : std_logic_vector(4 downto 0);
signal clk_cntvaluein_update_vio    : std_logic_vector(4 downto 0);
signal clk_cntvaluein_update_122_88MHz : std_logic_vector(4 downto 0);
signal clk_cntvaluein_update_122_88MHz_r : std_logic_vector(4 downto 0);
signal cha_cntvaluein    : std_logic_vector(4 downto 0);
signal cha_cntvaluein_update    : std_logic_vector(4 downto 0);
signal cha_cntvaluein_update_vio    : std_logic_vector(4 downto 0);
signal cha_cntvaluein_update_122_88MHz : std_logic_vector(4 downto 0);
signal cha_cntvaluein_update_122_88MHz_r : std_logic_vector(4 downto 0);
signal chb_cntvaluein    : std_logic_vector(4 downto 0);
signal chb_cntvaluein_update    : std_logic_vector(4 downto 0);
signal chb_cntvaluein_update_vio    : std_logic_vector(4 downto 0);
signal chb_cntvaluein_update_122_88MHz : std_logic_vector(4 downto 0);
signal chb_cntvaluein_update_122_88MHz_r : std_logic_vector(4 downto 0);

signal clk_cntvalueout   : std_logic_vector(4 downto 0);
type cha_cntvalueout_array is array(cha_p'length-1 downto 0) of std_logic_vector(4 downto 0);
signal cha_cntvalueout   : cha_cntvalueout_array;
type chb_cntvalueout_array is array(chb_p'length-1 downto 0) of std_logic_vector(4 downto 0);
signal chb_cntvalueout   : chb_cntvalueout_array;

signal rd_n_wr           : std_logic;
signal addr              : std_logic_vector(15 downto 0);
signal idata             : std_logic_vector(31 downto 0);
signal odata             : std_logic_vector(31 downto 0);
signal busy              : std_logic;
signal busy_reg	         : std_logic;
signal cdce72010_valid   : std_logic;
signal ads62p49_valid    : std_logic;
signal dac3283_valid     : std_logic;
signal amc7823_valid     : std_logic;
signal fmc150_spi_ctrl_done	: std_logic;
signal fmc150_spi_ctrl_done_r	: std_logic;

signal clk_15_36MHz      : std_logic;
signal clk_122_88MHz     : std_logic;
signal clk_245_76MHz     : std_logic;
signal clk_245_76MHz_1   : std_logic;
signal clk_245_76MHz_2   : std_logic;
signal clk_491_52MHz     : std_logic;
signal mmcm_adac_locked  : std_logic;

--signal clk_to_fpga       : std_logic;

signal dac_din_i         : std_logic_vector(15 downto 0);
signal dac_din_q         : std_logic_vector(15 downto 0);
signal DUC_if_out_i      : std_logic_vector(15 downto 0);
signal DUC_if_out_q      : std_logic_vector(15 downto 0);

signal frame             : std_logic;
signal io_rst          	 : std_logic;

signal dac_dclk_prebuf   : std_logic;
signal dac_data_prebuf   : std_logic_vector(7 downto 0);
signal dac_frame_prebuf  : std_logic;

signal adc_cha_re_mux_polarity 	 : std_logic := '1';	-- initial state '1' is contrary to actual default behaviour in hardware, but desired for simulation to verify correctness of state machine
signal adc_chb_re_mux_polarity 	 : std_logic := '1';	-- initial state '1' is contrary to actual default behaviour in hardware, but desired for simulation to verify correctness of state machine
signal adc_chb_re_mux_polarity_1 : std_logic_vector(0 downto 0) := "1";	-- initial state '1' is contrary to actual default behaviour in hardware, but desired for simulation to verify correctness of state machine

signal digital_mode      		 : std_logic;
signal ddc_duc_bypass    		 : std_logic;
signal adc_out_dac_in    		 : std_logic;
signal external_clock    		 : std_logic;
signal duc_dcc_route_ctrl_sig	 : std_logic_vector(2 downto 0);

signal baseband_out_i_sig    	 : std_logic_vector(15 downto 0);
signal baseband_out_q_sig    	 : std_logic_vector(15 downto 0);

signal baseband_out_valid_sig_v	 : std_logic_vector(0 downto 0);
signal baseband_out_valid_sig	 : std_logic;

signal ila_baseband_out_trig0    : std_logic_vector(31 downto 0);
signal ila_baseband_out_trig1    : std_logic_vector(0 downto 0);
signal ila_baseband_out_control	 : std_logic_vector(35 downto 0);

signal ila_dac_trig0     		 : std_logic_vector(31 downto 0);
signal ila_dac_control   		 : std_logic_vector(35 downto 0);

signal baseband_out_i_sig_dly1 	: std_logic_vector(15 downto 0);
signal baseband_out_q_sig_dly1 	: std_logic_vector(15 downto 0);

signal baseband_out_valid_sig_dly1	: std_logic;
signal baseband_out_valid_sig_dly1_1	: std_logic_vector(0 downto 0);

attribute mark_debug : string;
attribute mark_debug of dac_din_i: signal is "TRUE";
attribute mark_debug of dac_din_q: signal is "TRUE";
attribute mark_debug of baseband_out_i_sig_dly1: signal is "TRUE";
attribute mark_debug of baseband_out_q_sig_dly1: signal is "TRUE";
attribute mark_debug of baseband_out_valid_sig_dly1: signal is "TRUE";
attribute mark_debug of adc_chb_re_mux_polarity: signal is "TRUE";
attribute mark_debug of adc_dout_q_245_76_MSPS: signal is "TRUE";

attribute mark_debug of cha_cntvalueout: signal is "TRUE";
attribute mark_debug of chb_cntvalueout: signal is "TRUE";
--attribute mark_debug of vio_sync_in : signal is "TRUE";
--attribute mark_debug of vio_sync_out : signal is "TRUE";
-- Added signals for VIO probes
-- Synch In
signal ADC_Ch_A_iDelay       : std_logic_vector(4 downto 0);
signal ADC_Ch_B_iDelay       : std_logic_vector(4 downto 0);
signal ADC_CLK_iDelay       : std_logic_vector(4 downto 0);
signal SPI_Register_Data_from_FM150       : std_logic_vector(31 downto 0);
signal Busy_signal       : std_logic;
signal Busy_signal_1     : std_logic_vector(0 downto 0);
attribute mark_debug of ADC_Ch_A_iDelay: signal is "TRUE";
attribute mark_debug of ADC_Ch_B_iDelay: signal is "TRUE";
attribute mark_debug of ADC_CLK_iDelay: signal is "TRUE";
attribute mark_debug of SPI_Register_Data_from_FM150: signal is "TRUE";
attribute mark_debug of Busy_signal: signal is "TRUE";

--Synch Out
signal Set_CLK_iDelay   : std_logic_vector(4 downto 0); -- [14:10]
signal Set_CH_A_iDelay  : std_logic_vector(4 downto 0); -- [4:0]
signal Set_CH_B_iDelay  : std_logic_vector(4 downto 0); -- [9:5]
signal Register_Address : std_logic_vector(15 downto 0); -- [30:15]
signal SPI_Register_Data_to_FMC150  : std_logic_vector(31 downto 0);   --[62:31]
signal RW         : std_logic_vector(0 downto 0); --(read = 1, write = 0) [63]
signal CDCE72010  : std_logic_vector(0 downto 0); --(toggle to read/write) [64]
signal ADS62P49   : std_logic_vector(0 downto 0); -- (toggle to read/write) [65]
signal DAC3283    : std_logic_vector(0 downto 0); --(toggle to read/write) [66]
signal AMC7823    : std_logic_vector(0 downto 0); --(toggle to read/write) [67]
attribute mark_debug of Set_CLK_iDelay: signal is "TRUE";
attribute mark_debug of Set_CH_A_iDelay: signal is "TRUE";
attribute mark_debug of Set_CH_B_iDelay: signal is "TRUE";
attribute mark_debug of Register_Address: signal is "TRUE";
attribute mark_debug of SPI_Register_Data_to_FMC150: signal is "TRUE";
attribute mark_debug of RW: signal is "TRUE";
attribute mark_debug of CDCE72010: signal is "TRUE";
attribute mark_debug of ADS62P49: signal is "TRUE";
attribute mark_debug of DAC3283: signal is "TRUE";
attribute mark_debug of AMC7823: signal is "TRUE";

--  PROBE0  => dac_din_i,                            -- 16-bit
--  PROBE1  => dac_din_q,                            -- 16-bit
--  PROBE2  => baseband_out_i_sig_dly1,              -- 16-bit
--  PROBE3  => baseband_out_q_sig_dly1,              -- 16-bit
--  PROBE4  => (0 => baseband_out_valid_sig_dly1),   -- 1-bit
--  PROBE5  => (0 => adc_chb_re_mux_polarity),       -- 1-bit
--  PROBE6  => adc_dout_q_245_76_MSPS               -- 14-bit





signal ADC_cha_calibration_start       : std_logic;
signal ADC_chb_calibration_start       : std_logic;
signal ADC_cha_calibration_done        : boolean;
signal ADC_cha_calibration_done_r      : boolean;
signal ADC_cha_calibration_done_rr     : boolean;
signal ADC_chb_calibration_done        : boolean;
signal ADC_chb_calibration_done_r      : boolean;
signal ADC_chb_calibration_done_rr     : boolean;
signal ADC_chb_calibration_test_pattern_mode_command_sent : boolean;
signal ADC_cha_calibration_test_pattern_mode_command_sent : boolean;
signal ADC_chb_normal_mode_command_sent : boolean;
signal ADC_cha_normal_mode_command_sent : boolean;
signal ADC_chb_calibration_state       : std_logic_vector(2 downto 0);
signal ADC_cha_calibration_state       : std_logic_vector(2 downto 0);
signal ADC_chb_calibration_good	       : std_logic;
signal ADC_cha_calibration_good	       : std_logic;
signal ADC_calibration_good	           : std_logic;
signal ADC_chb_ready                   : boolean;
signal ADC_cha_ready                   : boolean;
signal ADC_ready                       : boolean;

signal ila_adc_cali_control	           : std_logic_vector(35 downto 0);
signal ILA_ADC_cali_data 		       : std_logic_vector(23 downto 0);
signal ILA_ADC_cali_inst_trig0         : std_logic_vector(0 downto 0);
signal ILA_ADC_cali_inst_trig1         : std_logic_vector(0 downto 0);
signal ILA_ADC_cali_inst_trig2         : std_logic_vector(0 downto 0);
signal ILA_ADC_cali_inst_trig3         : std_logic_vector(0 downto 0);

signal sysclk_buf                      : std_logic;

------------
attribute keep of ila_dac_trig0: signal is "TRUE";
attribute keep of ila_baseband_out_trig0: signal is "TRUE";
attribute keep of ila_baseband_out_trig1: signal is "TRUE";
attribute keep of ILA_ADC_cali_data: signal is "TRUE";
attribute keep of adc_dout_q_245_76_MSPS: signal is "TRUE";
attribute keep of ILA_ADC_cali_inst_trig1: signal is "TRUE";
attribute keep of ILA_ADC_cali_inst_trig2: signal is "TRUE";
---------------------
----------------------------------------------------------------------------------------------------
-- Begin
----------------------------------------------------------------------------------------------------
begin

--------------------------------------------------------------------------------------------------
-- VIO
--------------------------------------------------------------------------------------------------
--vio_inst : vio
--port map (
--    clk       => clk_100Mhz,
--    sync_in   => vio_sync_in,
--    control   => vio_control,
--    sync_out  => vio_sync_out
--);

    Busy_signal_1(0) <= Busy_signal;  
   vio_inst : vio
     PORT MAP (
       clk => clk_100Mhz,
       probe_in0 => ADC_Ch_A_iDelay,
       probe_in1 => ADC_Ch_B_iDelay,
       probe_in2 => ADC_CLK_iDelay,
       probe_in3 => SPI_Register_Data_from_FM150,
       probe_in4 => Busy_signal_1,--(0 => Busy_signal),
       probe_out0 => Set_CLK_iDelay,
       probe_out1 => Set_CH_A_iDelay,
       probe_out2 => Set_CH_B_iDelay,
       probe_out3 => Register_Address,
       probe_out4 => SPI_Register_Data_to_FMC150,
       probe_out5 => RW,
       probe_out6 => CDCE72010,
       probe_out7 => ADS62P49,
       probe_out8 => DAC3283,
       probe_out9 => AMC7823
     );


----------------------------------------------------------------------------------
-- VIO In Mapping
----------------------------------------------------------------------------------

vio_sync_in <=
  busy               & -- (47 downto 47)
  odata              & -- (46 downto 15)
  clk_cntvalueout    & -- (14 downto 10)
  chb_cntvalueout(0) & -- (09 downto 05)
  cha_cntvalueout(0);  -- (04 downto 00)

ADC_Ch_A_iDelay <= vio_sync_in(4 downto 0);
ADC_Ch_B_iDelay <= vio_sync_in(9 downto 5);
ADC_CLK_iDelay <= vio_sync_in(14 downto 10);
SPI_Register_Data_from_FM150 <= vio_sync_in(46 downto 15);
Busy_signal <= vio_sync_in(47);

vio_sync_out(14 downto 10) <= Set_CLK_iDelay;
vio_sync_out(4 downto 0) <= Set_CH_A_iDelay;
vio_sync_out(9 downto 5) <= Set_CH_B_iDelay;
vio_sync_out(30 downto 15) <= Register_Address;
-- bkf: need to swap these 16-bit words to work around CR 700077 & 700076
vio_sync_out(62 downto 31) <= SPI_Register_Data_to_FMC150;
--vio_sync_out(62 downto 47) <= SPI_Register_Data_to_FMC150(15 downto 0);
--vio_sync_out(46 downto 31) <= SPI_Register_Data_to_FMC150(31 downto 16);
--
vio_sync_out(63 downto 63) <= RW(0 downto 0);
vio_sync_out(64 downto 64) <= CDCE72010(0 downto 0);
vio_sync_out(65 downto 65) <= ADS62P49(0 downto 0);
vio_sync_out(66 downto 66) <= DAC3283(0 downto 0);
vio_sync_out(67 downto 67) <= AMC7823(0 downto 0);
--  -- Synch In
--  signal ADC_Ch_A_iDelay       : std_logic_vector(4 downto 0);
--  signal ADC_Ch_B_iDelay       : std_logic_vector(4 downto 0);
--  signal ADC_CLK_iDelay       : std_logic_vector(4 downto 0);
--  signal SPI_Register_Data_from_FM150       : std_logic_vector(31 downto 0);
--  signal Busy       : std_logic;
--  --Synch Out
--  signal Set_CLK_iDelay   : std_logic_vector(4 downto 0); -- [14:10]
--  signal Set_CH_A_iDelay  : std_logic_vector(4 downto 0); -- [4:0]
--  signal Set_CH_B_iDelay  : std_logic_vector(9 downto 0); -- [9:0]
--  signal Register_Address : std_logic_vector(15 downto 0); -- [30:15]
--  signal SPI_Register_Data_to_FMC150  : std_logic_vector(31 downto 0);   --[62:31]
--  signal RW         : std_logic; --(read = 1, write = 0) [63]
--  signal CDCE72010  : std_logic; --(toggle to read/write) [64]
--  signal ADS62P49   : std_logic; -- (toggle to read/write) [65]
--  signal DAC3283    : std_logic; --(toggle to read/write) [66]
--  signal AMC7823    : std_logic; --(toggle to read/write) [67]
----------------------------------------------------------------------------------
-- VIO Out / or incoming data received from GUI RX FIFO Mapping
----------------------------------------------------------------------------------
routing_to_SPI: process (arst, clk_100Mhz)
begin
    if (arst = '1') then
        busy_reg <= '0';
        cdce72010_valid	<= '0';
        ads62p49_valid		<= '0';
        dac3283_valid		<= '0';
        amc7823_valid		<= '0';
        cha_cntvaluein_update_vio <= vio_sync_out(4 downto 0);
        chb_cntvaluein_update_vio <= vio_sync_out(9 downto 5);
        clk_cntvaluein_update_vio <= vio_sync_out(14 downto 10);
        cha_cntvaluein_update <= conv_std_logic_vector(CHA_IDELAY, 5);
        chb_cntvaluein_update <= conv_std_logic_vector(CHB_IDELAY, 5);
        clk_cntvaluein_update <= conv_std_logic_vector(CLK_IDELAY, 5);
        ADC_chb_calibration_done_r <= FALSE;
        ADC_chb_calibration_done_rr <= FALSE;
        ADC_cha_calibration_done_r <= FALSE;
        ADC_cha_calibration_done_rr <= FALSE;
        ADC_chb_calibration_test_pattern_mode_command_sent <= FALSE;
        ADC_cha_calibration_test_pattern_mode_command_sent <= FALSE;
        ADC_chb_normal_mode_command_sent <= FALSE;
        ADC_cha_normal_mode_command_sent <= FALSE;
        ADC_chb_calibration_start <= '0';
        ADC_cha_calibration_start <= '0';
        fmc150_spi_ctrl_done_r <= '0';
        ADC_cha_ready <= FALSE;
        ADC_chb_ready <= FALSE;
        ADC_ready <= FALSE;
	elsif (rising_edge(clk_100Mhz)) then
        busy_reg <= busy;
        fmc150_spi_ctrl_done_r <= fmc150_spi_ctrl_done;
        ADC_chb_calibration_done_r <= ADC_chb_calibration_done;									-- double-register to cross from clock domain of 'ADC_auto_calibration'
        ADC_chb_calibration_done_rr <= ADC_chb_calibration_done_r;								-- where 'ADC_chb_calibration_done' is set
        ADC_cha_calibration_done_r <= ADC_cha_calibration_done;
        ADC_cha_calibration_done_rr <= ADC_cha_calibration_done_r;
		if not ADC_chb_ready then
			if not ADC_chb_calibration_done_rr then
				if not ADC_chb_calibration_test_pattern_mode_command_sent then 
					if (fmc150_spi_ctrl_done = '1' and fmc150_spi_ctrl_done_r = '0') then	-- rising edge of 'fmc150_spi_ctrl_done' indicates reset-time
																													-- initialization of FMC150 SPI devices has completed
						addr <= x"0075";
						idata <= x"00000004";																-- send SPI command to ads62p49 for test-mode / ramp pattern on Ch B
						rd_n_wr <= '0';
						ads62p49_valid <= not ads62p49_valid;											-- toggle triggers transaction with SPI device on FMC150
						ADC_chb_calibration_test_pattern_mode_command_sent <= TRUE;
					else
						ads62p49_valid <= ads62p49_valid;
						ADC_chb_calibration_test_pattern_mode_command_sent <= FALSE;					
					end if;
				else
					if (busy = '0' and busy_reg = '1') then	-- wait for falling edge of 'busy' indicating SPI port has sent command to ADS62P49 for test-mode
						ADC_chb_calibration_start <= '1'; 			-- ... ADC auto-calibration state-machine 'ADC_auto_calibration' is awaiting this event to start
					else
						ADC_chb_calibration_start <= '0';
					end if;
				end if;
			else
				if not ADC_chb_normal_mode_command_sent then
					addr <= x"0075";
					idata <= x"00000000";																	-- send SPI command to ads62p49 for normal capture mode
					rd_n_wr <= '0';
					ads62p49_valid <= not ads62p49_valid;												-- toggle triggers transaction with SPI device on FMC150
					ADC_chb_normal_mode_command_sent <= TRUE;
				else
					if (busy = '0' and busy_reg = '1') then		-- wait for falling edge of 'busy' indicating SPI port has sent command to ADS62P49 to resume normal capture mode after ADC calibration sequence
						ADC_chb_ready <= TRUE;																	-- ADC auto-calibration is done and ADS62P49 is now in normal capture mode ... allow RX FIFO to read
					else
						ADC_chb_ready <= FALSE;
					end if;
				end if;
			end if;
        elsif not ADC_cha_ready then
			if not ADC_cha_calibration_done_rr then
				if not ADC_cha_calibration_test_pattern_mode_command_sent then 
               addr <= x"0062";
					idata <= x"00000004";																-- send SPI command to ads62p49 for test-mode / ramp pattern on Ch A
					rd_n_wr <= '0';
					ads62p49_valid <= not ads62p49_valid;											-- toggle triggers transaction with SPI device on FMC150
					ADC_cha_calibration_test_pattern_mode_command_sent <= TRUE;
				else
					if (busy = '0' and busy_reg = '1') then           -- wait for falling edge of 'busy' indicating SPI port has sent command to ADS62P49 for test-mode
						ADC_cha_calibration_start <= '1';             -- ... ADC auto-calibration state-machine 'ADC_auto_calibration' is awaiting this event to start
					else
						ADC_cha_calibration_start <= '0';
					end if;
				end if;
			else
				if not ADC_cha_normal_mode_command_sent then
					addr <= x"0062";
					idata <= x"00000000";																	-- send SPI command to ads62p49 for normal capture mode
					rd_n_wr <= '0';
					ads62p49_valid <= not ads62p49_valid;												-- toggle triggers transaction with SPI device on FMC150
					ADC_cha_normal_mode_command_sent <= TRUE;
				else
					if (busy = '0' and busy_reg = '1') then		-- wait for falling edge of 'busy' indicating SPI port has sent command to ADS62P49 to resume normal capture mode after ADC calibration sequence
						ADC_cha_ready <= TRUE;																-- ADC auto-calibration is done and ADS62P49 is now in normal capture mode
                  ADC_ready <= TRUE;                                                   -- allow RX FIFO to read
					else
						ADC_cha_ready <= FALSE;
                  ADC_ready <= FALSE;
					end if;
				end if;
			end if;
		else																		        ----------------------- FMC150 SPI registers controlled by VIO
			addr					<= vio_sync_out(30 downto 15);
			idata					<= vio_sync_out(62 downto 31);
			rd_n_wr					<= vio_sync_out(63);
			cdce72010_valid		    <= vio_sync_out(64);
			ads62p49_valid			<= vio_sync_out(65);
			dac3283_valid			<= vio_sync_out(66);
			amc7823_valid			<= vio_sync_out(67);
			cha_cntvaluein_update_vio <= vio_sync_out(4 downto 0);
			chb_cntvaluein_update_vio <= vio_sync_out(9 downto 5);
			clk_cntvaluein_update_vio <= vio_sync_out(14 downto 10);
			if (cha_cntvaluein_update_vio /= vio_sync_out(4 downto 0)) then
				cha_cntvaluein_update <= vio_sync_out(4 downto 0);							-- triggers an update at process iDelay_update when user updates iDelay in VIO
			else
				cha_cntvaluein_update <= cha_cntvaluein_update;
			end if;
			if (chb_cntvaluein_update_vio /= vio_sync_out(9 downto 5)) then
				chb_cntvaluein_update <= vio_sync_out(9 downto 5);							-- triggers an update at process iDelay_update when user updates iDelay in VIO
			else
				chb_cntvaluein_update <= chb_cntvaluein_update;
			end if;
			if (clk_cntvaluein_update_vio /= vio_sync_out(14 downto 10)) then
				clk_cntvaluein_update <= vio_sync_out(14 downto 10);						-- triggers an update at process iDelay_update when user updates iDelay in VIO
			else
				clk_cntvaluein_update <= clk_cntvaluein_update;
			end if;
		end if;
	end if;
end process routing_to_SPI;

----------------------------------------------------------------------------------
-- Update iDelay values for incoming ADC data, clock
----------------------------------------------------------------------------------

iDelay_update: process (arst, clk_122_88MHz)
begin
    if (arst = '1') then
        iDelay_INC_cha_r   <= '0';
        iDelay_INC_chb_r   <= '0';
        idelay_LD_cha      <= '0';
        idelay_LD_chb      <= '0';
        delay_update_cha   <= '0';
        delay_update_chb   <= '0';
        delay_update_clk   <= '0';
        iserdes_rst_cha    <= '0';
        iserdes_rst_chb    <= '0';
        clk_cntvaluein <= conv_std_logic_vector(CLK_IDELAY, 5);
        cha_cntvaluein <= conv_std_logic_vector(CHA_IDELAY, 5);
        chb_cntvaluein <= conv_std_logic_vector(CHB_IDELAY, 5);
        clk_cntvaluein_update_122_88MHz <= conv_std_logic_vector(CLK_IDELAY, 5);
        cha_cntvaluein_update_122_88MHz <= conv_std_logic_vector(CLK_IDELAY, 5);
        chb_cntvaluein_update_122_88MHz <= conv_std_logic_vector(CLK_IDELAY, 5);
        clk_cntvaluein_update_122_88MHz_r <= conv_std_logic_vector(CLK_IDELAY, 5);
        cha_cntvaluein_update_122_88MHz_r <= conv_std_logic_vector(CLK_IDELAY, 5);
        chb_cntvaluein_update_122_88MHz_r <= conv_std_logic_vector(CLK_IDELAY, 5);
    
    elsif (rising_edge(clk_122_88MHz)) then
        cha_cntvaluein_update_122_88MHz <= cha_cntvaluein_update;              -- re-clock from 100 Mhz clock domain to 122.88 MHz, synchronous with iDelays and iSerdes
        cha_cntvaluein_update_122_88MHz_r <= cha_cntvaluein_update_122_88MHz;
        chb_cntvaluein_update_122_88MHz <= chb_cntvaluein_update;
        chb_cntvaluein_update_122_88MHz_r <= chb_cntvaluein_update_122_88MHz;
        clk_cntvaluein_update_122_88MHz <= clk_cntvaluein_update;
        clk_cntvaluein_update_122_88MHz_r <= clk_cntvaluein_update_122_88MHz;
    
        -- Generate an delay_update pulse when one of the cntvaluein values has been changed from VIO or Simulink GUI
        if (cha_cntvaluein /= cha_cntvaluein_update_122_88MHz_r) then
            delay_update_cha   <= '1';
            delay_update_chb   <= '0';
            delay_update_clk   <= '0';
            clk_cntvaluein <= clk_cntvaluein;
            chb_cntvaluein <= chb_cntvaluein;
            cha_cntvaluein <= cha_cntvaluein_update_122_88MHz_r;
        elsif (chb_cntvaluein /= chb_cntvaluein_update_122_88MHz_r) then
            delay_update_cha   <= '0';
            delay_update_chb   <= '1';
            delay_update_clk   <= '0';
            clk_cntvaluein <= clk_cntvaluein;
            chb_cntvaluein <= chb_cntvaluein_update_122_88MHz_r;
            cha_cntvaluein <= cha_cntvaluein;
        elsif (clk_cntvaluein /= clk_cntvaluein_update_122_88MHz_r) then
            delay_update_cha   <= '0';
            delay_update_chb   <= '0';
            delay_update_clk   <= '1';
            clk_cntvaluein <= clk_cntvaluein_update_122_88MHz_r;
            chb_cntvaluein <= chb_cntvaluein;
            cha_cntvaluein <= cha_cntvaluein;
        else
            delay_update_cha   <= '0';
            delay_update_chb   <= '0';
            delay_update_clk   <= '0';
            clk_cntvaluein <= clk_cntvaluein;
            chb_cntvaluein <= chb_cntvaluein;
            cha_cntvaluein <= cha_cntvaluein;
        end if;
    
        idelay_LD_cha   <= io_rst OR delay_update_cha;             -- LD pulse to iDelay from either system reset, or from VIO, or GUI
        idelay_LD_chb   <= io_rst OR delay_update_chb;
        
        iDelay_INC_cha_r <= iDelay_INC_cha;
        iDelay_INC_chb_r <= iDelay_INC_chb;
        
        iserdes_rst_cha <= iDelay_INC_cha OR delay_update_cha;     -- assert reset pulse to iSerdes from either ADC calibration sequence, or from VIO, or GUI
        iserdes_rst_chb <= iDelay_INC_chb OR delay_update_chb;

    end if;
end process iDelay_update;

-- Differential input buffer
ibufds_inst_sysclk : ibufds
port map (
    i  => sysclk_p,
    ib => sysclk_n,
    o  => sysclk_buf
);

----------------------------------------------------------------------------------------------------
-- MMCM System Clock
----------------------------------------------------------------------------------------------------
mmcm_inst : mmcm
port map (
    clk_in1 	=> sysclk_buf,
    clk_out1  => clk_100Mhz,
    clk_out2  => clk_200Mhz,
    reset     => cpu_reset,
    locked    => mmcm_locked
);

arst <= not mmcm_locked;

----------------------------------------------------------------------------------------------------
-- Clock from ADC on FMC150 for channel A and B
----------------------------------------------------------------------------------------------------

-- Differential input buffer
ibufds_inst : ibufds
generic map (
    IOSTANDARD => "LVDS_25",
    IBUF_LOW_PWR => FALSE,
    DIFF_TERM  => TRUE
)
port map (
    i  => clk_ab_p,
    ib => clk_ab_n,
    o  => clk_ab_l
);

IDELAYE2_inst_ADC_CLK : IDELAYE2
generic map (
	CINVCTRL_SEL => "FALSE",			-- Enable dynamic clock inversion (FALSE, TRUE)
	DELAY_SRC => "IDATAIN",				-- Delay input (IDATAIN, DATAIN)
	HIGH_PERFORMANCE_MODE => "TRUE",	-- Reduced jitter ("TRUE"), Reduced power ("FALSE")
	IDELAY_TYPE => "VAR_LOAD",			-- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
	IDELAY_VALUE => CLK_IDELAY,		    -- Input delay tap setting (0-31)
	PIPE_SEL => "FALSE",				-- Select pipelined mode, FALSE, TRUE
	REFCLK_FREQUENCY => 200.0,			-- IDELAYCTRL clock input frequency in MHz (190.0-210.0).
	SIGNAL_PATTERN => "CLOCK"			-- DATA, CLOCK input signal
)
port map (
	CNTVALUEOUT => clk_cntvalueout, 	-- 5-bit output: Counter value output
	DATAOUT => clk_ab_dly,         	    -- 1-bit output: Delayed data output
--	C => clk_200MHz,					-- 1-bit input: Clock input
	C => clk_122_88MHz,                 -- common clock with iSERDES to ensure load of iDelay value is synchronous to reset of iSerdes
--	CE => '0',							-- 1-bit input: Active high enable increment/decrement input
	CE => delay_update_clk,
	CINVCTRL => '0',					-- 1-bit input: Dynamic clock inversion input
	CNTVALUEIN => clk_cntvaluein,		-- 5-bit input: Counter value input
	DATAIN => '0',						-- 1-bit input: Internal delay data input
	IDATAIN => clk_ab_l,				-- 1-bit input: Data input from the I/O
	INC => '1',							-- 1-bit input: Increment / Decrement tap delay input
	LD => io_rst,					    -- 1-bit input: Load IDELAY_VALUE input
	LDPIPEEN => '0',					-- 1-bit input: Enable PIPELINE register to load data input
	REGRST => '0'						-- 1-bit input: Active-high reset tap-delay input
);

----------------------------------------------------------------------------------------------------
-- MMCM ADC / DAC Clocks
----------------------------------------------------------------------------------------------------
-- mmcm_adac_inst : mmcm_adac

mmcm_adac_inst : mmcm_adac
port map (
    clk_in1 => clk_ab_dly,
    clk_out1  => clk_15_36MHz,
    clk_out2  => clk_122_88MHz,
    clk_out3  => clk_245_76MHz,
    clk_out4  => clk_491_52MHz,
    reset     => cpu_reset,
    locked    => mmcm_adac_locked
);
----------------------------------------------------------------------------------------------------
-- Reset sequence
----------------------------------------------------------------------------------------------------
process (mmcm_adac_locked, clk_245_76MHz)
  variable cnt : integer range 0 to 1023 := 0;
begin
  if (mmcm_adac_locked = '0') then
    cnt := 0;
    rst <= '1';
	 
  elsif (rising_edge(clk_245_76MHz)) then
    -- DDC and DUC are kept in reset state for a while...
    if (cnt < 1023) then
      cnt := cnt + 1;
      rst <= '1';
		
    else
      cnt := cnt;
      rst <= '0';
		
    end if;
  end if;
end process;	
	 
process (mmcm_adac_locked, clk_122_88MHz)
  variable cnt : integer range 0 to 1023 := 0;
begin
  if (mmcm_adac_locked = '0') then

    cnt := 0;
    frame <= '0';
    txenable <= '0';

  elsif (rising_edge(clk_122_88MHz)) then

    if (cnt < 1023) then
      cnt := cnt + 1;
    else
      cnt := cnt;
    end if;
	 
    -- The iSERDES and OSERDES blocks are synchronously reset for 1 CLKDIV cycle @ 122.88 MHz ...
    if (cnt = 255) then
      io_rst <= '1';
    else
      io_rst <= '0';
    end if;

    -- Then a frame pulse is transmitted to the DAC...
    if (cnt = 511) then
      frame <= '1';
    else
      frame <= '0';
    end if;

    -- Finally the TX enable for the DAC can by pulled high.
    if (cnt = 1023) then
      txenable <= '1';
    end if;

  end if;
end process;

----------------------------------------------------------------------------------------------------
-- Channel A data from ADC
----------------------------------------------------------------------------------------------------
adc_data_a: for i in 0 to 6 generate

     -- Differential input buffer with termination (LVDS)
    ibufds_inst : ibufds
    generic map (
        IOSTANDARD => "LVDS_25",
        IBUF_LOW_PWR => FALSE,
        DIFF_TERM  => TRUE
    )
    port map (
        i  => cha_p(i),
        ib => cha_n(i),
        o  => cha_ddr(i)
    );

    IDELAYE2_inst_ADC_ch_A : IDELAYE2
    generic map (
        CINVCTRL_SEL => "FALSE",            -- Enable dynamic clock inversion (FALSE, TRUE)
        DELAY_SRC => "IDATAIN",             -- Delay input (IDATAIN, DATAIN)
        HIGH_PERFORMANCE_MODE => "TRUE",    -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
        IDELAY_TYPE => "VAR_LOAD",          -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
        IDELAY_VALUE => CHA_IDELAY,     	-- Input delay tap setting (0-31)
        PIPE_SEL => "FALSE",                -- Select pipelined mode, FALSE, TRUE
        REFCLK_FREQUENCY => 200.0,          -- IDELAYCTRL clock input frequency in MHz (190.0-210.0).
        SIGNAL_PATTERN => "DATA"            -- DATA, CLOCK input signal
    )
    port map (
        CNTVALUEOUT => cha_cntvalueout(i),	-- 5-bit output: Counter value output
        DATAOUT => cha_ddr_dly(i),			-- 1-bit output: Delayed data output
        --      C => clk_200MHz,            -- 1-bit input: Clock input
        C => clk_122_88MHz,                 -- common clock with iSERDES to ensure load of iDelay value is synchronous to reset of iSerdes
        CE => iDelay_INC_cha_r,             -- 1-bit input: Active high enable increment/decrement input
        CINVCTRL => '0',				    -- 1-bit input: Dynamic clock inversion input
        CNTVALUEIN => cha_cntvaluein,		-- 5-bit input: Counter value input
        DATAIN => '0',						-- 1-bit input: Internal delay data input
        IDATAIN => cha_ddr(i),				-- 1-bit input: Data input from the I/O
        INC => '1',							-- 1-bit input: Increment / Decrement tap delay input
        LD => idelay_LD_cha,                -- 1-bit input: Load IDELAY_VALUE input
        LDPIPEEN => '0',					-- 1-bit input: Enable PIPELINE register to load data input
        REGRST => '0'						-- 1-bit input: Active-high reset tap-delay input
    );
	
    ISERDESE2_adc_cha : ISERDESE2
    generic map (
        DATA_RATE => "DDR",           		-- DDR, SDR
        DATA_WIDTH => 4,              		-- Parallel data width (2-8,10,14)
        DYN_CLKDIV_INV_EN => "TRUE",		-- Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
        DYN_CLK_INV_EN => "FALSE",			-- Enable DYNCLKINVSEL inversion (FALSE, TRUE)
        -- INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
        INIT_Q1 => '0',
        INIT_Q2 => '0',
        INIT_Q3 => '0',
        INIT_Q4 => '0',
        INTERFACE_TYPE => "NETWORKING",		-- MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
        IOBDELAY => "IFD",					-- NONE, BOTH, IBUF, IFD
        NUM_CE => 1,						-- Number of clock enables (1,2)
        OFB_USED => "FALSE",				-- Select OFB path (FALSE, TRUE)
        SERDES_MODE => "MASTER",			-- MASTER, SLAVE
        -- SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
        SRVAL_Q1 => '0',
        SRVAL_Q2 => '0'
        --      SRVAL_Q3 => '0',
        --      SRVAL_Q4 => '0' 
    )
    port map (
        --      O => O,                       	-- 1-bit output: Combinatorial output
        --      Q1 - Q8: 1-bit (each) output: Registered data outputs
        Q1 	=> cha_sdr_sample1(2*i + 1),
        Q2 	=> cha_sdr_sample1(2*i),
        Q3 	=> cha_sdr_sample0(2*i + 1),
        Q4 	=> cha_sdr_sample0(2*i),
        --      Q5 => Q5,
        --      Q6 => Q6,
        --      Q7 => Q7,
        --      Q8 => Q8,
        --      SHIFTOUT1-SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
        --      SHIFTOUT1 => SHIFTOUT1,
        --      SHIFTOUT2 => SHIFTOUT2,
        BITSLIP => '0',             -- 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
                                    -- CLKDIV when asserted (active High). Subsequently, the data seen on the
                                    -- Q1 to Q8 output ports will shift, as in a barrel-shifter operation, one
                                    -- position every time Bitslip is invoked (DDR operation is different from SDR).
        
        -- CE1, CE2: 1-bit (each) input: Data register clock enable inputs
        CE1 => '1',
        CE2 => '0',
        CLKDIVP => '0',           		-- 1-bit input: TBD
        -- Clocks: 1-bit (each) input: ISERDESE2 clock input ports
        CLK => clk_245_76MHz,		    -- 1-bit input: High-speed clock
        CLKB => clk_245_76MHz_1,--not clk_245_76MHz,		-- 1-bit input: High-speed secondary clock
        CLKDIV => clk_122_88MHz,		-- 1-bit input: Divided clock
        OCLK => '0',                 	-- 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
        -- Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
        DYNCLKDIVSEL => '0',			-- 1-bit input: Dynamic CLKDIV inversion
        DYNCLKSEL => '0',				-- 1-bit input: Dynamic CLK/CLKB inversion
        -- Input Data: 1-bit (each) input: ISERDESE2 data input ports
        D => '0',						-- 1-bit input: Data input
        DDLY => cha_ddr_dly(i),			-- 1-bit input: Serial data from IDELAYE2
        OFB => '0',                     -- 1-bit input: Data feedback from OSERDESE2
        OCLKB => '0',					-- 1-bit input: High speed negative edge output clock
        RST => iserdes_rst_cha,         -- The iSERDES is synchronously reset for 1 CLKDIV cycle @ 122.88 MHz ...
        -- SHIFTIN1-SHIFTIN2: 1-bit (each) input: Data width expansion input ports
        SHIFTIN1 => '0',
        SHIFTIN2 => '0' 
    );
	clk_245_76MHz_1 <= not clk_245_76MHz;
end generate;

----------------------------------------------------------------------------------------------------
-- Channel B data from ADC
----------------------------------------------------------------------------------------------------
adc_data_b: for i in 0 to 6 generate

    -- Differantial input buffer with termination (LVDS)
    ibufds_inst : ibufds
    generic map (
        IOSTANDARD => "LVDS_25",
        IBUF_LOW_PWR => FALSE,
        DIFF_TERM  => TRUE
    )
    port map (
        i  => chb_p(i),
        ib => chb_n(i),
        o  => chb_ddr(i)
    );

    IDELAYE2_inst_ADC_ch_B : IDELAYE2
    generic map (
        CINVCTRL_SEL => "FALSE",            -- Enable dynamic clock inversion (FALSE, TRUE)
        DELAY_SRC => "IDATAIN",             -- Delay input (IDATAIN, DATAIN)
        HIGH_PERFORMANCE_MODE => "TRUE",    -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
        IDELAY_TYPE => "VAR_LOAD",          -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
        IDELAY_VALUE => CHB_IDELAY,     	-- Input delay tap setting (0-31)
        PIPE_SEL => "FALSE",                -- Select pipelined mode, FALSE, TRUE
        REFCLK_FREQUENCY => 200.0,          -- IDELAYCTRL clock input frequency in MHz (190.0-210.0).
        SIGNAL_PATTERN => "DATA"            -- DATA, CLOCK input signal
    )
    port map (
        CNTVALUEOUT => chb_cntvalueout(i), 	-- 5-bit output: Counter value output
        DATAOUT => chb_ddr_dly(i),         	-- 1-bit output: Delayed data output
        --      C => clk_200MHz,			-- 1-bit input: Clock input
        C => clk_122_88MHz,                 -- common clock with iSERDES to ensure load of iDelay value is synchronous to reset of iSerdes
        CE => iDelay_INC_chb_r,				-- 1-bit input: Active high enable increment/decrement input
        CINVCTRL => '0',					-- 1-bit input: Dynamic clock inversion input
        CNTVALUEIN => chb_cntvaluein,		-- 5-bit input: Counter value input
        DATAIN => '0',						-- 1-bit input: Internal delay data input
        IDATAIN => chb_ddr(i),				-- 1-bit input: Data input from the I/O
        INC => '1',							-- 1-bit input: Increment / Decrement tap delay input
        LD => idelay_LD_chb,        	    -- 1-bit input: Load IDELAY_VALUE input
        LDPIPEEN => '0',					-- 1-bit input: Enable PIPELINE register to load data input
        REGRST => '0'						-- 1-bit input: Active-high reset tap-delay input
    );

    ISERDESE2_adc_chb : ISERDESE2
    generic map (
        DATA_RATE => "DDR",					-- DDR, SDR
        DATA_WIDTH => 4,					-- Parallel data width (2-8,10,14)
        DYN_CLKDIV_INV_EN => "TRUE",		-- Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
        DYN_CLK_INV_EN => "TRUE",			-- Enable DYNCLKINVSEL inversion (FALSE, TRUE)
        -- INIT_Q1 - INIT_Q4:               -- Initial value on the Q outputs (0/1)
        INIT_Q1 => '0',
        INIT_Q2 => '0',
        INIT_Q3 => '0',
        INIT_Q4 => '0',
        INTERFACE_TYPE => "NETWORKING",		-- MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
        IOBDELAY => "IFD",					-- NONE, BOTH, IBUF, IFD
        NUM_CE => 1,						-- Number of clock enables (1,2)
        OFB_USED => "FALSE",          		-- Select OFB path (FALSE, TRUE)
        SERDES_MODE => "MASTER",      		-- MASTER, SLAVE
        -- SRVAL_Q1 - SRVAL_Q4:             -- Q output values when SR is used (0/1)
        SRVAL_Q1 => '0',
        SRVAL_Q2 => '0'
--      SRVAL_Q3 => '0',
--      SRVAL_Q4 => '0' 
    )
    port map (
--      O => O,                       		-- 1-bit output: Combinatorial output
--      Q1 - Q8: 1-bit (each) output: Registered data outputs
        Q1 	=> chb_sdr_sample1(2*i + 1),
        Q2 	=> chb_sdr_sample1(2*i),
        Q3 	=> chb_sdr_sample0(2*i + 1),
        Q4 	=> chb_sdr_sample0(2*i),
--      Q5 => Q5,
--      Q6 => Q6,
--      Q7 => Q7,
--      Q8 => Q8,
--      SHIFTOUT1-SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
--      SHIFTOUT1 => SHIFTOUT1,
--      SHIFTOUT2 => SHIFTOUT2,
        BITSLIP => '0',             -- 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
                                    -- CLKDIV when asserted (active High). Subsequently, the data seen on the
                                    -- CLKDIV when asserted (active High). Subsequently, the data seen on the
                                    -- Q1 to Q8 output ports will shift, as in a barrel-shifter operation, one
                                    -- position every time Bitslip is invoked (DDR operation is different from SDR).

        -- CE1, CE2: 1-bit (each) input: Data register clock enable inputs
        CE1 => '1',
        CE2 => '0',
        CLKDIVP => '0',                 -- 1-bit input: TBD
        -- Clocks: 1-bit (each) input: ISERDESE2 clock input ports
        CLK => clk_245_76MHz,		    -- 1-bit input: High-speed clock
        CLKB => clk_245_76MHz_2,-- not clk_245_76MHz,	    -- 1-bit input: High-speed secondary clock
        CLKDIV => clk_122_88MHz,		-- 1-bit input: Divided clock
        OCLK => '0',                 	-- 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
        -- Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
        DYNCLKDIVSEL => '0',			-- 1-bit input: Dynamic CLKDIV inversion
        DYNCLKSEL => '0',				-- 1-bit input: Dynamic CLK/CLKB inversion
        -- Input Data: 1-bit (each) input: ISERDESE2 data input ports
        D => '0',						-- 1-bit input: Data input
        DDLY => chb_ddr_dly(i),		    -- 1-bit input: Serial data from IDELAYE2
        OFB => '0',                     -- 1-bit input: Data feedback from OSERDESE2
        OCLKB => '0',					-- 1-bit input: High speed negative edge output clock
        RST => iserdes_rst_chb,         -- The iSERDES is synchronously reset for 1 CLKDIV cycle @ 122.88 MHz ...
        -- SHIFTIN1-SHIFTIN2: 1-bit (each) input: Data width expansion input ports
        SHIFTIN1 => '0',
        SHIFTIN2 => '0' 
   );
   clk_245_76MHz_2 <= not clk_245_76MHz;
end generate;

----------------------------------------------------------------------------------------------------
-- Re-clock dual 122.88 MSPS aligned output streams from iSERDES to 245.76 MHz clock domain
----------------------------------------------------------------------------------------------------
	process (clk_245_76MHz)
	begin
		if falling_edge(clk_245_76MHz) then
			if (mmcm_adac_locked = '0') then
				adc_dout_122_88_MSPS_valid <= '0';
			else
				adc_dout_122_88_MSPS_valid <= not adc_dout_122_88_MSPS_valid; -- make valid pulse to accompany 2 aligned ADC sample streams decimated by 2 @ 122.88 MSPS
			end if;
		end if;
	end process;
	
	process (clk_245_76MHz)
	begin
		if rising_edge(clk_245_76MHz) then
			if adc_dout_122_88_MSPS_valid = '1' then
				cha_sdr_sample0_re_clocked <= cha_sdr_sample0;
				cha_sdr_sample1_re_clocked <= cha_sdr_sample1;
				chb_sdr_sample0_re_clocked <= chb_sdr_sample0;
				chb_sdr_sample1_re_clocked <= chb_sdr_sample1;
			end if;
		end if;
	end process;

----------------------------------------------------------------------------------------------------
-- Re-mux to 245.76 MHz the 2 aligned ADC sample streams decimated by 2 @ 122.88 MSPS at output of ISERDES
-- to provide to the user a choice of:
-- -- re-mux'd 245.76 MSPS signals
--    or
-- -- 2 aligned sample streams decimated by 2 @ 122.88 MSPS
-- -- ... ideal for custom polyhase 2X decimation filter
----------------------------------------------------------------------------------------------------
process (clk_245_76MHz)
begin
    if rising_edge(clk_245_76MHz) then
        if (mmcm_adac_locked = '1') then
            adc_dout_245_76_MSPS_valid <= '1';  -- make valid pulse to accompany re-mux'd 245.76 MSPS ADC samples
            if (clk_245_76MHz_count = '0') then
                if adc_cha_re_mux_polarity = '0' then
                    adc_dout_i_245_76_MSPS <= cha_sdr_sample0;
                else
                    adc_dout_i_245_76_MSPS <= cha_sdr_sample1;
                end if;
                if adc_chb_re_mux_polarity = '0' then
                    adc_dout_q_245_76_MSPS <= chb_sdr_sample0;
                else
                    adc_dout_q_245_76_MSPS <= chb_sdr_sample1;
                end if;
                clk_245_76MHz_count <= '1';
            elsif (clk_245_76MHz_count = '1') then
                if adc_cha_re_mux_polarity = '0' then
                    adc_dout_i_245_76_MSPS <= cha_sdr_sample1;
                else
                    adc_dout_i_245_76_MSPS <= cha_sdr_sample0;
                end if;
                if adc_chb_re_mux_polarity = '0' then
                    adc_dout_q_245_76_MSPS <= chb_sdr_sample1;
                else
                    adc_dout_q_245_76_MSPS <= chb_sdr_sample0;
                end if;
                clk_245_76MHz_count <= '0';
            end if;
        else
            clk_245_76MHz_count <= '0';
            adc_dout_245_76_MSPS_valid <= '0';  -- make valid pulse to accompany re-mux'd 245.76 MSPS ADC samples
        end if;
        
        if (adc_dout_245_76_MSPS_valid = '1') then		
            adc_dout_i <= adc_dout_i_245_76_MSPS & "00";
            adc_dout_q <= adc_dout_q_245_76_MSPS & "00";
        else
            adc_dout_i <= adc_dout_i;
            adc_dout_q <= adc_dout_q;
        end if;
    end if;
end process;

------------------------------------------------------------------------------------
---- ILA for monitor of ADC calibration
------------------------------------------------------------------------------------

--ILA_ADC_cali_inst : ILA_ADC_cali
--  port map (
--   CONTROL => ila_adc_cali_control,
--    CLK => clk_245_76Mhz,
--    DATA => ILA_ADC_cali_data,  
--    TRIG0 => ILA_ADC_cali_inst_trig0,
--    TRIG1 => ILA_ADC_cali_inst_trig1,
--    TRIG2 => ILA_ADC_cali_inst_trig2,
--    TRIG3 => ILA_ADC_cali_inst_trig3);

    ILA_ADC_cali_inst_trig0(0) <= ADC_cha_calibration_state(0);
    ILA_ADC_cali_inst_trig1(0) <= ADC_cha_calibration_state(1);
    ILA_ADC_cali_inst_trig2(0) <= ADC_cha_calibration_state(2);
    ILA_ADC_cali_inst_trig3(0) <= iDelay_INC_cha;
	 
--	ILA_ADC_cali_data <= adc_dout_i_245_76_MSPS & ADC_cha_calibration_state & cha_cntvalueout(0) & iDelay_INC_cha & adc_cha_re_mux_polarity;

----------------------------------------------------------------------------------
-- ADC calibration Channel B
----------------------------------------------------------------------------------
ADC_auto_calibration_chB: ADC_auto_calibration
    generic map(
        MAX_PATTERN_CNT => MAX_PATTERN_CNT,
        INIT_IDELAY => CHB_IDELAY
    )
    Port map( reset => arst,
        clk => clk_245_76Mhz,
        ADC_calibration_start => ADC_chb_calibration_start,
        ADC_data => adc_dout_q_245_76_MSPS,
        re_mux_polarity => adc_chb_re_mux_polarity,
        iDelay_INC => iDelay_INC_chb,
        ADC_calibration_state => ADC_chb_calibration_state,
        ADC_calibration_done => ADC_chb_calibration_done,
        ADC_calibration_good => ADC_chb_calibration_good);

----------------------------------------------------------------------------------
-- ADC calibration Channel A
----------------------------------------------------------------------------------

ADC_auto_calibration_chA: ADC_auto_calibration
    generic map(
        MAX_PATTERN_CNT => MAX_PATTERN_CNT,
        INIT_IDELAY => CHA_IDELAY
	)
    Port map( reset => arst,
        clk => clk_245_76Mhz,
        ADC_calibration_start => ADC_cha_calibration_start,
        ADC_data => adc_dout_i_245_76_MSPS,
        re_mux_polarity => adc_cha_re_mux_polarity,
        iDelay_INC => iDelay_INC_cha,
        ADC_calibration_state => ADC_cha_calibration_state,
        ADC_calibration_done => ADC_cha_calibration_done,
        ADC_calibration_good => ADC_cha_calibration_good);

----------------------------------------------------------------------------------------------------
-- DAC Reference Clock Input
----------------------------------------------------------------------------------------------------
-- clk_to_fpga_p/n is an additional LVDS clock from the CDCE72010, but currently not used in this
-- reference design. This additional clock might be used in applications where the ADC is not used
-- and a reference clock for the DAC is required.
----------------------------------------------------------------------------------------------------
--ibufds_ref_clk : ibufds
--generic map (
--  IOSTANDARD => "LVDS_25",
--  DIFF_TERM => TRUE
--)
--port map (
--  i  => clk_to_fpga_p,
--  ib => clk_to_fpga_n,
--  o  => clk_to_fpga
--);

----------------------------------------------------------------------------------------------------
-- Output serdes and LVDS buffer for DAC clock
----------------------------------------------------------------------------------------------------
oserdes_clock : oserdes
generic map (
  DATA_RATE_OQ => "DDR",
  DATA_RATE_TQ => "DDR",
  DATA_WIDTH => 4,
  INIT_OQ => '0',
  INIT_TQ => '0',
  SERDES_MODE => "MASTER",
  SRVAL_OQ => '0',
  SRVAL_TQ => '0',
  TRISTATE_WIDTH => 1
)
port map (
  oq        => dac_dclk_prebuf,
  shiftout1 => open,
  shiftout2 => open,
  tq        => open,
  clk       => clk_491_52MHz,
  clkdiv    => clk_245_76MHz,
  d1        => '1',
  d2        => '0',
  d3        => '1',
  d4        => '0',
  d5        => '0',
  d6        => '0',
  oce       => '1',
  rev       => '0',
  shiftin1  => '0',
  shiftin2  => '0',
  sr        => io_rst,
  t1        => '0',
  t2        => '0',
  t3        => '0',
  t4        => '0',
  tce       => '0'
);

--output buffer
obufds_clock : obufds_lvds_25
port map (
  i  => dac_dclk_prebuf,
  o  => dac_dclk_p,
  ob => dac_dclk_n
);

----------------------------------------------------------------------------------------------------
-- Output serdes and LVDS buffers for DAC data
----------------------------------------------------------------------------------------------------
dac_data: for i in 0 to 7 generate

  --oserdes in data path
  oserdes_data : oserdes
  generic map (
    DATA_RATE_OQ => "DDR",
    DATA_RATE_TQ => "DDR",
    DATA_WIDTH => 4,
    INIT_OQ => '0',
    INIT_TQ => '0',
    SERDES_MODE => "MASTER",
    SRVAL_OQ => '0',
    SRVAL_TQ => '0',
    TRISTATE_WIDTH => 1
  )
  port map (
    oq        => dac_data_prebuf(i),
    shiftout1 => open,
    shiftout2 => open,
    tq        => open,
    clk       => clk_491_52MHz,
    clkdiv    => clk_245_76MHz,
    d1        => dac_din_i(i + 8),
    d2        => dac_din_i(i),
    d3        => dac_din_q(i + 8),
    d4        => dac_din_q(i),
    d5        => '0',
    d6        => '0',
    oce       => '1',
    rev       => '0',
    shiftin1  => '0',
    shiftin2  => '0',
    sr        => io_rst,
    t1        => '0',
    t2        => '0',
    t3        => '0',
    t4        => '0',
    tce       => '0'
  );

  --output buffers
  obufds_data : obufds_lvds_25
  port map (
    i  => dac_data_prebuf(i),
    o  => dac_data_p(i),
    ob => dac_data_n(i)
  );

end generate;

----------------------------------------------------------------------------------------------------
-- Output serdes and LVDS buffer for DAC frame
----------------------------------------------------------------------------------------------------
oserdes_frame : oserdes
generic map (
  DATA_RATE_OQ => "DDR",
  DATA_RATE_TQ => "DDR",
  DATA_WIDTH => 4,
  INIT_OQ => '0',
  INIT_TQ => '0',
  SERDES_MODE => "MASTER",
  SRVAL_OQ => '0',
  SRVAL_TQ => '0',
  TRISTATE_WIDTH => 1
)
port map (
  oq        => dac_frame_prebuf,
  shiftout1 => open,
  shiftout2 => open,
  tq        => open,
  clk       => clk_491_52MHz,
  clkdiv    => clk_245_76MHz,
  d1        => frame,
  d2        => frame,
  d3        => frame,
  d4        => frame,
  d5        => '0',
  d6        => '0',
  oce       => '1',
  rev       => '0',
  shiftin1  => '0',
  shiftin2  => '0',
  sr        => io_rst,
  t1        => '0',
  t2        => '0',
  t3        => '0',
  t4        => '0',
  tce       => '0'
);

--output buffer
obufds_frame : obufds_lvds_25
port map (
  i  => dac_frame_prebuf,
  o  => dac_frame_p,
  ob => dac_frame_n
);

----------------------------------------------------------------------------------------------------
-- Configuring the FMC150 card
----------------------------------------------------------------------------------------------------
-- the fmc150_spi_ctrl component configures the devices on the FMC150 card through the Serial
-- Peripheral Interfaces (SPI) and some additional direct control signals.
----------------------------------------------------------------------------------------------------
fmc150_spi_ctrl_inst : fmc150_spi_ctrl
port map (
  odata           => odata,

  addr            => addr,
  idata           => idata,
  rd_n_wr         => rd_n_wr,
  cdce72010_valid => cdce72010_valid,
  ads62p49_valid  => ads62p49_valid,
  dac3283_valid   => dac3283_valid,
  amc7823_valid   => amc7823_valid,

  busy            => busy,

  external_clock  => external_clock,

  rst             => arst,
  clk             => clk_100MHz,
  spi_sclk        => spi_sclk,
  spi_sdata       => spi_sdata,
  adc_n_en        => adc_n_en,
  adc_sdo         => adc_sdo,
  adc_reset       => adc_reset,
  cdce_n_en       => cdce_n_en,
  cdce_sdo        => cdce_sdo,
  cdce_n_reset    => cdce_n_reset,
  cdce_n_pd       => cdce_n_pd,
  ref_en          => ref_en,
  pll_status      => pll_status,
  dac_n_en        => dac_n_en,
  dac_sdo         => dac_sdo,
  mon_n_en        => mon_n_en,
  mon_sdo         => mon_sdo,
  mon_n_reset     => mon_n_reset,
  mon_n_int       => mon_n_int,
  prsnt_m2c_l     => prsnt_m2c_l,
  init_amc7823_done => fmc150_spi_ctrl_done
);

----------------------------------------------------------------------------------------------------
-- Connect entity
----------------------------------------------------------------------------------------------------

gpio_led(0) <= digital_mode;
gpio_led(1) <= adc_out_dac_in;
gpio_led(2) <= external_clock;
gpio_led(3) <= ddc_duc_bypass;
gpio_led(4) <= pll_status;
gpio_led(5) <= mmcm_adac_locked;
gpio_led(6) <= mmcm_locked;
gpio_led(7) <= ADC_calibration_good;

ADC_calibration_good <= ADC_chb_calibration_good AND ADC_cha_calibration_good;

gpio_led_c <= gpio_sw_c;
gpio_led_e <= gpio_sw_e;
gpio_led_n <= gpio_sw_n;
gpio_led_s <= gpio_sw_s;
gpio_led_w <= gpio_sw_w;

digital_mode   <= gpio_dip_sw(0);
adc_out_dac_in <= gpio_dip_sw(1);
external_clock <= gpio_dip_sw(2);
ddc_duc_bypass <= gpio_dip_sw(3);

----------------------------------------------------------------------------------------------------
-- IDELAYCTRL
----------------------------------------------------------------------------------------------------
idelayctrl_inst : idelayctrl
port map (
  rst    => arst,
  refclk => clk_200Mhz,
  rdy    => open
);

------------------------------------------------------------------------------------------------------
---- DUC / DDC
------------------------------------------------------------------------------------------------------
--	DUC 16X interpolationm
-- 	4 stages of FIR Compiler	(491.52 MHz clock domain)
--		FIFO to cross clock domains
--    complex mixer:					(245.76 MHz clock domain)
--			DDS for I/F generation
--			complex multipler
-- DDC 8X decimation
--		3 stages of FIR Compiler	(491.52 MHz clock domain)
--		FIFO to cross clock domains
--    complex mixer:					(245.76 MHz clock domain)
--			DDS for I/F generation
--			complex multipler
-- Also contains hardware-based sin/cos wave generator DDS and impulse generator as test signals
--

DUC_DDC_inst: DUC_DDC
port map(
	clock           		=> clk_491_52mhz,
	clock1           		=> clk_245_76mhz,
	clock2					=> clk_15_36mhz,
	reset						=> rst,
	if_freq					=> x"0000000",							-- unused / placeholder for I/F frequency for complex mixer
	baseband_in_i			=> "0000000000000000",				-- stub for baseband-side input to duc
	baseband_in_q			=> "0000000000000000",
	baseband_in_valid		=> '0',
	if_in_i					=> adc_dout_i,              		-- i/f-side dual output streams of adc data from iserdes @ 122.88 msps, re-mux'd to 245.76 msps, extended to 16-bits
	if_in_q					=> adc_dout_q,              		-- i/f-side dual output streams of adc data from iserdes @ 122.88 msps, re-mux'd to 245.76 msps, extended to 16-bits
	if_in_valid				=> adc_dout_245_76_MSPS_valid,	-- data_valid pulse accompanies re-mux'd 245.76 msps data towards ddc

	if_out_i					=> DUC_if_out_i,							-- i data to dac, 16-bit
	if_out_q					=> DUC_if_out_q,							-- q data to dac, 16-bit,
--	duc_out_valid														-- data_valid pulse accompanies dac data driven out from fpga @ 245.76 msps, dac3283 set for 2x interpolation in the dac
																			-- at 245.76 msps, this data_valid is a constant '1', included here for completeness
	baseband_out_i			=> baseband_out_i_sig,				-- baseband-side output of ddc (245.76 MHz clock domain)
	baseband_out_q			=> baseband_out_q_sig,
	baseband_out_valid	=> baseband_out_valid_sig,
	duc_dcc_route_ctrl	=> duc_dcc_route_ctrl_sig,			-- control of various mux'es within duc_ddc module
	test_mode				=> '1',									-- set to '1' for test_mode to select dds or impulse, set to '0' to select baseband-side input to duc
	gpio_sw_c				=> gpio_sw_c							-- gpio on baseboard triggers impulse generator
);

duc_dcc_route_ctrl_sig(0) 	<= digital_mode;
duc_dcc_route_ctrl_sig(1) 	<= adc_out_dac_in;
duc_dcc_route_ctrl_sig(2) 	<= ddc_duc_bypass;
  
----------------------------------------------------------------------------------------------------
-- ICON
----------------------------------------------------------------------------------------------------

--icon_inst : icon_v1_06_a_0
--port map (
--  control0 => vio_control
----  control1 => ila_baseband_out_control,
----  control2 => ila_dac_control,
----  control3 => ila_adc_cali_control
--);

------------------------------------------------------------------------------------
---- ILA for monitor of ADC calibration
------------------------------------------------------------------------------------
--
--ILA_ADC_cali_inst : ILA_ADC_cali
--  port map (
--    CONTROL => ila_adc_cali_control,
--    CLK => clk_245_76Mhz,
--    DATA => ILA_ADC_cali_data,  
--    TRIG0 => adc_dout_q_245_76_MSPS,
--    TRIG1 => ILA_ADC_cali_inst_trig1,
--    TRIG2 => ILA_ADC_cali_inst_trig2);
--	 
--	 ILA_ADC_cali_inst_trig1(0) <= ADC_chb_trace_edge;
--	 ILA_ADC_cali_inst_trig2(0) <= delay_update;
--	 ILA_ADC_cali_data <= adc_dout_q_245_76_MSPS & ADC_chb_calibration_state & chb_cntvaluein & delay_update & adc_chb_re_mux_polarity;

----------------------------------------------------------------------------------------------------
-- ILA Baseband Out
----------------------------------------------------------------------------------------------------
--ila_baseband_out_inst : ila_baseband_out
--port map (
--  clk     => clk_245_76MHz,
--  trig0   => ila_baseband_out_trig0,
--  trig1   => ila_baseband_out_trig1,
--  control => ila_baseband_out_control
--);
--
-- ila_baseband_out_trig0 <= baseband_out_q_sig_dly1 & baseband_out_i_sig_dly1;
-- ila_baseband_out_trig1(0) <= baseband_out_valid_sig_v_dly1;


register_to_ILA: process (clk_245_76MHz)
begin
  if rising_edge(clk_245_76MHz) then
		baseband_out_valid_sig_dly1 <= baseband_out_valid_sig;
		if baseband_out_valid_sig_dly1 = '1' then
		baseband_out_i_sig_dly1 <= baseband_out_i_sig;
		baseband_out_q_sig_dly1 <= baseband_out_q_sig;
		end if;
  end if;
end process register_to_ILA;

----------------------------------------------------------------------------------------------------
-- Register DAC data out of DUC
----------------------------------------------------------------------------------------------------
DAC_re_clock_to_245_76_MHz: process (clk_245_76MHz)
begin
	if (rising_edge(clk_245_76MHz)) then
		dac_din_i <= DUC_if_out_i;
		dac_din_q <= DUC_if_out_q;
	end if;
end process DAC_re_clock_to_245_76_MHz;

----------------------------------------------------------------------------------------------------
-- ILA DAC to monitor digital data driven to DAC3283
----------------------------------------------------------------------------------------------------

--ila_dac_inst : ila_dac
--port map (
--  clk     => clk_245_76MHz,
--  trig0   => ila_dac_trig0,
--  control => ila_dac_control
--);

ila_dac_baseband_ADC : ila
  PORT MAP (
    clk     => clk_245_76MHz,
    probe0  => dac_din_i,                            -- 16-bit
    probe1  => dac_din_q,                            -- 16-bit
    probe2  => baseband_out_i_sig_dly1,              -- 16-bit
    probe3  => baseband_out_q_sig_dly1,              -- 16-bit
    probe4  => baseband_out_valid_sig_dly1_1,--(0 => baseband_out_valid_sig_dly1),   -- 1-bit
    probe5  => adc_chb_re_mux_polarity_1,--(0 => adc_chb_re_mux_polarity),       -- 1-bit
    probe6  => adc_dout_i_245_76_MSPS               -- 14-bit
   );
    baseband_out_valid_sig_dly1_1(0) <= baseband_out_valid_sig_dly1;
    adc_chb_re_mux_polarity_1(0) <= adc_chb_re_mux_polarity;



end KC705_fmc150_syn;
