-------------------------------------------------------------------------------
-- Title      : COMP.CE.240, Exercise 05
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_multi_port_adder.vhd
-- Author     : Group 27: Tomas Rinne & Manjil Basnet
-- Company    : TUT/DCS
-- Created    : 2008-11-28
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Test bench for multi_port_adder.vhd
-------------------------------------------------------------------------------
-- Copyright (c) 2008 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-02-12  1.0      Group 27    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.all;

entity tb_multi_port_adder is
  generic (
    operand_width_g : positive := 3
    );
end entity tb_multi_port_adder;

architecture testbench of tb_multi_port_adder is

  constant clock_period_c  : time    := 10 ns;
  constant operand_count_c : integer := 4;
  constant duv_delay_c     : integer := 2;

  signal clk            : std_logic                                  := '0';
  signal rst_n          : std_logic                                  := '0';
  signal operands_r     : std_logic_vector(operand_width_g*operand_count_c-1 downto 0);
  signal sum            : std_logic_vector(operand_width_g-1 downto 0);
  signal output_valid_r : std_logic_vector(duv_delay_c+1-1 downto 0) := (others => '0');

  file input_f       : text open read_mode is "input.txt";
  file ref_results_f : text open read_mode is "ref_results.txt";
  file output_f      : text open write_mode is "output.txt";

  -- Type to contain reference result lines
  type values_array is array (0 to operand_count_c - 1) of integer;

  component multi_port_adder is
    generic(
      operand_width_g   : integer;
      num_of_operands_g : integer
      );
    port(
      clk         : in  std_logic;
      rst_n       : in  std_logic;
      operands_in : in  std_logic_vector(operand_width_g*operand_count_c-1 downto 0);
      sum_out     : out std_logic_vector(operand_width_g-1 downto 0)
      );
  end component;

begin
  clk_gen : process
  begin
    clk <= not clk after clock_period_c / 2;
    wait for clock_period_c;
  end process;

  rst_n_gen : process
  begin
    rst_n <= '1' after 4 * clock_period_c;
    wait;
  end process;

  -- Instantiation of the multi_port_adder component
  multi_port_adder_inst : multi_port_adder
    generic map (
      operand_width_g   => operand_width_g,
      num_of_operands_g => operand_count_c
      )
    port map (
      clk         => clk,
      rst_n       => rst_n,
      operands_in => operands_r,
      sum_out     => sum
      );

  -- Process for reading reference results from file
  input_reader : process(clk, rst_n)
    variable line_v   : line;
    variable values_v : values_array;
  begin
    if rst_n = '0' then
      operands_r     <= (others => '0');
      output_valid_r <= (others => '0');
    elsif (clk'event and clk = '1') then
      -- Delay
      output_valid_r <= '1' & output_valid_r(duv_delay_c+1-1 downto 1);
      if not endfile(input_f) then
        readline(input_f, line_v);
        -- Loop to get all operands
        for i in 0 to operand_count_c-1 loop
          read(line_v, values_v(i));
        end loop;
        -- Convert array of integers to std_logic_vector
        for i in 0 to operand_count_c-1 loop
          operands_r((i+1)*operand_width_g-1 downto i*operand_width_g)
            <= std_logic_vector(to_signed(values_v(i), operand_width_g));
        end loop;
      end if;
    end if;
  end process;

  -- Process for comparing reference results to multi_port_adder output
  checker : process(clk)
    variable ref_line_v    : line;
    variable ref_value_v   : integer;
    variable output_line_v : line;
  begin
    if (clk'event and clk = '1') then
      if (output_valid_r(0) = '1') then  -- If delay completed
        if not endfile(ref_results_f) then
          readline(ref_results_f, ref_line_v);
          read(ref_line_v, ref_value_v);
          -- Check that sums match
          assert sum = std_logic_vector(to_signed(ref_value_v, operand_width_g))
            -- If not inform of failure
            report "Output does not match the reference value."
            severity failure;
          -- Write multi_port_adder output to file
          write(output_line_v, to_integer(to_signed(ref_value_v, operand_width_g)));
          writeline(output_f, output_line_v);
        else
          assert false report "Simulation done." severity failure;
        end if;
      end if;
    end if;
  end process checker;
end testbench;
