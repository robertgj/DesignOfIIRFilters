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

ngABCDopt =    1.4606e+00
ngABCDoptf =    1.4556e+00
est_nvABCDoptf =    4.5237e-01
nvABCDoptf =    4.4377e-01
Ab =

 Columns 1 through 6:

  -4.9168e-01  -3.2985e-02  -7.9082e-02  -9.4057e-02   5.1598e-02  -2.2462e-01
   1.3169e-01  -6.1542e-01   1.3818e-01   9.7421e-02   2.2996e-01   2.7612e-01
   7.6949e-02   1.2755e-01  -3.9799e-01   1.8665e-01   4.0771e-01  -2.8491e-03
   1.3852e-01   1.6338e-01   1.9742e-01  -2.3298e-01  -9.8047e-02   3.9469e-01
  -1.2949e-01  -6.3565e-02  -1.2361e-01   5.9549e-01  -5.8893e-01  -1.4409e-01
  -8.2215e-02  -2.1399e-01  -2.0882e-01   2.1682e-02   3.8269e-01  -4.5416e-01
   1.9705e-01  -3.9815e-01   1.8628e-01   1.1633e-01   1.2029e-02   1.0998e-01
  -1.5497e-01  -4.2724e-02  -1.5394e-01   6.9770e-02  -7.9810e-02   3.3321e-01

 Columns 7 and 8:

   4.1253e-02  -8.2172e-02
   2.4260e-01  -1.6255e-01
  -2.6986e-01   2.1069e-01
  -1.2359e-02   1.0506e-01
   7.0388e-02   7.8024e-02
   1.7681e-02   9.8455e-02
  -5.8877e-01   2.2386e-01
   1.1498e-01  -2.6828e-01

Bb =

 Columns 1 through 6:

   6.1288e-02  -1.1635e-02  -8.7886e-02  -1.6156e-01  -2.2624e-01  -2.7547e-01
  -2.5054e-01  -2.5098e-01  -2.3815e-01  -2.1294e-01  -1.7705e-01  -1.3284e-01
  -1.2384e-01  -1.3641e-01  -1.4825e-01  -1.5671e-01  -1.5905e-01  -1.5278e-01
  -3.3385e-02  -3.6559e-02  -5.0362e-02  -7.5880e-02  -1.1299e-01  -1.6018e-01
  -2.3578e-01  -2.3471e-01  -2.2085e-01  -1.9623e-01  -1.6388e-01  -1.2753e-01
   9.6828e-02   7.8344e-02   5.2863e-02   2.0799e-02  -1.7465e-02  -6.1626e-02
  -9.9393e-02  -6.9530e-02  -4.1577e-02  -1.8155e-02  -1.2060e-03   8.1381e-03
  -2.2201e-01  -2.6577e-01  -2.9682e-01  -3.1281e-01  -3.1272e-01  -2.9726e-01

 Columns 7 through 12:

  -3.0313e-01  -3.0406e-01  -2.7450e-01  -2.1268e-01  -1.1927e-01   2.2046e-03
  -8.3030e-02  -3.0299e-02   2.3058e-02   7.5547e-02   1.2684e-01   1.7806e-01
  -1.3589e-01  -1.0695e-01  -6.5118e-02  -9.9904e-03   5.8734e-02   1.4175e-01
  -2.1444e-01  -2.7128e-01  -3.2483e-01  -3.6796e-01  -3.9255e-01  -3.8976e-01
  -9.1044e-02  -5.7958e-02  -3.0894e-02  -1.1042e-02   2.2897e-03   1.2014e-02
  -1.1145e-01  -1.6671e-01  -2.2710e-01  -2.9212e-01  -3.6087e-01  -4.3197e-01
   9.5831e-03   3.5749e-03  -8.9029e-03  -2.6611e-02  -4.8373e-02  -7.3384e-02
  -2.6899e-01  -2.3246e-01  -1.9411e-01  -1.6204e-01  -1.4552e-01  -1.5437e-01

Cb =

 Columns 1 through 6:

   8.8464e-02  -6.7101e-02  -2.0084e-01  -9.7503e-02  -9.2652e-02  -1.3966e-03
   6.5868e-02  -7.1791e-02  -1.6010e-01  -8.1097e-02  -7.7529e-02  -3.8906e-03
   3.7611e-02  -8.0650e-02  -1.1881e-01  -7.1219e-02  -6.5191e-02  -4.2143e-03
   7.3375e-03  -9.0350e-02  -7.8412e-02  -6.7454e-02  -5.5714e-02  -4.5408e-03
  -2.1988e-02  -9.7956e-02  -4.0587e-02  -6.8742e-02  -4.8916e-02  -6.2246e-03
  -4.8124e-02  -1.0114e-01  -7.0006e-03  -7.3645e-02  -4.4407e-02  -9.9684e-03
  -6.9528e-02  -9.8332e-02   2.0906e-02  -8.0574e-02  -4.1655e-02  -1.5976e-02
  -8.5293e-02  -8.8792e-02   4.2081e-02  -8.7971e-02  -4.0038e-02  -2.4089e-02
  -9.5047e-02  -7.2633e-02   5.5976e-02  -9.4459e-02  -3.8907e-02  -3.3895e-02
  -9.8852e-02  -5.0750e-02   6.2597e-02  -9.8939e-02  -3.7639e-02  -4.4812e-02
  -9.7094e-02  -2.4693e-02   6.2491e-02  -1.0065e-01  -3.5692e-02  -5.6160e-02
  -9.0387e-02   3.5161e-03   5.6684e-02  -9.9166e-02  -3.2651e-02  -6.7207e-02

 Columns 7 and 8:

  -6.9447e-02  -2.1749e-02
  -1.0162e-01  -6.3165e-02
  -1.2001e-01  -9.2761e-02
  -1.2472e-01  -1.1265e-01
  -1.1688e-01  -1.2469e-01
  -9.8540e-02  -1.3041e-01
  -7.2453e-02  -1.3102e-01
  -4.1793e-02  -1.2744e-01
  -9.8754e-03  -1.2034e-01
   2.0138e-02  -1.1022e-01
   4.5502e-02  -9.7509e-02
   6.4106e-02  -8.2614e-02

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

ngABCDbf =    1.2172e-01
est_nvABCDbf =    3.0574e-01
nvbf =    3.0754e-01
nvccbf =    3.0754e-01
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
	static const WORD A_1_1 =    -63;
	static const WORD A_1_2 =     -4;
	static const WORD A_1_3 =    -10;
	static const WORD A_1_4 =    -12;
	static const WORD A_1_5 =      7;
	static const WORD A_1_6 =    -29;
	static const WORD A_1_7 =      5;
	static const WORD A_1_8 =    -11;
	static const WORD A_2_1 =     17;
	static const WORD A_2_2 =    -79;
	static const WORD A_2_3 =     18;
	static const WORD A_2_4 =     12;
	static const WORD A_2_5 =     29;
	static const WORD A_2_6 =     35;
	static const WORD A_2_7 =     31;
	static const WORD A_2_8 =    -21;
	static const WORD A_3_1 =     10;
	static const WORD A_3_2 =     16;
	static const WORD A_3_3 =    -51;
	static const WORD A_3_4 =     24;
	static const WORD A_3_5 =     52;
	static const WORD A_3_7 =    -35;
	static const WORD A_3_8 =     27;
	static const WORD A_4_1 =     18;
	static const WORD A_4_2 =     21;
	static const WORD A_4_3 =     25;
	static const WORD A_4_4 =    -30;
	static const WORD A_4_5 =    -13;
	static const WORD A_4_6 =     51;
	static const WORD A_4_7 =     -2;
	static const WORD A_4_8 =     13;
	static const WORD A_5_1 =    -17;
	static const WORD A_5_2 =     -8;
	static const WORD A_5_3 =    -16;
	static const WORD A_5_4 =     76;
	static const WORD A_5_5 =    -75;
	static const WORD A_5_6 =    -18;
	static const WORD A_5_7 =      9;
	static const WORD A_5_8 =     10;
	static const WORD A_6_1 =    -11;
	static const WORD A_6_2 =    -27;
	static const WORD A_6_3 =    -27;
	static const WORD A_6_4 =      3;
	static const WORD A_6_5 =     49;
	static const WORD A_6_6 =    -58;
	static const WORD A_6_7 =      2;
	static const WORD A_6_8 =     13;
	static const WORD A_7_1 =     25;
	static const WORD A_7_2 =    -51;
	static const WORD A_7_3 =     24;
	static const WORD A_7_4 =     15;
	static const WORD A_7_5 =      2;
	static const WORD A_7_6 =     14;
	static const WORD A_7_7 =    -75;
	static const WORD A_7_8 =     29;
	static const WORD A_8_1 =    -20;
	static const WORD A_8_2 =     -5;
	static const WORD A_8_3 =    -20;
	static const WORD A_8_4 =      9;
	static const WORD A_8_5 =    -10;
	static const WORD A_8_6 =     43;
	static const WORD A_8_7 =     15;
	static const WORD A_8_8 =    -34;
	static const WORD b_1_1 =      8;
	static const WORD b_1_2 =     -1;
	static const WORD b_1_3 =    -11;
	static const WORD b_1_4 =    -21;
	static const WORD b_1_5 =    -29;
	static const WORD b_1_6 =    -35;
	static const WORD b_1_7 =    -39;
	static const WORD b_1_8 =    -39;
	static const WORD b_1_9 =    -35;
	static const WORD b_1_10 =    -27;
	static const WORD b_1_11 =    -15;
	static const WORD b_2_1 =    -32;
	static const WORD b_2_2 =    -32;
	static const WORD b_2_3 =    -30;
	static const WORD b_2_4 =    -27;
	static const WORD b_2_5 =    -23;
	static const WORD b_2_6 =    -17;
	static const WORD b_2_7 =    -11;
	static const WORD b_2_8 =     -4;
	static const WORD b_2_9 =      3;
	static const WORD b_2_10 =     10;
	static const WORD b_2_11 =     16;
	static const WORD b_2_12 =     23;
	static const WORD b_3_1 =    -16;
	static const WORD b_3_2 =    -17;
	static const WORD b_3_3 =    -19;
	static const WORD b_3_4 =    -20;
	static const WORD b_3_5 =    -20;
	static const WORD b_3_6 =    -20;
	static const WORD b_3_7 =    -17;
	static const WORD b_3_8 =    -14;
	static const WORD b_3_9 =     -8;
	static const WORD b_3_10 =     -1;
	static const WORD b_3_11 =      8;
	static const WORD b_3_12 =     18;
	static const WORD b_4_1 =     -4;
	static const WORD b_4_2 =     -5;
	static const WORD b_4_3 =     -6;
	static const WORD b_4_4 =    -10;
	static const WORD b_4_5 =    -14;
	static const WORD b_4_6 =    -21;
	static const WORD b_4_7 =    -27;
	static const WORD b_4_8 =    -35;
	static const WORD b_4_9 =    -42;
	static const WORD b_4_10 =    -47;
	static const WORD b_4_11 =    -50;
	static const WORD b_4_12 =    -50;
	static const WORD b_5_1 =    -30;
	static const WORD b_5_2 =    -30;
	static const WORD b_5_3 =    -28;
	static const WORD b_5_4 =    -25;
	static const WORD b_5_5 =    -21;
	static const WORD b_5_6 =    -16;
	static const WORD b_5_7 =    -12;
	static const WORD b_5_8 =     -7;
	static const WORD b_5_9 =     -4;
	static const WORD b_5_10 =     -1;
	static const WORD b_5_12 =      2;
	static const WORD b_6_1 =     12;
	static const WORD b_6_2 =     10;
	static const WORD b_6_3 =      7;
	static const WORD b_6_4 =      3;
	static const WORD b_6_5 =     -2;
	static const WORD b_6_6 =     -8;
	static const WORD b_6_7 =    -14;
	static const WORD b_6_8 =    -21;
	static const WORD b_6_9 =    -29;
	static const WORD b_6_10 =    -37;
	static const WORD b_6_11 =    -46;
	static const WORD b_6_12 =    -55;
	static const WORD b_7_1 =    -13;
	static const WORD b_7_2 =     -9;
	static const WORD b_7_3 =     -5;
	static const WORD b_7_4 =     -2;
	static const WORD b_7_6 =      1;
	static const WORD b_7_7 =      1;
	static const WORD b_7_9 =     -1;
	static const WORD b_7_10 =     -3;
	static const WORD b_7_11 =     -6;
	static const WORD b_7_12 =     -9;
	static const WORD b_8_1 =    -28;
	static const WORD b_8_2 =    -34;
	static const WORD b_8_3 =    -38;
	static const WORD b_8_4 =    -40;
	static const WORD b_8_5 =    -40;
	static const WORD b_8_6 =    -38;
	static const WORD b_8_7 =    -34;
	static const WORD b_8_8 =    -30;
	static const WORD b_8_9 =    -25;
	static const WORD b_8_10 =    -21;
	static const WORD b_8_11 =    -19;
	static const WORD b_8_12 =    -20;
	static const WORD c_1_1 =     11;
	static const WORD c_1_2 =     -9;
	static const WORD c_1_3 =    -26;
	static const WORD c_1_4 =    -12;
	static const WORD c_1_5 =    -12;
	static const WORD c_1_7 =     -9;
	static const WORD c_1_8 =     -3;
	static const WORD c_2_1 =      8;
	static const WORD c_2_2 =     -9;
	static const WORD c_2_3 =    -20;
	static const WORD c_2_4 =    -10;
	static const WORD c_2_5 =    -10;
	static const WORD c_2_7 =    -13;
	static const WORD c_2_8 =     -8;
	static const WORD c_3_1 =      5;
	static const WORD c_3_2 =    -10;
	static const WORD c_3_3 =    -15;
	static const WORD c_3_4 =     -9;
	static const WORD c_3_5 =     -8;
	static const WORD c_3_6 =     -1;
	static const WORD c_3_7 =    -15;
	static const WORD c_3_8 =    -12;
	static const WORD c_4_1 =      1;
	static const WORD c_4_2 =    -12;
	static const WORD c_4_3 =    -10;
	static const WORD c_4_4 =     -9;
	static const WORD c_4_5 =     -7;
	static const WORD c_4_6 =     -1;
	static const WORD c_4_7 =    -16;
	static const WORD c_4_8 =    -14;
	static const WORD c_5_1 =     -3;
	static const WORD c_5_2 =    -13;
	static const WORD c_5_3 =     -5;
	static const WORD c_5_4 =     -9;
	static const WORD c_5_5 =     -6;
	static const WORD c_5_6 =     -1;
	static const WORD c_5_7 =    -15;
	static const WORD c_5_8 =    -16;
	static const WORD c_6_1 =     -6;
	static const WORD c_6_2 =    -13;
	static const WORD c_6_3 =     -1;
	static const WORD c_6_4 =     -9;
	static const WORD c_6_5 =     -6;
	static const WORD c_6_6 =     -1;
	static const WORD c_6_7 =    -13;
	static const WORD c_6_8 =    -17;
	static const WORD c_7_1 =     -9;
	static const WORD c_7_2 =    -13;
	static const WORD c_7_3 =      3;
	static const WORD c_7_4 =    -10;
	static const WORD c_7_5 =     -5;
	static const WORD c_7_6 =     -2;
	static const WORD c_7_7 =     -9;
	static const WORD c_7_8 =    -17;
	static const WORD c_8_1 =    -11;
	static const WORD c_8_2 =    -11;
	static const WORD c_8_3 =      5;
	static const WORD c_8_4 =    -11;
	static const WORD c_8_5 =     -5;
	static const WORD c_8_6 =     -3;
	static const WORD c_8_7 =     -5;
	static const WORD c_8_8 =    -16;
	static const WORD c_9_1 =    -12;
	static const WORD c_9_2 =     -9;
	static const WORD c_9_3 =      7;
	static const WORD c_9_4 =    -12;
	static const WORD c_9_5 =     -5;
	static const WORD c_9_6 =     -4;
	static const WORD c_9_7 =     -1;
	static const WORD c_9_8 =    -15;
	static const WORD c_10_1 =    -13;
	static const WORD c_10_2 =     -6;
	static const WORD c_10_3 =      8;
	static const WORD c_10_4 =    -13;
	static const WORD c_10_5 =     -5;
	static const WORD c_10_6 =     -6;
	static const WORD c_10_7 =      3;
	static const WORD c_10_8 =    -14;
	static const WORD c_11_1 =    -12;
	static const WORD c_11_2 =     -3;
	static const WORD c_11_3 =      8;
	static const WORD c_11_4 =    -13;
	static const WORD c_11_5 =     -5;
	static const WORD c_11_6 =     -7;
	static const WORD c_11_7 =      6;
	static const WORD c_11_8 =    -12;
	static const WORD c_12_1 =    -12;
	static const WORD c_12_3 =      7;
	static const WORD c_12_4 =    -13;
	static const WORD c_12_5 =     -4;
	static const WORD c_12_6 =     -9;
	static const WORD c_12_7 =      8;
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
	mac += b_7_6*u[5];
	mac += b_7_7*u[6];
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

