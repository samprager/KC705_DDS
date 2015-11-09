-- Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2014.2 (win64) Build 928826 Thu Jun  5 18:17:50 MDT 2014
-- Date        : Sat Jun 07 13:26:49 2014
-- Host        : XCOJAMESM22 running 64-bit Service Pack 1  (build 7601)
-- Command     : write_vhdl -force -mode synth_stub
--               C:/kc705_mig/mig_7series_0_example/mig_7series_0_example.srcs/sources_1/ip/ila_ddrx_native/ila_ddrx_native_stub.vhdl
-- Design      : ila_ddrx_native
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k325tffg900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ila_ddrx_native is
  Port ( 
    clk : in STD_LOGIC;
    trig_out : out STD_LOGIC;
    trig_out_ack : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe2 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe3 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe4 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe5 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe6 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe7 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe8 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe9 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe10 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    probe11 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    probe12 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    probe13 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe14 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe15 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe16 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe17 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe18 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe19 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe20 : in STD_LOGIC_VECTOR ( 63 downto 0 );
    probe21 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe22 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe23 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe24 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe25 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe26 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe27 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe28 : in STD_LOGIC_VECTOR ( 63 downto 0 );
    probe29 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe30 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe31 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    probe32 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe33 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe34 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe35 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe36 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    probe37 : in STD_LOGIC_VECTOR ( 4 downto 0 );
    probe38 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe39 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe40 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe41 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe42 : in STD_LOGIC_VECTOR ( 2 downto 0 );
    probe43 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe44 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe45 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe46 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe47 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe48 : in STD_LOGIC_VECTOR ( 4 downto 0 );
    probe49 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe50 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe51 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe52 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe53 : in STD_LOGIC_VECTOR ( 4 downto 0 );
    probe54 : in STD_LOGIC_VECTOR ( 4 downto 0 );
    probe55 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe56 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe57 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe58 : in STD_LOGIC_VECTOR ( 53 downto 0 );
    probe59 : in STD_LOGIC_VECTOR ( 26 downto 0 );
    probe60 : in STD_LOGIC_VECTOR ( 11 downto 0 );
    probe61 : in STD_LOGIC_VECTOR ( 11 downto 0 );
    probe62 : in STD_LOGIC_VECTOR ( 11 downto 0 );
    probe63 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe64 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe65 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe66 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe67 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe68 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe69 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe70 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe71 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe72 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe73 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe74 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe75 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe76 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe77 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe78 : in STD_LOGIC_VECTOR ( 4 downto 0 );
    probe79 : in STD_LOGIC_VECTOR ( 11 downto 0 );
    probe80 : in STD_LOGIC_VECTOR ( 11 downto 0 );
    probe81 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe82 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe83 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe84 : in STD_LOGIC_VECTOR ( 107 downto 0 );
    probe85 : in STD_LOGIC_VECTOR ( 107 downto 0 );
    probe86 : in STD_LOGIC_VECTOR ( 107 downto 0 );
    probe87 : in STD_LOGIC_VECTOR ( 89 downto 0 );
    probe88 : in STD_LOGIC_VECTOR ( 254 downto 0 );
    probe89 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe90 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe91 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe92 : in STD_LOGIC_VECTOR ( 5 downto 0 );
    probe93 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe94 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe95 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe96 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe97 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe98 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe99 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe100 : in STD_LOGIC_VECTOR ( 7 downto 0 );
    probe101 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe102 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe103 : in STD_LOGIC_VECTOR ( 0 to 0 )
  );

end ila_ddrx_native;

architecture stub of ila_ddrx_native is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,trig_out,trig_out_ack,probe0[0:0],probe1[0:0],probe2[0:0],probe3[0:0],probe4[0:0],probe5[0:0],probe6[0:0],probe7[0:0],probe8[0:0],probe9[0:0],probe10[1:0],probe11[1:0],probe12[1:0],probe13[0:0],probe14[0:0],probe15[0:0],probe16[0:0],probe17[0:0],probe18[5:0],probe19[0:0],probe20[63:0],probe21[0:0],probe22[0:0],probe23[0:0],probe24[0:0],probe25[0:0],probe26[0:0],probe27[0:0],probe28[63:0],probe29[7:0],probe30[7:0],probe31[31:0],probe32[5:0],probe33[0:0],probe34[0:0],probe35[0:0],probe36[1:0],probe37[4:0],probe38[3:0],probe39[0:0],probe40[0:0],probe41[5:0],probe42[2:0],probe43[5:0],probe44[0:0],probe45[0:0],probe46[5:0],probe47[5:0],probe48[4:0],probe49[5:0],probe50[0:0],probe51[0:0],probe52[3:0],probe53[4:0],probe54[4:0],probe55[0:0],probe56[0:0],probe57[3:0],probe58[53:0],probe59[26:0],probe60[11:0],probe61[11:0],probe62[11:0],probe63[5:0],probe64[3:0],probe65[7:0],probe66[7:0],probe67[7:0],probe68[7:0],probe69[7:0],probe70[7:0],probe71[7:0],probe72[7:0],probe73[0:0],probe74[0:0],probe75[5:0],probe76[5:0],probe77[5:0],probe78[4:0],probe79[11:0],probe80[11:0],probe81[5:0],probe82[5:0],probe83[5:0],probe84[107:0],probe85[107:0],probe86[107:0],probe87[89:0],probe88[254:0],probe89[0:0],probe90[0:0],probe91[5:0],probe92[5:0],probe93[7:0],probe94[7:0],probe95[7:0],probe96[7:0],probe97[7:0],probe98[7:0],probe99[7:0],probe100[7:0],probe101[0:0],probe102[0:0],probe103[0:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "ila,Vivado 2014.2";
begin
end;
