--  Convolution encoder used in 802.11a
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity convolutional_encoder is 
  port (
    clk : in std_logic;
    n_reset : in std_logic;
    Din : in std_logic;
    DoutA : out std_logic;
    DoutB : out std_logic
    );
  end convolutional_encoder;

architecture FIMP_0 of convolutional_encoder is

  signal lfsr: std_logic_vector (6 downto 0);
  signal xor_result : std_logic;

begin

  process(clk, n_reset)
    begin

    if n_reset = '1' then
      DoutA <= '0';
      DoutB <= '0';
      lfsr <= (others => '0');
    elsif rising_edge(clk) then
      lfsr(6 downto 1) <= lfsr(5 downto 0); 
      lfsr(0) <= Din;
      DoutA <= lfsr(0) xor lfsr(2) xor lfsr(3) xor lfsr(5) xor lfsr(6);
      DoutB <= lfsr(0) xor lfsr(1) xor lfsr(2) xor lfsr(3) xor lfsr(6);
      end if;
    
    end process;

end FIMP_0;
