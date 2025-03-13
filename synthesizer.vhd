-------------------------------------------------------------------------------
-- Title      : COMP.CE.240, Exercise 06
-- Project    : 
-------------------------------------------------------------------------------
-- File       : synthesizer.vhd
-- Author     : Group 27: Tomas Rinne & Manjil Basnet
-- Company    : TUT/DCS
-- Created    : 2008-11-28
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 16-bit audio synthesizer top level
-------------------------------------------------------------------------------
-- Copyright (c) 2008 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-03-21  1.0      Group 27    Created
--------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity synthesizer is
  generic (
    clk_freq_g    : integer := 12288000;
    sample_rate_g : integer := 48000;
    data_width_g  : integer := 16;
    n_keys_g      : integer := 4
    );
  port(
    clk           : in  std_logic;
    rst_n         : in  std_logic;
    keys_in       : in  std_logic_vector(n_keys_g-1 downto 0);
    aud_bclk_out  : out std_logic;
    aud_data_out  : out std_logic;
    aud_lrclk_out : out std_logic
    );
end entity synthesizer;

architecture rtl of synthesizer is

  -- Components instantiation
  component audio_ctrl is
    generic (
      ref_clk_freq_g : integer := 12288000;  -- in Hz
      sample_rate_g  : integer := 48000;     -- in Hz
      data_width_g   : integer := 16         -- in bits
      );
    port (
      clk           : in  std_logic;
      rst_n         : in  std_logic;
      left_data_in  : in  std_logic_vector(data_width_g - 1 downto 0);
      right_data_in : in  std_logic_vector(data_width_g - 1 downto 0);
      aud_bclk_out  : out std_logic;
      aud_data_out  : out std_logic;
      aud_lrclk_out : out std_logic
      );
  end component;

  component wave_gen is
    generic (
      width_g : integer;
      step_g  : integer
      );
    port (
      clk             : in  std_logic;
      rst_n           : in  std_logic;
      sync_clear_n_in : in  std_logic;
      value_out       : out std_logic_vector(width_g-1 downto 0)
      );
  end component;

  component multi_port_adder is
    generic(
      operand_width_g   : integer;
      num_of_operands_g : integer
      );
    port(
      clk         : in  std_logic;
      rst_n       : in  std_logic;
      operands_in : in  std_logic_vector(operand_width_g*num_of_operands_g-1 downto 0);
      sum_out     : out std_logic_vector(operand_width_g-1 downto 0)
      );
  end component;

  signal multi_port_adder_input        : std_logic_vector(4*data_width_g-1 downto 0);
  signal sum                           : std_logic_vector(data_width_g-1 downto 0);
  signal aud_bclk, aud_lrclk, aud_data : std_logic;

begin

  -- Wave generators
  wave_gen1_inst : wave_gen
    generic map (
      width_g => data_width_g,
      step_g  => 1
      )
    port map (
      clk             => clk,
      rst_n           => rst_n,
      sync_clear_n_in => keys_in(0),
      value_out       => multi_port_adder_input(4*data_width_g-1 downto 3*data_width_g)
      );

  wave_gen2_inst : wave_gen
    generic map (
      width_g => data_width_g,
      step_g  => 2
      )
    port map (
      clk             => clk,
      rst_n           => rst_n,
      sync_clear_n_in => keys_in(1),
      value_out       => multi_port_adder_input(3*data_width_g-1 downto 2*data_width_g)
      );

  wave_gen3_inst : wave_gen
    generic map (
      width_g => data_width_g,
      step_g  => 4
      )
    port map (
      clk             => clk,
      rst_n           => rst_n,
      sync_clear_n_in => keys_in(2),
      value_out       => multi_port_adder_input(2*data_width_g-1 downto data_width_g)
      );

  wave_gen4_inst : wave_gen
    generic map (
      width_g => data_width_g,
      step_g  => 8
      )
    port map (
      clk             => clk,
      rst_n           => rst_n,
      sync_clear_n_in => keys_in(3),
      value_out       => multi_port_adder_input(data_width_g-1 downto 0)
      );

  -- Instantiation of the multi_port_adder component
  multi_port_adder_inst : multi_port_adder
    generic map (
      operand_width_g   => data_width_g,
      num_of_operands_g => n_keys_g
      )
    port map (
      clk         => clk,
      rst_n       => rst_n,
      operands_in => multi_port_adder_input,
      sum_out     => sum
      );

  -- Audio controller instantiation
  audio_ctrl_inst : audio_ctrl
    generic map (
      ref_clk_freq_g => clk_freq_g,
      sample_rate_g  => sample_rate_g,
      data_width_g   => data_width_g
      )
    port map (
      rst_n         => rst_n,
      clk           => clk,
      left_data_in  => sum,
      right_data_in => sum,
      aud_bclk_out  => aud_bclk_out,
      aud_data_out  => aud_data_out,
      aud_lrclk_out => aud_lrclk_out
      );

end architecture rtl;
