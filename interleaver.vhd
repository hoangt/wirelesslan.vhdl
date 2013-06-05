--  Interleaver
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

entity interleaver is
  generic (
    depth : integer range 0 to 255 := 6
    );
  port (
    clk : in std_logic;
    n_reset : in std_logic;
    Din : in std_logic_vector (depth * 8 - 1 downto 0);
    Dout : out std_logic_vector (depth * 8 - 1 downto 0)
    );
  end interleaver;

architecture FIMP_0 of interleaver is
  
  type buffer_type is array (0 to depth - 1) of std_logic_vector(7 downto 0);
    signal data_buffer : buffer_type;

begin

  buffer_construction: for i in 0 to depth - 1 generate
    data_buffer(i) <= Din( (depth - i) * 8 - 1 downto (depth - i - 1) * 8 );
    end generate buffer_construction;
  
  outter_loop: for X in 0 to 7 generate
    inner_loop: for Y in 0 to depth - 1 generate
      process(clk, n_reset)
        begin
        if (n_reset = '0') then
          Dout(X * depth + Y) <= '0';
        elsif (clk = '1' and clk'event) then
          Dout(X * depth + Y) <= data_buffer(Y)(X);
        end if;
        end process;
      end generate inner_loop;
    end generate outter_loop;

end FIMP_0;