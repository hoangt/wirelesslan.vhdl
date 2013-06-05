--  n-point Inverse FFT, radix-2
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
  --
  -- ifft(y) = conj( fft( conj(y) ) ) / len(y)
  --
  --================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.fixed_float_types.all;
use IEEE.fixed_pkg.all;

library work;
use work.all;

entity nifft is
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
  end nifft;

architecture FIMP_0 of nifft is

  component conjugate is
    generic (
      data_width : integer := 16
      );
    port (
      in_re : in sfixed(0 downto 1 - data_width);
      in_im : in sfixed(0 downto 1 - data_width);
      out_re : out sfixed(0 downto 1 - data_width);
      out_im : out sfixed(0 downto 1 - data_width)
      );
    end component;

  component nfft is
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
    end component;

  type buffer_type is array (point - 1 downto 0) of sfixed(0 downto 1 - data_width);
    signal y_buffer_re : buffer_type;
    signal y_buffer_im : buffer_type;
    signal conjugated_y_buffer_re : buffer_type;
    signal conjugated_y_buffer_im : buffer_type;
    signal x_buffer_re : buffer_type;
    signal x_buffer_im : buffer_type;
    signal conjugated_x_re : buffer_type;
    signal conjugated_x_im : buffer_type;
  
  signal conjugated_y_re : sfixed(data_width * point - 1 downto 0);
  signal conjugated_y_im : sfixed(data_width * point - 1 downto 0);
  signal serial_x_re : sfixed(data_width * point - 1 downto 0);
  signal serial_x_im : sfixed(data_width * point - 1 downto 0);  

begin

  read_input: for n in 0 to point - 1 generate
    y_buffer_re(n) <= y_re((n + 1) * data_width - 1 downto n * data_width); 
    y_buffer_im(n) <= y_im((n + 1) * data_width - 1 downto n * data_width);
    end generate read_input;

  conjugate_input: for n in 0 to point - 1 generate
    conjugate_unit: conjugate
      generic map(data_width)
      port map(y_buffer_re(n), y_buffer_im(n), conjugated_y_buffer_re(n), conjugated_y_buffer_im(n));
    end generate conjugate_input;

  serialize_conjugated_input: for n in 0 to point - 1 generate
    conjugated_y_re((n + 1) * data_width - 1 downto n * data_width) <=  conjugated_y_buffer_re(n);
    conjugated_y_im((n + 1) * data_width - 1 downto n * data_width) <=  conjugated_y_buffer_im(n);
    end generate serialize_conjugated_input;

  fft_core: nfft
    generic map(point, stage, data_width)
    port map(n_reset, conjugated_y_re, conjugated_y_im, serial_x_re, serial_x_im);
  
  read_fft_output: for n in 0 to point - 1 generate
    x_buffer_re(n) <= serial_x_re((n + 1) * data_width - 1 downto n * data_width); 
    x_buffer_im(n) <= serial_x_im((n + 1) * data_width - 1 downto n * data_width);
    end generate read_fft_output;

  conjugate_fft_output: for n in 0 to point - 1 generate
    conjugate_unit: conjugate
      generic map(data_width)
      port map(x_buffer_re(n), x_buffer_im(n), conjugated_x_re(n), conjugated_x_im(n));
    end generate conjugate_fft_output;

  factor: for n in 0 to point - 1 generate
    x_re((n + 1) * data_width - 1 downto n * data_width) <=  conjugated_x_re(n) sra stage;
    x_im((n + 1) * data_width - 1 downto n * data_width) <=  conjugated_x_im(n) sra stage;
    end generate factor;  

end FIMP_0;

