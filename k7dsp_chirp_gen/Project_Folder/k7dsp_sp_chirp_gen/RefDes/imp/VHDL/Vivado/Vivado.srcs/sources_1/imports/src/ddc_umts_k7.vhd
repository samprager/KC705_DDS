-------------------------------------------------------------------------------
-- DISCLAIMER OF LIABILITY
-- 
-- This text/file contains proprietary, confidential
-- information of Xilinx, Inc., is distributed under license
-- from Xilinx, Inc., and may be used, copied and/or
-- disclosed only pursuant to the terms of a valid license
-- agreement with Xilinx, Inc. Xilinx hereby grants you a 
-- license to use this text/file solely for design, simulation, 
-- implementation and creation of design files limited 
-- to Xilinx devices or technologies. Use with non-Xilinx 
-- devices or technologies is expressly prohibited and 
-- immediately terminates your license unless covered by
-- a separate agreement.
--
-- Xilinx is providing this design, code, or information 
-- "as-is" solely for use in developing programs and 
-- solutions for Xilinx devices, with no obligation on the 
-- part of Xilinx to provide support. By providing this design, 
-- code, or information as one possible implementation of 
-- this feature, application or standard, Xilinx is making no 
-- representation that this implementation is free from any 
-- claims of infringement. You are responsible for 
-- obtaining any rights you may require for your implementation. 
-- Xilinx expressly disclaims any warranty whatsoever with 
-- respect to the adequacy of the implementation, including 
-- but not limited to any warranties or representations that this
-- implementation is free from claims of infringement, implied 
-- warranties of merchantability or fitness for a particular 
-- purpose.
--
-- Xilinx products are not intended for use in life support
-- appliances, devices, or systems. Use in such applications is
-- expressly prohibited.
--
-- Any modifications that are made to the Source Code are 
-- done at the user?s sole risk and will be unsupported.
--
--
-- Copyright (c) 2010 Xilinx, Inc. All rights reserved.
--
-- This copyright and support notice must be retained as part 
-- of this text at all times. 
-------------------------------------------------------------------------------
-- Company: 	Avnet
-- Engineer:	Luc Langlois
--
-- Create Date:
-- Design Name:   
-- Module Name:   ./implementation/VHDL/ISE/ddc_umts_k7.vhd
-- Project Name:
-- Target Device: 7K325t-2ffg900  
-- Tool versions: ISE? Design Suite: System Edition 13.4 / build O.87
-- Description:   
-- 
-- This module is the digital down-converter (DDC)
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Nov 12, 2010 : release under 12.3 with IP blocks ported to AXI
-------------------------------------------------------------------------------------
-- Luc Langlois
-- August 2011 : 
--    - Increased ADC input sampling rate to 245.76 MSPS
--    - Updated control signaling between DDS, complex multipler and decimation FIR filters to use standard AXI flow control
-- Nov 4, 2011: CoreGen IP blocks re-generated for K7 / 13.3 build O.76
-- Nov 29, 2011:
--    - Adjusted ddc_imf2_register /  ddc_imf1_register to delay Vout from halfband FIR filters for symmetrical response from next stage decimator
--
-- January 30, 2012 : updated to 13.4 / build O.87 with 491.52 MHz system clock, for 2X over-clocking of fastest stage with input sampling rate of 245.76 MSPS
-- - staggered resets to FIR filters to reduce fanout on reset net
--
-- February 16, 2012
-- - over-clock FIR filters by 2X @ 491.52 MHz
-- - complex mixer remains in 245.76 MHz clock domain at incoming sample-rate from ADC
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ddc_umts_k7 is
	port (
		RESETn:     IN std_logic;
		CLK:        IN std_logic;
		CLK1:       IN std_logic;
		DIN_I:      IN std_logic_VECTOR(15 downto 0);
		DIN_Q:      IN std_logic_VECTOR(15 downto 0);
		VIN:        IN std_logic;
		FREQ:       IN std_logic_vector(27 downto 0);
		DDS_VOUT:   OUT std_logic;
		DOUT_I:     OUT std_logic_VECTOR(15 downto 0);
		DOUT_Q:     OUT std_logic_VECTOR(15 downto 0);
		VOUT:       OUT std_logic
		);
end ddc_umts_k7;

architecture structural of ddc_umts_k7 is

component complex_mixer_ddc
	port (
	RESETn:     IN std_logic;
	CLK:        IN std_logic;
	DIN_I:      IN std_logic_VECTOR(15 downto 0);
	DIN_Q:      IN std_logic_VECTOR(15 downto 0);
	VIN:        IN std_logic;
	FREQ:       IN std_logic_vector(27 downto 0);
	DDS_VOUT:   OUT std_logic;
	DOUT_I:     OUT std_logic_VECTOR(17 downto 0);
	DOUT_Q:     OUT std_logic_VECTOR(17 downto 0);
	VOUT:       OUT std_logic
	);
end component;

component ddc_imf2
	port (
	aresetn:             IN std_logic;
	aclk:                IN std_logic;
	s_axis_data_tvalid:  IN std_logic;
	s_axis_data_tready:  OUT std_logic;
	s_axis_data_tdata:   IN std_logic_VECTOR(47 downto 0);
	m_axis_data_tvalid:  OUT std_logic;
	m_axis_data_tdata:   OUT std_logic_VECTOR(47 downto 0));
end component;

component ddc_imf1
	port (
	aresetn:             IN std_logic;
	aclk:                IN std_logic;
	s_axis_data_tvalid:  IN std_logic;
	s_axis_data_tready:  OUT std_logic;
	s_axis_data_tdata:   IN std_logic_VECTOR(47 downto 0);
	m_axis_data_tvalid:  OUT std_logic;
	m_axis_data_tdata:   OUT std_logic_VECTOR(47 downto 0));
end component;

component ddc_srrc
	port (
	aresetn:                IN std_logic;
	aclk:                   IN std_logic;
	s_axis_data_tvalid:     IN std_logic;
	s_axis_data_tready:     OUT std_logic;
	s_axis_data_tdata:      IN std_logic_VECTOR(47 downto 0);
	m_axis_data_tvalid:     OUT std_logic;
	m_axis_data_tdata:      OUT std_logic_VECTOR(47 downto 0));
end component;

-- inputs

	signal din_i_sig  : std_logic_vector(15 downto 0) := (others => '0');
	signal din_q_sig  : std_logic_vector(15 downto 0) := (others => '0');
	signal vin_sig    : std_logic := '0';
	signal freq_sig   : std_logic_vector(27 downto 0) := (others => '0');
	
-- interconnect

	attribute S: string;
	attribute keep: string;

	signal mixer_dout_i : std_logic_vector(17 downto 0) := (others => '0');
	signal mixer_dout_q : std_logic_vector(17 downto 0) := (others => '0');
	signal mixer_dout_i_q_491_52MHz : std_logic_vector(47 downto 0);
	signal mixer_vout_491_52MHz : std_logic;
	
	signal mixer_vout : std_logic := '0';
	signal dds_vout_sig : std_logic;
	
	signal transition_491_52MHz, transition_491_52MHz_r : std_logic := '0';

	signal ddc_imf2_vout : std_logic;
	signal ddc_imf2_vout_r : std_logic;

	signal ddc_imf1_vout, ddc_imf1_vout_r : std_logic;
	
	signal ddc_imf0_vout : std_logic;
	
	signal ddc_srrc_rfd : std_logic;
	signal ddc_srrc_vout : std_logic;

-- outputs

	signal dout_i_sig : std_logic_vector(15 downto 0);
	signal dout_q_sig : std_logic_vector(15 downto 0);

   signal aclk                   : std_logic := '0';  -- fast clock, multiple of sample-rate for over-clocking FIR filters
	signal aclk1                  : std_logic := '0';  -- sample-rate clock
-- Declare a reset signal for AXI4 IP. Notice that the reset signal for all AXI4 IP is an active 
-- low signal and it has to be held low at least for two consecutive clock cycles
   signal aresetn_sig   : std_logic := '1';
	signal aresetn_sig_r, aresetn_sig_rr, aresetn_sig_rrr : std_logic;

	signal m_axis_data_tdata_ddc_imf2   : std_logic_vector(47 downto 0) :=(others => '0'); 
	signal m_axis_data_tdata_ddc_imf1   : std_logic_vector(47 downto 0) :=(others => '0');
	signal m_axis_data_tdata_ddc_srrc   : std_logic_vector(47 downto 0) :=(others => '0');

begin
   aclk 			<= CLK;
	aclk1 		<= CLK1;
   aresetn_sig <= RESETn;
	din_i_sig 	<= DIN_I;
	din_q_sig 	<= DIN_Q;
	vin_sig 		<= VIN;
	freq_sig 	<= FREQ;
	
	process (aclk)
	begin
		if (rising_edge(aclk)) then
			aresetn_sig_r <= aresetn_sig;		-- stagger resets to FIR filters to reduce fanout on reset net
			aresetn_sig_rr <= aresetn_sig_r;
			aresetn_sig_rrr <= aresetn_sig_rr;
		end if;
	end process;
	
	complex_mixer_ddc_i: complex_mixer_ddc
		port map(
			RESETn   =>	aresetn_sig,
			CLK      =>	aclk1,					-- 245.76 MHz clock domain
			DIN_I    =>	din_i_sig,
			DIN_Q    =>	din_q_sig,
			VIN      =>	vin_sig,
			FREQ     =>	freq_sig,
			DDS_VOUT  => dds_vout_sig,
			DOUT_I   => mixer_dout_i,
			DOUT_Q   => mixer_dout_q,
			VOUT     => mixer_vout
			);
			
	make_transition_491_52MHz: process(aclk1) 	-- make 'valid' pulse on every 1/2-cycle 256.76 MHz
	begin
		if rising_edge(aclk1) then
			transition_491_52MHz <= not transition_491_52MHz;
		end if;
		if falling_edge(aclk1) then
			transition_491_52MHz_r <= transition_491_52MHz;
		end if;
	end process make_transition_491_52MHz;
	
	re_clock_491_52MHz: process(aclk)				-- re-clock complex mixer output from 245.76 MHz clock domain to 491.52 MHz towards decimation FIRs
	begin
		if rising_edge(aclk) then
			mixer_vout_491_52MHz <= transition_491_52MHz XOR transition_491_52MHz_r;
			if (mixer_vout_491_52MHz = '1') then
				mixer_dout_i_q_491_52MHz <= "000000" & mixer_dout_q & "000000" & mixer_dout_i;
			end if;
		end if;
	end process re_clock_491_52MHz;
--
--	-- Cascade of three 2X decimation FIR filters for total decimation factor of 8.
--
--	-- Data flow and handshaking through the decimation FIR filters:
--		-- I & Q data flowing through the pipeline of decimation FIR filters is processed through 2 identical parallel data paths with the same filter coefficients.
--		-- In this configuration, the FIR Compiler can share control logic and coefficient memory resources between the parallel data paths. 
--		-- A data valid accompanies the incoming I & Q data
--		-- AXI control signals propagate through each stage

	ddc_imf2_i : ddc_imf2			-- 1st stage halfband 2X decimator
		port map (
   		aresetn => aresetn_sig_rr,
			aclk => aclk,
			s_axis_data_tvalid => mixer_vout_491_52MHz,
			s_axis_data_tready => open,
			s_axis_data_tdata => mixer_dout_i_q_491_52MHz,
			m_axis_data_tvalid => ddc_imf2_vout,
			m_axis_data_tdata  => m_axis_data_tdata_ddc_imf2);
	
	ddc_imf1_i : ddc_imf1			-- 2nd stage halfband 2X decimator
		port map (
   		aresetn => aresetn_sig_rr,
			aclk => aclk,
			s_axis_data_tvalid => ddc_imf2_vout,
			s_axis_data_tready => open,
			s_axis_data_tdata  => m_axis_data_tdata_ddc_imf2,
			m_axis_data_tvalid => ddc_imf1_vout,
			m_axis_data_tdata  => m_axis_data_tdata_ddc_imf1);
			
	ddc_srrc_i : ddc_srrc			-- square root raised cosine channel filter, 2X decimator
		port map (
   		aresetn => aresetn_sig_rrr,
			aclk => aclk,
			s_axis_data_tvalid => ddc_imf1_vout,
			s_axis_data_tready => open,
			s_axis_data_tdata => m_axis_data_tdata_ddc_imf1,
			m_axis_data_tvalid => ddc_srrc_vout,
			m_axis_data_tdata  => m_axis_data_tdata_ddc_srrc);

	ddc_srrc_register: process(aclk)
	begin
		if rising_edge(aclk) then
			if (ddc_srrc_vout = '1') then		-- align 'valid' pulse at right-most edge of data for multi-cycle path constraint to ease timing closure
				dout_i_sig <= m_axis_data_tdata_ddc_srrc (15 downto 0);
				dout_q_sig <= m_axis_data_tdata_ddc_srrc (39 downto 24);
			end if;
		end if;
	end process ddc_srrc_register;
	
	-- Apply back-pressure from DDC to delay data output of DUC complex mixer until DDC DDS start-up has completed
	
	DDS_VOUT <= dds_vout_sig;	
	
	-- The 'VOUT' signal accompanies the decimated data at the output of the FIR filter pipeline, indicating valid data to downstream blocks.
	
	DOUT_I <= dout_i_sig;
	DOUT_Q <= dout_q_sig;
	VOUT <= ddc_srrc_vout;

end structural;
