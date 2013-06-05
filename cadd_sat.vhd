--  Complex adder with saturated output
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

entity cadd_sat is
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
  end cadd_sat;

architecture FIMP_0 of cadd_sat is
  
  component cadd is
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
    end component;

  signal re : sfixed(1 downto 1 - data_width);
  signal im : sfixed(1 downto 1 - data_width);
  signal sat : std_logic;

begin

  warp_unit: cadd
    generic map (data_width => data_width)
    port map (in0_re, in0_im, in1_re, in1_im, re, im, result_sat_re, result_sat_im, sat);

end FIMP_0;








