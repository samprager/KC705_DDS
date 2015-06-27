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
-- Module Name:   ./implementation/VHDL/ISE/ddc_complex_mixer.vhd
-- Project Name:
-- Target Device: 7K325t-2ffg900  
-- Tool versions: ISE? Design Suite: System Edition 13.4 / build O.87
-- Description:   
-- 
-- This module is the complex mixer within the DDC.
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Nov 12, 2010 : release under 12.3 with IP blocks ported to AXI
-------------------------------------------------------------------------------------
-- Luc Langlois
-- July 2011 : 
--    - Increased ADC input sampling rate to 245.76 MSPS
--    - Updated control signaling between DDS, complex multipler to use standard AXI flow control
--
-- January 2012
--		- updated to 13.4 / build O.87
--
--  June 4 2013:
--		-Updated to Vivado 2013.2  
--      -upgraded FIR and complex multiplier IP
--      -Commented out black box in complex_mixer VHDL
--
--  July 20 2013:
--		- Complex multiplier:
--          - IP lacks rounding function, so ...
--          - Added rounding from 19_1 to 18_0 to match MATLAB model
--
-- Notes: 
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity complex_mixer_ddc is
	port (
		RESETn: 	IN std_logic;
		CLK: 		IN std_logic;
		DIN_I: 	IN std_logic_VECTOR(15 downto 0);
		DIN_Q: 	IN std_logic_VECTOR(15 downto 0);
		VIN: 		IN std_logic;
		FREQ: 	IN std_logic_vector(27 downto 0);
		DDS_VOUT: OUT std_logic;
		DOUT_I: 	OUT std_logic_VECTOR(17 downto 0);
		DOUT_Q: 	OUT std_logic_VECTOR(17 downto 0);
		VOUT: 	OUT std_logic
		);
end complex_mixer_ddc;

architecture structural of complex_mixer_ddc is

component dds_ddc
	port (
	aclk: IN std_logic;
	aresetn: IN std_logic;
--	s_axis_config_tvalid: IN std_logic;
--	s_axis_config_tdata: IN std_logic_VECTOR(31 downto 0);
	m_axis_data_tvalid: OUT std_logic;
	m_axis_data_tdata: OUT std_logic_VECTOR(47 downto 0));
end component;
	
component complex_multiplier
	port (
	aclk: IN std_logic;
	s_axis_a_tvalid: IN std_logic;
	s_axis_a_tdata: IN std_logic_VECTOR(47 downto 0);
	s_axis_b_tvalid: IN std_logic;
	s_axis_b_tdata: IN std_logic_VECTOR(31 downto 0);
	m_axis_dout_tvalid: OUT std_logic;
	m_axis_dout_tdata: OUT std_logic_VECTOR(47 downto 0));
end component;

-- Declare a clock signal for AXI4 IP 
   signal aclk                        : std_logic := '0';  -- the master clock
-- Declare a reset signal for AXI4 IP. Notice that the reset signal for all AXI4 IP is an active 
-- low signal and it has to be held low at least for two consecutive clock cycles
   signal aresetn_sig      : std_logic := '1'; 
--
    -- Synplicity black box declaration
--	attribute syn_black_box : boolean;
--	attribute syn_black_box of complex_multiplier: component is true;

	signal cosine : std_logic_vector(17 downto 0);
	signal sine : std_logic_vector(17 downto 0);
	
-- inputs
	signal resetn_int : std_logic;
	signal din_i_int : std_logic_vector(15 downto 0) := (others => '0');
	signal din_q_int : std_logic_vector(15 downto 0) := (others => '0');
	signal vin_int: std_logic := '0';
	signal freq_int : std_logic_vector(27 downto 0) := (others => '0');

-- Data slave channel signals
   signal dds_m_axis_data_tvalid          : std_logic := '0';  -- DDS sin/cos output valid
   signal m_axis_dout_tvalid              : std_logic := '0';  -- complex multiplier output valid
  
-- outputs
    signal Dout_I_signed, Dout_Q_signed : signed(18 downto 0);
    signal Dout_I_signed_plus_1, Dout_Q_signed_plus_1 : signed(18 downto 0);
	signal m_axis_data_tdata        : std_logic_vector(47 downto 0) :=  (others => '0');
	signal dds_sine_cosine : std_logic_vector(47 downto 0) := (others => '0');
	signal s_axis_b_tdata : std_logic_vector(31 downto 0) := (others => '0');
	signal s_axis_config_tdata: std_logic_vector(31 downto 0);

begin
   aclk <= CLK;
	resetn_int <= RESETn;
	din_i_int <= DIN_I;
	din_q_int <= DIN_Q;
	vin_int <= VIN;
	freq_int <= FREQ;

	s_axis_config_tdata (27 downto 0) <= freq_int;
	
	dds0  : dds_ddc			-- dds core to generate sinusoidal waveforms
		port map (
		   aresetn =>  resetn_int,
			aclk => aclk,
			m_axis_data_tvalid => dds_m_axis_data_tvalid,
			m_axis_data_tdata =>  dds_sine_cosine);
			
	DDS_VOUT <= dds_m_axis_data_tvalid;

	sine   <= dds_sine_cosine(41 downto 24);		-- stubs for observation in HDL simulation only
	cosine <= dds_sine_cosine(17 downto 0);		-- have no loads / trimmed by MAP
	
	s_axis_b_tdata(15 downto 0) <= din_i_int;		
	s_axis_b_tdata(31 downto 16) <= din_q_int;

	complex_mult : complex_multiplier
		port map (
			aclk => aclk,
			s_axis_a_tvalid => dds_m_axis_data_tvalid,
			s_axis_a_tdata => dds_sine_cosine,
			s_axis_b_tvalid => vin_int,
			s_axis_b_tdata => s_axis_b_tdata,
			m_axis_dout_tvalid => m_axis_dout_tvalid,
			m_axis_dout_tdata => m_axis_data_tdata);
			
	-- Complex multiplier IP lacks rounding function, so must perform ...
    -- rounding from 19_1 to 18_0 to match MATLAB model
    Dout_I_signed <= signed(m_axis_data_tdata(18 downto 0));
    Dout_q_signed <= signed(m_axis_data_tdata(42 downto 24));
	
	dout_register: process(aclk)
	begin
		if rising_edge(aclk) then	-- pipeline 'addition + 1' operation
            Dout_I_signed_plus_1 <= Dout_I_signed + 1;
            Dout_Q_signed_plus_1 <= Dout_Q_signed + 1;
		end if;
	end process dout_register;
	
	Dout_I <= std_logic_vector(Dout_I_signed_plus_1(18 downto 1));
    Dout_Q <= std_logic_vector(Dout_Q_signed_plus_1(18 downto 1));

VOUT <= m_axis_dout_tvalid;
	
end structural;