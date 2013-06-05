--  64-QAM, gray coded
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

entity qam_64 is
  generic (
    data_width : integer := 8
    );
  port (
    clk : in std_logic;
    n_reset : in std_logic;
    QAM64_in : in std_logic_vector(5 downto 0);
    I : out sfixed(0 downto 1 - data_width);
    Q : out sfixed(0 downto 1 - data_width)
  );
  end qam_64;
  
architecture FIMP_0 of qam_64 is

  signal positive_1_8 : sfixed (0 downto 1 - data_width);
  signal negative_1_8 : sfixed (0 downto 1 - data_width);
  signal positive_3_8 : sfixed (0 downto 1 - data_width);
  signal negative_3_8 : sfixed (0 downto 1 - data_width);
  signal positive_5_8 : sfixed (0 downto 1 - data_width);
  signal negative_5_8 : sfixed (0 downto 1 - data_width);
  signal positive_7_8 : sfixed (0 downto 1 - data_width);
  signal negative_7_8 : sfixed (0 downto 1 - data_width);
  
begin
  
  -- constants
    positive_1_8(0 downto -3) <= '0' & "001";
    negative_1_8(0 downto -3) <= '1' & "111";

    positive_3_8(0 downto -3) <= '0' & "011";
    negative_3_8(0 downto -3) <= '1' & "101";

    positive_5_8(0 downto -3) <= '0' & "101";
    negative_5_8(0 downto -3) <= '1' & "011";

    positive_7_8(0 downto -3) <= '0' & "111";
    negative_7_8(0 downto -3) <= '1' & "001";

    positive_1_8(-4 downto 1 - data_width) <= (others => '0');
    negative_1_8(-4 downto 1 - data_width) <= (others => '0');

    positive_3_8(-4 downto 1 - data_width) <= (others => '0');
    negative_3_8(-4 downto 1 - data_width) <= (others => '0');

    positive_5_8(-4 downto 1 - data_width) <= (others => '0');
    negative_5_8(-4 downto 1 - data_width) <= (others => '0');

    positive_7_8(-4 downto 1 - data_width) <= (others => '0');
    negative_7_8(-4 downto 1 - data_width) <= (others => '0');

  process(clk, n_reset)
  begin
    if (n_reset='0') then
      I <= (others => '0');
      Q <= (others => '0');
    elsif(clk = '1' and clk'event) then
      
      case QAM64_in(5 downto 3) is
        when "000" => -- 1001
          I <= negative_7_8;
        when "001" => -- 1011
          I <= negative_5_8;
        when "010" => -- 1101
          I <= negative_3_8;
        when "011" => -- 1111
          I <= negative_1_8;
        when "100" => -- 0111
          I <= positive_7_8;
        when "101" => -- 0101
          I <= positive_5_8;
        when "110" => -- 0011
          I <= positive_3_8;
        when "111" => -- 0001
          I <= positive_1_8;
        when others => null;
        end case;

      case QAM64_in(2 downto 0) is
        when "000" =>
          Q <= negative_7_8;
        when "001" =>
          Q <= negative_5_8;
        when "010" =>
          Q <= negative_3_8;
        when "011" =>
          Q <= negative_1_8;
        when "100" =>
          Q <= positive_7_8;
        when "101" =>
          Q <= positive_5_8;
        when "110" =>
          Q <= positive_3_8;
        when "111" =>
          Q <= positive_1_8;
        when others => null;
        end case;

      end if;
    end process;

end FIMP_0;
