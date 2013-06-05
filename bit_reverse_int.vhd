--  bit reverse integer
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
  
entity bit_reverse_int is
  generic (
    data_width : integer := 4
    );
  port (
    nreset : in std_logic;
    data_in : in integer range 0 to 2**data_width - 1;
    data_out : out integer range 0 to 2**data_width - 1
    );
  end bit_reverse_int;
  
architecture FIMP_0 of bit_reverse_int is

  signal din : std_logic_vector (data_width - 1 downto 0);
  signal dout : std_logic_vector (data_width - 1 downto 0);

begin
  
  din <= std_logic_vector(to_unsigned(data_in, din'LENGTH));
 
  bit_reverse_assignment: for i in 0 to data_width - 1 generate
    dout(i) <= din(data_width - 1 - i) and nreset;
    end generate bit_reverse_assignment;
  
  data_out <= to_integer(unsigned(dout));
  
end FIMP_0;

