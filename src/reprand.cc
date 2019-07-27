// file : reprand.cc
//
// A simple OS independent random number generator from:
//
//   http://www0.cs.ucl.ac.uk/staff/d.jones/GoodPracticeRNG.pdf
//
//   "Good Practice in (Pseudo) Random Number Generation for
//   Bioinformatics Applications" by David Jones, UCL Bioinformatics Group
//

// Copyright (C) 2017-2019 Robert G. Jenssen
// 
// This program is free software; you can redistribute it
// and/or modify it underthe terms of the GNU General Public
// License as published by the Free Software Foundation;
// either version 3 of the License, or (at your option)
// any later version. This program is distributed in the
// hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details. You should
// have received a copy of the GNU General Public License
// along with this program. If not, see:
// <http://www.gnu.org/licenses/>.

#if !defined(REPRAND_TEST)

#include <octave/oct.h>

static void init_JKISS(void);
static double uni_qdblflt(void);

DEFUN_DLD(reprand, args, nargout, "n=reprand(N)")
{
  if ((args.length() != 1) || (nargout > 1))
    {
      print_usage();
      return octave_value();
    }
  if (args(0).length() != 1)
    {
      error("expected single integer argument!");
      return octave_value();
    }

  uint64NDArray NN = args(0).vector_value();
  uint64_t N = NN(0);
  ColumnVector n(N);

  init_JKISS();
  for (uint64_t l = 0;l < N;l++)
    {
      n(l) = uni_qdblflt();
    }

  return octave_value(n);
}
#endif

// Public domain code for JKISS RNG

// Seed variables 
static unsigned int x;
static unsigned int y;
static unsigned int z;
static unsigned int c;

static void init_JKISS(void)
{
  x = 123456789;
  y = 987654321;
  z = 43219876;
  c = 6543217;
}

unsigned int JKISS(void)
{
  unsigned long long t;
  x = 314527869 * x + 1234567;
  y ^= y << 5; y ^= y >> 7; y ^= y << 22;
  t = 4294584393ULL * z + c; c = t >> 32; z = t;
  return x + y + z;
}

// Quickly generate random double precision float 0<=x<1 by type punning
static double uni_qdblflt(void)
{
  double x;
  unsigned long long a;
  a = ((unsigned long long)JKISS()<<32) + JKISS();
  a = (a >> 12) | 0x3FF0000000000000ULL; // Take upper 52 bits
  *((unsigned long long *)&x) = a;       // Make a double from bits
  return x-1.0;
}

