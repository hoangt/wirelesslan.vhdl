--  802.11a transmitter
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
use IEEE.math_real.all;
use IEEE.fixed_float_types.all;
use IEEE.fixed_pkg.all;

library work;
use work.all;

entity tx_802_11_a is
  generic (
    data_width : integer := 8
    );
  port (
    clk : in std_logic;
    n_reset : in std_logic;
    mode : in integer range 0 to 54;
      -- 6  -> 6  Mbit/s, default
      -- 9  -> 9  Mbit/s
      -- 12 -> 12 Mbit/s
      -- 18 -> 18 Mbit/s
      -- 24 -> 24 Mbit/s
      -- 36 -> 36 Mbit/s
      -- 48 -> 48 Mbit/s
      -- 54 -> 54 Mbit/s
    Din : in std_logic;
    Dout_I : out sfixed(data_width * 80 - 1 downto 0);
    Dout_Q : out sfixed(data_width * 80 - 1 downto 0)
    );
  end tx_802_11_a;
  
architecture FIMP_0 of tx_802_11_a is
  
  -- scrambling
    component scrambler_802_11_a is 
      port (
        clk : in std_logic;
        n_reset : in std_logic;
        Din : in std_logic ;
        Dout : out std_logic
        );
      end component;
    
    signal after_scrambler : std_logic;

  -- convolutional encoding
    component convolutional_encoder is 
      port (
        clk : in std_logic;
        n_reset : in std_logic;
        Din : in std_logic;
        DoutA : out std_logic;
        DoutB : out std_logic
        );
      end component;

    signal after_convolution_encoder_A : std_logic;
    signal after_convolution_encoder_B : std_logic;

  -- puncturing
    component puncturer is
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
      end component;

    signal puncture_rate_2_3 : std_logic;
    signal puncture_rate_3_4 : std_logic;
    signal puncture_ready_2_3 : std_logic;
    signal puncture_ready_3_4 : std_logic;
    signal after_puncturer_2_3 : std_logic_vector (8 downto 0);
    signal after_puncturer_3_4 : std_logic_vector (11 downto 0);

  -- interleaving
    signal counter : integer range 0 to 255;
    --                                       net bit per symbol, 1 / puncture rate
    -- signal buffer_6  : std_logic_vector ( 24                * 2 / 1            - 1 downto 0); -- 48  = 1 * 48
    -- signal buffer_9  : std_logic_vector ( 36                * 4 / 3            - 1 downto 0); -- 48  = 1 * 48
    signal buffer_6_9   : std_logic_vector (48 - 1 downto 0);
    -- signal buffer_12 : std_logic_vector ( 48                * 2 / 1            - 1 downto 0); -- 96  = 2 * 48
    -- signal buffer_18 : std_logic_vector ( 72                * 4 / 3            - 1 downto 0); -- 96  = 2 * 48
    signal buffer_12_18 : std_logic_vector (96 - 1 downto 0);
    -- signal buffer_24 : std_logic_vector ( 96                * 2 / 1            - 1 downto 0); -- 192 = 4 * 48
    -- signal buffer_36 : std_logic_vector ( 144               * 4 / 3            - 1 downto 0); -- 192 = 4 * 48
    signal buffer_24_36 : std_logic_vector (192 - 1 downto 0);
    -- signal buffer_48 : std_logic_vector ( 192               * 3 / 2            - 1 downto 0); -- 288 = 6 * 48
    -- signal buffer_54 : std_logic_vector ( 216               * 4 / 3            - 1 downto 0); -- 288 = 6 * 48
    signal buffer_48_54 : std_logic_vector (288 - 1 downto 0);

    signal interleaver_n_reset : std_logic_vector(3 downto 0);
    signal synchronized_interleaver_n_reset : std_logic_vector(3 downto 0);

    -- 4 interleavers are used
      -- 48 bits for 6 and 9 Mbit/s
      -- 96 bits for 12 and 18 Mbit/s
      -- 192 bits for 24 and 36 Mbit/s
      -- 288 bits for 48 and 54 Mbit/s
    component interleaver is
      generic (
        depth : integer range 0 to 255 := 6
        );
      port (
        clk : in std_logic;
        n_reset : in std_logic;
        Din : in std_logic_vector (depth * 8 - 1 downto 0);
        Dout : out std_logic_vector (depth * 8 - 1 downto 0)
        );
      end component;

    -- data buffer after interleaver
      signal after_interleaver_6_9  : std_logic_vector (48 - 1 downto 0);
      signal after_interleaver_12_18 : std_logic_vector (96 - 1 downto 0);
      signal after_interleaver_24_36 : std_logic_vector (192 - 1 downto 0);
      signal after_interleaver_48_54 : std_logic_vector (288 - 1 downto 0);

  -- IQ modulation
    component bpsk is
      generic (
        data_width : integer := 8
        );
      port (
        clk : in std_logic;
        n_reset : in std_logic;
        BPSK_in : in std_logic;
        I : out sfixed(0 downto 1 - data_width);
        Q : out sfixed(0 downto 1 - data_width)
      );
      end component;

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

    component qam_16 is
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
      end component;

    component qam_64 is
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
      end component;
    
    signal current_bpsk_input_A : std_logic;
    signal current_bpsk_input_B : std_logic;
    signal current_qpsk_input : std_logic_vector (1 downto 0);
    signal current_qam16_input : std_logic_vector (3 downto 0);
    signal current_qam64_input : std_logic_vector (5 downto 0);

    signal after_bpsk_A_I : sfixed (0 downto 1 - data_width);
    signal after_bpsk_B_I : sfixed (0 downto 1 - data_width);
    signal after_qpsk_I : sfixed (0 downto 1 - data_width);
    signal after_qam16_I : sfixed (0 downto 1 - data_width);
    signal after_qam64_I : sfixed (0 downto 1 - data_width);

    signal after_bpsk_A_Q : sfixed (0 downto 1 - data_width);
    signal after_bpsk_B_Q : sfixed (0 downto 1 - data_width);
    signal after_qpsk_Q : sfixed (0 downto 1 - data_width);
    signal after_qam16_Q : sfixed (0 downto 1 - data_width);
    signal after_qam64_Q : sfixed (0 downto 1 - data_width);

  -- IFFT
    component nifft is
      generic (
        point : integer := 64;
        stage : integer := 6; -- stage = log2(point)
        data_width : integer := 16
        );
      port (
        n_reset : in std_logic;
        y_re : in sfixed(data_width * point - 1 downto 0);
        y_im : in sfixed(data_width * point - 1 downto 0);
        x_re : out sfixed(data_width * point - 1 downto 0);
        x_im : out sfixed(data_width * point - 1 downto 0)
        );
      end component;

    signal ifft_input_I : sfixed(data_width * 64 - 1 downto 0);
    signal ifft_input_Q : sfixed(data_width * 64 - 1 downto 0);
    signal ifft_output_I : sfixed(data_width * 64 - 1 downto 0);
    signal ifft_output_Q : sfixed(data_width * 64 - 1 downto 0);
    signal ifft_enable : std_logic;
  
  -- guard insertion
    component guard_insertion is
      generic (
        data_width : integer := 16;
        data_length : integer := 64;
        whitespace_length : integer := 16
        );
      port (
        in_re : in sfixed(data_width * data_length - 1 downto 0);
        in_im : in sfixed(data_width * data_length - 1 downto 0);
        out_re : out sfixed(data_width * (data_length + whitespace_length) - 1 downto 0);
        out_im : out sfixed(data_width * (data_length + whitespace_length) - 1 downto 0)
        );
      end component;

begin
  
  -- scrambling
    scramling: scrambler_802_11_a
      port map (clk, n_reset, Din, after_scrambler);
  
  -- convolutional encoding
    convolutional_encoding: convolutional_encoder
      port map (clk, n_reset, after_scrambler, after_convolution_encoder_A, after_convolution_encoder_B);
  
  with mode select
    puncture_rate_2_3 <= '1' when 48, '0' when others;

  with mode select
    puncture_rate_3_4 <= '1' when 9 | 18 | 36 | 54, '0' when others;
    
  -- puncturing
    puncturing: puncturer
      port map (clk, n_reset,
                puncture_rate_2_3, puncture_rate_3_4,
                after_convolution_encoder_A, after_convolution_encoder_B,
                puncture_ready_2_3, puncture_ready_3_4,
                after_puncturer_2_3, after_puncturer_3_4);
    
  -- interleaving
    -- data acquisition, from puncturer or convolutional encoder to interleaver
      -- data acquisition counter
      process(clk, n_reset, mode, puncture_ready_2_3, puncture_ready_3_4)
        begin

        if (n_reset = '0') then
          counter <= 0;
        elsif (clk'event and clk = '1') then
          case mode is
            when 6 =>
              if (counter = 24 - 1) then counter <= 0; else counter <= counter + 1; end if;
            when 9 =>
              if (counter = 36 - 1) then counter <= 0; else counter <= counter + 1; end if;
            when 12 =>
              if (counter = 48 - 1) then counter <= 0; else counter <= counter + 1; end if;
            when 18 =>
              if (counter = 72 - 1) then counter <= 0; else counter <= counter + 1; end if;
            when 24 =>
              if (counter = 96 - 1) then counter <= 0; else counter <= counter + 1; end if;
            when 36 =>
              if (counter = 144 - 1) then counter <= 0; else counter <= counter + 1; end if;
            when 48 =>
              if (counter = 192 - 1) then counter <= 0; else counter <= counter + 1; end if;
            when 54 =>
              if (counter = 216 - 1) then counter <= 0; else counter <= counter + 1; end if;
            when others =>
              if (counter = 24 - 1) then counter <= 0; else counter <= counter + 1; end if;
            end case;
          end if;

        end process;

      -- data acquisition
      process(clk, n_reset, mode, counter)
        begin
        if (n_reset = '0') then
          buffer_6_9 <= (others => '0');
          buffer_12_18 <= (others => '0');
          buffer_24_36 <= (others => '0');
          buffer_48_54 <= (others => '0');
        elsif (clk'event and clk = '1') then
          case mode is
            when 6 => -- 1/2
              buffer_6_9(counter * 2) <= after_convolution_encoder_A;
              buffer_6_9(counter * 2) <= after_convolution_encoder_B;
            when 9 => -- 9/12
              if puncture_ready_3_4 = '1' then
                buffer_6_9(11 downto 0) <= after_puncturer_3_4;
                shift_6_9: for i in 1 to 3 loop
                  buffer_6_9((i+1)*12-1 downto i*12) <= buffer_6_9(i*12-1 downto (i-1)*12);
                  end loop shift_6_9;
                end if;
            when 12 => -- 1/2
              buffer_12_18(counter * 2) <= after_convolution_encoder_A;
              buffer_12_18(counter * 2) <= after_convolution_encoder_B;
            when 18 => -- 9/12
              if puncture_ready_3_4 = '1' then
                buffer_12_18(11 downto 0) <= after_puncturer_3_4;
                shift_12_18: for i in 1 to 7 loop
                  buffer_12_18((i+1)*12-1 downto i*12) <= buffer_12_18(i*12-1 downto (i-1)*12);
                  end loop shift_12_18;
                end if;
            when 24 => -- 1/2
              buffer_24_36(counter * 2) <= after_convolution_encoder_A;
              buffer_24_36(counter * 2) <= after_convolution_encoder_B;
            when 36 => -- 9/12
              if puncture_ready_3_4 = '1' then
                buffer_24_36(11 downto 0) <= after_puncturer_3_4;
                shift_24_36: for i in 1 to 15 loop
                  buffer_24_36((i+1)*12-1 downto i*12) <= buffer_24_36(i*12-1 downto (i-1)*12);
                  end loop shift_24_36;
                end if;
            when 48 => -- 6/9
              if puncture_ready_2_3 = '1' then
                buffer_48_54(8 downto 0) <= after_puncturer_2_3;
                shift_48: for i in 1 to 31 loop
                  buffer_48_54((i+1)*9-1 downto i*9) <= buffer_48_54(i*9-1 downto (i-1)*9);
                  end loop shift_48;
                end if;
            when 54 =>
              if puncture_ready_3_4 = '1' then
                buffer_48_54(11 downto 0) <= after_puncturer_3_4;
                shift_54: for i in 1 to 23 loop
                  buffer_48_54((i+1)*12-1 downto i*12) <= buffer_48_54(i*12-1 downto (i-1)*12);
                  end loop shift_54;
                end if;
            when others =>
              buffer_6_9(counter * 2) <= after_convolution_encoder_A;
              buffer_6_9(counter * 2) <= after_convolution_encoder_B;
            end case;

          end if;
        end process;
    
    -- interleaver control signal (n_reset)
      -- interleaver reset signals, not synchronized 
      process(mode)
        begin
        case mode is
          when 6 => interleaver_n_reset <= "0001";
          when 9 => interleaver_n_reset <= "0001";
          when 12 => interleaver_n_reset <= "0010";
          when 18 => interleaver_n_reset <= "0010";
          when 24 => interleaver_n_reset <= "0100";
          when 36 => interleaver_n_reset <= "0100";
          when 48 => interleaver_n_reset <= "1000";
          when 54 => interleaver_n_reset <= "1000";
          when others => interleaver_n_reset <= "0001"; -- default 6 Mbit/s
          end case;
        end process;
      
      -- synchronized interleaver reset signals 
      process(clk, n_reset, interleaver_n_reset)
        begin
        if (n_reset = '0') then
          synchronized_interleaver_n_reset <= (others => '0');
        elsif (clk'event and clk = '1') then
          if (counter = 1) then
            synchronized_interleaver_n_reset <= interleaver_n_reset;
            end if;
          end if;
        end process;

    -- interleavers
      interleaver_6_9: interleaver generic map(48/8)
        port map(clk, synchronized_interleaver_n_reset(0), buffer_6_9, after_interleaver_6_9);
      
      interleaver_12_18: interleaver generic map(96/8)
        port map(clk, synchronized_interleaver_n_reset(1), buffer_12_18, after_interleaver_12_18);
      
      interleaver_24_36: interleaver generic map(192/8)
        port map(clk, synchronized_interleaver_n_reset(2), buffer_24_36, after_interleaver_24_36);
      
      interleaver_48_54: interleaver generic map(288/8)
        port map(clk, synchronized_interleaver_n_reset(3), buffer_48_54, after_interleaver_48_54);

  -- IQ modulation
    process(clk, n_reset, counter)
      begin

      if (n_reset = '0') then

        current_bpsk_input_A <= '0';
        current_bpsk_input_B <= '0';
        current_qpsk_input <= (others => '0');
        current_qam16_input <= (others => '0');
        current_qam64_input <= (others => '0');

      elsif (clk'event and clk = '1') then
        case mode is
          when 6 => -- 1/2
            current_bpsk_input_A <= after_interleaver_6_9(counter * 2);
            current_bpsk_input_B <= after_interleaver_6_9(counter * 2 + 1);
          when 9 => -- 9/12
            if (counter > 36 - 48/2 - 1) then
              current_bpsk_input_A <= after_interleaver_6_9((counter - (36 - 48/2))*2);
              current_bpsk_input_B <= after_interleaver_6_9((counter - (36 - 48/2))*2 + 1);
              end if;
          when 12 => -- 1/2
            current_qpsk_input <= after_interleaver_12_18((counter + 1) * 2 - 1 downto counter * 2);
          when 18 => -- 9/12
            if (counter > 72 - 48 - 1) then
              current_qpsk_input <= after_interleaver_12_18((counter - (72 - 96/2) + 1) * 2 - 1 downto (counter - (72 - 96/2)) * 2);
              end if;
          when 24 => -- 1/2
            if (counter > 96 - 48 - 1) then
              current_qam16_input <= after_interleaver_24_36((counter - (96 - 48) + 1) * 4 - 1 downto (counter - (96 - 48)) * 4);
            end if;
          when 36 => -- 9/12
            if (counter > 144 - 48 - 1) then
              current_qam16_input <= after_interleaver_24_36((counter - (144 - 48) + 1) * 4 - 1 downto (counter - (144 - 48)) * 4);
            end if;
          when 48 => -- 6/9
            if (counter > 192 - 48 - 1) then
              current_qam64_input <= after_interleaver_48_54((counter - (192 - 48) + 1) * 6 - 1 downto (counter - (192 - 48)) * 6);
              end if;
          when 54 =>
           if (counter > 216 - 48 - 1) then
              current_qam64_input <= after_interleaver_48_54((counter - (216 - 48) + 1) * 6 - 1 downto (counter - (216 - 48)) * 6);
              end if;
          when others =>
            current_bpsk_input_A <= after_interleaver_6_9(counter * 2);
            current_bpsk_input_B <= after_interleaver_6_9(counter * 2 + 1);
          end case;

        end if;

      end process;
    
    bpsk_modulation_A: bpsk
      generic map(data_width)
      port map(clk, n_reset, current_bpsk_input_A, after_bpsk_A_I, after_bpsk_A_Q);
    bpsk_modulation_B: bpsk
      generic map(data_width)
      port map(clk, n_reset, current_bpsk_input_B, after_bpsk_B_I, after_bpsk_B_Q);
    qpsk_modulation: qpsk
      generic map(data_width)
      port map(clk, n_reset, current_qpsk_input, after_qpsk_I, after_qpsk_Q);
    qam16_modulation: qam_16
      generic map(data_width)
      port map(clk, n_reset, current_qam16_input, after_qam16_I, after_qam16_Q);
    qam64_modulation: qam_64
      generic map(data_width)
      port map(clk, n_reset, current_qam64_input, after_qam64_I, after_qam64_Q);

  -- IFFT
    process(clk, n_reset, mode)
      begin

        if (n_reset = '0') then
          ifft_input_I <= (others => '0');
          ifft_input_Q <= (others => '0');
        elsif (clk'event and clk = '1') then
          case mode is
            when 6 => -- 1/2
              ifft_input_I((counter * 2 + 1) * data_width - 1 downto (counter * 2 + 0) * data_width) <= after_bpsk_A_I;
              ifft_input_I((counter * 2 + 2) * data_width - 1 downto (counter * 2 + 1) * data_width) <= after_bpsk_B_I;
              ifft_input_Q <= (others => '0');
            when 9 => -- 9/12
              if (counter > 36 - 48/2 - 1) then
                ifft_input_I(((counter - (36 - 48/2)) * 2 + 1) * data_width - 1 downto ((counter - (36 - 48/2)) * 2 + 0) * data_width) <= after_bpsk_A_I;
                ifft_input_I(((counter - (36 - 48/2)) * 2 + 2) * data_width - 1 downto ((counter - (36 - 48/2)) * 2 + 1) * data_width) <= after_bpsk_B_I;
                end if;
              ifft_input_Q <= (others => '0');
            when 12 => -- 1/2
              ifft_input_I((counter + 1) * data_width - 1 downto counter * data_width) <= after_qpsk_I;
              ifft_input_Q((counter + 1) * data_width - 1 downto counter * data_width) <= after_qpsk_Q;
            when 18 => -- 9/12
              if (counter > 72 - 48 - 1) then
                ifft_input_I(((counter - (72 - 96/2)) + 1) * data_width - 1 downto (counter - (72 - 96/2)) * data_width) <= after_qpsk_I;
                ifft_input_Q(((counter - (72 - 96/2)) + 1) * data_width - 1 downto (counter - (72 - 96/2)) * data_width) <= after_qpsk_Q;
                end if;
            when 24 => -- 1/2
              if (counter > 96 - 48 - 1) then
                ifft_input_I(((counter - (96 - 48)) + 1) * data_width - 1 downto (counter - (96 - 48)) * data_width) <= after_qam16_I;
                ifft_input_Q(((counter - (96 - 48)) + 1) * data_width - 1 downto (counter - (96 - 48)) * data_width) <= after_qam16_Q;
              end if;
            when 36 => -- 9/12
              if (counter > 144 - 48 - 1) then
                ifft_input_I(((counter - (144 - 48)) + 1) * data_width - 1 downto (counter - (144 - 48)) * data_width) <= after_qam16_I;
                ifft_input_Q(((counter - (144 - 48)) + 1) * data_width - 1 downto (counter - (144 - 48)) * data_width) <= after_qam16_Q;
              end if;
            when 48 => -- 6/9
              if (counter > 192 - 48 - 1) then
                ifft_input_I(((counter - (192 - 48)) + 1) * data_width - 1 downto (counter - (192 - 48)) * data_width) <= after_qam64_I;
                ifft_input_Q(((counter - (192 - 48)) + 1) * data_width - 1 downto (counter - (192 - 48)) * data_width) <= after_qam64_Q;
                end if;
            when 54 =>
             if (counter > 216 - 48 - 1) then
                ifft_input_I(((counter - (216 - 48)) + 1) * data_width - 1 downto (counter - (216 - 48)) * data_width) <= after_qam64_I;
                ifft_input_Q(((counter - (216 - 48)) + 1) * data_width - 1 downto (counter - (216 - 48)) * data_width) <= after_qam64_Q;
                end if;
            when others =>
              ifft_input_I((counter * 2 + 1) * data_width - 1 downto (counter * 2 + 0) * data_width) <= after_bpsk_A_I;
              ifft_input_I((counter * 2 + 2) * data_width - 1 downto (counter * 2 + 1) * data_width) <= after_bpsk_B_I;
              ifft_input_Q <= (others => '0');
            end case; 
        end if;
      end process;
    
    with counter select
      ifft_enable <= '1' when 1,
                     '0' when others;
    ifft: nifft
      generic map(64, 6, data_width)
      port map(ifft_enable, ifft_input_I, ifft_input_Q, ifft_output_I, ifft_output_Q);
  
  -- guard insertion
    GI: guard_insertion
      generic map(data_width, 64, 16)
      port map (ifft_output_I, ifft_output_Q, Dout_I, Dout_Q);

end FIMP_0;