--  bit reverse logic
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
	
entity bit_reverse is
  generic (
    data_width : integer := 4
    );
  port (
  	nreset : in std_logic;
  	data_in : in std_logic_vector (data_width - 1 downto 0);
  	data_out : out std_logic_vector (data_width - 1 downto 0)
    );
  end bit_reverse;
	
architecture FIMP_0 of bit_reverse is

begin
    
  bit_reverse_assignment: for i in 0 to data_width - 1 generate
    with nreset select
      data_out(i) <= data_in(data_width - 1 - i) when '1', 
                     '0' when others;
    end generate bit_reverse_assignment;

end FIMP_0;
