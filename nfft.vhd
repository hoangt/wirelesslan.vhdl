--  n-point FFT, radix-2
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

entity nfft is
  generic (
    point : integer := 64;
    stage : integer := 6; -- stage = log2(point)
    data_width : integer := 16
    );
  port (
    n_reset : in std_logic;
    x_re : in sfixed(data_width * point - 1 downto 0);
    x_im : in sfixed(data_width * point - 1 downto 0);
    y_re : out sfixed(data_width * point - 1 downto 0);
    y_im : out sfixed(data_width * point - 1 downto 0)
    );
  end nfft;

architecture FIMP_0 of nfft is

  component butterfly_2 is
    generic (
      data_width : integer := 16
      );
    port (
      x0_re : in sfixed(0 downto 1 - data_width);
      x0_im : in sfixed(0 downto 1 - data_width);
      x1_re : in sfixed(0 downto 1 - data_width);
      x1_im : in sfixed(0 downto 1 - data_width);
      w_re : in sfixed(0 downto 1 - data_width);
      w_im : in sfixed(0 downto 1 - data_width);
      y0_re : out sfixed(0 downto 1 - data_width);
      y0_im : out sfixed(0 downto 1 - data_width);
      y1_re : out sfixed(0 downto 1 - data_width);
      y1_im : out sfixed(0 downto 1 - data_width)
      );
    end component;

  component bit_reverse_int is
    generic (
      data_width : integer := 4
      );
    port (
      nreset : in std_logic;
      data_in : in integer range 0 to 2**data_width - 1;
      data_out : out integer range 0 to 2**data_width - 1
      );
    end component;

  component bit_reverse is
    generic (
      data_width : integer := 4
      );
    port (
      nreset : in std_logic;
      data_in : in std_logic_vector (data_width - 1 downto 0);
      data_out : out std_logic_vector (data_width - 1 downto 0)
      );
    end component;

  component merge is
    generic (
      data_width: integer := 8;
      lsb_width: integer := 4
      );
    port (
      nreset : in std_logic;
      msb : in std_logic_vector (data_width - 1 downto 0);
      lsb : in std_logic_vector (lsb_width - 1 downto 0);
      merged : out std_logic_vector (data_width - 1 downto 0)
      );
    end component;

  type buffer_type is array (stage - 1 downto 0, point - 1 downto 0) of sfixed(0 downto 1 - data_width);
    signal x_buffer_re : buffer_type;
    signal x_buffer_im : buffer_type;
    signal y_buffer_re : buffer_type;
    signal y_buffer_im : buffer_type;

  type address_type is array (stage - 1 downto 0, point - 1 downto 0) of integer range 0 to point - 1;
    signal x_address : address_type;
    signal y_address : address_type;

  type address_type_std_logic_vector is
    array (stage - 1 downto 0, point - 1 downto 0)
    of std_logic_vector (stage - 1 downto 0);
    signal x_address_std_logic_vector : address_type_std_logic_vector;
    signal x_address_std_logic_vector_final : address_type_std_logic_vector;

  type w_address_type is array (point/2 - 1 downto 0) of integer range 0 to point/2 - 1;
    signal w_address : w_address_type;

  type twiddle_factor_buffer_type is array (point - 1 downto 0) of sfixed(0 downto 1 - data_width);
    signal twiddle_factor_re : twiddle_factor_buffer_type;
    signal twiddle_factor_im : twiddle_factor_buffer_type;
  
begin

  twiddle_factors: for n in 0 to point - 1 generate
    twiddle_factor_re(n) <= to_sfixed(cos(MATH_2_PI*real(n)/real(point)), 0, 1-data_width);
    twiddle_factor_im(n) <= to_sfixed(-sin(MATH_2_PI*real(n)/real(point)), 0, 1-data_width); 
    end generate twiddle_factors;

  twiddle_factor_address: for b in 0 to point/2 - 1 generate
    br_twiddle_factor: bit_reverse_int generic map(stage-1) port map(n_reset, b, w_address(b));

    end generate twiddle_factor_address;      
 
  read_input: for n in 0 to point - 1 generate
    br_read_input: bit_reverse_int generic map(stage) port map(n_reset, n, x_address(0, n));
    x_buffer_re(0, n) <= x_re((x_address(0, n) + 1) * data_width - 1 downto x_address(0, n) * data_width); 
    x_buffer_im(0, n) <= x_im((x_address(0, n) + 1) * data_width - 1 downto x_address(0, n) * data_width);
    end generate read_input;

  stage_0: for b in 0 to point/2 - 1 generate
    bf_stage_0: butterfly_2 generic map(data_width)
      port map (
        x_buffer_re(0, b*2),   x_buffer_im(0, b*2),
        x_buffer_re(0, b*2+1), x_buffer_im(0, b*2+1),
        twiddle_factor_re(w_address(b)),
        twiddle_factor_im(w_address(b)),
        y_buffer_re(0, b*2),   y_buffer_im(0, b*2),
        y_buffer_re(0, b*2+1), y_buffer_im(0, b*2+1));
    end generate stage_0;

  computation: for s in 1 to stage - 2 generate
    each_stage: for b in 0 to point/2 - 1 generate

      -- bit reverse ordered addressing for input 0
      br_each_stage_0: bit_reverse generic map(s+1)
        port map (
          n_reset,
          std_logic_vector(to_unsigned(b*2, s+1)),
          x_address_std_logic_vector(s, b*2)(s downto 0));
      merge_stage_0: merge generic map(stage, s+1)
        port map (
          n_reset,
          std_logic_vector(to_unsigned(b*2, stage)),
          x_address_std_logic_vector(s, b*2)(s downto 0),
          x_address_std_logic_vector_final(s, b*2));
      x_address(s, b*2) <= to_integer(unsigned(x_address_std_logic_vector_final(s, b*2)));

      -- bit reverse ordered addressing for input 1
      br_each_stage_1: bit_reverse generic map(s+1)
        port map (
          n_reset,
          std_logic_vector(to_unsigned(b*2+1, s+1)),
          x_address_std_logic_vector(s, b*2+1)(s downto 0));
      merge_stage_1: merge generic map(stage, s+1)
        port map (
          n_reset,
          std_logic_vector(to_unsigned(b*2+1, stage)),
          x_address_std_logic_vector(s, b*2+1)(s downto 0),
          x_address_std_logic_vector_final(s, b*2+1));
      x_address(s, b*2+1) <= to_integer(unsigned(x_address_std_logic_vector_final(s, b*2+1)));

      x_buffer_re(s, b*2) <= y_buffer_re(s-1, x_address(s, b*2));
      x_buffer_im(s, b*2) <= y_buffer_im(s-1, x_address(s, b*2));

      x_buffer_re(s, b*2+1) <= y_buffer_re(s-1, x_address(s, b*2+1));
      x_buffer_im(s, b*2+1) <= y_buffer_im(s-1, x_address(s, b*2+1));

      bf_stage: butterfly_2 generic map(data_width)
        port map (
          x_buffer_re(s, b*2),   x_buffer_im(s, b*2),
          x_buffer_re(s, b*2+1), x_buffer_im(s, b*2+1),
          twiddle_factor_re(w_address(to_integer(to_unsigned(b, stage-1) srl s))),
          twiddle_factor_im(w_address(to_integer(to_unsigned(b, stage-1) srl s))),
          y_buffer_re(s, b*2),   y_buffer_im(s, b*2),
          y_buffer_re(s, b*2+1), y_buffer_im(s, b*2+1));

      end generate each_stage;
    end generate computation;

  last_stage: for b in 0 to point/2 - 1 generate
    br_last_stage_0: bit_reverse_int generic map(stage) port map(n_reset, b*2, x_address(stage-1, b*2));
    br_last_stage_1: bit_reverse_int generic map(stage) port map(n_reset, b*2+1, x_address(stage-1, b*2+1));
    x_buffer_re(stage-1, b*2) <= y_buffer_re(stage-2, x_address(stage-1, b*2));
    x_buffer_im(stage-1, b*2) <= y_buffer_im(stage-2, x_address(stage-1, b*2));
    x_buffer_re(stage-1, b*2+1) <= y_buffer_re(stage-2, x_address(stage-1, b*2+1));
    x_buffer_im(stage-1, b*2+1) <= y_buffer_im(stage-2, x_address(stage-1, b*2+1));
    
    bf_last_stage: butterfly_2 generic map(data_width)
      port map (
        x_buffer_re(stage-1, b*2),   x_buffer_im(stage-1, b*2),
        x_buffer_re(stage-1, b*2+1), x_buffer_im(stage-1, b*2+1),
        to_sfixed(1.0, 0, 1-data_width), to_sfixed(0.0, 0, 1-data_width),
        y_buffer_re(stage-1, b*2),   y_buffer_im(stage-1, b*2),
        y_buffer_re(stage-1, b*2+1), y_buffer_im(stage-1, b*2+1));
    end generate last_stage;

  send_output: for b in 0 to point/2 - 1 generate
    y_re((b+1)        *data_width - 1 downto b          *data_width) <= y_buffer_re(stage-1, b*2);
    y_re((point/2+b+1)*data_width - 1 downto (point/2+b)*data_width) <= y_buffer_re(stage-1, b*2+1);
    y_im((b+1)        *data_width - 1 downto b          *data_width) <= y_buffer_im(stage-1, b*2);
    y_im((point/2+b+1)*data_width - 1 downto (point/2+b)*data_width) <= y_buffer_im(stage-1, b*2+1);
    end generate send_output;

end FIMP_0;
