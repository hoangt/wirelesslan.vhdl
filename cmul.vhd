--  Complex multiplier
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

entity cmul is
  generic (
    data_width : integer := 16
    );
  port (
    in0_re : in sfixed(0 downto 1 - data_width);
    in0_im : in sfixed(0 downto 1 - data_width);
    in1_re : in sfixed(0 downto 1 - data_width);
    in1_im : in sfixed(0 downto 1 - data_width);
    result_re : out sfixed(0 downto 1 - data_width);
    result_im : out sfixed(0 downto 1 - data_width)
    );
  end cmul;

architecture FIMP_0 of cmul is
  
  signal re_rere : sfixed(1 downto 1 - 2 * data_width + 1);
  signal re_imim : sfixed(1 downto 1 - 2 * data_width + 1);
  signal im_reim : sfixed(1 downto 1 - 2 * data_width + 1);
  signal im_imre : sfixed(1 downto 1 - 2 * data_width + 1);

  signal re_temp : sfixed(2 downto 1 - 2 * data_width + 1);
  signal im_temp : sfixed(2 downto 1 - 2 * data_width + 1);
begin

  re_rere <= in0_re * in1_re;
  re_imim <= in0_im * in1_im;
  im_reim <= in0_re * in1_im;
  im_imre <= in0_im * in1_re;

  re_temp <= re_rere - re_imim;
  im_temp <= im_reim + im_imre;
  
  result_re(0) <= re_temp(2);
  result_re(-1 downto 1 - data_width) <= re_temp(-1 downto 1 - data_width);
  result_im(0) <= im_temp(2);
  result_im(-1 downto 1 - data_width) <= im_temp(-1 downto 1 - data_width);

end FIMP_0;