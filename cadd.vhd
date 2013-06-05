--  Complex adder
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

entity cadd is
  generic (
    data_width : integer := 16
    );
  port (
    in0_re : in sfixed(0 downto 1 - data_width);
    in0_im : in sfixed(0 downto 1 - data_width);
    in1_re : in sfixed(0 downto 1 - data_width);
    in1_im : in sfixed(0 downto 1 - data_width);
    result_re : out sfixed(1 downto 1 - data_width);
    result_im : out sfixed(1 downto 1 - data_width);
    result_sat_re : out sfixed(0 downto 1 - data_width);
    result_sat_im : out sfixed(0 downto 1 - data_width);
    sat : out std_logic
    );
  end cadd;

architecture FIMP_0 of cadd is
  
  signal re : sfixed(1 downto 1 - data_width);
  signal im : sfixed(1 downto 1 - data_width);
  signal sat_re: std_logic;
  signal sat_im: std_logic;
  signal re_sat : sfixed(-1 downto 1 - data_width);
  signal im_sat : sfixed(-1 downto 1 - data_width);

begin

  re <= in0_re + in1_re;
  im <= in0_im + in1_im;

  result_re <= re;
  result_im <= im;

  sat_re <= re(1) xor re(0);
  sat_im <= im(1) xor im(0);

  sat <= sat_re or sat_im;

  re_sat <= (others => not re(1));
  im_sat <= (others => not im(1));

  result_sat_re <= re(1) & re(-1 downto 1 - data_width) when sat_re = '0' else
                   re(1) & re_sat(-1 downto 1 - data_width);

  result_sat_im <= im(1) & im(-1 downto 1 - data_width) when sat_im = '0' else
                   im(1) & im_sat(-1 downto 1 - data_width);

end FIMP_0;