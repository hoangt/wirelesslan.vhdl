--  16-QAM, gray coded
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

entity qam_16 is
  generic (
    data_width : integer := 8
    );
  port (
    clk : in std_logic;
    n_reset : in std_logic;
    QAM16_in : in std_logic_vector(3 downto 0);
    I : out sfixed(0 downto 1 - data_width);
    Q : out sfixed(0 downto 1 - data_width)
  );
  end qam_16;
  
architecture FIMP_0 of qam_16 is

  signal positive_1_4 : sfixed (0 downto 1 - data_width);
  signal negative_1_4 : sfixed (0 downto 1 - data_width);
  signal positive_3_4 : sfixed (0 downto 1 - data_width);
  signal negative_3_4 : sfixed (0 downto 1 - data_width);

begin

  positive_1_4(0 downto -2) <= '0' & "01";
  negative_1_4(0 downto -2) <= '1' & "11";
  positive_3_4(0 downto -2) <= '0' & "11";
  negative_3_4(0 downto -2) <= '1' & "01";

  positive_1_4(-3 downto 1 - data_width) <= (others => '0');
  negative_1_4(-3 downto 1 - data_width) <= (others => '0');
  positive_3_4(-3 downto 1 - data_width) <= (others => '0');
  negative_3_4(-3 downto 1 - data_width) <= (others => '0');

  process(clk, n_reset)
  begin
    if (n_reset='0') then
      I <= (others => '0');
      Q <= (others => '0');
    elsif(clk = '1' and clk'event) then
      
      case QAM16_in(3 downto 2) is
        when "11" =>
          I <= positive_1_4;
        when "10" =>
          I <= positive_3_4;
        when "01" =>
          I <= negative_1_4;
        when "00" =>
          I <= negative_3_4;
        when others => null;
        end case;

      case QAM16_in(1 downto 0) is
        when "11" =>
          Q <= positive_1_4;
        when "10" =>
          Q <= positive_3_4;
        when "01" =>
          Q <= negative_1_4;
        when "00" =>
          Q <= negative_3_4;
        when others => null;
        end case;

      end if;
    end process;

end FIMP_0;
