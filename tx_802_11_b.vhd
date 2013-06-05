--  802.11b transmitter
  -- DSSS + CCK
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

entity tx_802_11_b is
  generic (
    data_width : integer := 8
    );
  port (
    clk : in std_logic;
    n_reset : in std_logic;
    mode : in std_logic_vector(1 downto 0);
      -- 00: 1 Mbit/s
      -- 01: 2 Mbit/s
      -- 10: 5.5 Mbit/s
      -- 11: 11 Mbit/s
    Din_1M : in std_logic; -- for 1 Mbit/s
    Din_2M : in std_logic_vector(1 downto 0); -- for 2 Mbit/s
    Din_5M_500K : in std_logic_vector(3 downto 0); -- for 5.5 Mbit/s
    Din_11M : in std_logic_vector(7 downto 0); -- for 5.5 Mbit/s
    I : out sfixed(0 downto 1 - data_width);
    Q : out sfixed(0 downto 1 - data_width)
    );
  end tx_802_11_b;

architecture FIMP_0 of tx_802_11_b is
  
  -- 1 and 2 Mbit/s
  component dsss_802_11_b is
    generic (
      data_width : integer := 8
      );
    port (
      clk : in std_logic;
      n_reset : in std_logic;
      mode : in std_logic;
        -- 0: 1 Mbit/s
        -- 1: 2 Mbit/s
      Din_1M_2M_MSB : in std_logic; -- for 1Mbit/s
      Din_2M_LSB : in std_logic; -- together with Din_A for 2Mbit/s
      I : out sfixed(0 downto 1 - data_width);
      Q : out sfixed(0 downto 1 - data_width)
      );
    end component;
  
  -- 5.5 and 11 Mbit/s
  component cck is 
    generic (
      data_width : integer := 8
      );
    port (
      clk : in std_logic;
      n_reset : in std_logic;
      data_in : in std_logic_vector(7 downto 0);
      I : out sfixed(data_width * 8 -1 downto 0);
      Q : out sfixed(data_width * 8 -1 downto 0)
      );
    end component;

begin

end FIMP_0;
