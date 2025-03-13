-------------------------------------------------------------------------------
-- Title      : COMP.CE.240, Exercise 06
-- Project    : 
-------------------------------------------------------------------------------
-- File       : wave_gen.vhd
-- Author     : Group 27: Tomas Rinne & Manjil Basnet
-- Company    : TUT/DCS
-- Created    : 2008-11-28
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Generate a triangular wave
-------------------------------------------------------------------------------
-- Copyright (c) 2008 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-02-23  1.0      Group 27    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wave_gen is
  generic (
    width_g : integer := 8;
    step_g  : integer := 1
    );
  port (
    clk             : in  std_logic;
    rst_n           : in  std_logic;
    sync_clear_n_in : in  std_logic;
    value_out       : out std_logic_vector(width_g-1 downto 0)
    );
end entity wave_gen;

architecture rtl of wave_gen is

  -- Internal signals
  signal count_r     : signed(width_g-1 downto 0);
  signal direction_r : std_logic := '0';  -- 0 for up, 1 for down

  -- Constants
  constant max_value_c : signed(width_g-1 downto 0) := to_signed((((2**(width_g-1))-1)/step_g)*step_g, width_g);
  constant min_value_c : signed(width_g-1 downto 0) := -max_value_c;

begin
  -- Process for generating a triangular wave
  wave_generator : process(clk, rst_n)
  begin
    if (rst_n = '0') then
      count_r     <= (others => '0');
      direction_r <= '0';
      value_out   <= (others => '0');
    elsif (clk'event and clk = '1') then
      -- Handle sync_clear
      if (sync_clear_n_in = '0') then
        count_r     <= (others => '0');
        value_out   <= (others => '0');
        direction_r <= '0';
      -- Counter part
      else
        if count_r = max_value_c then
          direction_r <= '1';           -- downwards
          count_r     <= count_r - to_signed(step_g, width_g);
          value_out   <= std_logic_vector(count_r - to_signed(step_g, width_g));
        elsif (direction_r = '0') then
          count_r   <= count_r + to_signed(step_g, width_g);
          value_out <= std_logic_vector(count_r + to_signed(step_g, width_g));
        end if;
        if count_r = min_value_c then
          direction_r <= '0';           -- upwards
          count_r     <= count_r + to_signed(step_g, width_g);
          value_out   <= std_logic_vector(count_r + to_signed(step_g, width_g));
        elsif (direction_r = '1') then
          count_r   <= count_r - to_signed(step_g, width_g);
          value_out <= std_logic_vector(count_r - to_signed(step_g, width_g));
        end if;
      end if;
    end if;
  end process wave_generator;

end architecture rtl;
