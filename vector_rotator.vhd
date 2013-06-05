--  Vector rotator
  --================================================================
  --  Author: Shuo Li (shuol@kth.se), Fangyuan Liu (fangyuan@kth.se)
  --================================================================
  --  Copyright (C) Shuo Li, Fangyuan Liu
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

entity vector_rotator is
  port (
    n_reset : in std_logic;
    vector_I : in std_logic;
    vector_Q : in std_logic;
    phase_I : in std_logic;
    phase_Q : in std_logic;
    out_I : out std_logic;
    out_Q : out std_logic
    );
  end vector_rotator;

architecture FIMP_0 of vector_rotator is

  signal vector : signed(1 downto 0);
  signal phase : signed(1 downto 0);

  signal result_temp : signed(1 downto 0);

begin

  vector <= vector_I & vector_Q;
  phase <= phase_I & phase_Q;

  result_temp <= vector + phase;

  out_I <= result_temp(1) and n_reset;
  out_Q <= result_temp(0) and n_reset;

end FIMP_0;

