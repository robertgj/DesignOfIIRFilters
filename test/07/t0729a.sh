#!/bin/sh

prog=schurOneMlatticeFilter_test.m

depends="test/schurOneMlatticeFilter_test.m test_common.m \
tf2schurOneMlattice.m schurOneMscale.m \
schurOneMlatticeNoiseGain.m schurOneMlatticeRetimedNoiseGain.m \
KW.m p2n60.m svf.m crossWelch.m \
qroots.oct schurexpand.oct schurdecomp.oct reprand.oct \
schurOneMlattice2Abcd.oct complex_zhong_inverse.oct"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED ${0#$here"/"} $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED ${0#$here"/"} $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
for file in $depends;do \
  cp -R src/$file $tmp; \
  if [ $? -ne 0 ]; then echo "Failed cp "$file; fail; fi \
done
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# Save schurOneMlatticeFilter.cc
#
# Avoid conflict with existing schurOneMlatticeFilter.m
#
cat > schurOneMlatticeFilter.cc << 'EOF'
// schurOneMlatticeFilter.cc
//
// [yap y xx] = schurOneMlatticeFilter(k,epsilon,p,c,u,rounding)
// Simulate a Schur one-multiplier lattice filter.
// Inputs:
//  k        - the lattice filter one-multiplier coefficients (used as 1:Nk)
//  epsilon  - the sign coefficients for each module (used as 1:Nk)
//  p        - the state scaling factors (used as 0:(Nk-1))
//  c        - the numerator polynomial orthogonal basis weights (used as 0:Nk)
//  u        - input sequence (Nu)
//  rounding - rounding mode. "round" for rounding to nearest
//             and "fix" for truncation to zero(2s complement)
// Outputs:  
//  yap - all pass output (Nu)
//  y   - filter output (Nu)
//  xx  - state (Nu+1 by 0:(Nk-1))
//
// See DesignOfSchurLatticeFIlters.tex
//
// To debug with gdb:
/*
   XCXXFLAGS="-ggdb3 -O0" make -B schurOneMlatticeFilter.oct
   gdb -ex "b FschurOneMlatticeFilter" \
       --args octave --no-gui -p src src/test/schurOneMlatticeFilter_test.m
*/
// To run address-sanitizer:
/*
   XCXXFLAGS="-ggdb3 -O0 -fsanitize=undefined -fsanitize=address \
              -fno-sanitize=vptr -fno-omit-frame-pointer" \
   make -B schurOneMlatticeFilter.oct
   LD_PRELOAD=/usr/lib64/libasan.so.8 \
   octave --no-gui -p src -p src/test --eval "schurOneMlatticeFilter_test"
*/

// Copyright (C) 2025 Robert G. Jenssen
//
// This program is free software; you can redistribute it and/or 
// modify it underthe terms of the GNU General Public License as 
// published by the Free Software Foundation; either version 3 of 
// the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

#include <cstring>
#include <cmath>

#include <octave/oct.h>
#include <octave/parse.h>

static double no_rounding(double x) { return x; }

DEFUN_DLD(schurOneMlatticeFilter, args, nargout,
          "[yap y xx] = schurOneMlatticeFilter(k,epsilon,p,c,u,rounding)")
{
  // Sanity checks
  octave_idx_type nargin=args.length();
  if ((nargin != 6) || (nargout>3))
    {
      print_usage();
      return octave_value_list();
     }

  if (nargout == 0)
    {
      return octave_value_list();
    }

  // Input arguments
  octave_idx_type Nk=args(0).numel();
  RowVector arg0=args(0).row_vector_value();
  RowVector k(Nk+1);
  k(0) = 0.0;
  for (octave_idx_type n=1;n<=arg0.numel();n++)
    {
      k(n)=arg0(n-1);
    }

  RowVector arg1 = args(1).row_vector_value();
  if (arg1.numel() != Nk)
    {
      error("k and epsilon vector lengths inconsistent!");
      return octave_value_list();
    }
  RowVector epsilon(Nk+1);
  epsilon(0) = 0.0;
  for (octave_idx_type n=1;n<=arg1.numel();n++)
    {
      epsilon(n)=arg1(n-1);
    }

  RowVector arg2 = args(2).row_vector_value();
  if (arg2.numel() != Nk)
    {
      error("k and p vector lengths inconsistent!");
      return octave_value_list();
    }
  RowVector p(Nk);
  for (octave_idx_type n=0;n<arg2.numel();n++)
    {
      p(n)=arg2(n);
    }

  RowVector c = args(3).row_vector_value();
  if (c.numel() != (Nk+1))
    {   
      error("k and c vector lengths inconsistent!");
      return octave_value_list();
    }
  
  ColumnVector u = args(4).column_vector_value();
  octave_idx_type Nu=u.numel();
  if (Nu == 0)
    {
      return octave_value_list();
    }

  double (*fround)(double x);
  try
    {
      charMatrix ch = args(5).char_matrix_value ();
      std::string rounding = ch.row_as_string(0);
      if (rounding.compare(0, 3, std::string("non")) == 0) 
        {
          fround = &no_rounding;
        }
      else if (rounding.compare(0, 3, std::string("rou")) == 0)
        {
          fround = &round;
        }
      else if (rounding.compare(0, 3, std::string("fix")) == 0)
        {
          fround = &trunc;
        }
      else
        {
          error("Expect rounding to be \"none\", \"round\" or \"fix\"!");
          return octave_value_list();
        }
    }
  catch(...)
    {
      error("rounding string error!");
      return octave_value_list();
    }
  
  //
  // Run the filter
  //
  ColumnVector yap(Nu);
  ColumnVector y(Nu);
  Matrix xx(Nu+1,Nk);

  RowVector x(Nk);
  RowVector yhat(Nk);
  RowVector xprime(Nk);
  for (octave_idx_type n=0;n<Nk;n++)
    {
      x(n) = 0.0;
      yhat(n) = 0.0;
      xprime(n) = 0.0;
      xx(0,n) = 0.0;
    }
  
  for (octave_idx_type m=0;m<Nu;m++)
    {
      // State scaling
      for (octave_idx_type n=0;n<Nk;n++)
        {
          x(n)=x(n)*p(n);
        }

      // Filter
      yhat(0)=x(0);
      for (octave_idx_type n=1;n<Nk;n++)
        {
          // Lattice section
          xprime(n-1) = (-k(n)*yhat(n-1))+
                        ((1.0+(k(n)*epsilon(n)))*x(n));
          yhat(n) = ((1-(k(n)*epsilon(n)))*yhat(n-1))+(k(n)*x(n));

          // Round all pass intermediate output
          yhat(n) = p(n)*fround(yhat(n)/p(n));
        }
      
      // Output lattice section
      xprime(Nk-1) = (-k(Nk)*yhat(Nk-1))+((1+(k(Nk)*epsilon(Nk)))*u(m));
      yap(m) = ((1-(k(Nk)*epsilon(Nk)))*yhat(Nk-1))+(k(Nk)*u(m));
      yap(m) = fround(yap(m));

      // Tapped output
      y(m) = 0.0;
      for (octave_idx_type n=0;n<Nk;n++)
        {
          y(m) = y(m)+(c(n)*x(n));
        }
      y(m) = y(m)+(c(Nk)*u(m));
      y(m) = fround(y(m));
      
      // Update and save state
      for(octave_idx_type n=0;n<Nk;n++)
        {
          x(n) = fround(xprime(n)/p(n));
          xx(m+1,n) = x(n);
        }
    }
  
  // Done
  octave_value_list retval(nargout);
  if (nargout >= 1)
    {
      retval(0)=yap;
    }
  if (nargout >= 2)
    {
      retval(1)=y;
    }
  if (nargout >= 3)
    {
      retval(2)=xx;
    }

  return retval;
}
EOF
if [ $? -ne 0 ]; then echo "Failed output schurOneMlatticeFilter.cc"; fail; fi
mkoctfile -v -o schurOneMlatticeFilter.oct schurOneMlatticeFilter.cc >/dev/null 2>&1
if [ $? -ne 0 ]; then echo "Failed compile schurOneMlatticeFilter.cc"; fail; fi

#
# the output should look like this (as for m-file test in t0582a.sh)
#
cat > test.ok << 'EOF'

Testing Nk=1
ng = 0.2500
ngap = 1.0000
ngSchur = 0.2500
ngSchurap = 1.0000
ngABCD = 0.2500
ngABCDap = 1.0000
est_varyd = 0.1042
est_varySchurd = 0.1042
varyd = 0.1054
est_varydABCD = 0.1042
varyABCDd = 0.1054
est_varyapd = 0.1667
est_varySchurapd = 0.1667
varyapd = 0.1675
est_varyABCDapd = 0.1667
varyABCDapd = 0.1675
stdxx = 126.21
stdxxf = 126.21
stdxxABCD = 126.22
stdxxABCDf = 126.22
stdxxABCDap = 126.22
stdxxABCDapf = 126.22
At fc Hf=-3.005182 (dB)

Testing Nk=2
ng = 0.5764
ngap = 3.0000
ngSchur = 0.5764
ngSchurap = 3.0000
ngABCD = 0.5000
ngABCDap = 2.0000
est_varyd = 0.1314
est_varySchurd = 0.1314
varyd = 0.1318
est_varydABCD = 0.1250
varyABCDd = 0.1282
est_varyapd = 0.3333
est_varySchurapd = 0.3333
varyapd = 0.3288
est_varyABCDapd = 0.2500
varyABCDapd = 0.2474
stdxx =
   125.70   126.77

stdxxf =
   125.69   126.77

stdxxABCD =
   125.70   126.77

stdxxABCDf =
   125.72   126.78

stdxxABCDap =
   125.70   126.77

stdxxABCDapf =
   125.72   126.78

At fc Hf=-3.000463 (dB)

Testing Nk=3
ng = 0.9823
ngap = 5.0000
ngSchur = 0.9823
ngSchurap = 5.0000
ngABCD = 0.7500
ngABCDap = 3.0000
est_varyd = 0.1652
est_varySchurd = 0.1652
varyd = 0.1667
est_varydABCD = 0.1458
varyABCDd = 0.1477
est_varyapd = 0.5000
est_varySchurapd = 0.5000
varyapd = 0.4977
est_varyABCDapd = 0.3333
varyABCDapd = 0.3377
stdxx =
   125.56   126.17   126.98

stdxxf =
   125.56   126.18   126.99

stdxxABCD =
   125.55   126.17   126.97

stdxxABCDf =
   125.55   126.18   126.98

stdxxABCDap =
   125.55   126.17   126.97

stdxxABCDapf =
   125.55   126.18   126.98

At fc Hf=-2.996263 (dB)

Testing Nk=4
ng = 1.4091
ngap = 7.0000
ngSchur = 1.4091
ngSchurap = 7.0000
ngABCD = 1.0000
ngABCDap = 4.0000
est_varyd = 0.2008
est_varySchurd = 0.2008
varyd = 0.2020
est_varydABCD = 0.1667
varyABCDd = 0.1675
est_varyapd = 0.6667
est_varySchurapd = 0.6667
varyapd = 0.6567
est_varyABCDapd = 0.4167
varyABCDapd = 0.4110
stdxx =
   125.46   125.94   126.28   127.18

stdxxf =
   125.49   125.99   126.33   127.18

stdxxABCD =
   125.46   125.94   126.29   127.17

stdxxABCDf =
   125.48   125.94   126.29   127.16

stdxxABCDap =
   125.46   125.94   126.29   127.17

stdxxABCDapf =
   125.48   125.94   126.29   127.16

At fc Hf=-2.991232 (dB)

Testing Nk=5
ng = 1.8422
ngap = 9.0000
ngSchur = 1.8422
ngSchurap = 9.0000
ngABCD = 1.2500
ngABCDap = 5.0000
est_varyd = 0.2369
est_varySchurd = 0.2369
varyd = 0.2307
est_varydABCD = 0.1875
varyABCDd = 0.1851
est_varyapd = 0.8333
est_varySchurapd = 0.8333
varyapd = 0.8270
est_varyABCDapd = 0.5000
varyABCDapd = 0.4893
stdxx =
   125.35   125.68   125.94   126.51   127.29

stdxxf =
   125.36   125.69   125.96   126.52   127.29

stdxxABCD =
   125.32   125.68   125.94   126.52   127.29

stdxxABCDf =
   125.34   125.69   125.96   126.53   127.29

stdxxABCDap =
   125.32   125.68   125.94   126.52   127.29

stdxxABCDapf =
   125.34   125.69   125.96   126.53   127.29

At fc Hf=-2.979559 (dB)

Testing Nk=6
ng = 2.2767
ngap = 11.000
ngSchur = 2.2767
ngSchurap = 11.000
ngABCD = 1.5000
ngABCDap = 6.0000
est_varyd = 0.2731
est_varySchurd = 0.2731
varyd = 0.2679
est_varydABCD = 0.2083
varyABCDd = 0.2088
est_varyapd = 1.0000
est_varySchurapd = 1.0000
varyapd = 1.0066
est_varyABCDapd = 0.5833
varyABCDapd = 0.5663
stdxx =
   125.18   125.49   125.66   126.41   126.60   127.32

stdxxf =
   125.21   125.48   125.69   126.46   126.61   127.32

stdxxABCD =
   125.18   125.49   125.67   126.41   126.58   127.32

stdxxABCDf =
   125.17   125.48   125.65   126.38   126.56   127.32

stdxxABCDap =
   125.18   125.49   125.67   126.41   126.58   127.32

stdxxABCDapf =
   125.17   125.48   125.65   126.38   126.56   127.32

At fc Hf=-2.998905 (dB)

Testing Nk=7
ng = 2.7104
ngap = 13.000
ngSchur = 2.7104
ngSchurap = 13.000
ngABCD = 1.7500
ngABCDap = 7.0000
est_varyd = 0.3092
est_varySchurd = 0.3092
varyd = 0.3141
est_varydABCD = 0.2292
varyABCDd = 0.2290
est_varyapd = 1.1667
est_varySchurapd = 1.1667
varyapd = 1.1663
est_varyABCDapd = 0.6667
varyABCDapd = 0.6732
stdxx =
   125.16   125.36   125.36   126.23   126.77   126.05   127.63

stdxxf =
   125.16   125.39   125.40   126.28   126.78   126.05   127.63

stdxxABCD =
   125.16   125.35   125.37   126.23   126.77   126.06   127.64

stdxxABCDf =
   125.14   125.33   125.37   126.24   126.77   126.08   127.64

stdxxABCDap =
   125.16   125.35   125.37   126.23   126.77   126.06   127.64

stdxxABCDapf =
   125.14   125.33   125.37   126.24   126.77   126.08   127.64

At fc Hf=-3.020638 (dB)

Testing Nk=8
ng = 3.1421
ngap = 15.000
ngSchur = 3.1421
ngSchurap = 15.000
ngABCD = 2.0000
ngABCDap = 8.0000
est_varyd = 0.3452
est_varySchurd = 0.3452
varyd = 0.3403
est_varydABCD = 0.2500
varyABCDd = 0.2493
est_varyapd = 1.3333
est_varySchurapd = 1.3333
varyapd = 1.3134
est_varyABCDapd = 0.7500
varyABCDapd = 0.7524
stdxx =
   125.04   125.24   125.14   125.97   127.06   125.68   126.61   127.65

stdxxf =
   125.05   125.30   125.18   126.00   127.09   125.69   126.60   127.65

stdxxABCD =
   125.04   125.24   125.13   125.97   127.05   125.69   126.59   127.64

stdxxABCDf =
   125.06   125.24   125.13   126.00   127.06   125.72   126.58   127.64

stdxxABCDap =
   125.04   125.24   125.13   125.97   127.05   125.69   126.59   127.64

stdxxABCDapf =
   125.06   125.24   125.13   126.00   127.06   125.72   126.58   127.64

At fc Hf=-3.060137 (dB)

Testing Nk=9
ng = 3.5711
ngap = 17.000
ngSchur = 3.5711
ngSchurap = 17.000
ngABCD = 2.2500
ngABCDap = 9.0000
est_varyd = 0.3809
est_varySchurd = 0.3809
varyd = 0.3579
est_varydABCD = 0.2708
varyABCDd = 0.2698
est_varyapd = 1.5000
est_varySchurapd = 1.5000
varyapd = 1.4528
est_varyABCDapd = 0.8333
varyABCDapd = 0.8123
stdxx =
 Columns 1 through 8:
   124.99   125.12   124.72   125.59   127.28   125.89   125.98   126.87
 Column 9:
   127.67

stdxxf =
 Columns 1 through 8:
   125.04   125.19   124.75   125.62   127.30   125.87   125.98   126.87
 Column 9:
   127.67

stdxxABCD =
 Columns 1 through 8:
   124.98   125.12   124.72   125.58   127.28   125.88   125.98   126.86
 Column 9:
   127.67

stdxxABCDf =
 Columns 1 through 8:
   124.91   125.06   124.68   125.56   127.32   125.87   125.96   126.86
 Column 9:
   127.67

stdxxABCDap =
 Columns 1 through 8:
   124.98   125.12   124.72   125.58   127.28   125.88   125.98   126.86
 Column 9:
   127.67

stdxxABCDapf =
 Columns 1 through 8:
   124.91   125.06   124.68   125.56   127.32   125.87   125.96   126.86
 Column 9:
   127.67

At fc Hf=-3.088373 (dB)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog (octfile)"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass
