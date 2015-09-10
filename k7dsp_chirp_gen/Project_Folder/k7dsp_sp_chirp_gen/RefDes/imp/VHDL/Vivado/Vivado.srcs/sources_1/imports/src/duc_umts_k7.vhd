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
-- Module Name:   ./implementation/VHDL/ISE/duc_umts_k7.vhd
-- Project Name:
-- Target Device: 7K325t-2ffg900  
-- Tool versions: ISE? Design Suite: System Edition 13.4 / build O.87
-- Description:   
-- 
-- This module is the digital up-converter (DUC)
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Nov 12, 2010 : release under 12.3 with IP blocks ported to AXI
-- July 2011 : Updated to 2-path data flow through DUC interpolation filters to eliminate TDM of I & Q
-- Nov 4, 2011: CoreGen IP blocks re-generated for K7 / 13.4 build O.87
--
-- January 30, 2012 : updated to 491.52 MHz system clock, for 2X over-clocking of fastest stage with input sampling rate of 245.76 MSPS
-- - staggered resets to FIR filters to reduce fanout on reset net
--
-- February 16, 2012
-- - over-clock FIR filters by 2X @ 491.52 MHz
-- - complex mixer remains in 245.76 MHz clock domain
--
-- Additional Comments:
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity duc_umts_k7 is
	port (
		RESETN: IN std_logic;
		CLK: IN std_logic;		-- system clock, nominally 491.52 MHz for over-clocking FIRs
		CLK1: IN std_logic;		-- nominally 245.75 MHz
		VIN: IN std_logic;
		DIN_I: IN std_logic_VECTOR(15 downto 0);
		DIN_Q: IN std_logic_VECTOR(15 downto 0);
		freq: IN std_logic_VECTOR(27 downto 0);
		DOUT_I: OUT std_logic_VECTOR(15 downto 0);
		DOUT_Q: OUT std_logic_VECTOR(15 downto 0);
		DDS_VOUT: OUT std_logic;
		CMPLX_MULT_VOUT: OUT std_logic;
		DUC_OE: IN std_logic
		);
end duc_umts_k7;

architecture structural of duc_umts_k7 is

component duc_srrc
	port (
	aresetn: IN std_logic;
	aclk: IN std_logic;
	s_axis_data_tvalid: IN std_logic;
	s_axis_data_tready: OUT std_logic;
	s_axis_data_tdata: IN std_logic_VECTOR(31 downto 0);
	m_axis_data_tvalid: OUT std_logic;
	m_axis_data_tdata: OUT std_logic_VECTOR(31 downto 0));
end component;

component duc_imf1
	port (
	aresetn: IN std_logic;
	aclk: IN std_logic;
	s_axis_data_tvalid: IN std_logic;
	s_axis_data_tready: OUT std_logic;
	s_axis_data_tdata: IN std_logic_VECTOR(31 downto 0);
	m_axis_data_tvalid: OUT std_logic;
	m_axis_data_tdata: OUT std_logic_VECTOR(47 downto 0));
end component;

component duc_imf2
	port (
	aresetn: IN std_logic;
	aclk: IN std_logic;
	s_axis_data_tvalid: IN std_logic;
	s_axis_data_tready: OUT std_logic;
	s_axis_data_tdata: IN std_logic_VECTOR(47 downto 0);
	m_axis_data_tvalid: OUT std_logic;
	m_axis_data_tdata: OUT std_logic_VECTOR(47 downto 0));
end component;

component duc_imf3
	port (
	aresetn: IN std_logic;
	aclk: IN std_logic;
	s_axis_data_tvalid: IN std_logic;
	s_axis_data_tready: OUT std_logic;
	s_axis_data_tdata: IN std_logic_VECTOR(47 downto 0);
	m_axis_data_tvalid: OUT std_logic;
	m_axis_data_tdata: OUT std_logic_VECTOR(47 downto 0));
end component;

component complex_mixer
port (
	resetn: IN std_logic;
	clk: IN std_logic;
	vin: IN std_logic;
	OE:  IN std_logic;
	Din_I: IN std_logic_VECTOR(17 downto 0);
	Din_Q: IN std_logic_VECTOR(17 downto 0);
	Dout_I: OUT std_logic_VECTOR(15 downto 0);
	Dout_Q: OUT std_logic_VECTOR(15 downto 0);
	dds_vout: OUT std_logic;
	cmplx_mult_vout: OUT std_logic);
end component;

-- inputs

	signal vin_int : std_logic := '0';
	signal duc_OE_sig : std_logic;

-- interconnect

	signal duc_srrc_vin : std_logic := '0';
	signal duc_srrc_din : std_logic_vector(31 downto 0) := (others => '0');
	signal duc_srrc_vout : std_logic;
	signal duc_srrc_dout : std_logic_vector(31 downto 0);
	signal duc_srrc_dout_i : std_logic_vector(15 downto 0);
	signal duc_srrc_dout_q : std_logic_vector(15 downto 0);

	signal duc_imf1_vout : std_logic;
	signal duc_imf1_dout_i : std_logic_vector(17 downto 0);
	signal duc_imf1_dout_q : std_logic_vector(17 downto 0);
	
	signal duc_imf2_vout : std_logic;
	signal duc_imf2_dout_i : std_logic_vector(17 downto 0);
	signal duc_imf2_dout_q : std_logic_vector(17 downto 0);

	signal duc_imf3_vout : std_logic;
	
	signal complex_mixer_vin : std_logic;
	signal complex_mixer_vin_245_76MHz : std_logic;
	
-- Declare a reset signal for AXI4 IP. Notice that the reset signal for all AXI4 IP is an active 
-- low signal and it has to be held low at least for two consecutive clock cycles
   signal aresetn_sig	: std_logic := '1';
	signal aresetn_sig_r, aresetn_sig_rr, aresetn_sig_rrr 	: std_logic;

-- outputs

	signal dout_i_int : std_logic_vector(15 downto 0);
	signal dout_q_int : std_logic_vector(15 downto 0);
	signal dds_vout_sig : std_logic;
	signal cmplx_mult_vout_sig : std_logic;

	signal s_axis_data_tdata_duc_imf1	 : std_logic_vector(31 downto 0) := (others => '0');
   signal m_axis_data_tdata_duc_imf1    : std_logic_vector(47 downto 0) := (others => '0');
	signal s_axis_data_tdata_duc_imf2    : std_logic_vector(47 downto 0) := (others => '0');
	signal m_axis_data_tdata_duc_imf2    : std_logic_vector(47 downto 0) := (others => '0');
	signal s_axis_data_tdata_duc_imf3    : std_logic_vector(47 downto 0) := (others => '0');
	signal m_axis_data_tdata_duc_imf3    : std_logic_vector(47 downto 0) := (others => '0');
	
	signal m_axis_data_tdata_duc_imf3_245_76MHz : std_logic_vector(47 downto 0);

begin
   aresetn_sig <= RESETn;
	duc_srrc_din(31 downto 16) <= DIN_I;
	duc_srrc_din(15 downto 0)  <= DIN_Q;
	vin_int <= VIN;
	
	process (clk)
	begin
		if (rising_edge(clk)) then
			aresetn_sig_r <= aresetn_sig;		-- stagger resets to FIR filters to reduce fanout on reset net
			aresetn_sig_rr <= aresetn_sig_r;
			aresetn_sig_rrr <= aresetn_sig_rr;
		end if;
	end process;
		
		-- Cascade of four 2X interpolation FIR filters for total interpolation factor of 16
		
		-- Data flow and handshaking through the interpolation FIR filters:
			-- I & Q data is time division multiplexed (TDM) as 2 individual channels onto a single data stream for simple and efficient 
			-- dataflow with minimal handshaking through the filter stages.

	duc_srrc_i : duc_srrc						-- DUC Channel filter Square Root Raised Cosine, 2X interpolation
		port map (
			aresetn => aresetn_sig,
			aclk => clk,
			s_axis_data_tvalid => vin_int,
			s_axis_data_tready => open,
			s_axis_data_tdata => duc_srrc_din,
			m_axis_data_tvalid => duc_srrc_vout,
			m_axis_data_tdata => duc_srrc_dout);
				
	duc_srrc_dout_i <= duc_srrc_dout(31 downto 16);
	duc_srrc_dout_q <= duc_srrc_dout(15 downto 0);

	duc_imf1_i : duc_imf1						-- 1st Halfband filter, 2X interpolation
		port map (
			aresetn => aresetn_sig_r,
			aclk => clk,
			s_axis_data_tvalid => duc_srrc_vout,
			s_axis_data_tready => open,
			s_axis_data_tdata => s_axis_data_tdata_duc_imf1,
			m_axis_data_tvalid => duc_imf1_vout,
			m_axis_data_tdata => m_axis_data_tdata_duc_imf1);
				
	s_axis_data_tdata_duc_imf1 (31 downto 16) <= duc_srrc_dout_i;				
	s_axis_data_tdata_duc_imf1 (15 downto 0) <= duc_srrc_dout_q;
						
	duc_imf1_dout_i <= m_axis_data_tdata_duc_imf1 (41 downto 24);
	duc_imf1_dout_q <= m_axis_data_tdata_duc_imf1 (17 downto 0);

	duc_imf2_i : duc_imf2						-- 2nd Halfband filter, 2X interpolation
		port map (
			aresetn => aresetn_sig_rr,
			aclk => clk,
			s_axis_data_tvalid => duc_imf1_vout,
			s_axis_data_tready => open,
			s_axis_data_tdata => s_axis_data_tdata_duc_imf2,
			m_axis_data_tvalid => duc_imf2_vout,
			m_axis_data_tdata => m_axis_data_tdata_duc_imf2);

	s_axis_data_tdata_duc_imf2 (41 downto 24) <= duc_imf1_dout_i;				
	s_axis_data_tdata_duc_imf2 (17 downto 0) <= duc_imf1_dout_q;
		
	duc_imf2_dout_i <= m_axis_data_tdata_duc_imf2(41 downto 24); -- restrict bit growth propagation between filter stages
	duc_imf2_dout_q <= m_axis_data_tdata_duc_imf2(17 downto 0);
	
	s_axis_data_tdata_duc_imf3 (41 downto 24) <= duc_imf2_dout_i;				
	s_axis_data_tdata_duc_imf3 (17 downto 0) <= duc_imf2_dout_q;

	duc_imf3_i : duc_imf3						-- 3rd Halfband filter, 2X interpolation
		port map (
			aresetn => aresetn_sig_rrr,
			aclk => clk,
			s_axis_data_tvalid => duc_imf2_vout,
			s_axis_data_tready => open,
			s_axis_data_tdata  => s_axis_data_tdata_duc_imf3,
			m_axis_data_tvalid => duc_imf3_vout,
			m_axis_data_tdata => m_axis_data_tdata_duc_imf3); 

	duc_OE_sig <= DUC_OE;
		
	make_complex_mixer_vin: process(clk)				-- propagate 'valid' signal from last stage FIR in 245.76 MHz clock domain appropriate for complex mixer
	begin
		if rising_edge(clk) then
			if (aresetn_sig = '0') then
				complex_mixer_vin <= '0';					-- de-assert on active-low reset
			elsif (duc_imf3_vout = '1') then
				complex_mixer_vin <= '1';					-- assert on first '1' of duc_imf3_vout
			else
				complex_mixer_vin <= complex_mixer_vin;
			end if;
		end if;
	end process make_complex_mixer_vin;
	
	re_clock_duc_imf3_to_complex_mixer: process(clk1)
	begin
		if rising_edge(clk1) then
			complex_mixer_vin_245_76MHz <= complex_mixer_vin;
			m_axis_data_tdata_duc_imf3_245_76MHz <= m_axis_data_tdata_duc_imf3;
		end if;
	end process re_clock_duc_imf3_to_complex_mixer;
	
	complex_mixer_duc: complex_mixer
		port map(
			resetn => aresetn_sig,
			clk => clk1,												-- 245.76 MHz clock domain
			vin => complex_mixer_vin_245_76MHz,
			OE => duc_OE_sig,											-- allow back-pressure from DDC to delay data output of DUC complex mixer until DDC DDS start-up has completed
			Din_I => m_axis_data_tdata_duc_imf3_245_76MHz(41 downto 24), -- restrict bit growth propagation between filter stages,
			Din_Q => m_axis_data_tdata_duc_imf3_245_76MHz(17 downto 0),
			Dout_I => dout_i_int,
			Dout_Q => dout_q_int,
			dds_vout => dds_vout_sig,
			cmplx_mult_vout => cmplx_mult_vout_sig);
  
	DOUT_I <= dout_i_int;
	DOUT_Q <= dout_q_int;
	DDS_VOUT <= dds_vout_sig;
	CMPLX_MULT_VOUT <= cmplx_mult_vout_sig;

end structural;
