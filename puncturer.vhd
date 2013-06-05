--  Puncturer for 802.11a rate 2/3 and/or 3/4
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity puncturer is
  port (
    clk : in std_logic;
    n_reset : in std_logic;
    mode_2_3 : in std_logic; -- '1': puncture rate 2/3, '0': idle
    mode_3_4 : in std_logic; -- '1': puncture rate 3/4, '0': idle
    DinA : in std_logic;
    DinB : in std_logic;
    ready_2_3 : out std_logic;
    ready_3_4 : out std_logic;
    Dout_2_3 : out std_logic_vector (8 downto 0);
    Dout_3_4 : out std_logic_vector (11 downto 0)
    );
  end puncturer;

architecture FIMP_0 of puncturer is

  signal counter_2_3 : integer range 0 to 5;
  signal regA_2_3 : std_logic_vector (5 downto 0);
  signal regB_2_3 : std_logic_vector (5 downto 0);

  signal counter_3_4 : integer range 0 to 8;
  signal regA_3_4 : std_logic_vector (8 downto 0);
  signal regB_3_4 : std_logic_vector (8 downto 0);

begin

-- cyclic buffer
process(clk, n_reset)
  begin
  if (n_reset = '0') then
    regA_2_3 <= (others=>'0');
    regB_2_3 <= (others=>'0');
    regA_3_4 <= (others=>'0');
    regB_3_4 <= (others=>'0'); 
  elsif (clk = '1' and clk'event) then
    regA_2_3(counter_2_3) <= DinA and mode_2_3;
    regB_2_3(counter_2_3) <= DinB and mode_2_3;
    regA_3_4(counter_3_4) <= DinA and mode_3_4;
    regB_3_4(counter_3_4) <= DinB and mode_3_4;  
    end if;
  end process;

-- state counter
process(clk, n_reset)
  begin
  if (n_reset = '0') then
    counter_2_3 <= 0;
    counter_3_4 <= 0;
    ready_2_3 <= '0';
    ready_3_4 <= '0';
  elsif (clk = '1' and clk'event) then

    if (counter_2_3 = 5) then
      counter_2_3 <= 0;
      ready_2_3 <= '1';
      Dout_2_3 <= regA_2_3(0) & regB_2_3(0)
                & regA_2_3(1)
                & regA_2_3(2) & regB_2_3(2)
                & regA_2_3(3)
                & regA_2_3(4) & regB_2_3(4)
                & regA_2_3(5);
    else
      counter_2_3 <= counter_2_3 + 1;
      ready_2_3 <= '0';
      end if;

    if (counter_3_4 = 8) then
      counter_3_4 <= 0;
      ready_3_4 <= '1';
      Dout_3_4 <= regA_3_4(0) & regB_3_4(0)
                & regA_3_4(1)
                & regB_3_4(2)
                & regA_3_4(3) & regB_3_4(3)
                & regA_3_4(4)
                & regB_3_4(5)
                & regA_3_4(6) & regB_3_4(6)
                & regA_3_4(7)
                & regB_3_4(8);
    else
      counter_3_4 <= counter_3_4 + 1;
      ready_3_4 <= '0';
      end if;

    end if;
  end process;





end FIMP_0;

