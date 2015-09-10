-------------------------------------------------------------------------------------
-- FILE NAME : ADC_auto_calibration.vhd
--
-- AUTHOR    : Luc Langlois
--
-- COMPANY   : Avnet
--
-- Create Date:    14:21:37 12/07/2011 
--
-- ITEM      : 1
--
-- UNITS     : Entity       - ADC_auto_calibration
--             architecture - ADC_auto_calibration_syn
--
-- LANGUAGE  : VHDL
--
-------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- State machine for ADC auto-calibration:
-- From system reset:
--    ADC is configured for test pattern mode (monotonic ramp) over SPI port (from top-level 'routing_to_SPI')
--    State machine waits for ADC data zero-crossing then tests if current incoming ADC sample = previous sample + 1
--    ... if not, then invert polarity of re-mux of dual-stream 122.88 MSPS ADC data to 245.76 MSPS
--    Wait for next zero-crossing and test again if current incoming ADC sample = previous sample + 1
--    ... if not then increment iDelay of incoming ADC data bus for this ADC channel
--    Successful auto-calibration / determination of polarity of re-mux requires error-free ramp capture over MAX_PATTERN_CNT ramp patterns
--    Each ADC channel undergoes auto-calibration in sequence (not simulataneously)
-- When all ADC channels have successfully passed ADC auto-calibration, LED 7 --> ON
-- NOTES: 
--    -- iDelay is applied globally across all bits of a particular ADC channel data bus
--       ... if no value of iDelay can provide error-free ramp capture, then ADC data bus may require more robust individual per-bit de-skew
--    -- State machine stops adjusting iDelay as soon as very first value of iDelay provides error-free ramp capture over MAX_PATTERN_CNT ramp patterns
--       ... currently no provision to find a sweet-spot iDelay value in the middle of the error-free range
--       ... hard-coded initial values of iDelay were set to sweet-spot iDelay value in the middle of the error-free range by experimentation (FMC150 rev 1.0/1.2 + KC705 Rev 1.0)
--
-------------------------------------------------------------------------------------
-- Revisions
-- Luc Langlois
-- Aug 19, 2012:
--       - Updated to Vivado 2012.2
--       - Updated ADC auto-calibration to fix intermittent ADC data-capture errors

library ieee;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ADC_auto_calibration is
    generic (
           MAX_PATTERN_CNT : integer := 2000;   -- value of 15000 = approx 1 sec for ramp of length 2^14 samples @ 245.76 MSPS
           INIT_IDELAY : integer                -- Initial number of delay taps on ADC data port
         );
    Port ( reset                 : in  STD_LOGIC;
           clk                   : in  STD_LOGIC;
           ADC_calibration_start : in  STD_LOGIC;
           ADC_data              : in  STD_LOGIC_VECTOR(13 downto 0);
           re_mux_polarity       : out  STD_LOGIC;
           iDelay_INC            : out  STD_LOGIC;
           ADC_calibration_state : out  STD_LOGIC_VECTOR(2 downto 0);
           ADC_calibration_done  : out  BOOLEAN;
           ADC_calibration_good  : out  STD_LOGIC);
end ADC_auto_calibration;

architecture ADC_auto_calibration_syn of ADC_auto_calibration is

signal arst                      : std_logic;
signal ADC_calibration_start_r   : std_logic;
signal ADC_calibration_start_rr  : std_logic;
signal adc_data_sig              : std_logic_vector(13 downto 0);
signal adc_data_prev_sig         : std_logic_vector(13 downto 0);
signal re_mux_polarity_sig       : std_logic;
signal iDelay_INC_sig            : std_logic;
signal iDelay_INC_sig_r          : std_logic;
signal ADC_calibration_done_sig  : boolean;
signal ADC_calibration_good_sig  : std_logic;
signal state                     : std_logic_vector(2 downto 0);
-- type 	 states is (WAIT_TO_START, PRE_SEQUENCE_1, SEQUENCE_1, SEQUENCE_1_OK, PRE_SEQUENCE_2, SEQUENCE_2, SEQUENCE_2_OK, ADC_DATA_CAPTURE_BAD);
-- signal state       		 : states;
constant WAIT_TO_START           : std_logic_vector(2 downto 0) := "000";
constant PRE_SEQUENCE_1          : std_logic_vector(2 downto 0) := "001";
constant SEQUENCE_1              : std_logic_vector(2 downto 0) := "010";
constant SEQUENCE_1_OK           : std_logic_vector(2 downto 0) := "011";
constant PRE_SEQUENCE_2          : std_logic_vector(2 downto 0) := "100";
constant SEQUENCE_2              : std_logic_vector(2 downto 0) := "101";
constant SEQUENCE_2_OK           : std_logic_vector(2 downto 0) := "110";
constant ADC_DATA_CAPTURE_BAD    : std_logic_vector(2 downto 0) := "111";

begin

arst <= reset;
adc_data_sig <= ADC_data;

ADC_auto_calibration:	process (arst, clk)
variable pattern_cnt :integer range 0 to MAX_PATTERN_CNT;      -- value of 15000 = approx 1 sec for ramp of length 2^14 samples @ 245.76 MSPS
variable iDelay_cnt  :std_logic_vector(4 downto 0);            -- counter to keep track of number of iDelay increments

begin
	if (arst = '1') then
		ADC_calibration_start_r <= '0';
		ADC_calibration_start_rr <= '0';
		state <= WAIT_TO_START;
		re_mux_polarity_sig <= '0';
		ADC_calibration_done_sig <= FALSE;
		iDelay_cnt := conv_std_logic_vector(INIT_IDELAY, 5);
		ADC_calibration_good_sig <= '0';                         -- turn OFF 'ADC data capture good' LED
		pattern_cnt := 0;
		iDelay_INC_sig <= '0';
        iDelay_INC_sig_r <= '0';
	elsif rising_edge(clk) then
		ADC_calibration_start_r <= ADC_calibration_start;        -- double-register to cross clock domain 
		ADC_calibration_start_rr <= ADC_calibration_start_r;     -- from process 'routing_to_SPI' where 'ADC_calibration_start' signal was set
		adc_data_prev_sig <= adc_data_sig;
        iDelay_INC_sig_r <= iDelay_INC_sig;
		
		case state is				
			when WAIT_TO_START =>
				if (ADC_calibration_start_r = '0' and ADC_calibration_start_rr = '0') then
					state <= WAIT_TO_START;
				elsif (ADC_calibration_start_r = '1' and ADC_calibration_start_rr = '0') then
					state <= PRE_SEQUENCE_1;
				else
					state <= WAIT_TO_START;
				end if;
				pattern_cnt := 0;
                iDelay_INC_sig <= '0';
				ADC_calibration_done_sig <= FALSE;

			when PRE_SEQUENCE_1 =>
				if adc_data_sig = "00000000000000" then 	   -- zero-crossing
					if pattern_cnt = 1 then                   -- ignore test while ADC ramp sequence settles thru iDelay for an entire ramp pattern
						state <= SEQUENCE_1;
						pattern_cnt := 0;
					else
						state <= PRE_SEQUENCE_1;
						pattern_cnt := 1;
					end if;
				else
					state <= PRE_SEQUENCE_1;
					pattern_cnt := pattern_cnt;
				end if;
                iDelay_INC_sig <= '0';
				ADC_calibration_done_sig <= FALSE;
				
			when SEQUENCE_1 =>
				if adc_data_sig = "00000000000000" then 	   -- next zero-crossing after complete successful sequence of ADC ramp pattern
					if pattern_cnt = MAX_PATTERN_CNT then
						state <= SEQUENCE_1_OK;
						pattern_cnt := MAX_PATTERN_CNT;
					else
						pattern_cnt := pattern_cnt + 1;
						state <= SEQUENCE_1;
					end if;
				elsif not(adc_data_sig = adc_data_prev_sig + 1) then
					re_mux_polarity_sig <= not re_mux_polarity_sig;			-- invert re-mux polarity
					pattern_cnt := 0;
					state <= PRE_SEQUENCE_2;
				end if;
                iDelay_INC_sig <= '0';
                ADC_calibration_done_sig <= FALSE;
				
			when PRE_SEQUENCE_2 =>
				if adc_data_sig = "00000000000000" then 	   -- zero-crossing
					if pattern_cnt = 1 then                   -- ignore test while ADC ramp sequence settles thru iDelay for 2 entire ramp patterns
						state <= SEQUENCE_2;
						pattern_cnt := 0;
					else
						state <= PRE_SEQUENCE_2;
						pattern_cnt := 1;
					end if;
				else
					state <= PRE_SEQUENCE_2;
					pattern_cnt := pattern_cnt;
				end if;
                iDelay_INC_sig <= '0';
                ADC_calibration_done_sig <= FALSE;
				
			when SEQUENCE_2 =>
				if adc_data_sig = "00000000000000" then 	   -- next zero-crossing after complete successful sequence of ADC ramp pattern
					if pattern_cnt = MAX_PATTERN_CNT then			
						state <= SEQUENCE_2_OK;
						pattern_cnt := MAX_PATTERN_CNT;
					else
						pattern_cnt := pattern_cnt + 1;
						state <= SEQUENCE_2;
					end if;
				elsif not(adc_data_sig = adc_data_prev_sig + 1) then
					state <= ADC_DATA_CAPTURE_BAD;	         -- neither re-mux polarity gives correct ramp pattern data capture from ADS62P49 in test mode ... need to proceed with per-bit de-skew
				end if;
                iDelay_INC_sig <= '0';
                ADC_calibration_done_sig <= FALSE;

			when SEQUENCE_1_OK =>
				ADC_calibration_good_sig <= '1'; 		      -- turn on 'ADC data capture good' LED
				ADC_calibration_done_sig <= TRUE;
				state <= SEQUENCE_1_OK;
                iDelay_INC_sig <= '0';
			when SEQUENCE_2_OK =>
				ADC_calibration_good_sig <= '1'; 		      -- turn on 'ADC data capture good' LED
				ADC_calibration_done_sig <= TRUE;
				state <= SEQUENCE_2_OK;
                iDelay_INC_sig <= '0';

			when ADC_DATA_CAPTURE_BAD =>
				ADC_calibration_good_sig <= '0'; 		      -- turn OFF 'ADC data capture good' LED
				if (iDelay_cnt /= conv_std_logic_vector(INIT_IDELAY - 1, 5)) then    -- test if all 32 values of iDelay have been tried
					iDelay_cnt := iDelay_cnt + 1;	            -- increment counter
                    iDelay_INC_sig <= '1';                    -- assert pulse to increment iDelay tap
					state <= PRE_SEQUENCE_1;			         -- re-commence calibration sequence
					ADC_calibration_done_sig <= FALSE;
				else
					state <= ADC_DATA_CAPTURE_BAD;	         -- all iDelay settings have been tried but calibration sequence could not get error-free capture of ADC ramp test-pattern
					ADC_calibration_done_sig <= TRUE;
				end if;
				pattern_cnt := 0;
			when others =>
				iDelay_cnt := iDelay_cnt;
				re_mux_polarity_sig <= re_mux_polarity_sig;
				ADC_calibration_done_sig <= ADC_calibration_done_sig;
				state <= state;
				iDelay_INC_sig <= '0';
				pattern_cnt := pattern_cnt;			
      end case;
	end if;
end process;

re_mux_polarity <= re_mux_polarity_sig;
iDelay_INC <= iDelay_INC_sig or iDelay_INC_sig_r;        -- pulse to 'CE' port of iDelay lasts for 2 cycles of 245_76_MHz clock = 1 clock cycle of 122_88_Mhz clock
ADC_calibration_state <= state;
ADC_calibration_done <= ADC_calibration_done_sig;
ADC_calibration_good <= ADC_calibration_good_sig;

end ADC_auto_calibration_syn;