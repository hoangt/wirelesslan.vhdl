--  Complex conjugate
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

entity conjugate is
  generic (
    data_width : integer := 16
    );
  port (
    in_re : in sfixed(0 downto 1 - data_width);
    in_im : in sfixed(0 downto 1 - data_width);
    out_re : out sfixed(0 downto 1 - data_width);
    out_im : out sfixed(0 downto 1 - data_width)
    );
  end conjugate;

architecture FIMP_0 of conjugate is
  signal temp : sfixed(1 downto 1 - data_width);
begin

  out_re <= in_re;
  temp <= -in_im;
  out_im <= temp(1) & temp(-1 downto 1 - data_width);

end FIMP_0;