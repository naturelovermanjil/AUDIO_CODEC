-------------------------------------------------------------------------------
-- Title      : COMP.CE.240, Exercise 02
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ripple_carry_adder.vhd
-- Author     : Group 27: Tomas Rinne & Manjil Basnet
-- Company    : TUT/DCS
-- Created    : 2023-02-28
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Tests all combinations of summing two 3-bit values
-------------------------------------------------------------------------------
-- Copyright (c) 2008 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-02-01  1.0      Group 27    Created
-------------------------------------------------------------------------------

-- Include default libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Include own logic (=compiled ripple_carry_adder)
use work.all;

entity ripple_carry_adder is
  port(
    a_in  : in  std_logic_vector(3-1 downto 0);
    b_in  : in  std_logic_vector(3-1 downto 0);
    s_out : out std_logic_vector(4-1 downto 0)
    );
end entity ripple_carry_adder;



-------------------------------------------------------------------------------

-- Architecture called 'gate' is already defined. Just fill it.
-- Architecture defines an implementation for an entity
architecture gate of ripple_carry_adder is
  signal Carry_ha, C, D, E, Carry_fa, F, G, H : std_logic;
begin  -- gate
  -- half adder
  s_out(0) <= a_in(0) xor b_in(0);
  Carry_ha <= a_in(0) and b_in(0);
  -- Full adder 1
  C        <= a_in(1) xor b_in(1);
  s_out(1) <= C xor Carry_ha;
  D        <= Carry_ha and C;
  E        <= a_in(1) and b_in(1);
  Carry_fa <= D or E;
  -- Full adder 2
  F        <= a_in(2) xor b_in(2);
  s_out(2) <= F xor Carry_fa;
  G        <= F and Carry_fa;
  H        <= a_in(2) and b_in(2);
  s_out(1) <= G or H;
end gate;
