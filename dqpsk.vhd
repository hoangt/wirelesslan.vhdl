--  DQPSK
  -- Differential Quadrature Phase Shift Keying
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

entity dqpsk is
  generic (
    data_width : integer := 8
    );
  port (
    clk : in std_logic;
    n_reset : in std_logic;
    DQPSK_in : in std_logic_vector(1 downto 0);
    I : out sfixed(0 downto 1 - data_width);
    Q : out sfixed(0 downto 1 - data_width)
    );
  end dqpsk;
  
architecture FIMP_0 of dqpsk is

  component qpsk is
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
    end component;

  signal last_I : sfixed (0 downto 1 - data_width);
  signal last_Q : sfixed (0 downto 1 - data_width);
  signal current_I : sfixed (0 downto 1 - data_width);
  signal current_Q : sfixed (0 downto 1 - data_width);
  signal I_temp : sfixed (1 downto 1 - data_width);
  signal Q_temp : sfixed (1 downto 1 - data_width);
  
begin
  
  I <= I_temp(1) & I_temp(-1 downto 1 - data_width);
  Q <= Q_temp(1) & Q_temp(-1 downto 1 - data_width);
  
  process(clk, n_reset)
    begin
    if (n_reset='0') then     
      last_I <= (others => '0');
      last_Q <= (others => '0');
      I_temp <= (others => '0');
      Q_temp <= (others => '0');
    elsif(clk = '1' and clk'event) then
      I_temp <= last_I + current_I;
      Q_temp <= last_Q + current_Q;
      last_I <= current_I;
      last_Q <= current_Q;
      end if;
    end process;

  qpsk_unit: qpsk generic map(data_width)
    port map(clk, n_reset, DQPSK_in, current_I, current_Q);

end FIMP_0;



