-------------------------------------------------------------------------------
-- Title      : COMP.CE.240, Exercise 08
-- Project    : 
-------------------------------------------------------------------------------
-- File       : audio_ctrl.vhd
-- Author     : Group 27: Tomas Rinne & Manjil Basnet
-- Company    : TUT/DCS
-- Created    : 2008-11-28
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: DA7212 audio controller
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

entity audio_ctrl is
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
end entity;

architecture rtl of audio_ctrl is
  -- Clock generation counters
  constant bclk_count_max_c : integer := ref_clk_freq_g / (sample_rate_g * data_width_g * 2);
  signal bclk_count         : integer;

  -- Internal signals
  signal bit_counter    : integer;
  signal aud_bclk       : std_logic;
  signal aud_bclk_last  : std_logic;
  signal left_data_reg  : std_logic_vector(data_width_g - 1 downto 0);
  signal right_data_reg : std_logic_vector(data_width_g - 1 downto 0);

  -- Define custom state type for the state machine
  type state_type is (wait_for_output, write_left, write_right);
  signal current_state : state_type;

begin

  -- Process for generating BCLK based on bclk_count_max_c
  bclk_gen : process(clk, rst_n, bclk_count, aud_bclk)
  begin
    if (rst_n = '0') then
      aud_bclk   <= '0';
      bclk_count <= 0;
    elsif (clk'event and clk = '1') then
      if bclk_count = bclk_count_max_c then
        bclk_count <= 0;
        aud_bclk   <= not aud_bclk;
      else
        bclk_count <= bclk_count + 1;
      end if;
    end if;
    aud_bclk_out <= aud_bclk;
  end process;

  -- Process for writing bit output
  write_output : process(clk, rst_n)
  begin
    if (rst_n = '0') then
      -- Reset state machine and output values
      current_state <= wait_for_output;
      bit_counter   <= data_width_g - 2;
      aud_data_out  <= '0';
      aud_bclk_last <= '0';
      aud_lrclk_out <= '0';
    elsif (clk'event and clk = '1') then
      aud_bclk_last <= aud_bclk;
      if (aud_bclk_last = '1' and aud_bclk = '0') then          -- Falling edge
        case current_state is
          when wait_for_output =>       -- wait before writing
            bit_counter <= bit_counter - 1;
            if (bit_counter = 0) then
              left_data_reg <= left_data_in;
              current_state <= write_left;
              aud_data_out  <= left_data_in(data_width_g - 1);  --transition bit
              aud_lrclk_out <= '1';
              bit_counter   <= data_width_g - 2;
            else
              current_state <= wait_for_output;
            end if;
          when write_left =>            -- (lrclk up)
            bit_counter  <= bit_counter - 1;
            aud_data_out <= left_data_reg(bit_counter);
            if (bit_counter = 0) then
              right_data_reg <= right_data_in;
              current_state  <= write_right;
              aud_data_out   <= right_data_in(data_width_g - 1);  --transition bit
              bit_counter    <= data_width_g - 2;
              aud_lrclk_out  <= '0';
            end if;
          when write_right =>           -- (lrclk down)
            bit_counter  <= bit_counter - 1;
            aud_data_out <= right_data_reg(bit_counter);
            if (bit_counter = 0) then
              left_data_reg <= left_data_in;
              current_state <= write_left;
              aud_data_out  <= left_data_in(data_width_g - 1);  --transition bit
              bit_counter   <= data_width_g - 2;
              aud_lrclk_out <= '1';
            end if;
        end case;
      end if;
    end if;
  end process;

end architecture rtl;
