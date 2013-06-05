--  Guard insertion, whitespace at MSB
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
use IEEE.fixed_float_types.all;
use IEEE.fixed_pkg.all;

entity guard_insertion is
  generic (
    data_width : integer := 16;
    data_length : integer := 64;
    whitespace_length : integer := 16
    );
  port (
    in_re : in sfixed(data_width * data_length - 1 downto 0);
    in_im : in sfixed(data_width * data_length - 1 downto 0);
    out_re : out sfixed(data_width * (data_length + whitespace_length) - 1 downto 0);
    out_im : out sfixed(data_width * (data_length + whitespace_length) - 1 downto 0)
    );
  end guard_insertion;

architecture FIMP_0 of guard_insertion is
  
begin

  out_re(data_width * data_length - 1 downto 0) <= in_re;
  out_im(data_width * data_length - 1 downto 0) <= in_im;
  out_re(data_width * (data_length + whitespace_length) - 1 downto data_width * data_length) <= (others => '0');
  out_im(data_width * (data_length + whitespace_length) - 1 downto data_width * data_length) <= (others => '0');

end FIMP_0;