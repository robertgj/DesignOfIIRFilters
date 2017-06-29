#!/bin/sh

prog=Abcd2cc_test.m

depends="Abcd2cc_test.m test_common.m \
Abcd2cc.m KW.m tf2Abcd.m optKW.m sv2block.m svf.m crossWelch.m"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
for file in $depends;do \
  cp -R src/$file $tmp; \
  if [ $? -ne 0 ]; then echo "Failed cp "$file; fail; fi \
done
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# the output should look like this
#
cat > test.ok << 'EOF'
bits =    8.0000e+00
scale =    1.2800e+02
delta =    1.0000e+00
N =    8.0000e+00
P =    1.2000e+01
dbap =    1.0000e-01
dbas =    4.0000e+01
fc =    5.0000e-02
n =

 Columns 1 through 6:

   1.0375e-02  -6.9395e-02   2.1334e-01  -3.9425e-01   4.7988e-01  -3.9425e-01

 Columns 7 through 9:

   2.1334e-01  -6.9395e-02   1.0375e-02

d =

 Columns 1 through 6:

   1.0000e+00  -7.2403e+00   2.3185e+01  -4.2863e+01   5.0014e+01  -3.7707e+01

 Columns 7 through 9:

   1.7932e+01  -4.9177e+00   5.9536e-01

ngABCDopt =    1.4662e+00
ngABCDoptf =    7.1795e+00
est_nvABCDoptf =    8.2560e-01
nvABCDoptf =    6.0888e-01
Ab =

 Columns 1 through 6:

  -4.8711e-01  -6.4141e-02  -5.2425e-02  -1.3843e-01   3.6162e-02  -2.3818e-01
   2.5127e-01  -6.0385e-01   1.2970e-01  -7.7810e-02   3.0256e-01   2.9088e-01
   9.8315e-02   8.5509e-02  -4.0110e-01  -1.2656e-01   4.1895e-01  -8.6086e-02
   1.9016e-01   1.5478e-01   1.3347e-01  -6.5476e-01  -8.7592e-02   3.3268e-01
  -4.4329e-02   1.2867e-01  -3.3158e-02   4.1881e-01  -7.2991e-02   1.1075e-03
  -1.3536e-01  -3.3604e-01  -1.8000e-01  -3.2448e-01   1.5516e-01  -5.7425e-01
   2.6819e-01  -3.5013e-01   1.2084e-01   1.8165e-01   9.7807e-02   2.7340e-03
  -1.3553e-01  -7.3841e-02  -8.6136e-02   1.4890e-01   1.2839e-01   3.2615e-01

 Columns 7 and 8:

  -3.5824e-02  -2.1298e-02
   2.3699e-01  -8.6947e-02
  -3.0433e-01   1.6419e-01
  -1.6144e-01   6.0195e-02
   1.5817e-02   1.5977e-01
  -9.9863e-04   4.7266e-02
  -6.4115e-01   1.4537e-01
   4.3482e-02  -2.0298e-01

Bb =

 Columns 1 through 6:

   2.2450e-02  -5.0175e-02  -1.2600e-01  -1.9867e-01  -2.6134e-01  -3.0712e-01
  -1.9302e-01  -1.9359e-01  -1.8699e-01  -1.7402e-01  -1.5578e-01  -1.3346e-01
  -1.4471e-01  -1.3485e-01  -1.2278e-01  -1.0773e-01  -8.9057e-02  -6.6405e-02
   1.9816e-01   1.9532e-01   1.7285e-01   1.3156e-01   7.3981e-02   4.2621e-03
  -1.5079e-01  -1.5834e-01  -1.6592e-01  -1.7545e-01  -1.8885e-01  -2.0767e-01
   1.6741e-01   1.5375e-01   1.3227e-01   1.0392e-01   6.9666e-02   3.0270e-02
  -5.0206e-02  -9.8664e-03   2.6021e-02   5.4211e-02   7.2382e-02   7.9347e-02
  -2.3560e-01  -2.7255e-01  -2.9750e-01  -3.0870e-01  -3.0559e-01  -2.8909e-01

 Columns 7 through 12:

  -3.2964e-01  -3.2354e-01  -2.8500e-01  -2.1218e-01  -1.0561e-01   3.1581e-02
  -1.0814e-01  -8.0577e-02  -5.0953e-02  -1.8670e-02   1.7832e-02   6.1198e-02
  -3.9759e-02  -9.4193e-03   2.4163e-02   6.0712e-02   1.0060e-01   1.4544e-01
  -7.2191e-02  -1.4915e-01  -2.2009e-01  -2.7878e-01  -3.1979e-01  -3.3903e-01
  -2.3268e-01  -2.6350e-01  -2.9821e-01  -3.3306e-01  -3.6220e-01  -3.7757e-01
  -1.3790e-02  -6.2414e-02  -1.1591e-01  -1.7495e-01  -2.4054e-01  -3.1386e-01
   7.5139e-02   6.0954e-02   3.8949e-02   1.1933e-02  -1.7030e-02  -4.5044e-02
  -2.6182e-01  -2.2819e-01  -1.9434e-01  -1.6800e-01  -1.5802e-01  -1.7387e-01

Cb =

 Columns 1 through 6:

   2.3303e-02  -6.3524e-02  -2.1937e-01   6.0743e-03  -1.2718e-01   4.4876e-02
   1.2741e-02  -6.8911e-02  -1.7417e-01   1.0077e-02  -1.0624e-01   3.6535e-02
  -2.5743e-03  -7.8995e-02  -1.2681e-01   1.2533e-02  -9.0622e-02   3.2424e-02
  -1.9632e-02  -9.0481e-02  -7.9649e-02   1.2730e-02  -8.0950e-02   3.0284e-02
  -3.6161e-02  -1.0035e-01  -3.5060e-02   1.0371e-02  -7.6960e-02   2.8443e-02
  -5.0601e-02  -1.0614e-01   4.7604e-03   5.4922e-03  -7.7764e-02   2.5737e-02
  -6.2004e-02  -1.0607e-01   3.8011e-02  -1.6188e-03  -8.2084e-02   2.1430e-02
  -6.9924e-02  -9.9237e-02   6.3420e-02  -1.0491e-02  -8.8456e-02   1.5148e-02
  -7.4274e-02  -8.5592e-02   8.0326e-02  -2.0532e-02  -9.5398e-02   6.8184e-03
  -7.5207e-02  -6.5901e-02   8.8701e-02  -3.1080e-02  -1.0155e-01  -3.3830e-03
  -7.3009e-02  -4.1627e-02   8.9113e-02  -4.1453e-02  -1.0576e-01  -1.5069e-02
  -6.8016e-02  -1.4740e-02   8.2641e-02  -5.0987e-02  -1.0718e-01  -2.7680e-02

 Columns 7 and 8:

  -6.3804e-02  -3.4693e-02
  -8.6345e-02  -8.2017e-02
  -9.7553e-02  -1.1490e-01
  -9.7261e-02  -1.3548e-01
  -8.6354e-02  -1.4582e-01
  -6.6636e-02  -1.4787e-01
  -4.0620e-02  -1.4336e-01
  -1.1262e-02  -1.3383e-01
   1.8331e-02  -1.2061e-01
   4.5195e-02  -1.0482e-01
   6.6783e-02  -8.7439e-02
   8.1175e-02  -6.9277e-02

Db =

 Columns 1 through 6:

   1.0375e-02   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   5.7233e-03   1.0375e-02   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   1.4232e-02   5.7233e-03   1.0375e-02   0.0000e+00   0.0000e+00   0.0000e+00
   2.0803e-02   1.4232e-02   5.7233e-03   1.0375e-02   0.0000e+00   0.0000e+00
   2.6939e-02   2.0803e-02   1.4232e-02   5.7233e-03   1.0375e-02   0.0000e+00
   3.3476e-02   2.6939e-02   2.0803e-02   1.4232e-02   5.7233e-03   1.0375e-02
   4.0732e-02   3.3476e-02   2.6939e-02   2.0803e-02   1.4232e-02   5.7233e-03
   4.8650e-02   4.0732e-02   3.3476e-02   2.6939e-02   2.0803e-02   1.4232e-02
   5.6919e-02   4.8650e-02   4.0732e-02   3.3476e-02   2.6939e-02   2.0803e-02
   6.5084e-02   5.6919e-02   4.8650e-02   4.0732e-02   3.3476e-02   2.6939e-02
   7.2623e-02   6.5084e-02   5.6919e-02   4.8650e-02   4.0732e-02   3.3476e-02
   7.9019e-02   7.2623e-02   6.5084e-02   5.6919e-02   4.8650e-02   4.0732e-02

 Columns 7 through 12:

   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   1.0375e-02   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   5.7233e-03   1.0375e-02   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   1.4232e-02   5.7233e-03   1.0375e-02   0.0000e+00   0.0000e+00   0.0000e+00
   2.0803e-02   1.4232e-02   5.7233e-03   1.0375e-02   0.0000e+00   0.0000e+00
   2.6939e-02   2.0803e-02   1.4232e-02   5.7233e-03   1.0375e-02   0.0000e+00
   3.3476e-02   2.6939e-02   2.0803e-02   1.4232e-02   5.7233e-03   1.0375e-02

ngABCDbf =    1.2218e-01
est_nvABCDbf =    3.0580e-01
nvbf =    3.0450e-01
nvccbf =    3.0450e-01
N=8,P=12
For block length 1, multipliers/output=81.000000
For block length 12, multipliers/output=27.833333
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

cat > test.cc << 'EOF'
// Generated by Abcd2cc.m for the ellip8ABCD12 filter.
// Compile with :
//	"mkoctfile("ellip8ABCD12.cc","-D USING_OCTAVE")"
//
// This file is linked with Octave and so is a derivative
// work and is subject to the GPLv3 or later. Accordingly
// the following notice applies:
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

#if defined(USING_OCTAVE)

#include <math.h>

#include <octave/oct.h>

typedef double WORD;
typedef double MAC;

void filter_ellip8ABCD12_init(void);
void filter_ellip8ABCD12(const WORD *, WORD *);

DEFUN_DLD(ellip8ABCD12, args, nargout,"y=ellip8ABCD12(u)")
{
	// Sanity check
	if ((args.length() != 1) || (nargout != 1))
	{
		print_usage();
		return octave_value();
	}

	// Input argument
	int64_t N = args(0).length();
	ColumnVector u = args(0).vector_value();

	// Output argument
	ColumnVector y(N);

	// Call the filter
	filter_ellip8ABCD12_init();
	const int64_t mblock=12;
	for(int64_t k=0; (k+mblock)<N; k+=mblock)
		{
			WORD ublock[mblock];
			WORD yblock[mblock];
			for(int64_t l=0; l<mblock; l++)
				{
					ublock[l] = u(k+l);
				}
			filter_ellip8ABCD12(ublock, yblock);
			for(int64_t l=0; l<mblock; l++)
				{
					y(k+l) = yblock[l];
				}
		}

	// Done
	return octave_value(y);
}

static WORD filter_scale_output(MAC mac)
{
	static const double scale = 128.000000;
	return round(mac/scale);
}

#endif // USING_OCTAVE

static WORD ellip8ABCD12_x_1;
static WORD ellip8ABCD12_x_2;
static WORD ellip8ABCD12_x_3;
static WORD ellip8ABCD12_x_4;
static WORD ellip8ABCD12_x_5;
static WORD ellip8ABCD12_x_6;
static WORD ellip8ABCD12_x_7;
static WORD ellip8ABCD12_x_8;

void filter_ellip8ABCD12_init(void)
{
	ellip8ABCD12_x_1 = 0;
	ellip8ABCD12_x_2 = 0;
	ellip8ABCD12_x_3 = 0;
	ellip8ABCD12_x_4 = 0;
	ellip8ABCD12_x_5 = 0;
	ellip8ABCD12_x_6 = 0;
	ellip8ABCD12_x_7 = 0;
	ellip8ABCD12_x_8 = 0;
}

void filter_ellip8ABCD12(const WORD *u, WORD *y)
{
	static const WORD A_1_1 =    -62;
	static const WORD A_1_2 =     -8;
	static const WORD A_1_3 =     -7;
	static const WORD A_1_4 =    -18;
	static const WORD A_1_5 =      5;
	static const WORD A_1_6 =    -30;
	static const WORD A_1_7 =     -5;
	static const WORD A_1_8 =     -3;
	static const WORD A_2_1 =     32;
	static const WORD A_2_2 =    -77;
	static const WORD A_2_3 =     17;
	static const WORD A_2_4 =    -10;
	static const WORD A_2_5 =     39;
	static const WORD A_2_6 =     37;
	static const WORD A_2_7 =     30;
	static const WORD A_2_8 =    -11;
	static const WORD A_3_1 =     13;
	static const WORD A_3_2 =     11;
	static const WORD A_3_3 =    -51;
	static const WORD A_3_4 =    -16;
	static const WORD A_3_5 =     54;
	static const WORD A_3_6 =    -11;
	static const WORD A_3_7 =    -39;
	static const WORD A_3_8 =     21;
	static const WORD A_4_1 =     24;
	static const WORD A_4_2 =     20;
	static const WORD A_4_3 =     17;
	static const WORD A_4_4 =    -84;
	static const WORD A_4_5 =    -11;
	static const WORD A_4_6 =     43;
	static const WORD A_4_7 =    -21;
	static const WORD A_4_8 =      8;
	static const WORD A_5_1 =     -6;
	static const WORD A_5_2 =     16;
	static const WORD A_5_3 =     -4;
	static const WORD A_5_4 =     54;
	static const WORD A_5_5 =     -9;
	static const WORD A_5_7 =      2;
	static const WORD A_5_8 =     20;
	static const WORD A_6_1 =    -17;
	static const WORD A_6_2 =    -43;
	static const WORD A_6_3 =    -23;
	static const WORD A_6_4 =    -42;
	static const WORD A_6_5 =     20;
	static const WORD A_6_6 =    -74;
	static const WORD A_6_8 =      6;
	static const WORD A_7_1 =     34;
	static const WORD A_7_2 =    -45;
	static const WORD A_7_3 =     15;
	static const WORD A_7_4 =     23;
	static const WORD A_7_5 =     13;
	static const WORD A_7_7 =    -82;
	static const WORD A_7_8 =     19;
	static const WORD A_8_1 =    -17;
	static const WORD A_8_2 =     -9;
	static const WORD A_8_3 =    -11;
	static const WORD A_8_4 =     19;
	static const WORD A_8_5 =     16;
	static const WORD A_8_6 =     42;
	static const WORD A_8_7 =      6;
	static const WORD A_8_8 =    -26;
	static const WORD b_1_1 =      3;
	static const WORD b_1_2 =     -6;
	static const WORD b_1_3 =    -16;
	static const WORD b_1_4 =    -25;
	static const WORD b_1_5 =    -33;
	static const WORD b_1_6 =    -39;
	static const WORD b_1_7 =    -42;
	static const WORD b_1_8 =    -41;
	static const WORD b_1_9 =    -36;
	static const WORD b_1_10 =    -27;
	static const WORD b_1_11 =    -14;
	static const WORD b_1_12 =      4;
	static const WORD b_2_1 =    -25;
	static const WORD b_2_2 =    -25;
	static const WORD b_2_3 =    -24;
	static const WORD b_2_4 =    -22;
	static const WORD b_2_5 =    -20;
	static const WORD b_2_6 =    -17;
	static const WORD b_2_7 =    -14;
	static const WORD b_2_8 =    -10;
	static const WORD b_2_9 =     -7;
	static const WORD b_2_10 =     -2;
	static const WORD b_2_11 =      2;
	static const WORD b_2_12 =      8;
	static const WORD b_3_1 =    -19;
	static const WORD b_3_2 =    -17;
	static const WORD b_3_3 =    -16;
	static const WORD b_3_4 =    -14;
	static const WORD b_3_5 =    -11;
	static const WORD b_3_6 =     -8;
	static const WORD b_3_7 =     -5;
	static const WORD b_3_8 =     -1;
	static const WORD b_3_9 =      3;
	static const WORD b_3_10 =      8;
	static const WORD b_3_11 =     13;
	static const WORD b_3_12 =     19;
	static const WORD b_4_1 =     25;
	static const WORD b_4_2 =     25;
	static const WORD b_4_3 =     22;
	static const WORD b_4_4 =     17;
	static const WORD b_4_5 =      9;
	static const WORD b_4_6 =      1;
	static const WORD b_4_7 =     -9;
	static const WORD b_4_8 =    -19;
	static const WORD b_4_9 =    -28;
	static const WORD b_4_10 =    -36;
	static const WORD b_4_11 =    -41;
	static const WORD b_4_12 =    -43;
	static const WORD b_5_1 =    -19;
	static const WORD b_5_2 =    -20;
	static const WORD b_5_3 =    -21;
	static const WORD b_5_4 =    -22;
	static const WORD b_5_5 =    -24;
	static const WORD b_5_6 =    -27;
	static const WORD b_5_7 =    -30;
	static const WORD b_5_8 =    -34;
	static const WORD b_5_9 =    -38;
	static const WORD b_5_10 =    -43;
	static const WORD b_5_11 =    -46;
	static const WORD b_5_12 =    -48;
	static const WORD b_6_1 =     21;
	static const WORD b_6_2 =     20;
	static const WORD b_6_3 =     17;
	static const WORD b_6_4 =     13;
	static const WORD b_6_5 =      9;
	static const WORD b_6_6 =      4;
	static const WORD b_6_7 =     -2;
	static const WORD b_6_8 =     -8;
	static const WORD b_6_9 =    -15;
	static const WORD b_6_10 =    -22;
	static const WORD b_6_11 =    -31;
	static const WORD b_6_12 =    -40;
	static const WORD b_7_1 =     -6;
	static const WORD b_7_2 =     -1;
	static const WORD b_7_3 =      3;
	static const WORD b_7_4 =      7;
	static const WORD b_7_5 =      9;
	static const WORD b_7_6 =     10;
	static const WORD b_7_7 =     10;
	static const WORD b_7_8 =      8;
	static const WORD b_7_9 =      5;
	static const WORD b_7_10 =      2;
	static const WORD b_7_11 =     -2;
	static const WORD b_7_12 =     -6;
	static const WORD b_8_1 =    -30;
	static const WORD b_8_2 =    -35;
	static const WORD b_8_3 =    -38;
	static const WORD b_8_4 =    -40;
	static const WORD b_8_5 =    -39;
	static const WORD b_8_6 =    -37;
	static const WORD b_8_7 =    -34;
	static const WORD b_8_8 =    -29;
	static const WORD b_8_9 =    -25;
	static const WORD b_8_10 =    -22;
	static const WORD b_8_11 =    -20;
	static const WORD b_8_12 =    -22;
	static const WORD c_1_1 =      3;
	static const WORD c_1_2 =     -8;
	static const WORD c_1_3 =    -28;
	static const WORD c_1_4 =      1;
	static const WORD c_1_5 =    -16;
	static const WORD c_1_6 =      6;
	static const WORD c_1_7 =     -8;
	static const WORD c_1_8 =     -4;
	static const WORD c_2_1 =      2;
	static const WORD c_2_2 =     -9;
	static const WORD c_2_3 =    -22;
	static const WORD c_2_4 =      1;
	static const WORD c_2_5 =    -14;
	static const WORD c_2_6 =      5;
	static const WORD c_2_7 =    -11;
	static const WORD c_2_8 =    -10;
	static const WORD c_3_2 =    -10;
	static const WORD c_3_3 =    -16;
	static const WORD c_3_4 =      2;
	static const WORD c_3_5 =    -12;
	static const WORD c_3_6 =      4;
	static const WORD c_3_7 =    -12;
	static const WORD c_3_8 =    -15;
	static const WORD c_4_1 =     -3;
	static const WORD c_4_2 =    -12;
	static const WORD c_4_3 =    -10;
	static const WORD c_4_4 =      2;
	static const WORD c_4_5 =    -10;
	static const WORD c_4_6 =      4;
	static const WORD c_4_7 =    -12;
	static const WORD c_4_8 =    -17;
	static const WORD c_5_1 =     -5;
	static const WORD c_5_2 =    -13;
	static const WORD c_5_3 =     -4;
	static const WORD c_5_4 =      1;
	static const WORD c_5_5 =    -10;
	static const WORD c_5_6 =      4;
	static const WORD c_5_7 =    -11;
	static const WORD c_5_8 =    -19;
	static const WORD c_6_1 =     -6;
	static const WORD c_6_2 =    -14;
	static const WORD c_6_3 =      1;
	static const WORD c_6_4 =      1;
	static const WORD c_6_5 =    -10;
	static const WORD c_6_6 =      3;
	static const WORD c_6_7 =     -9;
	static const WORD c_6_8 =    -19;
	static const WORD c_7_1 =     -8;
	static const WORD c_7_2 =    -14;
	static const WORD c_7_3 =      5;
	static const WORD c_7_5 =    -11;
	static const WORD c_7_6 =      3;
	static const WORD c_7_7 =     -5;
	static const WORD c_7_8 =    -18;
	static const WORD c_8_1 =     -9;
	static const WORD c_8_2 =    -13;
	static const WORD c_8_3 =      8;
	static const WORD c_8_4 =     -1;
	static const WORD c_8_5 =    -11;
	static const WORD c_8_6 =      2;
	static const WORD c_8_7 =     -1;
	static const WORD c_8_8 =    -17;
	static const WORD c_9_1 =    -10;
	static const WORD c_9_2 =    -11;
	static const WORD c_9_3 =     10;
	static const WORD c_9_4 =     -3;
	static const WORD c_9_5 =    -12;
	static const WORD c_9_6 =      1;
	static const WORD c_9_7 =      2;
	static const WORD c_9_8 =    -15;
	static const WORD c_10_1 =    -10;
	static const WORD c_10_2 =     -8;
	static const WORD c_10_3 =     11;
	static const WORD c_10_4 =     -4;
	static const WORD c_10_5 =    -13;
	static const WORD c_10_7 =      6;
	static const WORD c_10_8 =    -13;
	static const WORD c_11_1 =     -9;
	static const WORD c_11_2 =     -5;
	static const WORD c_11_3 =     11;
	static const WORD c_11_4 =     -5;
	static const WORD c_11_5 =    -14;
	static const WORD c_11_6 =     -2;
	static const WORD c_11_7 =      9;
	static const WORD c_11_8 =    -11;
	static const WORD c_12_1 =     -9;
	static const WORD c_12_2 =     -2;
	static const WORD c_12_3 =     11;
	static const WORD c_12_4 =     -7;
	static const WORD c_12_5 =    -14;
	static const WORD c_12_6 =     -4;
	static const WORD c_12_7 =     10;
	static const WORD c_12_8 =     -9;
	static const WORD d_1_1 =      1;
	static const WORD d_2_1 =      1;
	static const WORD d_2_2 =      1;
	static const WORD d_3_1 =      2;
	static const WORD d_3_2 =      1;
	static const WORD d_3_3 =      1;
	static const WORD d_4_1 =      3;
	static const WORD d_4_2 =      2;
	static const WORD d_4_3 =      1;
	static const WORD d_4_4 =      1;
	static const WORD d_5_1 =      3;
	static const WORD d_5_2 =      3;
	static const WORD d_5_3 =      2;
	static const WORD d_5_4 =      1;
	static const WORD d_5_5 =      1;
	static const WORD d_6_1 =      4;
	static const WORD d_6_2 =      3;
	static const WORD d_6_3 =      3;
	static const WORD d_6_4 =      2;
	static const WORD d_6_5 =      1;
	static const WORD d_6_6 =      1;
	static const WORD d_7_1 =      5;
	static const WORD d_7_2 =      4;
	static const WORD d_7_3 =      3;
	static const WORD d_7_4 =      3;
	static const WORD d_7_5 =      2;
	static const WORD d_7_6 =      1;
	static const WORD d_7_7 =      1;
	static const WORD d_8_1 =      6;
	static const WORD d_8_2 =      5;
	static const WORD d_8_3 =      4;
	static const WORD d_8_4 =      3;
	static const WORD d_8_5 =      3;
	static const WORD d_8_6 =      2;
	static const WORD d_8_7 =      1;
	static const WORD d_8_8 =      1;
	static const WORD d_9_1 =      7;
	static const WORD d_9_2 =      6;
	static const WORD d_9_3 =      5;
	static const WORD d_9_4 =      4;
	static const WORD d_9_5 =      3;
	static const WORD d_9_6 =      3;
	static const WORD d_9_7 =      2;
	static const WORD d_9_8 =      1;
	static const WORD d_9_9 =      1;
	static const WORD d_10_1 =      8;
	static const WORD d_10_2 =      7;
	static const WORD d_10_3 =      6;
	static const WORD d_10_4 =      5;
	static const WORD d_10_5 =      4;
	static const WORD d_10_6 =      3;
	static const WORD d_10_7 =      3;
	static const WORD d_10_8 =      2;
	static const WORD d_10_9 =      1;
	static const WORD d_10_10 =      1;
	static const WORD d_11_1 =      9;
	static const WORD d_11_2 =      8;
	static const WORD d_11_3 =      7;
	static const WORD d_11_4 =      6;
	static const WORD d_11_5 =      5;
	static const WORD d_11_6 =      4;
	static const WORD d_11_7 =      3;
	static const WORD d_11_8 =      3;
	static const WORD d_11_9 =      2;
	static const WORD d_11_10 =      1;
	static const WORD d_11_11 =      1;
	static const WORD d_12_1 =     10;
	static const WORD d_12_2 =      9;
	static const WORD d_12_3 =      8;
	static const WORD d_12_4 =      7;
	static const WORD d_12_5 =      6;
	static const WORD d_12_6 =      5;
	static const WORD d_12_7 =      4;
	static const WORD d_12_8 =      3;
	static const WORD d_12_9 =      3;
	static const WORD d_12_10 =      2;
	static const WORD d_12_11 =      1;
	static const WORD d_12_12 =      1;
	WORD x_1_tmp;
	WORD x_2_tmp;
	WORD x_3_tmp;
	WORD x_4_tmp;
	WORD x_5_tmp;
	WORD x_6_tmp;
	WORD x_7_tmp;
	WORD x_8_tmp;
	MAC mac;

	// Calculate the y[0] output
	mac = 0;
	mac += c_1_1*ellip8ABCD12_x_1;
	mac += c_1_2*ellip8ABCD12_x_2;
	mac += c_1_3*ellip8ABCD12_x_3;
	mac += c_1_4*ellip8ABCD12_x_4;
	mac += c_1_5*ellip8ABCD12_x_5;
	mac += c_1_6*ellip8ABCD12_x_6;
	mac += c_1_7*ellip8ABCD12_x_7;
	mac += c_1_8*ellip8ABCD12_x_8;
	mac += d_1_1*u[0];
	y[0] = filter_scale_output(mac);

	// Calculate the y[1] output
	mac = 0;
	mac += c_2_1*ellip8ABCD12_x_1;
	mac += c_2_2*ellip8ABCD12_x_2;
	mac += c_2_3*ellip8ABCD12_x_3;
	mac += c_2_4*ellip8ABCD12_x_4;
	mac += c_2_5*ellip8ABCD12_x_5;
	mac += c_2_6*ellip8ABCD12_x_6;
	mac += c_2_7*ellip8ABCD12_x_7;
	mac += c_2_8*ellip8ABCD12_x_8;
	mac += d_2_1*u[0];
	mac += d_2_2*u[1];
	y[1] = filter_scale_output(mac);

	// Calculate the y[2] output
	mac = 0;
	mac += c_3_2*ellip8ABCD12_x_2;
	mac += c_3_3*ellip8ABCD12_x_3;
	mac += c_3_4*ellip8ABCD12_x_4;
	mac += c_3_5*ellip8ABCD12_x_5;
	mac += c_3_6*ellip8ABCD12_x_6;
	mac += c_3_7*ellip8ABCD12_x_7;
	mac += c_3_8*ellip8ABCD12_x_8;
	mac += d_3_1*u[0];
	mac += d_3_2*u[1];
	mac += d_3_3*u[2];
	y[2] = filter_scale_output(mac);

	// Calculate the y[3] output
	mac = 0;
	mac += c_4_1*ellip8ABCD12_x_1;
	mac += c_4_2*ellip8ABCD12_x_2;
	mac += c_4_3*ellip8ABCD12_x_3;
	mac += c_4_4*ellip8ABCD12_x_4;
	mac += c_4_5*ellip8ABCD12_x_5;
	mac += c_4_6*ellip8ABCD12_x_6;
	mac += c_4_7*ellip8ABCD12_x_7;
	mac += c_4_8*ellip8ABCD12_x_8;
	mac += d_4_1*u[0];
	mac += d_4_2*u[1];
	mac += d_4_3*u[2];
	mac += d_4_4*u[3];
	y[3] = filter_scale_output(mac);

	// Calculate the y[4] output
	mac = 0;
	mac += c_5_1*ellip8ABCD12_x_1;
	mac += c_5_2*ellip8ABCD12_x_2;
	mac += c_5_3*ellip8ABCD12_x_3;
	mac += c_5_4*ellip8ABCD12_x_4;
	mac += c_5_5*ellip8ABCD12_x_5;
	mac += c_5_6*ellip8ABCD12_x_6;
	mac += c_5_7*ellip8ABCD12_x_7;
	mac += c_5_8*ellip8ABCD12_x_8;
	mac += d_5_1*u[0];
	mac += d_5_2*u[1];
	mac += d_5_3*u[2];
	mac += d_5_4*u[3];
	mac += d_5_5*u[4];
	y[4] = filter_scale_output(mac);

	// Calculate the y[5] output
	mac = 0;
	mac += c_6_1*ellip8ABCD12_x_1;
	mac += c_6_2*ellip8ABCD12_x_2;
	mac += c_6_3*ellip8ABCD12_x_3;
	mac += c_6_4*ellip8ABCD12_x_4;
	mac += c_6_5*ellip8ABCD12_x_5;
	mac += c_6_6*ellip8ABCD12_x_6;
	mac += c_6_7*ellip8ABCD12_x_7;
	mac += c_6_8*ellip8ABCD12_x_8;
	mac += d_6_1*u[0];
	mac += d_6_2*u[1];
	mac += d_6_3*u[2];
	mac += d_6_4*u[3];
	mac += d_6_5*u[4];
	mac += d_6_6*u[5];
	y[5] = filter_scale_output(mac);

	// Calculate the y[6] output
	mac = 0;
	mac += c_7_1*ellip8ABCD12_x_1;
	mac += c_7_2*ellip8ABCD12_x_2;
	mac += c_7_3*ellip8ABCD12_x_3;
	mac += c_7_5*ellip8ABCD12_x_5;
	mac += c_7_6*ellip8ABCD12_x_6;
	mac += c_7_7*ellip8ABCD12_x_7;
	mac += c_7_8*ellip8ABCD12_x_8;
	mac += d_7_1*u[0];
	mac += d_7_2*u[1];
	mac += d_7_3*u[2];
	mac += d_7_4*u[3];
	mac += d_7_5*u[4];
	mac += d_7_6*u[5];
	mac += d_7_7*u[6];
	y[6] = filter_scale_output(mac);

	// Calculate the y[7] output
	mac = 0;
	mac += c_8_1*ellip8ABCD12_x_1;
	mac += c_8_2*ellip8ABCD12_x_2;
	mac += c_8_3*ellip8ABCD12_x_3;
	mac += c_8_4*ellip8ABCD12_x_4;
	mac += c_8_5*ellip8ABCD12_x_5;
	mac += c_8_6*ellip8ABCD12_x_6;
	mac += c_8_7*ellip8ABCD12_x_7;
	mac += c_8_8*ellip8ABCD12_x_8;
	mac += d_8_1*u[0];
	mac += d_8_2*u[1];
	mac += d_8_3*u[2];
	mac += d_8_4*u[3];
	mac += d_8_5*u[4];
	mac += d_8_6*u[5];
	mac += d_8_7*u[6];
	mac += d_8_8*u[7];
	y[7] = filter_scale_output(mac);

	// Calculate the y[8] output
	mac = 0;
	mac += c_9_1*ellip8ABCD12_x_1;
	mac += c_9_2*ellip8ABCD12_x_2;
	mac += c_9_3*ellip8ABCD12_x_3;
	mac += c_9_4*ellip8ABCD12_x_4;
	mac += c_9_5*ellip8ABCD12_x_5;
	mac += c_9_6*ellip8ABCD12_x_6;
	mac += c_9_7*ellip8ABCD12_x_7;
	mac += c_9_8*ellip8ABCD12_x_8;
	mac += d_9_1*u[0];
	mac += d_9_2*u[1];
	mac += d_9_3*u[2];
	mac += d_9_4*u[3];
	mac += d_9_5*u[4];
	mac += d_9_6*u[5];
	mac += d_9_7*u[6];
	mac += d_9_8*u[7];
	mac += d_9_9*u[8];
	y[8] = filter_scale_output(mac);

	// Calculate the y[9] output
	mac = 0;
	mac += c_10_1*ellip8ABCD12_x_1;
	mac += c_10_2*ellip8ABCD12_x_2;
	mac += c_10_3*ellip8ABCD12_x_3;
	mac += c_10_4*ellip8ABCD12_x_4;
	mac += c_10_5*ellip8ABCD12_x_5;
	mac += c_10_7*ellip8ABCD12_x_7;
	mac += c_10_8*ellip8ABCD12_x_8;
	mac += d_10_1*u[0];
	mac += d_10_2*u[1];
	mac += d_10_3*u[2];
	mac += d_10_4*u[3];
	mac += d_10_5*u[4];
	mac += d_10_6*u[5];
	mac += d_10_7*u[6];
	mac += d_10_8*u[7];
	mac += d_10_9*u[8];
	mac += d_10_10*u[9];
	y[9] = filter_scale_output(mac);

	// Calculate the y[10] output
	mac = 0;
	mac += c_11_1*ellip8ABCD12_x_1;
	mac += c_11_2*ellip8ABCD12_x_2;
	mac += c_11_3*ellip8ABCD12_x_3;
	mac += c_11_4*ellip8ABCD12_x_4;
	mac += c_11_5*ellip8ABCD12_x_5;
	mac += c_11_6*ellip8ABCD12_x_6;
	mac += c_11_7*ellip8ABCD12_x_7;
	mac += c_11_8*ellip8ABCD12_x_8;
	mac += d_11_1*u[0];
	mac += d_11_2*u[1];
	mac += d_11_3*u[2];
	mac += d_11_4*u[3];
	mac += d_11_5*u[4];
	mac += d_11_6*u[5];
	mac += d_11_7*u[6];
	mac += d_11_8*u[7];
	mac += d_11_9*u[8];
	mac += d_11_10*u[9];
	mac += d_11_11*u[10];
	y[10] = filter_scale_output(mac);

	// Calculate the y[11] output
	mac = 0;
	mac += c_12_1*ellip8ABCD12_x_1;
	mac += c_12_2*ellip8ABCD12_x_2;
	mac += c_12_3*ellip8ABCD12_x_3;
	mac += c_12_4*ellip8ABCD12_x_4;
	mac += c_12_5*ellip8ABCD12_x_5;
	mac += c_12_6*ellip8ABCD12_x_6;
	mac += c_12_7*ellip8ABCD12_x_7;
	mac += c_12_8*ellip8ABCD12_x_8;
	mac += d_12_1*u[0];
	mac += d_12_2*u[1];
	mac += d_12_3*u[2];
	mac += d_12_4*u[3];
	mac += d_12_5*u[4];
	mac += d_12_6*u[5];
	mac += d_12_7*u[6];
	mac += d_12_8*u[7];
	mac += d_12_9*u[8];
	mac += d_12_10*u[9];
	mac += d_12_11*u[10];
	mac += d_12_12*u[11];
	y[11] = filter_scale_output(mac);

	// Make temporary variables
	x_1_tmp = ellip8ABCD12_x_1;
	x_2_tmp = ellip8ABCD12_x_2;
	x_3_tmp = ellip8ABCD12_x_3;
	x_4_tmp = ellip8ABCD12_x_4;
	x_5_tmp = ellip8ABCD12_x_5;
	x_6_tmp = ellip8ABCD12_x_6;
	x_7_tmp = ellip8ABCD12_x_7;
	x_8_tmp = ellip8ABCD12_x_8;

	// Update state ellip8ABCD12_x_1
	mac = 0;
	mac += A_1_1*x_1_tmp;
	mac += A_1_2*x_2_tmp;
	mac += A_1_3*x_3_tmp;
	mac += A_1_4*x_4_tmp;
	mac += A_1_5*x_5_tmp;
	mac += A_1_6*x_6_tmp;
	mac += A_1_7*x_7_tmp;
	mac += A_1_8*x_8_tmp;
	mac += b_1_1*u[0];
	mac += b_1_2*u[1];
	mac += b_1_3*u[2];
	mac += b_1_4*u[3];
	mac += b_1_5*u[4];
	mac += b_1_6*u[5];
	mac += b_1_7*u[6];
	mac += b_1_8*u[7];
	mac += b_1_9*u[8];
	mac += b_1_10*u[9];
	mac += b_1_11*u[10];
	mac += b_1_12*u[11];
	ellip8ABCD12_x_1 = filter_scale_output(mac);

	// Update state ellip8ABCD12_x_2
	mac = 0;
	mac += A_2_1*x_1_tmp;
	mac += A_2_2*x_2_tmp;
	mac += A_2_3*x_3_tmp;
	mac += A_2_4*x_4_tmp;
	mac += A_2_5*x_5_tmp;
	mac += A_2_6*x_6_tmp;
	mac += A_2_7*x_7_tmp;
	mac += A_2_8*x_8_tmp;
	mac += b_2_1*u[0];
	mac += b_2_2*u[1];
	mac += b_2_3*u[2];
	mac += b_2_4*u[3];
	mac += b_2_5*u[4];
	mac += b_2_6*u[5];
	mac += b_2_7*u[6];
	mac += b_2_8*u[7];
	mac += b_2_9*u[8];
	mac += b_2_10*u[9];
	mac += b_2_11*u[10];
	mac += b_2_12*u[11];
	ellip8ABCD12_x_2 = filter_scale_output(mac);

	// Update state ellip8ABCD12_x_3
	mac = 0;
	mac += A_3_1*x_1_tmp;
	mac += A_3_2*x_2_tmp;
	mac += A_3_3*x_3_tmp;
	mac += A_3_4*x_4_tmp;
	mac += A_3_5*x_5_tmp;
	mac += A_3_6*x_6_tmp;
	mac += A_3_7*x_7_tmp;
	mac += A_3_8*x_8_tmp;
	mac += b_3_1*u[0];
	mac += b_3_2*u[1];
	mac += b_3_3*u[2];
	mac += b_3_4*u[3];
	mac += b_3_5*u[4];
	mac += b_3_6*u[5];
	mac += b_3_7*u[6];
	mac += b_3_8*u[7];
	mac += b_3_9*u[8];
	mac += b_3_10*u[9];
	mac += b_3_11*u[10];
	mac += b_3_12*u[11];
	ellip8ABCD12_x_3 = filter_scale_output(mac);

	// Update state ellip8ABCD12_x_4
	mac = 0;
	mac += A_4_1*x_1_tmp;
	mac += A_4_2*x_2_tmp;
	mac += A_4_3*x_3_tmp;
	mac += A_4_4*x_4_tmp;
	mac += A_4_5*x_5_tmp;
	mac += A_4_6*x_6_tmp;
	mac += A_4_7*x_7_tmp;
	mac += A_4_8*x_8_tmp;
	mac += b_4_1*u[0];
	mac += b_4_2*u[1];
	mac += b_4_3*u[2];
	mac += b_4_4*u[3];
	mac += b_4_5*u[4];
	mac += b_4_6*u[5];
	mac += b_4_7*u[6];
	mac += b_4_8*u[7];
	mac += b_4_9*u[8];
	mac += b_4_10*u[9];
	mac += b_4_11*u[10];
	mac += b_4_12*u[11];
	ellip8ABCD12_x_4 = filter_scale_output(mac);

	// Update state ellip8ABCD12_x_5
	mac = 0;
	mac += A_5_1*x_1_tmp;
	mac += A_5_2*x_2_tmp;
	mac += A_5_3*x_3_tmp;
	mac += A_5_4*x_4_tmp;
	mac += A_5_5*x_5_tmp;
	mac += A_5_7*x_7_tmp;
	mac += A_5_8*x_8_tmp;
	mac += b_5_1*u[0];
	mac += b_5_2*u[1];
	mac += b_5_3*u[2];
	mac += b_5_4*u[3];
	mac += b_5_5*u[4];
	mac += b_5_6*u[5];
	mac += b_5_7*u[6];
	mac += b_5_8*u[7];
	mac += b_5_9*u[8];
	mac += b_5_10*u[9];
	mac += b_5_11*u[10];
	mac += b_5_12*u[11];
	ellip8ABCD12_x_5 = filter_scale_output(mac);

	// Update state ellip8ABCD12_x_6
	mac = 0;
	mac += A_6_1*x_1_tmp;
	mac += A_6_2*x_2_tmp;
	mac += A_6_3*x_3_tmp;
	mac += A_6_4*x_4_tmp;
	mac += A_6_5*x_5_tmp;
	mac += A_6_6*x_6_tmp;
	mac += A_6_8*x_8_tmp;
	mac += b_6_1*u[0];
	mac += b_6_2*u[1];
	mac += b_6_3*u[2];
	mac += b_6_4*u[3];
	mac += b_6_5*u[4];
	mac += b_6_6*u[5];
	mac += b_6_7*u[6];
	mac += b_6_8*u[7];
	mac += b_6_9*u[8];
	mac += b_6_10*u[9];
	mac += b_6_11*u[10];
	mac += b_6_12*u[11];
	ellip8ABCD12_x_6 = filter_scale_output(mac);

	// Update state ellip8ABCD12_x_7
	mac = 0;
	mac += A_7_1*x_1_tmp;
	mac += A_7_2*x_2_tmp;
	mac += A_7_3*x_3_tmp;
	mac += A_7_4*x_4_tmp;
	mac += A_7_5*x_5_tmp;
	mac += A_7_7*x_7_tmp;
	mac += A_7_8*x_8_tmp;
	mac += b_7_1*u[0];
	mac += b_7_2*u[1];
	mac += b_7_3*u[2];
	mac += b_7_4*u[3];
	mac += b_7_5*u[4];
	mac += b_7_6*u[5];
	mac += b_7_7*u[6];
	mac += b_7_8*u[7];
	mac += b_7_9*u[8];
	mac += b_7_10*u[9];
	mac += b_7_11*u[10];
	mac += b_7_12*u[11];
	ellip8ABCD12_x_7 = filter_scale_output(mac);

	// Update state ellip8ABCD12_x_8
	mac = 0;
	mac += A_8_1*x_1_tmp;
	mac += A_8_2*x_2_tmp;
	mac += A_8_3*x_3_tmp;
	mac += A_8_4*x_4_tmp;
	mac += A_8_5*x_5_tmp;
	mac += A_8_6*x_6_tmp;
	mac += A_8_7*x_7_tmp;
	mac += A_8_8*x_8_tmp;
	mac += b_8_1*u[0];
	mac += b_8_2*u[1];
	mac += b_8_3*u[2];
	mac += b_8_4*u[3];
	mac += b_8_5*u[4];
	mac += b_8_6*u[5];
	mac += b_8_7*u[6];
	mac += b_8_8*u[7];
	mac += b_8_9*u[8];
	mac += b_8_10*u[9];
	mac += b_8_11*u[10];
	mac += b_8_12*u[11];
	ellip8ABCD12_x_8 = filter_scale_output(mac);
}
EOF
if [ $? -ne 0 ]; then echo "Failed test.cc cat"; fail; fi


#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi
diff -Bb test.cc ellip8ABCD12.cc
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.cc"; fail; fi


#
# this much worked
#
pass

