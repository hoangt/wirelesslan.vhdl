--  QPSK
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

entity qpsk is
  generic (
    data_width : integer := 8
    );
  port (
    clk : in std_logic;
    n_reset : in std_logic;
    QPSK_in : in std_logic_vector(1 downto 0);
    I : out sfixed(0 downto 1 - data_width);
    Q : out sfixed(0 downto 1 - data_width)
  );
  end qpsk;
  
architecture FIMP_0 of qpsk is

  signal positive_one : sfixed (0 downto 1 - data_width);
  signal negative_one : sfixed (0 downto 1 - data_width);
  
begin

  positive_one(0) <= '0';
  negative_one(0) <= '1';

  positive_one(-1 downto 1 - data_width) <= (others => '1');
  negative_one(-1 downto 1 - data_width) <= (others => '0');

  process(clk, n_reset)
  begin
    if (n_reset='0') then
      I <= (others => '0');
      Q <= (others => '0');
    elsif(clk = '1' and clk'event) then
      
      case QPSK_in(1) is
        when '1' =>
          I <= positive_one;
        when '0' =>
          I <= negative_one;
        when others => null;
        end case;

      case QPSK_in(0) is
        when '1' =>
          Q <= positive_one;
        when '0' =>
          Q <= negative_one;
        when others => null;
        end case;

      end if;
    end process;

end FIMP_0;

