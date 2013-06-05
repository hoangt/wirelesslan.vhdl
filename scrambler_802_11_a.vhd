--  scrambler for 802.11a
  -- y = x^7 + x^4 + x^0
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

entity scrambler_802_11_a is 
  port (
    clk : in std_logic;
    n_reset : in std_logic;
    Din : in std_logic ;
    Dout : out std_logic
    );
  end scrambler_802_11_a;

architecture FIMP_0 of scrambler_802_11_a is

  signal lfsr : std_logic_vector(7 downto 1);
  signal xor_result : std_logic;

begin

  process(clk, n_reset)
    begin

    if n_reset = '1' then
      Dout <= '0';
      lfsr <= (others => '1');
    elsif rising_edge(clk) then
      lfsr(7 downto 2) <= lfsr(6 downto 1); 
      lfsr(1) <= xor_result;
      xor_result <= lfsr(4) xor lfsr(7);
      Dout <= xor_result xor Din ;
      end if;
      
    end process;

end FIMP_0;


 