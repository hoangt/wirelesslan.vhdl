--  DSSS for 802.11b
  -- 11-bit scrambler + DBPSK(1Mbit/s) or DQPSK(2Mbit/s)
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

entity dsss_802_11_b is
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
  end dsss_802_11_b;

architecture FIMP_0 of dsss_802_11_b is
  
  component dbpsk is
    generic (
      data_width : integer := 8
      );
    port (
      clk : in std_logic;
      n_reset : in std_logic;
      DBPSK_in : in std_logic;
      I : out sfixed(0 downto 1 - data_width);
      Q : out sfixed(0 downto 1 - data_width)
      );
    end component;

  component dqpsk is
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
    end component;
 
  signal dbpsk_in : std_logic;
  signal dqpsk_in : std_logic_vector(1 downto 0);

  signal dbpsk_en : std_logic;
  signal dqpsk_en : std_logic;
  
  signal dbpsk_out_I : sfixed(0 downto 1 - data_width);
  signal dbpsk_out_Q : sfixed(0 downto 1 - data_width);
  signal dqpsk_out_I : sfixed(0 downto 1 - data_width);
  signal dqpsk_out_Q : sfixed(0 downto 1 - data_width);
  
  signal barker_out_A : std_logic;
  signal barker_out_B : std_logic;

  signal Barker_sequence : std_logic_vector(10 downto 0);
  signal counter : integer range 0 to 10;

begin
  
  Barker_sequence <= "10110111000";

  -- counter for barker sequence
    process(clk, n_reset)
      begin
      if n_reset = '0' then
        counter <= 0;
      elsif clk'event and clk = '1' then
        if counter = 10 then
          counter <= 0;
        else
          counter <= counter + 1;
        end if;
      end if;
      end process;

  -- final output selection
    with mode select
      I <= dbpsk_out_I when '0',
           dqpsk_out_I when others;
    
    with mode select
      Q <= dbpsk_out_Q when '0',
           dqpsk_out_Q when others;
  
  -- n_reset(enable) signal for dbpsk and dqpsk
    dbpsk_en <= n_reset and not mode;
    dqpsk_en <= n_reset and mode;
  
  -- input selection for dbpsk and dqpsk
    process(clk, n_reset)
      begin
      if n_reset = '0' then
        dbpsk_in <= '0';
        dqpsk_in <= "00";
      elsif clk'event and clk = '1' then
        dbpsk_in <= Din_1M_2M_MSB xor Barker_sequence(counter);
        dqpsk_in(1) <= Din_1M_2M_MSB xor Barker_sequence(counter);
        dqpsk_in(0) <= Din_2M_LSB xor Barker_sequence(counter);
      end if;
      end process;
      
  -- dbpsk and dqpsk design units
    dbpsk_unit: dbpsk generic map(data_width)
      port map(clk, dbpsk_en, dbpsk_in, dbpsk_out_I, dbpsk_out_Q);
    
    dqpsk_unit: dqpsk generic map(data_width)
      port map(clk, dqpsk_en, dqpsk_in, dqpsk_out_I, dqpsk_out_Q);

end FIMP_0;