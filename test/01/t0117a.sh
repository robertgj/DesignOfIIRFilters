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

ngABCDopt =    1.4675e+00
ngABCDoptf =    1.1991e+00
est_nvABCDoptf =    4.2809e-01
nvABCDoptf =    4.3393e-01
Ab =

 Columns 1 through 6:

  -5.2534e-01  -8.1420e-02  -1.4682e-01  -7.9206e-02  -8.0061e-03  -3.3501e-01
   1.4398e-01  -6.2970e-01   1.3180e-01  -2.2581e-02   1.2062e-01   2.7430e-01
   1.1289e-01   1.1832e-01  -3.9409e-01  -1.0505e-01   4.9907e-01   3.9953e-03
   2.1959e-01   1.3661e-01   1.9971e-01  -5.9301e-01  -1.0996e-01   3.0574e-01
  -2.2360e-01   2.0778e-01  -3.0572e-02   4.4329e-01  -2.8247e-01   1.0169e-01
  -1.5121e-03  -2.1167e-01  -2.1318e-01  -2.4896e-01   2.8165e-01  -4.6802e-01
   8.7884e-02  -3.5739e-01   1.6900e-01   3.1617e-01   2.0897e-01   1.5022e-01
  -1.7965e-01  -4.3863e-02  -1.6410e-01   5.0830e-02  -5.5059e-02   3.2881e-01

 Columns 7 and 8:

   6.3332e-02  -9.8418e-02
   3.1437e-01  -1.6022e-01
  -8.9306e-02   2.0555e-01
  -9.2845e-02   1.5578e-02
   1.5702e-01   4.1329e-02
   1.3071e-01   9.4387e-02
  -4.8871e-01   2.5149e-01
   1.0375e-01  -2.5687e-01

Bb =

 Columns 1 through 6:

   2.3124e-02  -4.5050e-02  -1.1153e-01  -1.7087e-01  -2.1765e-01  -2.4682e-01
  -2.4605e-01  -2.4629e-01  -2.3337e-01  -2.0826e-01  -1.7271e-01  -1.2914e-01
  -1.3169e-01  -1.4452e-01  -1.5615e-01  -1.6391e-01  -1.6506e-01  -1.5717e-01
   1.4314e-01   1.1827e-01   7.6652e-02   2.0564e-02  -4.6058e-02  -1.1784e-01
  -1.5137e-01  -1.6423e-01  -1.7394e-01  -1.8155e-01  -1.8831e-01  -1.9538e-01
   9.8008e-02   8.0727e-02   5.6357e-02   2.5251e-02  -1.2251e-02  -5.5853e-02
  -1.6492e-01  -1.3736e-01  -1.1047e-01  -8.7533e-02  -7.1209e-02  -6.3273e-02
  -2.1917e-01  -2.6345e-01  -2.9518e-01  -3.1197e-01  -3.1280e-01  -2.9832e-01

 Columns 7 through 12:

  -2.5404e-01  -2.3613e-01  -1.9141e-01  -1.2005e-01  -2.4417e-02   9.0673e-02
  -8.0232e-02  -2.8664e-02   2.3326e-02   7.4303e-02   1.2399e-01   1.7354e-01
  -1.3825e-01  -1.0696e-01  -6.2544e-02  -4.7269e-03   6.6669e-02   1.5220e-01
  -1.8835e-01  -2.5057e-01  -2.9751e-01  -3.2279e-01  -3.2124e-01  -2.8946e-01
  -2.0344e-01  -2.1232e-01  -2.2055e-01  -2.2503e-01  -2.2073e-01  -2.0053e-01
  -1.0529e-01  -1.6026e-01  -2.2033e-01  -2.8480e-01  -3.5255e-01  -4.2190e-01
  -6.4420e-02  -7.4208e-02  -9.1106e-02  -1.1265e-01  -1.3566e-01  -1.5652e-01
  -2.7110e-01  -2.3568e-01  -1.9850e-01  -1.6766e-01  -1.5248e-01  -1.6278e-01

Cb =

 Columns 1 through 6:

   9.1289e-02  -6.0853e-02  -2.0147e-01   1.4762e-02  -1.0170e-01  -3.8281e-03
   6.8504e-02  -6.6640e-02  -1.6171e-01   9.8014e-03  -6.9202e-02  -4.5976e-03
   4.1330e-02  -7.6733e-02  -1.2137e-01   3.4748e-04  -4.7632e-02  -3.5210e-03
   1.3133e-02  -8.7732e-02  -8.1748e-02  -1.2165e-02  -3.6746e-02  -2.7707e-03
  -1.3472e-02  -9.6627e-02  -4.4398e-02  -2.6217e-02  -3.5362e-02  -3.6885e-03
  -3.6612e-02  -1.0101e-01  -1.0923e-02  -4.0368e-02  -4.1596e-02  -6.9538e-03
  -5.5083e-02  -9.9239e-02   1.7254e-02  -5.3376e-02  -5.3121e-02  -1.2739e-02
  -6.8266e-02  -9.0515e-02   3.9057e-02  -6.4272e-02  -6.7413e-02  -2.0849e-02
  -7.6002e-02  -7.4912e-02   5.3881e-02  -7.2397e-02  -8.1983e-02  -3.0828e-02
  -7.8486e-02  -5.3307e-02   6.1648e-02  -7.7396e-02  -9.4585e-02  -4.2056e-02
  -7.6160e-02  -2.7256e-02   6.2806e-02  -7.9200e-02  -1.0338e-01  -5.3810e-02
  -6.9626e-02   1.1891e-03   5.8272e-02  -7.7975e-02  -1.0704e-01  -6.5320e-02

 Columns 7 and 8:

  -1.1206e-01  -2.0862e-02
  -1.3432e-01  -6.2630e-02
  -1.4597e-01  -9.2522e-02
  -1.4704e-01  -1.1268e-01
  -1.3829e-01  -1.2498e-01
  -1.2120e-01  -1.3094e-01
  -9.7828e-02  -1.3178e-01
  -7.0603e-02  -1.2842e-01
  -4.2118e-02  -1.2152e-01
  -1.4894e-02  -1.1158e-01
   8.8389e-03  -9.9038e-02
   2.7323e-02  -8.4291e-02

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

ngABCDbf =    1.2229e-01
est_nvABCDbf =    3.0582e-01
nvbf =    3.0663e-01
nvccbf =    3.0663e-01
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
	static const WORD A_1_1 =    -67;
	static const WORD A_1_2 =    -10;
	static const WORD A_1_3 =    -19;
	static const WORD A_1_4 =    -10;
	static const WORD A_1_5 =     -1;
	static const WORD A_1_6 =    -43;
	static const WORD A_1_7 =      8;
	static const WORD A_1_8 =    -13;
	static const WORD A_2_1 =     18;
	static const WORD A_2_2 =    -81;
	static const WORD A_2_3 =     17;
	static const WORD A_2_4 =     -3;
	static const WORD A_2_5 =     15;
	static const WORD A_2_6 =     35;
	static const WORD A_2_7 =     40;
	static const WORD A_2_8 =    -21;
	static const WORD A_3_1 =     14;
	static const WORD A_3_2 =     15;
	static const WORD A_3_3 =    -50;
	static const WORD A_3_4 =    -13;
	static const WORD A_3_5 =     64;
	static const WORD A_3_6 =      1;
	static const WORD A_3_7 =    -11;
	static const WORD A_3_8 =     26;
	static const WORD A_4_1 =     28;
	static const WORD A_4_2 =     17;
	static const WORD A_4_3 =     26;
	static const WORD A_4_4 =    -76;
	static const WORD A_4_5 =    -14;
	static const WORD A_4_6 =     39;
	static const WORD A_4_7 =    -12;
	static const WORD A_4_8 =      2;
	static const WORD A_5_1 =    -29;
	static const WORD A_5_2 =     27;
	static const WORD A_5_3 =     -4;
	static const WORD A_5_4 =     57;
	static const WORD A_5_5 =    -36;
	static const WORD A_5_6 =     13;
	static const WORD A_5_7 =     20;
	static const WORD A_5_8 =      5;
	static const WORD A_6_2 =    -27;
	static const WORD A_6_3 =    -27;
	static const WORD A_6_4 =    -32;
	static const WORD A_6_5 =     36;
	static const WORD A_6_6 =    -60;
	static const WORD A_6_7 =     17;
	static const WORD A_6_8 =     12;
	static const WORD A_7_1 =     11;
	static const WORD A_7_2 =    -46;
	static const WORD A_7_3 =     22;
	static const WORD A_7_4 =     40;
	static const WORD A_7_5 =     27;
	static const WORD A_7_6 =     19;
	static const WORD A_7_7 =    -63;
	static const WORD A_7_8 =     32;
	static const WORD A_8_1 =    -23;
	static const WORD A_8_2 =     -6;
	static const WORD A_8_3 =    -21;
	static const WORD A_8_4 =      7;
	static const WORD A_8_5 =     -7;
	static const WORD A_8_6 =     42;
	static const WORD A_8_7 =     13;
	static const WORD A_8_8 =    -33;
	static const WORD b_1_1 =      3;
	static const WORD b_1_2 =     -6;
	static const WORD b_1_3 =    -14;
	static const WORD b_1_4 =    -22;
	static const WORD b_1_5 =    -28;
	static const WORD b_1_6 =    -32;
	static const WORD b_1_7 =    -33;
	static const WORD b_1_8 =    -30;
	static const WORD b_1_9 =    -25;
	static const WORD b_1_10 =    -15;
	static const WORD b_1_11 =     -3;
	static const WORD b_1_12 =     12;
	static const WORD b_2_1 =    -31;
	static const WORD b_2_2 =    -32;
	static const WORD b_2_3 =    -30;
	static const WORD b_2_4 =    -27;
	static const WORD b_2_5 =    -22;
	static const WORD b_2_6 =    -17;
	static const WORD b_2_7 =    -10;
	static const WORD b_2_8 =     -4;
	static const WORD b_2_9 =      3;
	static const WORD b_2_10 =     10;
	static const WORD b_2_11 =     16;
	static const WORD b_2_12 =     22;
	static const WORD b_3_1 =    -17;
	static const WORD b_3_2 =    -18;
	static const WORD b_3_3 =    -20;
	static const WORD b_3_4 =    -21;
	static const WORD b_3_5 =    -21;
	static const WORD b_3_6 =    -20;
	static const WORD b_3_7 =    -18;
	static const WORD b_3_8 =    -14;
	static const WORD b_3_9 =     -8;
	static const WORD b_3_10 =     -1;
	static const WORD b_3_11 =      9;
	static const WORD b_3_12 =     19;
	static const WORD b_4_1 =     18;
	static const WORD b_4_2 =     15;
	static const WORD b_4_3 =     10;
	static const WORD b_4_4 =      3;
	static const WORD b_4_5 =     -6;
	static const WORD b_4_6 =    -15;
	static const WORD b_4_7 =    -24;
	static const WORD b_4_8 =    -32;
	static const WORD b_4_9 =    -38;
	static const WORD b_4_10 =    -41;
	static const WORD b_4_11 =    -41;
	static const WORD b_4_12 =    -37;
	static const WORD b_5_1 =    -19;
	static const WORD b_5_2 =    -21;
	static const WORD b_5_3 =    -22;
	static const WORD b_5_4 =    -23;
	static const WORD b_5_5 =    -24;
	static const WORD b_5_6 =    -25;
	static const WORD b_5_7 =    -26;
	static const WORD b_5_8 =    -27;
	static const WORD b_5_9 =    -28;
	static const WORD b_5_10 =    -29;
	static const WORD b_5_11 =    -28;
	static const WORD b_5_12 =    -26;
	static const WORD b_6_1 =     13;
	static const WORD b_6_2 =     10;
	static const WORD b_6_3 =      7;
	static const WORD b_6_4 =      3;
	static const WORD b_6_5 =     -2;
	static const WORD b_6_6 =     -7;
	static const WORD b_6_7 =    -13;
	static const WORD b_6_8 =    -21;
	static const WORD b_6_9 =    -28;
	static const WORD b_6_10 =    -36;
	static const WORD b_6_11 =    -45;
	static const WORD b_6_12 =    -54;
	static const WORD b_7_1 =    -21;
	static const WORD b_7_2 =    -18;
	static const WORD b_7_3 =    -14;
	static const WORD b_7_4 =    -11;
	static const WORD b_7_5 =     -9;
	static const WORD b_7_6 =     -8;
	static const WORD b_7_7 =     -8;
	static const WORD b_7_8 =     -9;
	static const WORD b_7_9 =    -12;
	static const WORD b_7_10 =    -14;
	static const WORD b_7_11 =    -17;
	static const WORD b_7_12 =    -20;
	static const WORD b_8_1 =    -28;
	static const WORD b_8_2 =    -34;
	static const WORD b_8_3 =    -38;
	static const WORD b_8_4 =    -40;
	static const WORD b_8_5 =    -40;
	static const WORD b_8_6 =    -38;
	static const WORD b_8_7 =    -35;
	static const WORD b_8_8 =    -30;
	static const WORD b_8_9 =    -25;
	static const WORD b_8_10 =    -21;
	static const WORD b_8_11 =    -20;
	static const WORD b_8_12 =    -21;
	static const WORD c_1_1 =     12;
	static const WORD c_1_2 =     -8;
	static const WORD c_1_3 =    -26;
	static const WORD c_1_4 =      2;
	static const WORD c_1_5 =    -13;
	static const WORD c_1_7 =    -14;
	static const WORD c_1_8 =     -3;
	static const WORD c_2_1 =      9;
	static const WORD c_2_2 =     -9;
	static const WORD c_2_3 =    -21;
	static const WORD c_2_4 =      1;
	static const WORD c_2_5 =     -9;
	static const WORD c_2_6 =     -1;
	static const WORD c_2_7 =    -17;
	static const WORD c_2_8 =     -8;
	static const WORD c_3_1 =      5;
	static const WORD c_3_2 =    -10;
	static const WORD c_3_3 =    -16;
	static const WORD c_3_5 =     -6;
	static const WORD c_3_7 =    -19;
	static const WORD c_3_8 =    -12;
	static const WORD c_4_1 =      2;
	static const WORD c_4_2 =    -11;
	static const WORD c_4_3 =    -10;
	static const WORD c_4_4 =     -2;
	static const WORD c_4_5 =     -5;
	static const WORD c_4_7 =    -19;
	static const WORD c_4_8 =    -14;
	static const WORD c_5_1 =     -2;
	static const WORD c_5_2 =    -12;
	static const WORD c_5_3 =     -6;
	static const WORD c_5_4 =     -3;
	static const WORD c_5_5 =     -5;
	static const WORD c_5_7 =    -18;
	static const WORD c_5_8 =    -16;
	static const WORD c_6_1 =     -5;
	static const WORD c_6_2 =    -13;
	static const WORD c_6_3 =     -1;
	static const WORD c_6_4 =     -5;
	static const WORD c_6_5 =     -5;
	static const WORD c_6_6 =     -1;
	static const WORD c_6_7 =    -16;
	static const WORD c_6_8 =    -17;
	static const WORD c_7_1 =     -7;
	static const WORD c_7_2 =    -13;
	static const WORD c_7_3 =      2;
	static const WORD c_7_4 =     -7;
	static const WORD c_7_5 =     -7;
	static const WORD c_7_6 =     -2;
	static const WORD c_7_7 =    -13;
	static const WORD c_7_8 =    -17;
	static const WORD c_8_1 =     -9;
	static const WORD c_8_2 =    -12;
	static const WORD c_8_3 =      5;
	static const WORD c_8_4 =     -8;
	static const WORD c_8_5 =     -9;
	static const WORD c_8_6 =     -3;
	static const WORD c_8_7 =     -9;
	static const WORD c_8_8 =    -16;
	static const WORD c_9_1 =    -10;
	static const WORD c_9_2 =    -10;
	static const WORD c_9_3 =      7;
	static const WORD c_9_4 =     -9;
	static const WORD c_9_5 =    -10;
	static const WORD c_9_6 =     -4;
	static const WORD c_9_7 =     -5;
	static const WORD c_9_8 =    -16;
	static const WORD c_10_1 =    -10;
	static const WORD c_10_2 =     -7;
	static const WORD c_10_3 =      8;
	static const WORD c_10_4 =    -10;
	static const WORD c_10_5 =    -12;
	static const WORD c_10_6 =     -5;
	static const WORD c_10_7 =     -2;
	static const WORD c_10_8 =    -14;
	static const WORD c_11_1 =    -10;
	static const WORD c_11_2 =     -3;
	static const WORD c_11_3 =      8;
	static const WORD c_11_4 =    -10;
	static const WORD c_11_5 =    -13;
	static const WORD c_11_6 =     -7;
	static const WORD c_11_7 =      1;
	static const WORD c_11_8 =    -13;
	static const WORD c_12_1 =     -9;
	static const WORD c_12_3 =      7;
	static const WORD c_12_4 =    -10;
	static const WORD c_12_5 =    -14;
	static const WORD c_12_6 =     -8;
	static const WORD c_12_7 =      3;
	static const WORD c_12_8 =    -11;
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
	mac += c_3_1*ellip8ABCD12_x_1;
	mac += c_3_2*ellip8ABCD12_x_2;
	mac += c_3_3*ellip8ABCD12_x_3;
	mac += c_3_5*ellip8ABCD12_x_5;
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
	mac += c_7_4*ellip8ABCD12_x_4;
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
	mac += c_10_6*ellip8ABCD12_x_6;
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
	mac += A_5_6*x_6_tmp;
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
	mac += A_6_2*x_2_tmp;
	mac += A_6_3*x_3_tmp;
	mac += A_6_4*x_4_tmp;
	mac += A_6_5*x_5_tmp;
	mac += A_6_6*x_6_tmp;
	mac += A_6_7*x_7_tmp;
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
	mac += A_7_6*x_6_tmp;
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

