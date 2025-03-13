-------------------------------------------------------------------------------
-- Title      : COMP.CE.240, Exercise 03
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adder.vhd
-- Author     : Group 27: Tomas Rinne & Manjil Basnet
-- Company    : TUT/DCS
-- Created    : 2008-11-28
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


use work.all;

entity adder is
  generic(
    operand_width_g : integer
    );
  port(
    clk     : in  std_logic;
    rst_n   : in  std_logic;
    a_in    : in  std_logic_vector(operand_width_g-1 downto 0);
    b_in    : in  std_logic_vector(operand_width_g-1 downto 0);
    sum_out : out std_logic_vector(operand_width_g downto 0)
    );
end entity adder;

architecture rtl of adder is
-- using the signed signal results in a metavalue, not using it passes the test bench so is there a point using it?
-- signal result : signed;
begin
-- sum_out <= std_logic_vector(result);
  sum : process(clk, rst_n)
  begin
    if (rst_n = '0') then
      -- result <= (others => '0');
      sum_out <= (others => '0');
    elsif (clk'event and clk = '1') then
      sum_out <= std_logic_vector(resize(signed(a_in), operand_width_g+1) + resize(signed(b_in), operand_width_g+1));
    end if;
  end process sum;
end rtl;
