--  Radix-2 butterfly operator
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

library work;
use work.all;

entity butterfly_2 is
  generic (
    data_width : integer := 16
    );
  port (
    x0_re : in sfixed(0 downto 1 - data_width);
    x0_im : in sfixed(0 downto 1 - data_width);
    x1_re : in sfixed(0 downto 1 - data_width);
    x1_im : in sfixed(0 downto 1 - data_width);
    w_re : in sfixed(0 downto 1 - data_width);
    w_im : in sfixed(0 downto 1 - data_width);
    y0_re : out sfixed(0 downto 1 - data_width);
    y0_im : out sfixed(0 downto 1 - data_width);
    y1_re : out sfixed(0 downto 1 - data_width);
    y1_im : out sfixed(0 downto 1 - data_width)
    );
  end butterfly_2;

architecture FIMP_0 of butterfly_2 is

  component cmul is
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
    end component;
  
  component cadd_sat is
    generic (
      data_width : integer := 16
      );
    port (
      in0_re : in sfixed(0 downto 1 - data_width);
      in0_im : in sfixed(0 downto 1 - data_width);
      in1_re : in sfixed(0 downto 1 - data_width);
      in1_im : in sfixed(0 downto 1 - data_width);
      result_sat_re : out sfixed(0 downto 1 - data_width);
      result_sat_im : out sfixed(0 downto 1 - data_width)
      );
    end component;

  signal mul_re : sfixed(0 downto 1 - data_width);
  signal mul_im : sfixed(0 downto 1 - data_width);

  signal minus_mul_re : sfixed(0 downto 1 - data_width);
  signal minus_mul_im : sfixed(0 downto 1 - data_width);

  signal minus_mul_re_temp : sfixed(1 downto 1 - data_width);
  signal minus_mul_im_temp : sfixed(1 downto 1 - data_width);

begin

  minus_mul_re_temp <= -mul_re;
  minus_mul_re <= minus_mul_re_temp(0) & minus_mul_re_temp(-1 downto 1 - data_width);
  minus_mul_im_temp <= -mul_im;
  minus_mul_im <= minus_mul_im_temp(0) & minus_mul_im_temp(-1 downto 1 - data_width);

  multiplier: cmul
    generic map (data_width)
    port map (w_re, w_im, x1_re, x1_im, mul_re, mul_im);

  adder: cadd_sat
    generic map (data_width)
    port map (x0_re, x0_im, mul_re, mul_im, y0_re, y0_im);

  subtractor: cadd_sat
    generic map (data_width)
    port map (x0_re, x0_im, minus_mul_re, minus_mul_im, y1_re, y1_im);

end FIMP_0;