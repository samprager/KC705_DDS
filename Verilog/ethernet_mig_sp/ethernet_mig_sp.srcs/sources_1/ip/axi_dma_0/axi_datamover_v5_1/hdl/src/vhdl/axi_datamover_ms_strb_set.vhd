-------------------------------------------------------------------------------
-- axi_datamover_ms_strb_set.vhd
-------------------------------------------------------------------------------
--
-- *************************************************************************
--                                                                      
--  (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
--
--  This file contains confidential and proprietary information
--  of Xilinx, Inc. and is protected under U.S. and
--  international copyright and other intellectual property
--  laws.
--
--  DISCLAIMER
--  This disclaimer is not a license and does not grant any
--  rights to the materials distributed herewith. Except as
--  otherwise provided in a valid license issued to you by
--  Xilinx, and to the maximum extent permitted by applicable
--  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
--  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
--  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
--  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
--  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
--  (2) Xilinx shall not be liable (whether in contract or tort,
--  including negligence, or under any other theory of
--  liability) for any loss or damage of any kind or nature
--  related to, arising under or in connection with these
--  materials, including for any direct, or any indirect,
--  special, incidental, or consequential loss or damage
--  (including loss of data, profits, goodwill, or any type of
--  loss or damage suffered as a result of any action brought
--  by a third party) even if such damage or loss was
--  reasonably foreseeable or Xilinx had been advised of the
--  possibility of the same.
--
--  CRITICAL APPLICATIONS
--  Xilinx products are not designed or intended to be fail-
--  safe, or for use in any application requiring fail-safe
--  performance, such as life-support or safety devices or
--  systems, Class III medical devices, nuclear facilities,
--  applications related to the deployment of airbags, or any
--  other applications that could lead to death, personal
--  injury, or severe property or environmental damage
--  (individually and collectively, "Critical
--  Applications"). Customer assumes the sole risk and
--  liability of any use of Xilinx products in Critical
--  Applications, subject only to applicable laws and
--  regulations governing limitations on product liability.
--
--  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
--  PART OF THIS FILE AT ALL TIMES. 
--
-- *************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        axi_datamover_ms_strb_set.vhd
--
-- Description:     
--   This module implements a function to detect the most significant strobe 
--  bit asserted and outputs the index value of that strobe bit. It can only 
--  be used in applications where the asserted strobe bits are contiguous and
--  always asserted from LS to MS bit positions,
--  
--                  
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   
--              axi_datamover_ms_strb_set.vhd
--
-------------------------------------------------------------------------------
-- Revision History:
--
--
-- Author:          DET
--
-- History:
--   DET   04/19/2011       Initial Version for EDK 13.3
--
--     DET     6/20/2011     Initial Version for EDK 13.3
-- ~~~~~~
--     - Added 512 and 1024 data width support
-- ^^^^^^
--
--
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;




-------------------------------------------------------------------------------

entity axi_datamover_ms_strb_set is
  generic (
    
    C_STRB_WIDTH     : Integer := 8; 
    -- Sets the width of the input strobe port
    
    C_INDEX_WIDTH    : Integer := 3 
    -- Sets the  width of the ms_strb_index output port 
    -- Should be log2(C_STRB_WIDTH)
    
    );
  port (
    
    -- Input strobe value ------------------------------------------------
    strbs_in         : in  std_logic_vector(C_STRB_WIDTH-1 downto 0);   --
    ----------------------------------------------------------------------
    
      
    -- Specifies the index of the most significant strobe set ------------
    ms_strb_index    : out std_logic_vector(C_INDEX_WIDTH-1 downto 0);  --
    ----------------------------------------------------------------------
      
      
    -- Invalid strobe input Indcation ------------------------------------
    strb_error       : Out std_logic                                    --
      -- Indicates an error with the strobe input, either a hole in the --
      -- asserted strobes or not asserted from LS bits upwards.         --
    ----------------------------------------------------------------------
    
    );

end entity axi_datamover_ms_strb_set;


architecture implementation of axi_datamover_ms_strb_set is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";


  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_ms_index_2
  --
  -- Function Description:
  --   Returns the index of the most significant strobe set in a 
  -- 2-bit wide strobe value.
  --
  -------------------------------------------------------------------
  function get_ms_index_2 (input_strobe : std_logic_vector) return natural is
  
    Variable var_ms_strb_index : natural := 0;
    Variable var_strb_value : std_logic_vector(1 downto 0);
    
  begin
  
    var_strb_value := input_strobe(1 downto 0);
    
    
    case var_strb_value is
      when "01" =>
        var_ms_strb_index := 0;
      when "11" | "10" =>
        var_ms_strb_index := 1;
      when others =>
        var_ms_strb_index := 2;
    end case;
   
    Return (var_ms_strb_index);
   
  end function get_ms_index_2; 
  
  
  
  
  
  
  
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_ms_index_4
  --
  -- Function Description:
  --   Returns the index of the most significant strobe set in a 
  -- 4-bit wide strobe value.
  --
  -------------------------------------------------------------------
  function get_ms_index_4 (input_strobe : std_logic_vector) return natural is
  
    Variable var_ms_strb_index : natural := 0;
    Variable var_strb_value : std_logic_vector(3 downto 0);
  
  begin

    var_strb_value := input_strobe(3 downto 0);

  
    case var_strb_value is
      when "0001" =>
        var_ms_strb_index := 0;
      when "0011" | "0010" =>
        var_ms_strb_index := 1;
      when "0111" | "0110" | "0100" =>
        var_ms_strb_index := 2;
      when "1111" | "1110" | "1100" | "1000"=>
        var_ms_strb_index := 3;
      when others =>
        var_ms_strb_index := 4;
    end case;
   
    Return (var_ms_strb_index);
   
  end function get_ms_index_4; 
  
  
  
  
  
  
  
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_ms_index_8
  --
  -- Function Description:
  --   Returns the index of the most significant strobe set in a 
  -- 8-bit wide strobe value.
  --
  -- Note that this function expects an input vector marking the
  -- assertion/deassertion boundaries, not the actual strobe vector.
  --
  -------------------------------------------------------------------
  function get_ms_index_8 (input_strobe : std_logic_vector) return natural is
  
    Variable var_ms_strb_index : natural := 0;
    Variable var_strb_value    : std_logic_vector(7 downto 0);
  
  begin
  
    var_strb_value := input_strobe(7 downto 0);
    
    
    case var_strb_value is
      when "00000001" =>
        var_ms_strb_index := 0;
      when "00000010" =>
        var_ms_strb_index := 1;
      when "00000100" =>
        var_ms_strb_index := 2;
      when "00001000" =>
        var_ms_strb_index := 3;
      when "00010000" =>
        var_ms_strb_index := 4;
      when "00100000" =>
        var_ms_strb_index := 5;
      when "01000000" =>
        var_ms_strb_index := 6;
      when "10000000" =>
        var_ms_strb_index := 7;
      when others =>
        var_ms_strb_index := 8;
    end case;
   
   
    Return (var_ms_strb_index);
   
  end function get_ms_index_8; 
  
  
  
  
  
  
  
  
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_ms_index_16
  --
  -- Function Description:
  --   Returns the index of the most significant strobe set in a 
  -- 16-bit wide strobe value.
  --
  --
  -- Note that this function expects an input vector marking the
  -- assertion/deassertion boundaries, not the actual strobe vector.
  --
  -------------------------------------------------------------------
  function get_ms_index_16 (input_strobe : std_logic_vector) return natural is
  
    Variable var_ms_strb_index : natural := 0;
    Variable var_strb_value : std_logic_vector(15 downto 0);
    
  begin
  
    var_strb_value := input_strobe(15 downto 0);
    
    
    case var_strb_value is
      when "0000000000000001" =>
        var_ms_strb_index :=  0;
      when "0000000000000010" =>
        var_ms_strb_index :=  1;
      when "0000000000000100" =>
        var_ms_strb_index :=  2;
      when "0000000000001000" =>
        var_ms_strb_index :=  3;
      when "0000000000010000" =>
        var_ms_strb_index :=  4;
      when "0000000000100000" =>
        var_ms_strb_index :=  5;
      when "0000000001000000" =>
        var_ms_strb_index :=  6;
      when "0000000010000000" =>
        var_ms_strb_index :=  7;
      when "0000000100000000" =>
        var_ms_strb_index :=  8;
      when "0000001000000000" =>
        var_ms_strb_index :=  9;
      when "0000010000000000" =>
        var_ms_strb_index := 10;
      when "0000100000000000" =>
        var_ms_strb_index := 11;
      when "0001000000000000" =>
        var_ms_strb_index := 12;
      when "0010000000000000" =>
        var_ms_strb_index := 13;
      when "0100000000000000" =>
        var_ms_strb_index := 14;
      when "1000000000000000" =>
        var_ms_strb_index := 15;
      when others =>
        var_ms_strb_index := 16;
    end case;
   
   
    Return (var_ms_strb_index);
   
  end function get_ms_index_16;
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_ms_index_32
  --
  -- Function Description:
  --   Returns the index of the most significant strobe set in a 
  -- 32-bit wide strobe value.
  --
  --
  -- Note that this function expects an input vector marking the
  -- assertion/deassertion boundaries, not the actual strobe vector.
  --
  -------------------------------------------------------------------
  function get_ms_index_32 (input_strobe : std_logic_vector) return natural is
  
    Variable var_ms_strb_index : natural := 0;
    Variable var_strb_value : std_logic_vector(31 downto 0);
    
  begin
  
    var_strb_value := input_strobe(31 downto 0);
    
    
    case var_strb_value is
      when "00000000000000000000000000000001" =>
        var_ms_strb_index := 0;
      when "00000000000000000000000000000010" =>            
        var_ms_strb_index := 1;
      when "00000000000000000000000000000100" =>
        var_ms_strb_index := 2;
      when "00000000000000000000000000001000" =>
        var_ms_strb_index := 3;
      when "00000000000000000000000000010000" =>
        var_ms_strb_index := 4;
      when "00000000000000000000000000100000" =>
        var_ms_strb_index := 5;
      when "00000000000000000000000001000000" =>
        var_ms_strb_index := 6;
      when "00000000000000000000000010000000" =>
        var_ms_strb_index := 7;
      when "00000000000000000000000100000000" =>
        var_ms_strb_index := 8;
      when "00000000000000000000001000000000" =>
        var_ms_strb_index := 9;
      when "00000000000000000000010000000000" =>
        var_ms_strb_index := 10;
      when "00000000000000000000100000000000" =>
        var_ms_strb_index := 11;
      when "00000000000000000001000000000000" =>
        var_ms_strb_index := 12;
      when "00000000000000000010000000000000" =>
        var_ms_strb_index := 13;
      when "00000000000000000100000000000000" =>
        var_ms_strb_index := 14;
      when "00000000000000001000000000000000" =>
        var_ms_strb_index := 15;
      when "00000000000000010000000000000000" =>
        var_ms_strb_index := 16;
      when "00000000000000100000000000000000" =>
        var_ms_strb_index := 17;
      when "00000000000001000000000000000000" =>
        var_ms_strb_index := 18;
      when "00000000000010000000000000000000" =>
        var_ms_strb_index := 19;
      when "00000000000100000000000000000000" =>
        var_ms_strb_index := 20;
      when "00000000001000000000000000000000" =>
        var_ms_strb_index := 21;
      when "00000000010000000000000000000000" =>
        var_ms_strb_index := 22;
      when "00000000100000000000000000000000" =>
        var_ms_strb_index := 23;
      when "00000001000000000000000000000000" =>
        var_ms_strb_index := 24;
      when "00000010000000000000000000000000" =>
        var_ms_strb_index := 25;
      when "00000100000000000000000000000000" =>
        var_ms_strb_index := 26;
      when "00001000000000000000000000000000" =>
        var_ms_strb_index := 27;
      when "00010000000000000000000000000000" =>
        var_ms_strb_index := 28;
      when "00100000000000000000000000000000" =>
        var_ms_strb_index := 29;
      when "01000000000000000000000000000000" =>
        var_ms_strb_index := 30;
      when "10000000000000000000000000000000" =>
        var_ms_strb_index := 31;
      when others =>
        var_ms_strb_index := 32;
    end case;
   
   
    Return (var_ms_strb_index);
   
  end function get_ms_index_32;
  
  
 
 
 
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_ms_index_64
  --
  -- Function Description:
  --   Returns the index of the most significant strobe set in a 
  -- 64-bit wide strobe value.
  --
  --
  -- Note that this function expects an input vector marking the
  -- assertion/deassertion boundaries, not the actual strobe vector.
  --
  -------------------------------------------------------------------
  function get_ms_index_64 (input_strobe : std_logic_vector) return natural is
  
    Variable var_ms_strb_index : natural := 0;
    Variable var_strb_value    : std_logic_vector(63 downto 0);
    
  begin
  
    var_strb_value := input_strobe(63 downto 0);
    
    
    case var_strb_value is
      
      when "0000000000000000000000000000000000000000000000000000000000000001" =>
        var_ms_strb_index := 0;
      when "0000000000000000000000000000000000000000000000000000000000000010" =>            
        var_ms_strb_index := 1;
      when "0000000000000000000000000000000000000000000000000000000000000100" =>
        var_ms_strb_index := 2;
      when "0000000000000000000000000000000000000000000000000000000000001000" =>
        var_ms_strb_index := 3;
      when "0000000000000000000000000000000000000000000000000000000000010000" =>
        var_ms_strb_index := 4;
      when "0000000000000000000000000000000000000000000000000000000000100000" =>
        var_ms_strb_index := 5;
      when "0000000000000000000000000000000000000000000000000000000001000000" =>
        var_ms_strb_index := 6;
      when "0000000000000000000000000000000000000000000000000000000010000000" =>
        var_ms_strb_index := 7;
      when "0000000000000000000000000000000000000000000000000000000100000000" =>
        var_ms_strb_index := 8;
      when "0000000000000000000000000000000000000000000000000000001000000000" =>
        var_ms_strb_index := 9;
      when "0000000000000000000000000000000000000000000000000000010000000000" =>
        var_ms_strb_index := 10;
      when "0000000000000000000000000000000000000000000000000000100000000000" =>
        var_ms_strb_index := 11;
      when "0000000000000000000000000000000000000000000000000001000000000000" =>
        var_ms_strb_index := 12;
      when "0000000000000000000000000000000000000000000000000010000000000000" =>
        var_ms_strb_index := 13;
      when "0000000000000000000000000000000000000000000000000100000000000000" =>
        var_ms_strb_index := 14;
      when "0000000000000000000000000000000000000000000000001000000000000000" =>
        var_ms_strb_index := 15;
      when "0000000000000000000000000000000000000000000000010000000000000000" =>
        var_ms_strb_index := 16;
      when "0000000000000000000000000000000000000000000000100000000000000000" =>
        var_ms_strb_index := 17;
      when "0000000000000000000000000000000000000000000001000000000000000000" =>
        var_ms_strb_index := 18;
      when "0000000000000000000000000000000000000000000010000000000000000000" =>
        var_ms_strb_index := 19;
      when "0000000000000000000000000000000000000000000100000000000000000000" =>
        var_ms_strb_index := 20;
      when "0000000000000000000000000000000000000000001000000000000000000000" =>
        var_ms_strb_index := 21;
      when "0000000000000000000000000000000000000000010000000000000000000000" =>
        var_ms_strb_index := 22;
      when "0000000000000000000000000000000000000000100000000000000000000000" =>
        var_ms_strb_index := 23;
      when "0000000000000000000000000000000000000001000000000000000000000000" =>
        var_ms_strb_index := 24;
      when "0000000000000000000000000000000000000010000000000000000000000000" =>
        var_ms_strb_index := 25;
      when "0000000000000000000000000000000000000100000000000000000000000000" =>
        var_ms_strb_index := 26;
      when "0000000000000000000000000000000000001000000000000000000000000000" =>
        var_ms_strb_index := 27;
      when "0000000000000000000000000000000000010000000000000000000000000000" =>
        var_ms_strb_index := 28;
      when "0000000000000000000000000000000000100000000000000000000000000000" =>
        var_ms_strb_index := 29;
      when "0000000000000000000000000000000001000000000000000000000000000000" =>
        var_ms_strb_index := 30;
      when "0000000000000000000000000000000010000000000000000000000000000000" =>
        var_ms_strb_index := 31;
      
      when "0000000000000000000000000000000100000000000000000000000000000000" =>          
        var_ms_strb_index := 32;
      when "0000000000000000000000000000001000000000000000000000000000000000" =>            
        var_ms_strb_index := 33;
      when "0000000000000000000000000000010000000000000000000000000000000000" =>
        var_ms_strb_index := 34;
      when "0000000000000000000000000000100000000000000000000000000000000000" =>
        var_ms_strb_index := 35;
      when "0000000000000000000000000001000000000000000000000000000000000000" =>
        var_ms_strb_index := 36;
      when "0000000000000000000000000010000000000000000000000000000000000000" =>
        var_ms_strb_index := 37;
      when "0000000000000000000000000100000000000000000000000000000000000000" =>
        var_ms_strb_index := 38;
      when "0000000000000000000000001000000000000000000000000000000000000000" =>
        var_ms_strb_index := 39;
      when "0000000000000000000000010000000000000000000000000000000000000000" =>
        var_ms_strb_index := 40;
      when "0000000000000000000000100000000000000000000000000000000000000000" =>
        var_ms_strb_index := 41;
      when "0000000000000000000001000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 42;
      when "0000000000000000000010000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 43;
      when "0000000000000000000100000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 44;
      when "0000000000000000001000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 45;
      when "0000000000000000010000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 46;
      when "0000000000000000100000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 47;
      when "0000000000000001000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 48;
      when "0000000000000010000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 49;
      when "0000000000000100000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 50;
      when "0000000000001000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 51;
      when "0000000000010000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 52;
      when "0000000000100000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 53;
      when "0000000001000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 54;
      when "0000000010000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 55;
      when "0000000100000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 56;
      when "0000001000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 57;
      when "0000010000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 58;
      when "0000100000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 59;
      when "0001000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 60;
      when "0010000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 61;
      when "0100000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 62;
      when "1000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 63;
      
      when others =>
        var_ms_strb_index := 64;
    end case;
   
   
    Return (var_ms_strb_index);
   
  end function get_ms_index_64;
  
  
  
 
 
 
 
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_ms_index_128
  --
  -- Function Description:
  --   Returns the index of the most significant strobe set in a 
  -- 64-bit wide strobe value.
  --
  --
  -- Note that this function expects an input vector marking the
  -- assertion/deassertion boundaries, not the actual strobe vector.
  --
  -------------------------------------------------------------------
  function get_ms_index_128 (input_strobe : std_logic_vector) return natural is
  
    Variable var_ms_strb_index : natural := 0;
    Variable var_strb_value    : std_logic_vector(127 downto 0);
    
  begin
  
    var_strb_value := input_strobe(127 downto 0);
    
    
    case var_strb_value is
      
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001" =>         
        var_ms_strb_index := 0;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010" =>            
        var_ms_strb_index := 1;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100" =>
        var_ms_strb_index := 2;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000" =>
        var_ms_strb_index := 3;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000" =>
        var_ms_strb_index := 4;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000" =>
        var_ms_strb_index := 5;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000" =>
        var_ms_strb_index := 6;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000" =>
        var_ms_strb_index := 7;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000" =>
        var_ms_strb_index := 8;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000" =>
        var_ms_strb_index := 9;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000" =>
        var_ms_strb_index := 10;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000" =>
        var_ms_strb_index := 11;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000" =>
        var_ms_strb_index := 12;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000" =>
        var_ms_strb_index := 13;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000" =>
        var_ms_strb_index := 14;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000" =>
        var_ms_strb_index := 15;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000" =>
        var_ms_strb_index := 16;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000" =>
        var_ms_strb_index := 17;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000" =>
        var_ms_strb_index := 18;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000" =>
        var_ms_strb_index := 19;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000" =>
        var_ms_strb_index := 20;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000" =>
        var_ms_strb_index := 21;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000" =>
        var_ms_strb_index := 22;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000" =>
        var_ms_strb_index := 23;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000" =>
        var_ms_strb_index := 24;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000" =>
        var_ms_strb_index := 25;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000" =>
        var_ms_strb_index := 26;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000" =>
        var_ms_strb_index := 27;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000" =>
        var_ms_strb_index := 28;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000" =>
        var_ms_strb_index := 29;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000" =>
        var_ms_strb_index := 30;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000" =>
        var_ms_strb_index := 31;
      
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000" =>          
        var_ms_strb_index := 32;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000" =>            
        var_ms_strb_index := 33;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000" =>
        var_ms_strb_index := 34;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000" =>
        var_ms_strb_index := 35;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000" =>
        var_ms_strb_index := 36;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000" =>
        var_ms_strb_index := 37;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000" =>
        var_ms_strb_index := 38;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000" =>
        var_ms_strb_index := 39;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000" =>
        var_ms_strb_index := 40;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000" =>
        var_ms_strb_index := 41;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 42;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 43;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 44;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 45;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 46;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 47;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 48;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 49;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 50;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 51;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 52;
      when "00000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 53;
      when "00000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 54;
      when "00000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 55;
      when "00000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 56;
      when "00000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 57;
      when "00000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 58;
      when "00000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 59;
      when "00000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 60;
      when "00000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 61;
      when "00000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 62;
      when "00000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 63;
      
      
      
      when "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000" =>                   
        var_ms_strb_index := 64;
      when "00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000" =>            
        var_ms_strb_index := 65;
      when "00000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 66;
      when "00000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 67;
      when "00000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 68;
      when "00000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 69;
      when "00000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 70;
      when "00000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 71;
      when "00000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 72;
      when "00000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 73;
      when "00000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 74;
      when "00000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 75;
      when "00000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 76;
      when "00000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 77;
      when "00000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 78;
      when "00000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 79;
      when "00000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 80;
      when "00000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 81;
      when "00000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 82;
      when "00000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 83;
      when "00000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 84;
      when "00000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 85;
      when "00000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 86;
      when "00000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 87;
      when "00000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 88;
      when "00000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 89;
      when "00000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 90;
      when "00000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 91;
      when "00000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 92;
      when "00000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 93;
      when "00000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 94;
      when "00000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 95;
      
      when "00000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>          
        var_ms_strb_index := 96;
      when "00000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>            
        var_ms_strb_index := 97;
      when "00000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 98;
      when "00000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 99;
      when "00000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 100;
      when "00000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 101;
      when "00000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 102;
      when "00000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 103;
      when "00000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 104;
      when "00000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 105;
      when "00000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 106;
      when "00000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 107;
      when "00000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 108;
      when "00000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 109;
      when "00000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 110;
      when "00000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 111;
      when "00000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 112;
      when "00000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 113;
      when "00000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 114;
      when "00000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 115;
      when "00000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 116;
      when "00000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 117;
      when "00000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 118;
      when "00000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 119;
      when "00000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 120;
      when "00000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 121;
      when "00000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 122;
      when "00001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 123;
      when "00010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 124;
      when "00100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 125;
      when "01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 126;
      when "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" =>
        var_ms_strb_index := 127;
      
      when others =>
        var_ms_strb_index := 128;
    end case;
   
   
    Return (var_ms_strb_index);
   
  end function get_ms_index_128;
  
  
  
 
 
 
 
 
 
  
  -- Constants 
  Constant ERROR_INDEX   : natural := C_STRB_WIDTH;
  Constant TEMP_NAT_MAX  : natural := 255;  -- allows for a 0 to 255 strobe index value
  Constant TEMP_UN_WIDTH : natural :=   8;  -- 8 bits allows for a 0 to 255 index value
   
   
  
  
  -- Signals
  
  signal sig_input_stbs            : std_logic_vector(C_STRB_WIDTH-1 downto 0) := (others => '0');
  
  signal sig_ms_asserted_index_un  : unsigned(C_INDEX_WIDTH-1 downto 0) := (others => '0');
  
  signal sig_strb_error            : std_logic := '0';
 
  signal sig_temp_ms_index_un      : unsigned(TEMP_UN_WIDTH-1 downto 0) := (others => '0');
  
  signal sig_temp_ms_index_nat     : natural range 0 to TEMP_NAT_MAX := 0;




begin --(architecture implementation)

 
  -- Assign the ms asserted strobe value
  ms_strb_index  <= STD_LOGIC_VECTOR(sig_ms_asserted_index_un);
                                      
  
  -- Assign the input strobe
  sig_input_stbs <= strbs_in       ; -- assign input strobes
  
  -- Assign the strobe eror output
  strb_error     <= sig_strb_error ; -- assign the strobe error output
  
   
  
  
  
  
  -- Rip the valid index bits
  sig_ms_asserted_index_un   <= sig_temp_ms_index_un(C_INDEX_WIDTH-1 downto 0);
  
  
  
  -- Assert the Strobe Error output if an out of range index is returned
  
  sig_temp_ms_index_nat      <= TO_INTEGER(sig_ms_asserted_index_un) ;
  
  
  sig_strb_error <= '1'
    When (sig_temp_ms_index_nat >= ERROR_INDEX)
    else '0';


  
  
  
  
   






  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_1BIT_CASE
  --
  -- If Generate Description:
  --  Generates the MS asserted strobe index for the 
  -- 1-bit strobe width case.
  --
  --
  ------------------------------------------------------------
  GEN_1BIT_CASE : if (C_STRB_WIDTH = 1) generate
 
    
    begin
  
      sig_temp_ms_index_un   <= TO_UNSIGNED( 0, TEMP_UN_WIDTH);
      
    
    end generate GEN_1BIT_CASE;
  
  
  
  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_2BIT_CASE
  --
  -- If Generate Description:
  --  Generates the MS asserted strobe index for the 
  -- 2-bit strobe width case.
  --
  --
  ------------------------------------------------------------
  GEN_2BIT_CASE : if (C_STRB_WIDTH = 2) generate
    
    -- local signals
    Signal lsig_ms_asserted_index_nat : natural range 0 to TEMP_NAT_MAX := 0;
    
    begin
  
      
      lsig_ms_asserted_index_nat <= get_ms_index_2(sig_input_stbs);
      
      sig_temp_ms_index_un       <= TO_UNSIGNED(lsig_ms_asserted_index_nat, TEMP_UN_WIDTH);

  
    end generate GEN_2BIT_CASE;
  
  
  
  
  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_4BIT_CASE
  --
  -- If Generate Description:
  --  Generates the MS asserted strobe index for the 
  -- 4-bit strobe width case.
  --
  ------------------------------------------------------------
  GEN_4BIT_CASE : if (C_STRB_WIDTH = 4) generate
    
    -- local signals
    Signal lsig_ms_asserted_index_nat : natural range 0 to TEMP_NAT_MAX := 0;
    
    begin
      
      
      lsig_ms_asserted_index_nat <= get_ms_index_4(sig_input_stbs);
      
      sig_temp_ms_index_un       <= TO_UNSIGNED(lsig_ms_asserted_index_nat, TEMP_UN_WIDTH);

  
    end generate GEN_4BIT_CASE;
  
  
  
  
  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_8BIT_CASE
  --
  -- If Generate Description:
  --  Generates the MS asserted strobe index for the 
  -- 8-bit strobe width case.
  --
  ------------------------------------------------------------
  GEN_8BIT_CASE : if (C_STRB_WIDTH = 8) generate
    
    -- local signals
    Signal lsig_ms_asserted_index_nat  : natural range 0 to TEMP_NAT_MAX := 0;
    
    Signal lsig_strb_last_assert_vect  : std_logic_vector(C_STRB_WIDTH downto 0);
    Signal lsig_strb_test_vect         : std_logic_vector(C_STRB_WIDTH downto 0);
    
    
    begin
  
       -- Create a strobe vector with the most significant bit zeroed.
       lsig_strb_test_vect <=  '0' & sig_input_stbs;
       
       
      
       ------------------------------------------------------------
       -- For Generate
       --
       -- Label: GEN_ASSERT_BNDRY_CHK
       --
       -- For Generate Description:
       --  Find the assertion/deassertion boundaries in the input
       -- Strobe vector in the least to most significant index 
       -- direction.
       --
       --
       ------------------------------------------------------------
       GEN_ASSERT_BNDRY_CHK : for strb_index in 1 to C_STRB_WIDTH generate
       
       begin
       
         
          
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: IMP_FIND_DEASSERTION
         --
         -- Process Description:
         --  Detects the case when two adjoining strobe bits have an 
         -- assertion transition from asserted to deasserted moving
         -- from lower to higher bit ordering.
         --
         -------------------------------------------------------------
         IMP_FIND_DEASSERTION : process (lsig_strb_test_vect)
            begin
         
              if ((lsig_strb_test_vect(strb_index-1) = '1') and
                   (lsig_strb_test_vect(strb_index) = '0')) then
              
                 lsig_strb_last_assert_vect(strb_index-1) <= '1';
               
              else
              
                 lsig_strb_last_assert_vect(strb_index-1) <= '0';
               
              end if;
         
            end process IMP_FIND_DEASSERTION; 
         
         
         
       end generate GEN_ASSERT_BNDRY_CHK;
      
      
      
      
      
      lsig_ms_asserted_index_nat <= get_ms_index_8(lsig_strb_last_assert_vect);
      
      sig_temp_ms_index_un       <= TO_UNSIGNED(lsig_ms_asserted_index_nat, TEMP_UN_WIDTH);

  
    end generate GEN_8BIT_CASE;
  
  
  
  
  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_16BIT_CASE
  --
  -- If Generate Description:
  --  Generates the MS asserted strobe index for the 
  -- 16-bit strobe width case.
  --
  --
  ------------------------------------------------------------
  GEN_16BIT_CASE : if (C_STRB_WIDTH = 16) generate
    
    -- local signals
    Signal lsig_ms_asserted_index_nat : natural range 0 to TEMP_NAT_MAX := 0;
    
    Signal lsig_strb_last_assert_vect  : std_logic_vector(C_STRB_WIDTH downto 0);
    Signal lsig_strb_test_vect         : std_logic_vector(C_STRB_WIDTH downto 0);
    
    
    begin
  
       -- Create a strobe vector with the most significant bit zeroed.
       lsig_strb_test_vect <=  '0' & sig_input_stbs;
       
       
      
       ------------------------------------------------------------
       -- For Generate
       --
       -- Label: GEN_ASSERT_BNDRY_CHK
       --
       -- For Generate Description:
       --  Find the assertion/deassertion boundaries in the input
       -- Strobe vector in the least to most significant index 
       -- direction.
       --
       --
       ------------------------------------------------------------
       GEN_ASSERT_BNDRY_CHK : for strb_index in 1 to C_STRB_WIDTH generate
       
       begin
       
         
          
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: IMP_FIND_DEASSERTION
         --
         -- Process Description:
         --  Detects the case when two adjoining strobe bits have an 
         -- assertion transition from asserted to deasserted moving
         -- from lower to higher bit ordering.
         --
         -------------------------------------------------------------
         IMP_FIND_DEASSERTION : process (lsig_strb_test_vect)
            begin
         
              if ((lsig_strb_test_vect(strb_index-1) = '1') and
                   (lsig_strb_test_vect(strb_index) = '0')) then
              
                 lsig_strb_last_assert_vect(strb_index-1) <= '1';
               
              else
              
                 lsig_strb_last_assert_vect(strb_index-1) <= '0';
               
              end if;
         
            end process IMP_FIND_DEASSERTION; 
         
         
         
       end generate GEN_ASSERT_BNDRY_CHK;
      
      
      
      
      
      lsig_ms_asserted_index_nat <= get_ms_index_16(lsig_strb_last_assert_vect);
      
      sig_temp_ms_index_un       <= TO_UNSIGNED(lsig_ms_asserted_index_nat, TEMP_UN_WIDTH);

  
    end generate GEN_16BIT_CASE;
  
  
  
  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_32BIT_CASE
  --
  -- If Generate Description:
  --  Generates the MS asserted strobe index for the 
  -- 32-bit strobe width case.
  --
  ------------------------------------------------------------
  GEN_32BIT_CASE : if (C_STRB_WIDTH = 32) generate
    
    -- local signals
    Signal lsig_ms_asserted_index_nat : natural range 0 to TEMP_NAT_MAX := 0;
    
    Signal lsig_strb_last_assert_vect  : std_logic_vector(C_STRB_WIDTH downto 0);
    Signal lsig_strb_test_vect         : std_logic_vector(C_STRB_WIDTH downto 0);
    
    
    begin
  
       -- Create a strobe vector with the most significant bit zeroed.
       lsig_strb_test_vect <=  '0' & sig_input_stbs;
       
       
      
       ------------------------------------------------------------
       -- For Generate
       --
       -- Label: GEN_ASSERT_BNDRY_CHK
       --
       -- For Generate Description:
       --  Find the assertion/deassertion boundaries in the input
       -- Strobe vector in the least to most significant index 
       -- direction.
       --
       --
       ------------------------------------------------------------
       GEN_ASSERT_BNDRY_CHK : for strb_index in 1 to C_STRB_WIDTH generate
       
       begin
       
         
          
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: IMP_FIND_DEASSERTION
         --
         -- Process Description:
         --  Detects the case when two adjoining strobe bits have an 
         -- assertion transition from asserted to deasserted moving
         -- from lower to higher bit ordering.
         --
         -------------------------------------------------------------
         IMP_FIND_DEASSERTION : process (lsig_strb_test_vect)
            begin
         
              if ((lsig_strb_test_vect(strb_index-1) = '1') and
                   (lsig_strb_test_vect(strb_index) = '0')) then
              
                 lsig_strb_last_assert_vect(strb_index-1) <= '1';
               
              else
              
                 lsig_strb_last_assert_vect(strb_index-1) <= '0';
               
              end if;
         
            end process IMP_FIND_DEASSERTION; 
         
         
         
       end generate GEN_ASSERT_BNDRY_CHK;
      
      
      
      
      
      lsig_ms_asserted_index_nat <= get_ms_index_32(lsig_strb_last_assert_vect);
      
      sig_temp_ms_index_un       <= TO_UNSIGNED(lsig_ms_asserted_index_nat, TEMP_UN_WIDTH);

  
    end generate GEN_32BIT_CASE;
  
  
  
  
  
 
 
 
 
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_64BIT_CASE
  --
  -- If Generate Description:
  --  Generates the MS asserted strobe index for the 
  -- 64-bit strobe width case.
  --
  ------------------------------------------------------------
  GEN_64BIT_CASE : if (C_STRB_WIDTH = 64) generate
    
    -- local signals
    Signal lsig_ms_asserted_index_nat : natural range 0 to TEMP_NAT_MAX := 0;
    
    Signal lsig_strb_last_assert_vect  : std_logic_vector(C_STRB_WIDTH downto 0);
    Signal lsig_strb_test_vect         : std_logic_vector(C_STRB_WIDTH downto 0);
    
    
    begin
  
       -- Create a strobe vector with the most significant bit zeroed.
       lsig_strb_test_vect <=  '0' & sig_input_stbs;
       
       
      
       ------------------------------------------------------------
       -- For Generate
       --
       -- Label: GEN_ASSERT_BNDRY_CHK
       --
       -- For Generate Description:
       --  Find the assertion/deassertion boundaries in the input
       -- Strobe vector in the least to most significant index 
       -- direction.
       --
       --
       ------------------------------------------------------------
       GEN_ASSERT_BNDRY_CHK : for strb_index in 1 to C_STRB_WIDTH generate
       
       begin
       
         
          
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: IMP_FIND_DEASSERTION
         --
         -- Process Description:
         --  Detects the case when two adjoining strobe bits have an 
         -- assertion transition from asserted to deasserted moving
         -- from lower to higher bit ordering.
         --
         -------------------------------------------------------------
         IMP_FIND_DEASSERTION : process (lsig_strb_test_vect)
            begin
         
              if ((lsig_strb_test_vect(strb_index-1) = '1') and
                   (lsig_strb_test_vect(strb_index) = '0')) then
              
                 lsig_strb_last_assert_vect(strb_index-1) <= '1';
               
              else
              
                 lsig_strb_last_assert_vect(strb_index-1) <= '0';
               
              end if;
         
            end process IMP_FIND_DEASSERTION; 
         
         
         
       end generate GEN_ASSERT_BNDRY_CHK;
      
      
      
      
      
      lsig_ms_asserted_index_nat <= get_ms_index_64(lsig_strb_last_assert_vect);
      
      sig_temp_ms_index_un       <= TO_UNSIGNED(lsig_ms_asserted_index_nat, TEMP_UN_WIDTH);

  
    end generate GEN_64BIT_CASE;
  
  
  
  
  
 
 
 
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_128BIT_CASE
  --
  -- If Generate Description:
  --  Generates the MS asserted strobe index for the 
  -- 128-bit strobe width case.
  --
  ------------------------------------------------------------
  GEN_128BIT_CASE : if (C_STRB_WIDTH = 128) generate
    
    -- local signals
    Signal lsig_ms_asserted_index_nat : natural range 0 to TEMP_NAT_MAX := 0;
    
    Signal lsig_strb_last_assert_vect  : std_logic_vector(C_STRB_WIDTH downto 0);
    Signal lsig_strb_test_vect         : std_logic_vector(C_STRB_WIDTH downto 0);
    
    
    begin
  
       -- Create a strobe vector with the most significant bit zeroed.
       lsig_strb_test_vect <=  '0' & sig_input_stbs;
       
       
      
       ------------------------------------------------------------
       -- For Generate
       --
       -- Label: GEN_ASSERT_BNDRY_CHK
       --
       -- For Generate Description:
       --  Find the assertion/deassertion boundaries in the input
       -- Strobe vector in the least to most significant index 
       -- direction.
       --
       --
       ------------------------------------------------------------
       GEN_ASSERT_BNDRY_CHK : for strb_index in 1 to C_STRB_WIDTH generate
       
       begin
       
         
          
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: IMP_FIND_DEASSERTION
         --
         -- Process Description:
         --  Detects the case when two adjoining strobe bits have an 
         -- assertion transition from asserted to deasserted moving
         -- from lower to higher bit ordering.
         --
         -------------------------------------------------------------
         IMP_FIND_DEASSERTION : process (lsig_strb_test_vect)
            begin
         
              if ((lsig_strb_test_vect(strb_index-1) = '1') and
                   (lsig_strb_test_vect(strb_index) = '0')) then
              
                 lsig_strb_last_assert_vect(strb_index-1) <= '1';
               
              else
              
                 lsig_strb_last_assert_vect(strb_index-1) <= '0';
               
              end if;
         
            end process IMP_FIND_DEASSERTION; 
         
         
         
       end generate GEN_ASSERT_BNDRY_CHK;
      
      
      
      
      
      lsig_ms_asserted_index_nat <= get_ms_index_128(lsig_strb_last_assert_vect);
      
      sig_temp_ms_index_un       <= TO_UNSIGNED(lsig_ms_asserted_index_nat, TEMP_UN_WIDTH);

  
    end generate GEN_128BIT_CASE;
  
  
  
  
  
 
 
 
 


 


end implementation;
