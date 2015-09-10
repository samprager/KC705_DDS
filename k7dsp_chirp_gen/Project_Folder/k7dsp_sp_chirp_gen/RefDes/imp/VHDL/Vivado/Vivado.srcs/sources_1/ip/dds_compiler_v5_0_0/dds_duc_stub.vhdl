-- Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2014.2 (win64) Build 932637 Wed Jun 11 13:33:10 MDT 2014
-- Date        : Fri Jun 26 18:19:55 2015
-- Host        : radar-PC running 64-bit Service Pack 1  (build 7601)
-- Command     : write_vhdl -force -mode synth_stub
--               C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/dds_compiler_v5_0_0/dds_duc_stub.vhdl
-- Design      : dds_duc
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k325tffg900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dds_duc is
  Port ( 
    aclk : in STD_LOGIC;
    aclken : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 47 downto 0 );
    event_pinc_invalid : out STD_LOGIC;
    event_poff_invalid : out STD_LOGIC
  );

end dds_duc;

architecture stub of dds_duc is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "aclk,aclken,aresetn,m_axis_data_tvalid,m_axis_data_tdata[47:0],event_pinc_invalid,event_poff_invalid";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "dds_compiler_v6_0,Vivado 2014.2";
begin
end;
