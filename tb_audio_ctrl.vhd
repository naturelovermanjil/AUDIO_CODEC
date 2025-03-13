-------------------------------------------------------------------------------
-- Title      : COMP.CE.240, Exercise 08
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_audio_ctrl.vhd
-- Author     : Group 27: Tomas Rinne & Manjil Basnet
-- Company    : TUT/DCS
-- Created    : 2008-11-28
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Test bench for audio_ctrl.vhd
-------------------------------------------------------------------------------
-- Copyright (c) 2008 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-03-11  1.0      Group 27    Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.all;

entity tb_audio_ctrl is
end tb_audio_ctrl;

architecture testbench of tb_audio_ctrl is

  constant data_width_c   : integer := 16;
  constant clock_period_c : time    := 50 ns;
  constant freq_c         : integer := 20000000;
  constant sampling_freq  : integer := 48000;

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
      width_g : integer := 16;
      step_g  : integer := 1
      );
    port (
      clk             : in  std_logic;
      rst_n           : in  std_logic;
      sync_clear_n_in : in  std_logic;
      value_out       : out std_logic_vector(width_g-1 downto 0)
      );
  end component;

  component audio_codec_model is
    generic (
      data_width_g : integer := 16
      );
    port (
      rst_n           : in  std_logic;
      aud_data_in     : in  std_logic;
      aud_bclk_in     : in  std_logic;
      aud_lrclk_in    : in  std_logic;
      value_left_out  : out std_logic_vector(data_width_g-1 downto 0);
      value_right_out : out std_logic_vector(data_width_g-1 downto 0)
      );
  end component;


  -- Clock and Reset Signals
  signal clk      : std_logic := '0';
  signal rst_n    : std_logic := '0';
  signal sync_clr : std_logic := '1';

  -- Connecting signals
  signal left_data, right_data, left_output, right_output : std_logic_vector(data_width_c-1 downto 0);
  signal aud_bclk_in, aud_lrclk_in, aud_data_in           : std_logic;

begin

  -- Waveform generator instantiation
  wave_gen1_inst : wave_gen
    generic map (
      width_g => data_width_c,
      step_g  => 2
      )
    port map (
      clk             => clk,
      rst_n           => rst_n,
      sync_clear_n_in => sync_clr,
      value_out       => left_data
      );

  wave_gen2_inst : wave_gen
    generic map (
      width_g => data_width_c,
      step_g  => 10
      )
    port map (
      clk             => clk,
      rst_n           => rst_n,
      sync_clear_n_in => sync_clr,
      value_out       => right_data
      );

  -- Audio controller instantiation
  audio_ctrl_inst : audio_ctrl
    generic map (
      ref_clk_freq_g => freq_c,
      sample_rate_g  => sampling_freq,
      data_width_g   => data_width_c
      )
    port map (
      rst_n         => rst_n,
      clk           => clk,
      left_data_in  => left_data,
      right_data_in => right_data,
      aud_bclk_out  => aud_bclk_in,
      aud_data_out  => aud_data_in,
      aud_lrclk_out => aud_lrclk_in
      );

  audio_codec_inst : audio_codec_model
    generic map (
      data_width_g => data_width_c
      )
    port map (
      rst_n           => rst_n,
      aud_data_in     => aud_data_in,
      aud_bclk_in     => aud_bclk_in,
      aud_lrclk_in    => aud_lrclk_in,
      value_left_out  => left_output,
      value_right_out => right_output
      );

  clk_gen : process
  begin
    clk <= not clk after clock_period_c / 2;
    wait for clock_period_c;
  end process;

  rst_process : process
  begin
    rst_n    <= '1' after 4 * clock_period_c;
    wait for 4 ms;
    sync_clr <= '0';                    -- Generate sync_clear signal
    wait for 1 ms;
    sync_clr <= '1';
    wait;
  end process;

end testbench;
