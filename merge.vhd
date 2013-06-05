--  merge two std_logic_vectors
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
  
entity merge is
  generic (
    data_width: integer := 8;
    lsb_width: integer := 4
    );
  port (
    nreset : in std_logic;
    msb : in std_logic_vector (data_width - 1 downto 0);
    lsb : in std_logic_vector (lsb_width - 1 downto 0);
    merged : out std_logic_vector (data_width - 1 downto 0)
    );
  end merge;
  
architecture FIMP_0 of merge is

begin

  merged <= msb(data_width - 1 downto lsb_width) & lsb;

end FIMP_0;