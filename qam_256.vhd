--  256-QAM, gray coded
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

entity qam_256 is
  generic (
    data_width : integer := 8
    );
  port (
    clk : in std_logic;
    n_reset : in std_logic;
    QAM256_in : in std_logic_vector(7 downto 0);
    I : out sfixed(0 downto 1 - data_width);
    Q : out sfixed(0 downto 1 - data_width)
  );
  end qam_256;
  
architecture FIMP_0 of qam_256 is

begin

  process (clk, n_reset)
    begin
    if n_reset = '0' then
      I <= (others => '0');
      Q <= (others => '0');
    elsif clk'event and clk = '1' then
      I(0) <= not QAM256_in(7);
      I(-1) <= QAM256_in(6) xor QAM256_in(7);
      I(-2) <= QAM256_in(5) xor QAM256_in(7);
      I(-3) <= QAM256_in(4) xor QAM256_in(7);
      I(-4) <= '1';
      I(-5 downto 1 - data_width) <= (others => '0');

      Q(0) <= not QAM256_in(3);
      Q(-1) <= QAM256_in(2) xor QAM256_in(4);
      Q(-2) <= QAM256_in(1) xor QAM256_in(4);
      Q(-3) <= QAM256_in(0) xor QAM256_in(4);
      Q(-4) <= '1';
      Q(-5 downto 1 - data_width) <= (others => '0');
      end if;
    end process;

end FIMP_0;
