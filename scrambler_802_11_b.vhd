--  scrambler for 802.11b = scrambler for 802.11a
  -- y = x^7 + x^4 + x^0
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

library work;
use work.all;

entity scrambler_802_11_b is 
  port (
    clk : in std_logic;
    n_reset : in std_logic;
    Din : in std_logic ;
    Dout : out std_logic
    );
  end scrambler_802_11_b;

architecture FIMP_0 of scrambler_802_11_b is

	component scrambler_802_11_a is 
	  port (
	    clk : in std_logic;
	    n_reset : in std_logic;
	    Din : in std_logic ;
	    Dout : out std_logic
	    );
	  end component;

begin

  scrambler_entity: scrambler_802_11_a port map(clk, n_reset, Din, Dout);

end FIMP_0;


 