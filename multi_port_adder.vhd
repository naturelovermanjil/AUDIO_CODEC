-------------------------------------------------------------------------------
-- Title      : COMP.CE.240, Exercise 04
-- Project    : 
-------------------------------------------------------------------------------
-- File       : multi_port_adder.vhd
-- Author     : Group 27: Tomas Rinne & Manjil Basnet
-- Company    : TUT/DCS
-- Created    : 2008-11-28
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Component for adding multiple operands
-------------------------------------------------------------------------------
-- Copyright (c) 2008 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-02-12  1.0      Group 27    Created
-------------------------------------------------------------------------------



-- Include default libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


use work.all;

entity multi_port_adder is
  generic(
    operand_width_g   : integer := 16;
    num_of_operands_g : integer
    );
  port(
    clk         : in  std_logic;
    rst_n       : in  std_logic;
    operands_in : in  std_logic_vector(operand_width_g*num_of_operands_g-1 downto 0);
    sum_out     : out std_logic_vector(operand_width_g-1 downto 0)
    );
end entity multi_port_adder;

architecture structural of multi_port_adder is
  component adder is
    generic (
      operand_width_g : integer
      );
    port(
      clk     : in  std_logic;
      rst_n   : in  std_logic;
      a_in    : in  std_logic_vector(operand_width_g-1 downto 0);
      b_in    : in  std_logic_vector(operand_width_g-1 downto 0);
      sum_out : out std_logic_vector(operand_width_g downto 0)
      );
  end component;

  type subtotal_type is array (0 to num_of_operands_g / 2 - 1) of std_logic_vector(operand_width_g downto 0);
  signal subtotal : subtotal_type;
  signal total    : std_logic_vector(operand_width_g+1 downto 0);
begin
  adder1 : adder
    generic map(
      operand_width_g => operand_width_g
      )
    port map(
      clk     => clk,
      rst_n   => rst_n,
      a_in    => operands_in(operand_width_g * 3 -1 downto operand_width_g *2),
      b_in    => operands_in(operand_width_g * 4 -1 downto operand_width_g * 3),
      sum_out => subtotal(0));
  adder2 : adder
    generic map(
      operand_width_g => operand_width_g
      )
    port map(
      clk     => clk,
      rst_n   => rst_n,
      a_in    => operands_in(operand_width_g-1 downto 0),
      b_in    => operands_in(operand_width_g * 2 -1 downto operand_width_g),
      sum_out => subtotal(1));
  adder_total : adder
    generic map(
      operand_width_g => operand_width_g
      )
    port map(
      clk     => clk,
      rst_n   => rst_n,
      a_in    => subtotal(0)(operand_width_g-1 downto 0),
      b_in    => subtotal(1)(operand_width_g-1 downto 0),
      sum_out => total(operand_width_g downto 0));
  sum_out <= total(operand_width_g-1 downto 0);

  assert num_of_operands_g = 4 report "The total number operands must always be 4" severity failure;
end structural;
