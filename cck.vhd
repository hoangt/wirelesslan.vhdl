--  Complementary code keying for 802.11b
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

library work;
use work.all;

entity cck is 
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
  end cck;

architecture FIMP_0 of cck is

  -- vector rotator
    component vector_rotator is
      port (
        n_reset : in std_logic;
        vector_I : in std_logic;
        vector_Q : in std_logic;
        phase_I : in std_logic;
        phase_Q : in std_logic;
        out_I : in std_logic;
        out_Q : in std_logic
        );
      end component;

    -- C
      signal c0_I : sfixed(0 downto 1 - data_width);
      signal c1_I : sfixed(0 downto 1 - data_width);
      signal c2_I : sfixed(0 downto 1 - data_width);
      signal c3_I : sfixed(0 downto 1 - data_width);
      signal c4_I : sfixed(0 downto 1 - data_width);
      signal c5_I : sfixed(0 downto 1 - data_width);
      signal c6_I : sfixed(0 downto 1 - data_width);
      signal c7_I : sfixed(0 downto 1 - data_width);
      signal c0_Q : sfixed(0 downto 1 - data_width);
      signal c1_Q : sfixed(0 downto 1 - data_width);
      signal c2_Q : sfixed(0 downto 1 - data_width);
      signal c3_Q : sfixed(0 downto 1 - data_width);
      signal c4_Q : sfixed(0 downto 1 - data_width);
      signal c5_Q : sfixed(0 downto 1 - data_width);
      signal c6_Q : sfixed(0 downto 1 - data_width);
      signal c7_Q : sfixed(0 downto 1 - data_width);  

begin

    -- c7 = phi0
      c7_I(0) <= not data_in(7);
      c7_Q(0) <= not data_in(6);
      c7_I(-1 downto 1 - data_width) <= (others => data_in(7));
      c7_Q(-1 downto 1 - data_width) <= (others => data_in(6));
    
    -- c6 = phi0 * phi1
      vector_rotator_c6: vector_rotator
        port map(n_reset, not data_in(7), not data_in(6), not data_in(5), not data_in(4), c6_I(0), c6_Q(0));
      c6_I(-1 downto 1 - data_width) <= (others => not c6_I(0));
      c6_Q(-1 downto 1 - data_width) <= (others => not c6_Q(0));

    -- c5 = phi0 * phi2
      vector_rotator_c5: vector_rotator
        port map(n_reset, not data_in(7), not data_in(6), not data_in(3), not data_in(2), c5_I(0), c5_Q(0));
      c5_I(-1 downto 1 - data_width) <= (others => not c5_I(0));
      c5_Q(-1 downto 1 - data_width) <= (others => not c5_Q(0));

    -- c4 = phi0 * phi1 * phi2 = c6 * phi2
      vector_rotator_c4: vector_rotator
        port map(n_reset, c6_I(0), c6_Q(0), not data_in(3), not data_in(2), c4_I(0), c4_Q(0));
      c4_I(-1 downto 1 - data_width) <= (others => not c4_I(0));
      c4_Q(-1 downto 1 - data_width) <= (others => not c4_Q(0));

    -- c3 = phi0 * phi3
      vector_rotator_c3: vector_rotator
        port map(n_reset, not data_in(7), not data_in(6), not data_in(1), not data_in(0), c3_I(0), c3_Q(0));
      c3_I(-1 downto 1 - data_width) <= (others => not c3_I(0));
      c3_Q(-1 downto 1 - data_width) <= (others => not c3_Q(0));

    -- c2 = phi0 * phi1 * phi3 = c6 * phi3
      vector_rotator_c2: vector_rotator
        port map(n_reset, c6_I(0), c6_Q(0), not data_in(1), not data_in(0), c2_I(0), c2_Q(0));
      c2_I(-1 downto 1 - data_width) <= (others => not c2_I(0));
      c2_Q(-1 downto 1 - data_width) <= (others => not c2_Q(0));

    -- c1 = phi0 * phi2 * phi3 = c3 * phi2
      vector_rotator_0_2_3: vector_rotator
        port map(n_reset, c3_I(0), c3_Q(0), not data_in(3), not data_in(2), c1_I(0), c1_Q(0));
      c1_I(-1 downto 1 - data_width) <= (others => not c1_I(0));
      c1_Q(-1 downto 1 - data_width) <= (others => not c1_Q(0));
    
    -- c0 = phi0 * phi1 * phi2 * phi3 = c4 * phi3
      vector_rotator_c0: vector_rotator
        port map(n_reset, c4_I(0), c4_Q(0), not data_in(1), not data_in(0), c0_I(0), c0_Q(0));
      c0_I(-1 downto 1 - data_width) <= (others => not c0_I(0));
      c0_Q(-1 downto 1 - data_width) <= (others => not c0_Q(0));

end FIMP_0;
