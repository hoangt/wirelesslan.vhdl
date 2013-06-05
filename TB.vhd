--  testbench for n-point FFT
--================================================================
--  Author: Shuo Li (shuol@kth.se)
--================================================================
--  Copyright (C) Shuo Li
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2
--  of the License, or (at your option) any later version.
--  
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--================================================================

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
  
entity tb is end tb;
  
architecture tb_bit_reverse of tb is

  component bit_reverse is
    generic (
      data_width : integer := 16
      );
    port (
      nreset : in std_logic;
      data_in : in std_logic_vector (data_width - 1 downto 0);
      data_out : out std_logic_vector (data_width - 1 downto 0)
      );
    end component;

  signal nreset : std_logic := '1';
  signal din_integer : integer range 0 to 15 := 0;
  signal din : std_logic_vector (3 downto 0);
  signal dout : std_logic_vector (3 downto 0);
  signal clk : std_logic := '0';

begin
  
  clk <= not clk after 10 ns;

  process(clk)
    begin

    if (clk'event and clk = '1') then
      if din_integer = 15 then
        din_integer <= 0;
      else
        din_integer <= din_integer + 1;
        end if;
      end if;

    end process;

  din <= std_logic_vector(to_unsigned(din_integer, din'LENGTH));

  DUT: bit_reverse
    generic map(4)
    port map(nreset, din, dout);

end tb_bit_reverse;

