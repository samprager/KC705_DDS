-- Modified by Sam Prager
-- 5/30/2015
-- MiXIL, University of Southern Calfiornia
-- Chirp Generation using DUC_DDC.vhd

  
  --------------DDS Chirp Generation Parameters-------------------
  -- period = 4.17 us, BW = 46.08 MHz 
  -- 491.52 Mhz clock, 2048 samples, 16 bit phase accumulator (n = 16)
  -- tuning_word_coeff = 3      for BW = 46.08 MHz
  -- tuning_word_coeff = 4      for BW = 61.44 MHz
  -- Calculated Using:
  --    tuning_word_coeff = BW*(2^n)/(num_samples*fClock)
  -- Taken From:
  --    tuning_word_coeff = period*slope*(2^n)/(num_samples*fClock)  
  -- Where:
  --    slope = BW/period       
  --    num_samples = period*fclock
  --
  -- Note: Derived From:
  --    tuning_word = rect[t/period] t*slope*(2^n)/fclock
  -- And:
  --     t = sample_count*period/num_samples
  -- Therefore:
  --    tuning_word = sample_count*tuning_coeff
  -------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- FILE NAME : DUC_DDC.vhd
--
-- AUTHOR    : Luc Langlois
--
-- COMPANY   : Avnet
--
-- UNITS     : Entity       - DUC_DDC
--             architecture - DUC_DDC_syn
--
-- LANGUAGE  : VHDL
--
-- Target Device: 7K325t-2ffg900
-- Tool versions: ISE? Design Suite: System Edition 13.4 / build O.87
--
-------------------------------------------------------------------------------------
--
-- Revisions
-- Luc Langlois
--
-- Nov 4, 2011: Module created for K7 DSP Kit on KC705 Rev C + FMC150 Rev 1.0 / 13.3 build O.76
--
-- February 16, 2012 : updated to 13.4 / build O.87 with 491.52 MHz system clock, for 2X over-clocking of fastest stage with input sampling rate of 245.76 MSPS
--
-------------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- This file encapsulates DUC and DDC.
-- In most cases ...
--	IF_IN will be driven from ADC at top-level
--	IF_OUT will drive the DAC at top-level
-------------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_misc.all;
  use ieee.std_logic_unsigned.all;

entity DUC_DDC is
port (
	CLOCK           		: in std_logic;
	CLOCK1           		: in std_logic;
	CLOCK2           		: in std_logic;
	RESET           		: in std_logic;
	IF_FREQ					: in std_logic_vector(27 downto 0);
	BASEBAND_IN_I			: in std_logic_vector(15 downto 0);
	BASEBAND_IN_Q			: in std_logic_vector(15 downto 0);
	BASEBAND_IN_VALID		: in std_logic;
	IF_IN_I					: in std_logic_vector(15 downto 0);
	IF_IN_Q					: in std_logic_vector(15 downto 0);
	IF_IN_VALID				: in std_logic;

	IF_OUT_I					: out std_logic_vector(15 downto 0);
	IF_OUT_Q					: out std_logic_vector(15 downto 0);
	IF_OUT_VALID			: out std_logic;
	BASEBAND_OUT_I			: out std_logic_vector(15 downto 0);
	BASEBAND_OUT_Q			: out std_logic_vector(15 downto 0);
	BASEBAND_OUT_VALID	: out std_logic;

	DUC_DCC_ROUTE_CTRL	: in std_logic_vector(2 downto 0);
	TEST_MODE				: in std_logic;
	GPIO_SW_C				: in std_logic
);
end DUC_DDC;

architecture DUC_DDC_syn of DUC_DDC is

component ddc_umts_k7 is
port (
  resetn        : in  std_logic;
  clk           : in  std_logic;
  clk1          : in  std_logic;
  din_i         : in  std_logic_vector(15 downto 0);
  din_q         : in  std_logic_vector(15 downto 0);
  vin           : in  std_logic;
  freq          : in  std_logic_vector(27 downto 0);
  dds_vout		 : out std_logic;
  dout_i        : out std_logic_vector(15 downto 0);
  dout_q        : out std_logic_vector(15 downto 0);
  vout          : out std_logic
);
end component;

component duc_umts_k7
port (
  resetn        : in  std_logic;
  clk           : in  std_logic;
  clk1          : in  std_logic;
  din_i         : in  std_logic_vector(15 downto 0);
  din_q         : in  std_logic_vector(15 downto 0);
  vin           : in  std_logic;
  freq          : in  std_logic_vector(27 downto 0);
  dout_i        : out std_logic_vector(15 downto 0);
  dout_q        : out std_logic_vector(15 downto 0);
  dds_vout      : out std_logic;
  cmplx_mult_vout : out std_logic;
  duc_OE        : in  std_logic
);
end component;

component DDS
port (
  aclken : in std_logic;
  aclk   : in std_logic;
  m_axis_data_tvalid : out std_logic;
  m_axis_data_tdata  : out std_logic_vector(31 downto 0)
);
end component;

-- Added by SP
component SP_DDS
port (
  aclken : in std_logic;
  aclk   : in std_logic;
  s_axis_phase_tvalid : in std_logic;
  s_axis_phase_tdata: in std_logic_vector(15 downto 0);
  m_axis_data_tvalid : out std_logic;
  m_axis_data_tdata  : out std_logic_vector(31 downto 0)
);
end component;

signal clk					: std_logic;
signal clk1 				: std_logic;
signal clk2					: std_logic;
signal rst			      : std_logic;
signal freq					: std_logic_vector(27 downto 0);
signal rst_duc_ddc_n 	: std_logic :='1';
signal rst_duc_ddc_n_r 	: std_logic:='1';
signal ddc_resetn 		: std_logic;

signal if_out_i_sig		: std_logic_vector(15 downto 0);
signal if_out_q_sig		: std_logic_vector(15 downto 0);
signal if_out_valid_sig	: std_logic;

signal if_in_i_sig		: std_logic_vector(15 downto 0);
signal if_in_q_sig		: std_logic_vector(15 downto 0);
signal if_in_valid_sig	: std_logic;

signal digital_mode		: std_logic;
signal ddc_duc_bypass	: std_logic;
signal adc_out_dac_in	: std_logic;

signal ddc_din_i         : std_logic_vector(15 downto 0);
signal ddc_din_q         : std_logic_vector(15 downto 0);
signal ddc_vin           : std_logic;
signal baseband_out_i_sig    	: std_logic_vector(15 downto 0);
signal baseband_out_q_sig    	: std_logic_vector(15 downto 0);
signal baseband_out_valid_sig	: std_logic;
signal ddc_dout_i        : std_logic_vector(15 downto 0);
signal ddc_dout_q        : std_logic_vector(15 downto 0);
signal ddc_dout_i_r      : std_logic_vector(15 downto 0);
signal ddc_dout_q_r      : std_logic_vector(15 downto 0);
signal ddc_vout          : std_logic;
signal ddc_vout_r        : std_logic;

signal ddc_vout_245_76MHz	: std_logic;

signal duc_din_i         : std_logic_vector(15 downto 0);
signal duc_din_q         : std_logic_vector(15 downto 0);
signal duc_vin				 : std_logic;
signal duc_in_valid_reg	 : std_logic;
signal duc_dout_i        : std_logic_vector(15 downto 0);
signal duc_dout_q        : std_logic_vector(15 downto 0);
signal duc_vout          : std_logic;
signal duc_OE  	       : std_logic;
signal dds_reset_duc     : std_logic;

signal signal_ce         : std_logic;
signal signal_ce_prev    : std_logic;
signal signal_vout       : std_logic := '0';
signal signal_vout2      : std_logic := '0';
signal signal_vout_edge  : std_logic := '0';
signal signal_vout_edge_r  : std_logic := '0';
signal signal_vout_edge_rr : std_logic := '0';
signal signal_vout_edge_rrr : std_logic := '0';
signal signal_vout_DDS   : std_logic;

signal sine              : std_logic_vector(15 downto 0);
signal cosine            : std_logic_vector(15 downto 0);
signal dds_dout_i        : std_logic_vector(15 downto 0);
signal dds_dout_q        : std_logic_vector(15 downto 0);
signal dds_dout_i_q      : std_logic_vector(31 downto 0);

-- For Chirp---------------------------------
--signal chirp_begin : std_logic := '0';
--signal chirp_finish : std_logic := '0';
--signal chirp_busy : std_logic := '0';
signal s_axis_phase_tvalid, m_axis_data_tvalid : std_logic;
--signal phase_acc  : std_logic_vector(15 downto 0) := (others=>'0');
signal chirp_i              : std_logic_vector(15 downto 0);
signal chirp_q            : std_logic_vector(15 downto 0);
signal dds_dout_chirp_i        : std_logic_vector(15 downto 0);
signal dds_dout_chirp_q        : std_logic_vector(15 downto 0);
signal dds_dout_chirp_i_q      : std_logic_vector(31 downto 0);
signal dds_dout_chirp_phase      : std_logic_vector(15 downto 0);

-- Use if using library ieee.std_logic_unsigned.all:
signal tuning_word  :std_logic_vector(31 downto 0) := (others=>'0');
signal phase_acc_long  :std_logic_vector(31 downto 0) := (others=>'0');

-- For 2048 sample / chirp use 11 bit counter
signal chirp_count  :std_logic_vector(10 downto 0) := (others=>'0');

-- For 4096 sample / chirp use 12 bit counter
--signal chirp_count  :std_logic_vector(11 downto 0) := (others=>'0');

-- tuning word coeff = 3 for 46.08 MHz BW, and 4 for 61.44 MHz BW
constant tuning_word_coeff :std_logic_vector(31 downto 0) := (0=> '1',1=>'1',others=>'0');  
--constant tuning_word_coeff :std_logic_vector(31 downto 0) := (2=>'1',others=>'0');
-- tuning word coeff = 6
--constant tuning_word_coeff :std_logic_vector(31 downto 0) := (1=> '1',2=>'1',others=>'0'); 

-- Try doubling freq slope and number of samples. tuning word coeff = 6
--constant tuning_word_coeff :std_logic_vector(31 downto 0) := (1=>'1',2=>'1',others=>'0');

-- test tuning word coeff = 1. Note: must calculate BW
--constant tuning_word_coeff :std_logic_vector(31 downto 0) := (0=> '1',others=>'0'); 

-- Push the initial freq beyon baseband
constant freq_offset  :std_logic_vector(31 downto 0) := (10=>'1',others=>'0'); 



-- Use if using library ieee.numeric_std.all:
--signal tuning_word  :unsigned(31 downto 0) := (others=>'0');
--signal phase_acc_long  :unsigned(31 downto 0) := (others=>'0');
--signal chirp_count  :unsigned(9 downto 0) := (others=>'0');
--constant tuning_word_coeff :unsigned(31 downto 0) := (4=>'1',others=>'0');
--signal delay_count : unsigned(3 downto 0) := "0111";
--constant chirp_delay : unsigned(3 downto 0) := "0111";
-------------------------------

signal imp_dout_i        : std_logic;
signal imp_dout_i_491_52_Mhz      : std_logic;
signal imp_dout_i_491_52_Mhz_r    : std_logic;

signal debounce_rst      : std_logic:='0';
signal debounce_rst_r    : std_logic:='0';
signal debounce_rst_r15_36MHz  : std_logic:='0';
signal debounce_cnt      : std_logic_vector(15 downto 0) := (others => '0');

constant OVERCLOCK		 : integer := 2;

begin

clk <= CLOCK;
clk1 <= CLOCK1;
clk2 <= CLOCK2;
rst <= RESET;
freq <= IF_FREQ;

digital_mode	<= DUC_DCC_ROUTE_CTRL(0);
adc_out_dac_in <= DUC_DCC_ROUTE_CTRL(1);
ddc_duc_bypass <= DUC_DCC_ROUTE_CTRL(2);

if_in_i_sig 		<= IF_IN_I;
if_in_q_sig 		<= IF_IN_Q;
if_in_valid_sig 	<= IF_IN_VALID;

----------------------------------------------------------------------------------------------------
-- Signal generation
----------------------------------------------------------------------------------------------------
-- Two type of signals are generates:
--  a.  quadrature sinusoid from DDS
--  b.  impulse stimulus
--
-- System clock = 491.52 MHz
-- Baseband sampling rate = 15.36 MSPS entering the DUC
-- Therefore baseband sample duration = 32 system-clock periods
-- ADC sampling rate = 245.76 MSPS, or 1/2 system clock rate
--
----------------------------------------------------------------------------------------------------

process (clk2)
begin
	if (rising_edge(clk2)) then
	  signal_vout_edge <= not signal_vout_edge;
	end if;
end process;

process (clk)
begin
  if (rising_edge(clk)) then
	 signal_vout_edge_r <= signal_vout_edge;
	 signal_vout_edge_rr <= signal_vout_edge_r;
	 signal_vout_edge_rrr <= signal_vout_edge_rr;
	 signal_vout <= signal_vout_edge_rrr XOR signal_vout_edge_rr;		-- make data_valid pulse of 32 system clock periods
	 signal_vout2 <= signal_vout_edge_rrr XOR signal_vout_edge_rr;		-- replicate to reduce fanout
  end if;
end process;

process (clk)
  variable cnt : integer range 0 to (OVERCLOCK - 1) := 0;
begin
  if (rising_edge(clk)) then
	if (ddc_duc_bypass = '1') then		-- If DDC and DUC is bypassed
		if (adc_out_dac_in = '0') then	-- and DAC NOT driven in loopback directly from ADC
		    if (cnt = OVERCLOCK - 1 ) then
				signal_vout_DDS <= '1';		-- ... drive DDS at full 245.76 MHz and connect output of DDS directly to DAC
				cnt := 0;
			 else
				signal_vout_DDS <= '0';
				cnt := cnt + 1;
			 end if;
		else
			signal_vout_DDS <= signal_vout;
		end if;
	else
		signal_vout_DDS <= signal_vout;
	end if;
  end if;
end process;

----------------------------------------------------------------------------------
-- A) DDS generating a 50 MHz BW signal based on 491.52 MHz system clock.
----------------------------------------------------------------------------------
DDS_inst : DDS
port map (
  aclken     => signal_vout_DDS,
  aclk       => clk,
-- m_axis_data_tvalid
  m_axis_data_tdata   => dds_dout_i_q
);

dds_dout_i <= dds_dout_i_q(31 downto 16);
dds_dout_q <= dds_dout_i_q(15 downto 0);

----------------------------------------------------------------------------------
-- A) DDS generating a Chirp signal based on a 15.36 Msps sample clock.
----------------------------------------------------------------------------------
SP_DDS_inst : SP_DDS
port map (
  --aclken     => signal_vout_DDS,
  aclken        => '1',
  aclk       => clk,
 m_axis_data_tvalid => open,
  s_axis_phase_tvalid => s_axis_phase_tvalid,
  s_axis_phase_tdata => dds_dout_chirp_phase,
  m_axis_data_tdata   => dds_dout_chirp_i_q
);

m_axis_data_tvalid <= '1';
s_axis_phase_tvalid <= '1';
--dds_dout_chirp_phase <= phase_acc(15 downto 0);
dds_dout_chirp_phase <= phase_acc_long(15 downto 0);
dds_dout_chirp_i <= dds_dout_chirp_i_q(31 downto 16);
dds_dout_chirp_q <= dds_dout_chirp_i_q(15 downto 0);

----------------------------------------------------------------------------------
-- B) Impulse stimulus
----------------------------------------------------------------------------------
process(rst, clk2)
begin
  if (rst = '1') then
  
	debounce_rst <= '0';
    debounce_cnt <= "0000000001111111";
	imp_dout_i <= '0';

  elsif (rising_edge(clk2)) then			-- debounce pushbuttons with delay counter in slow clock domain (15.63 MHz) to conserve resources

      -- start of reset debounce pulse, approx. 1 second
      if (GPIO_SW_C = '1') then
        debounce_cnt <= (others => '0');
        debounce_rst <= '1';
		elsif (debounce_cnt = "0000000001111100") then
        debounce_cnt <= debounce_cnt + '1';
        debounce_rst <= '0';
      elsif (debounce_cnt < "0000000001111111") then
        debounce_cnt <= debounce_cnt + '1';
        debounce_rst <= debounce_rst;
      else
        debounce_cnt <= debounce_cnt;
        debounce_rst <= debounce_rst;
      end if;

		debounce_rst_r15_36MHz <= debounce_rst;

      -- drive impulse into real input port
      if (debounce_cnt = "0000000001111110") then
        imp_dout_i <= '1';
      else
        imp_dout_i <= '0';
      end if;
  end if;
end process;

------------------ Chirp Generation -----------------------
process (rst,clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        
       -- chirp_begin <= '0';
       -- chirp_finish <= '0';
       -- chirp_busy <= '0';
        
        chirp_count <= (others => '0');
        
        --tuning_word <= (others => '0');
        tuning_word(31 downto 0) <= freq_offset(31 downto 0);
        --phase_acc <= (others => '0');
        phase_acc_long <= (others => '0');
        
        
        chirp_i  <= (others => '0');
        chirp_q  <= (others => '0');
        
      else       
        chirp_count <= chirp_count + 1;
        phase_acc_long(31 downto 0) <= phase_acc_long(31 downto 0) + tuning_word(31 downto 0);
        
        -- if phase_acc_long is unsigned use:
       -- phase_acc(15 downto 0) <= std_logic_vector(phase_acc_long(15 downto 0));
       
       -- if phase_acc_long is std logic vector use:
       --phase_acc(15 downto 0) <= phase_acc_long(15 downto 0);
        
        chirp_i <= dds_dout_chirp_i;
        chirp_q <= dds_dout_chirp_q;
        
        if (chirp_count(10 downto 0) = "11111111111") then
        --if (chirp_count(11 downto 0) = "111111111111") then
        
            --tuning_word(31 downto 0) <= (others => '0');
            
            tuning_word(31 downto 0) <= freq_offset(31 downto 0);
            -- Push the initial freq beyon baseband
        --elsif (chirp_count(10 downto 0) = "00000000000") then  
        --elsif (chirp_count(11 downto 0) = "000000000000") then 
            --tuning_word(31 downto 0) <= freq_offset(31 downto 0); 
        else
            tuning_word(31 downto 0) <= tuning_word(31 downto 0) + tuning_word_coeff;
        end if;
              
      end if;
    end if;
  end process;

----------------------------------------------------------------------------------------------------
-- Make synchronous active-low reset in 245.76 MHz clock domain for DUC & DDC, after debounce-delay triggered by pushbutton-press
-- User can substitute their own reset-triggering event in place of signal 'debounce_rst_r15_36MHz' if needed
----------------------------------------------------------------------------------------------------

process (clk1)			
begin
  if rising_edge(clk1) then
	 debounce_rst_r <= debounce_rst_r15_36MHz;	-- synchronize reset pulse triggered from pushbutton into 245.76 MHz clock domain
	 rst_duc_ddc_n <= not debounce_rst_r;
  end if;
end process;

----------------------------------------------------------------------------------------------------
-- Signal MUX - Select data connected to input of the DUC
----------------------------------------------------------------------------------------------------
TX_mux_to_DUC: process (clk)
begin
  if (rising_edge(clk)) then
		if (signal_vout2) = '1' then
			imp_dout_i_491_52_Mhz <= imp_dout_i;
		else
			imp_dout_i_491_52_Mhz <= imp_dout_i_491_52_Mhz;
		end if;
		imp_dout_i_491_52_Mhz_r <= imp_dout_i_491_52_Mhz;
		if (TEST_MODE = '1') then
			 -- In digital mode connect the impulse signal to the DUC input
			 if (digital_mode = '1') then
				duc_din_i <= '0' & imp_dout_i_491_52_Mhz_r & "00000000000000";
				duc_din_q <= (others => '0');
			 -- In converter loopback mode connect the DDS output to the DUC input
			 else
				--duc_din_i <= dds_dout_i;
				--duc_din_q <= dds_dout_q;
				
				-- Connect the Chirp DDS output to DUC input in converter loopback mode
				duc_din_i <= chirp_i;
                duc_din_q <= chirp_q;
			 end if;
		else
			duc_din_i <= BASEBAND_IN_I;
			duc_din_q <= BASEBAND_IN_Q;
			duc_in_valid_reg <= BASEBAND_IN_VALID;
		end if;
  end if;
end process TX_mux_to_DUC;

duc_vin <= signal_vout when test_mode = '1' else duc_in_valid_reg;

----------------------------------------------------------------------------------------------------
-- DUC - Digital Up Conversion
----------------------------------------------------------------------------------------------------
duc_umts_k7_inst : duc_umts_k7
port map (
  resetn        => rst_duc_ddc_n_r,
  clk           => clk,
  clk1          => clk1,
  vin           => duc_vin,
  din_i         => duc_din_i,
  din_q         => duc_din_q,
  freq          => freq,
  dout_i        => duc_dout_i,
  dout_q        => duc_dout_q,
  dds_vout 		 => dds_reset_duc,
  cmplx_mult_vout  => duc_vout,
  duc_OE			 => duc_OE					-- this input connects to DUC complex mult TREADY IN 
													-- it is driven by DDC complex mult TVALID OUT form back-pressure from DDC to delay data output of DUC complex mixer until DDC DDS start-up has completed
  );
  
----------------------------------------------------------------------------------------------------
-- Output MUX - Select data connected to the physical DAC interface
----------------------------------------------------------------------------------------------------
TX_mux_to_DAC: process (clk)
begin
  if (rising_edge(clk)) then

    -- If DDC and DUC is bypassed connect the incoming ADC outputs right back out to the DAC inputs
    if (ddc_duc_bypass = '1') then
		 if (adc_out_dac_in = '1') then
			if_out_i_sig <= if_in_i_sig;
			if_out_q_sig <= if_in_q_sig;
		 else
			--if_out_i_sig <= dds_dout_i;	-- connect DDS output directly to DAC @ 245.76 MSPS
			--if_out_q_sig <= dds_dout_q;
			
			if_out_i_sig <= chirp_i;	-- connect Chirp DDS output directly to DAC @ 245.76 MSPS
            if_out_q_sig <= chirp_q;
		 end if;
    -- otherwise DUC is used connect the DUC output to the DAC inputs
    else
      if_out_i_sig <= duc_dout_i;
      if_out_q_sig <= duc_dout_q;
    end if;

  end if;
end process TX_mux_to_DAC;

IF_OUT_I <= if_out_i_sig;
IF_OUT_Q <= if_out_q_sig;

----------------------------------------------------------------------------------------------------
-- Select data connected to the DDC
----------------------------------------------------------------------------------------------------
RX_mux_to_DDC: process (clk1)
begin
  if (rising_edge(clk1)) then
    -- In digital mode connect the DUC output to the DDC input
    if (digital_mode = '1') then
		ddc_vin   <= duc_vout;
		ddc_din_i <= duc_dout_i;
		ddc_din_q <= duc_dout_q;
		ddc_resetn     <= dds_reset_duc;
    -- In converter analog loopback mode connect the ADC outputs to the DDC input
    else
      ddc_vin   <= if_in_valid_sig;
      ddc_din_i <= if_in_i_sig;
      ddc_din_q <= if_in_q_sig;
		ddc_resetn  <= rst_duc_ddc_n;
    end if;
	 
	 rst_duc_ddc_n_r  <= rst_duc_ddc_n;	-- align resets to both DDC and DUC
  end if;
end process RX_mux_to_DDC;

----------------------------------------------------------------------------------------------------
-- DDC - Digital Down Conversion
----------------------------------------------------------------------------------------------------
ddc_umts_k7_inst : ddc_umts_k7
port map (
  resetn        => ddc_resetn,
  clk           => clk,
  clk1          => clk1,
  din_i         => ddc_din_i,
  din_q         => ddc_din_q,
  vin           => ddc_vin,
  freq          => freq,
  dds_vout		 => duc_OE,
  dout_i        => ddc_dout_i,
  dout_q        => ddc_dout_q,
  vout          => ddc_vout
);

------------------------------------------------------------------------------------------------------
-- Align baseband data and 'valid' pulse in 491.52 MHz clock domain to pass to 245.76 MHz clock domain
------------------------------------------------------------------------------------------------------

baseband_output_align: process (clk)
begin
	if (rising_edge(clk)) then
		ddc_vout_r <= ddc_vout;
		ddc_vout_245_76MHz <= ddc_vout_r OR ddc_vout; -- stretch 'valid' pulse to ensure it is seen by 245.76 MHz clock
		if (ddc_vout = '1') then
			ddc_dout_i_r <= ddc_dout_i;		-- align 'stretched-valid' pulse at start of data transition
			ddc_dout_q_r <= ddc_dout_q;
		end if;
	end if;
end process baseband_output_align;

------------------------------------------------------------------------------------------------------
-- DDC Output MUX - Select data connected to the baseband-side output
-- ... Re-clock DDC baseband output data from 491.52 MHz clock domain to 245.76 MHz clock domain
-- ... Note: Data can't be re-clocked any slower than 245.76 MHz clock domain because, 
-- ... although baseband DDC output data @ 15.36 MSPS, 'ddc_duc_bypass' may be active for 245.76 MSPS data from ADC
------------------------------------------------------------------------------------------------------
baseband_output_mux: process (clk1)
begin
	if (rising_edge(clk1)) then
		if (ddc_duc_bypass = '1') then
			baseband_out_valid_sig	<= ddc_vin;
			if (baseband_out_valid_sig = '1') then
				baseband_out_i_sig		<= ddc_din_i;
				baseband_out_q_sig		<= ddc_din_q;
			end if;
		else
			baseband_out_valid_sig	<= ddc_vout_245_76MHz;	-- delay 'valid' pulse to create multi-cycle path of 1 period of 245.76 MHz
			if (baseband_out_valid_sig = '1') then
				baseband_out_i_sig		<= ddc_dout_i_r;
				baseband_out_q_sig		<= ddc_dout_q_r;
			end if;
		end if;
	end if;
end process baseband_output_mux;

BASEBAND_OUT_I		<= baseband_out_i_sig;		 -- baseband data @ 15.36 MSPS, clocked by 491.52 MHz clock domain
BASEBAND_OUT_Q		<= baseband_out_q_sig;
BASEBAND_OUT_VALID <= baseband_out_valid_sig; -- baseband data-valid pulse every 16 clock cycles (of 491.52 MHz clock)

----------------------------------------------------------------------------------------------------
-- End
----------------------------------------------------------------------------------------------------
end DUC_DDC_syn;