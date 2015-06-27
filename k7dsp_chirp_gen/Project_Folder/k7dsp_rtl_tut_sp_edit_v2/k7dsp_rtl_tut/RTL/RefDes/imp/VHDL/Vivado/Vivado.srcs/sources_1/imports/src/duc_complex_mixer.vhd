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
-- Module Name:   ./implementation/VHDL/ISE/duc_complex_mixer.vhd
-- Project Name:
-- Target Device: 7K325t-2ffg900  
-- Tool versions: ISE? Design Suite: System Edition 13.3 / build O.76 
-- Description:   
-- 
-- This module is the complex mixer within the DUC.
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Nov 12, 2010 : release under 12.3 with IP blocks ported to AXI
-- Additional Comments:
-------------------------------------------------------------------------------------
-- Luc Langlois
-- July 2011 : 
--    - Increased DAC sampling rate to 245.76 MSPS, intended for 2X interpolation in DAC3283 for 491.52 MSPS output
--    - Updated control signaling between DDS, complex multipler to use standard AXI flow control
--
--  June 4 2013:
--		-Updated to Vivado 2013.2  
--      -upgraded FIR and complex multiplier IP
--      -Commented out black box in complex_mixer VHDL
--
--  July 20 2013:
--		- Complex multiplier output:
--          - IP lacks rounding function, so ...
--          - Added rounding from 17_1 to 16_0 to match MATLAB model
--
-- Notes: 
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity complex_mixer is
	port (
		resetn: IN std_logic;
		clk: IN std_logic;
		vin: IN std_logic;
		OE:  IN std_logic;
		DIN_I: IN std_logic_vector(17 downto 0);
		DIN_Q: IN std_logic_vector(17 downto 0);
		Dout_I: OUT std_logic_vector(15 downto 0);
		Dout_Q: OUT std_logic_vector(15 downto 0);
		dds_vout: OUT std_logic;
		cmplx_mult_vout: OUT std_logic
		);
end complex_mixer;

architecture structural of complex_mixer is

	component dds_duc
		port (
			aclk: IN std_logic;
			aclken: IN std_logic;
			aresetn: IN std_logic;
			m_axis_data_tvalid: OUT std_logic;
			m_axis_data_tdata: OUT std_logic_VECTOR(47 downto 0));
   end component;

	component complex_multiplier_DUC
		port (
			aclk: IN std_logic;
			s_axis_a_tready: OUT std_logic;
			s_axis_a_tvalid: IN std_logic;
			s_axis_a_tdata: IN std_logic_VECTOR(47 downto 0);
			s_axis_b_tvalid: IN std_logic;
			s_axis_b_tready: OUT std_logic;
			s_axis_b_tdata: IN std_logic_VECTOR(47 downto 0);
			m_axis_dout_tvalid: OUT std_logic;
			m_axis_dout_tready: IN std_logic;
			m_axis_dout_tdata: OUT std_logic_VECTOR(47 downto 0));
	end component;

	-- Synplicity black box declaration
--	attribute syn_black_box : boolean;
--	attribute syn_black_box of complex_multiplier_DUC: component is true;

	signal dds_reset_int, areset_int : std_logic;
	signal dds_rfd : std_logic;
	signal cmplx_mult_m_axis_dout_tvalid : std_logic;
	signal duc_dds_m_axis_data_tvalid : std_logic := '0';
	signal duc_dds_m_axis_data_tvalid_r : std_logic := '0';
	signal duc_dds_m_axis_data_tvalid_rr : std_logic := '0';
	signal duc_dds_m_axis_data_tvalid_rrr : std_logic := '0';
	signal duc_dds_m_axis_data_tvalid_rrrr : std_logic := '0';
	signal dds_sine_cosine, dds_sine_cosine_r, s_axis_b_tdata : std_logic_vector(47 downto 0) := (others => '0');
	signal s_axis_config_tdata: std_logic_vector(31 downto 0) :=  (others => '0');
	signal m_axis_dout_tdata : std_logic_vector(47 downto 0) :=  (others => '0');
	signal Dout_I_signed, Dout_Q_signed : signed(16 downto 0);
	signal Dout_I_signed_plus_1, Dout_Q_signed_plus_1 : signed(16 downto 0);
	signal cosine : std_logic_vector(17 downto 0);
	signal sine : std_logic_vector(17 downto 0);
	
	signal Din_re : std_logic_vector(17 downto 0);
	signal Din_im : std_logic_vector(17 downto 0);
	signal cmplx_mult_m_axis_dout_tready : std_logic;
	signal vin_r, vin_rr : std_logic;
	signal resetn_r : std_logic;
	signal vout : std_logic;

begin
	
	process(clk)		-- register all inputs
	begin
		if rising_edge(clk) then
			vin_r <= vin;
			vin_rr <= vin_r;	-- extra delay on DDS start-up to compensate latency from last-stage DUC FIR and align with MATLAB model, which doesn't account for any FIR latency
			resetn_r <= resetn;
		end if;
	end process;
	
	Din_re <= DIN_I;
	Din_im <= DIN_Q;

	-- dds core to generate sinusoidal waveforms
--	s_axis_config_tdata (27 downto 0) <= freq;
	dds0 : dds_duc
		port map (
			aclk => clk,
			aclken => vin_rr,
			aresetn => resetn_r,
			m_axis_data_tvalid => duc_dds_m_axis_data_tvalid,
			m_axis_data_tdata => dds_sine_cosine);
				
	make_dds_delay: process(clk)		-- extra delay on DDS output to compensate latency from last-stage DUC FIR and align with MATLAB model, which doesn't account for any FIR latency
	begin
		if rising_edge(clk) then
		    if (resetn = '0') then
		      duc_dds_m_axis_data_tvalid_r <= '0';
		      duc_dds_m_axis_data_tvalid_rr <= '0';
		      duc_dds_m_axis_data_tvalid_rrr <= '0';
		      duc_dds_m_axis_data_tvalid_rrrr <= '0';
		    else
		      dds_sine_cosine_r <= dds_sine_cosine;
			  duc_dds_m_axis_data_tvalid_r <= duc_dds_m_axis_data_tvalid;
			  duc_dds_m_axis_data_tvalid_rr <= duc_dds_m_axis_data_tvalid_r;
			  duc_dds_m_axis_data_tvalid_rrr <= duc_dds_m_axis_data_tvalid_rr;
			  duc_dds_m_axis_data_tvalid_rrrr <= duc_dds_m_axis_data_tvalid_rrr;
			end if;
		end if;
	end process make_dds_delay;
				
	sine   <= dds_sine_cosine_r(41 downto 24);
	cosine <= dds_sine_cosine_r(17 downto 0);

	-- mix sin/cos with data from interpolation filters using CoreGen complex mixer v3.1
	s_axis_b_tdata(17 downto 0) <= Din_re;
	s_axis_b_tdata(41 downto 24) <= Din_im;
	complex_mult: complex_multiplier_DUC
	   port map (
			aclk => clk,
			s_axis_a_tvalid => duc_dds_m_axis_data_tvalid_r,
--			s_axis_a_tready =>
			s_axis_a_tdata => dds_sine_cosine_r,
			s_axis_b_tvalid => '1',				-- 'm_axis_dout_tvalid' from DUC FIFO
--			s_axis_b_tready =>
			s_axis_b_tdata => s_axis_b_tdata,
			m_axis_dout_tvalid => cmplx_mult_m_axis_dout_tvalid,
			m_axis_dout_tready => cmplx_mult_m_axis_dout_tready,
			m_axis_dout_tdata => m_axis_dout_tdata);

    -- Complex multiplier IP lacks rounding function, so must perform ...
    -- rounding from 17_1 to 16_0 to match MATLAB model
    Dout_I_signed <= signed(m_axis_dout_tdata(16 downto 0));
    Dout_q_signed <= signed(m_axis_dout_tdata(40 downto 24));
    
    dout_register: process(clk)
    begin
        if rising_edge(clk) then	-- pipeline 'addition + 1' operation
            Dout_I_signed_plus_1 <= Dout_I_signed + 1;
            Dout_Q_signed_plus_1 <= Dout_Q_signed + 1;
        end if;
    end process dout_register;    

    Dout_I <= std_logic_vector(Dout_I_signed_plus_1(16 downto 1));
    Dout_Q <= std_logic_vector(Dout_Q_signed_plus_1(16 downto 1));
        
	cmplx_mult_m_axis_dout_tready	<= OE;		-- allow back-pressure from DDC to delay data output of DUC complex mixer until DDC DDS start-up has completed
	cmplx_mult_vout	 <= cmplx_mult_m_axis_dout_tvalid;
	dds_vout <= duc_dds_m_axis_data_tvalid_rrrr;
	
end structural;
