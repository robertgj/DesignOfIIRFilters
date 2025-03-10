#!/bin/sh

prog=Abcd2cc_test.m

depends="test/Abcd2cc_test.m test_common.m \
Abcd2cc.m KW.m tf2Abcd.m optKW.m sv2block.m svf.m crossWelch.m \
p2n60.m qroots.oct"

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
# the output should look like this
#
cat > test.ok << 'EOF'
bits = 8
scale = 128
delta = 1
N = 8
P = 12
dbap = 0.1000
dbas = 40
fc = 0.050000
n =
 Columns 1 through 7:
   0.010374  -0.069387   0.213314  -0.394202   0.479825  -0.394202   0.213314
 Columns 8 and 9:
  -0.069387   0.010374

d =
 Columns 1 through 8:
    1.0000   -7.2403   23.1851  -42.8626   50.0145  -37.7065   17.9323   -4.9177
 Column 9:
    0.5954

ngABCDopt = 1.4657
ngABCDoptf = 1.4883
est_nvABCDoptf = 0.4554
nvABCDoptf = 0.4529
Ab =
 Columns 1 through 6:
  -4.9466e-01  -4.7363e-02  -8.4032e-02  -1.3735e-01  -1.2998e-01  -1.7669e-01
   1.4271e-01  -6.2874e-01   1.2225e-01  -1.6591e-01   3.4140e-01   1.2315e-01
   7.8270e-02   1.0945e-01  -3.7914e-01   5.0891e-02   3.8393e-01  -2.2327e-01
   4.1007e-02   8.9619e-02   5.3787e-02  -3.8172e-01   1.8142e-01   4.8666e-01
  -5.0736e-02  -4.3561e-02  -8.2219e-02   3.6916e-01  -7.0048e-02  -1.0063e-01
  -6.5759e-02  -1.9320e-01  -2.0987e-01  -3.4080e-01   6.4671e-02  -5.8248e-01
   1.9333e-01  -4.0446e-01   1.5663e-01   2.2114e-01   1.3117e-01   5.4565e-02
  -2.4056e-01  -1.2711e-01  -2.7929e-01   2.2161e-01   6.1365e-02  -7.3490e-02
 Columns 7 and 8:
   3.9788e-02   2.4458e-02
   2.5923e-01  -7.2053e-02
  -2.6027e-01   2.3354e-01
   4.3214e-02   1.5283e-01
   4.4148e-02  -1.3094e-01
  -8.4681e-03   3.5330e-01
  -5.8977e-01   1.0602e-01
   1.3180e-01  -5.1162e-01

Bb =
 Columns 1 through 6:
   6.4072e-02  -8.5990e-03  -8.4877e-02  -1.5889e-01  -2.2426e-01  -2.7453e-01
  -2.4239e-01  -2.4181e-01  -2.2831e-01  -2.0300e-01  -1.6783e-01  -1.2533e-01
  -1.4016e-01  -1.5241e-01  -1.6321e-01  -1.6999e-01  -1.7016e-01  -1.6137e-01
  -6.1706e-02  -9.4596e-02  -1.3037e-01  -1.6705e-01  -2.0247e-01  -2.3457e-01
  -1.1270e-01  -1.2277e-01  -1.3449e-01  -1.4955e-01  -1.6965e-01  -1.9611e-01
   1.9140e-01   1.7894e-01   1.5888e-01   1.3259e-01   1.0144e-01   6.6510e-02
  -9.4856e-02  -6.3235e-02  -3.3716e-02  -9.0508e-03   8.6813e-03   1.8218e-02
  -2.4947e-01  -2.7878e-01  -2.8756e-01  -2.7446e-01  -2.4023e-01  -1.8782e-01
 Columns 7 through 12:
  -3.0362e-01  -3.0636e-01  -2.7905e-01  -2.1996e-01  -1.2982e-01  -1.2256e-02
  -7.8306e-02  -2.9485e-02   1.8884e-02   6.5408e-02   1.0989e-01   1.5358e-01
  -1.4171e-01  -1.0987e-01  -6.5072e-02  -6.9079e-03   6.5003e-02   1.5152e-01
  -2.6175e-01  -2.8312e-01  -2.9878e-01  -3.0994e-01  -3.1900e-01  -3.2932e-01
  -2.2962e-01  -2.6976e-01  -3.1474e-01  -3.6105e-01  -4.0324e-01  -4.3374e-01
   2.8452e-02  -1.2711e-02  -5.7669e-02  -1.0785e-01  -1.6541e-01  -2.3311e-01
   1.9141e-02   1.1787e-02  -2.9485e-03  -2.3889e-02  -4.9890e-02  -8.0137e-02
  -1.2243e-01  -5.1280e-02   1.6718e-02   7.1501e-02   1.0250e-01   9.9401e-02

Cb =
 Columns 1 through 6:
   8.8731e-02  -5.6176e-02  -2.0575e-01  -2.4204e-02  -1.1413e-01   6.6749e-02
   6.4767e-02  -6.3861e-02  -1.6548e-01  -5.1304e-02  -9.5849e-02   5.4656e-02
   3.5657e-02  -7.5596e-02  -1.2493e-01  -7.2373e-02  -8.1839e-02   4.7798e-02
   4.9902e-03  -8.7975e-02  -8.5305e-02  -8.8689e-02  -7.3144e-02   4.4072e-02
  -2.4343e-02  -9.7977e-02  -4.8043e-02  -1.0109e-01  -6.9837e-02   4.1771e-02
  -5.0189e-02  -1.0319e-01  -1.4642e-02  -1.1006e-01  -7.1295e-02   3.9563e-02
  -7.1104e-02  -1.0197e-01   1.3560e-02  -1.1581e-01  -7.6429e-02   3.6460e-02
  -8.6278e-02  -9.3550e-02   3.5550e-02  -1.1842e-01  -8.3904e-02   3.1794e-02
  -9.5441e-02  -7.8035e-02   5.0754e-02  -1.1787e-01  -9.2311e-02   2.5188e-02
  -9.8738e-02  -5.6354e-02   5.9093e-02  -1.1418e-01  -1.0031e-01   1.6544e-02
  -9.6625e-02  -3.0121e-02   6.0987e-02  -1.0745e-01  -1.0671e-01   6.0121e-03
  -8.9763e-02  -1.4434e-03   5.7303e-02  -9.7913e-02  -1.1059e-01  -6.0243e-03
 Columns 7 and 8:
  -6.8658e-02  -8.0793e-03
  -1.0073e-01  -3.9187e-02
  -1.1871e-01  -5.9599e-02
  -1.2287e-01  -7.1129e-02
  -1.1447e-01  -7.5609e-02
  -9.5673e-02  -7.4749e-02
  -6.9297e-02  -7.0029e-02
  -3.8563e-02  -6.2654e-02
  -6.7982e-03  -5.3542e-02
   2.2846e-02  -4.3349e-02
   4.7656e-02  -3.2525e-02
   6.5566e-02  -2.1379e-02

Db =
 Columns 1 through 7:
   0.010374          0          0          0          0          0          0
   0.005723   0.010374          0          0          0          0          0
   0.014231   0.005723   0.010374          0          0          0          0
   0.020802   0.014231   0.005723   0.010374          0          0          0
   0.026938   0.020802   0.014231   0.005723   0.010374          0          0
   0.033475   0.026938   0.020802   0.014231   0.005723   0.010374          0
   0.040731   0.033475   0.026938   0.020802   0.014231   0.005723   0.010374
   0.048648   0.040731   0.033475   0.026938   0.020802   0.014231   0.005723
   0.056918   0.048648   0.040731   0.033475   0.026938   0.020802   0.014231
   0.065082   0.056918   0.048648   0.040731   0.033475   0.026938   0.020802
   0.072622   0.065082   0.056918   0.048648   0.040731   0.033475   0.026938
   0.079017   0.072622   0.065082   0.056918   0.048648   0.040731   0.033475
 Columns 8 through 12:
          0          0          0          0          0
          0          0          0          0          0
          0          0          0          0          0
          0          0          0          0          0
          0          0          0          0          0
          0          0          0          0          0
          0          0          0          0          0
   0.010374          0          0          0          0
   0.005723   0.010374          0          0          0
   0.014231   0.005723   0.010374          0          0
   0.020802   0.014231   0.005723   0.010374          0
   0.026938   0.020802   0.014231   0.005723   0.010374

ngABCDbf = 0.1221
est_nvABCDbf = 0.3058
ans = 0
nvbf = 0.3068
nvccbf = 0.3068
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
	static const WORD A_1_2 =     -6;
	static const WORD A_1_3 =    -11;
	static const WORD A_1_4 =    -18;
	static const WORD A_1_5 =    -17;
	static const WORD A_1_6 =    -23;
	static const WORD A_1_7 =      5;
	static const WORD A_1_8 =      3;
	static const WORD A_2_1 =     18;
	static const WORD A_2_2 =    -80;
	static const WORD A_2_3 =     16;
	static const WORD A_2_4 =    -21;
	static const WORD A_2_5 =     44;
	static const WORD A_2_6 =     16;
	static const WORD A_2_7 =     33;
	static const WORD A_2_8 =     -9;
	static const WORD A_3_1 =     10;
	static const WORD A_3_2 =     14;
	static const WORD A_3_3 =    -49;
	static const WORD A_3_4 =      7;
	static const WORD A_3_5 =     49;
	static const WORD A_3_6 =    -29;
	static const WORD A_3_7 =    -33;
	static const WORD A_3_8 =     30;
	static const WORD A_4_1 =      5;
	static const WORD A_4_2 =     11;
	static const WORD A_4_3 =      7;
	static const WORD A_4_4 =    -49;
	static const WORD A_4_5 =     23;
	static const WORD A_4_6 =     62;
	static const WORD A_4_7 =      6;
	static const WORD A_4_8 =     20;
	static const WORD A_5_1 =     -6;
	static const WORD A_5_2 =     -6;
	static const WORD A_5_3 =    -11;
	static const WORD A_5_4 =     47;
	static const WORD A_5_5 =     -9;
	static const WORD A_5_6 =    -13;
	static const WORD A_5_7 =      6;
	static const WORD A_5_8 =    -17;
	static const WORD A_6_1 =     -8;
	static const WORD A_6_2 =    -25;
	static const WORD A_6_3 =    -27;
	static const WORD A_6_4 =    -44;
	static const WORD A_6_5 =      8;
	static const WORD A_6_6 =    -75;
	static const WORD A_6_7 =     -1;
	static const WORD A_6_8 =     45;
	static const WORD A_7_1 =     25;
	static const WORD A_7_2 =    -52;
	static const WORD A_7_3 =     20;
	static const WORD A_7_4 =     28;
	static const WORD A_7_5 =     17;
	static const WORD A_7_6 =      7;
	static const WORD A_7_7 =    -75;
	static const WORD A_7_8 =     14;
	static const WORD A_8_1 =    -31;
	static const WORD A_8_2 =    -16;
	static const WORD A_8_3 =    -36;
	static const WORD A_8_4 =     28;
	static const WORD A_8_5 =      8;
	static const WORD A_8_6 =     -9;
	static const WORD A_8_7 =     17;
	static const WORD A_8_8 =    -65;
	static const WORD b_1_1 =      8;
	static const WORD b_1_2 =     -1;
	static const WORD b_1_3 =    -11;
	static const WORD b_1_4 =    -20;
	static const WORD b_1_5 =    -29;
	static const WORD b_1_6 =    -35;
	static const WORD b_1_7 =    -39;
	static const WORD b_1_8 =    -39;
	static const WORD b_1_9 =    -36;
	static const WORD b_1_10 =    -28;
	static const WORD b_1_11 =    -17;
	static const WORD b_1_12 =     -2;
	static const WORD b_2_1 =    -31;
	static const WORD b_2_2 =    -31;
	static const WORD b_2_3 =    -29;
	static const WORD b_2_4 =    -26;
	static const WORD b_2_5 =    -21;
	static const WORD b_2_6 =    -16;
	static const WORD b_2_7 =    -10;
	static const WORD b_2_8 =     -4;
	static const WORD b_2_9 =      2;
	static const WORD b_2_10 =      8;
	static const WORD b_2_11 =     14;
	static const WORD b_2_12 =     20;
	static const WORD b_3_1 =    -18;
	static const WORD b_3_2 =    -20;
	static const WORD b_3_3 =    -21;
	static const WORD b_3_4 =    -22;
	static const WORD b_3_5 =    -22;
	static const WORD b_3_6 =    -21;
	static const WORD b_3_7 =    -18;
	static const WORD b_3_8 =    -14;
	static const WORD b_3_9 =     -8;
	static const WORD b_3_10 =     -1;
	static const WORD b_3_11 =      8;
	static const WORD b_3_12 =     19;
	static const WORD b_4_1 =     -8;
	static const WORD b_4_2 =    -12;
	static const WORD b_4_3 =    -17;
	static const WORD b_4_4 =    -21;
	static const WORD b_4_5 =    -26;
	static const WORD b_4_6 =    -30;
	static const WORD b_4_7 =    -34;
	static const WORD b_4_8 =    -36;
	static const WORD b_4_9 =    -38;
	static const WORD b_4_10 =    -40;
	static const WORD b_4_11 =    -41;
	static const WORD b_4_12 =    -42;
	static const WORD b_5_1 =    -14;
	static const WORD b_5_2 =    -16;
	static const WORD b_5_3 =    -17;
	static const WORD b_5_4 =    -19;
	static const WORD b_5_5 =    -22;
	static const WORD b_5_6 =    -25;
	static const WORD b_5_7 =    -29;
	static const WORD b_5_8 =    -35;
	static const WORD b_5_9 =    -40;
	static const WORD b_5_10 =    -46;
	static const WORD b_5_11 =    -52;
	static const WORD b_5_12 =    -56;
	static const WORD b_6_1 =     24;
	static const WORD b_6_2 =     23;
	static const WORD b_6_3 =     20;
	static const WORD b_6_4 =     17;
	static const WORD b_6_5 =     13;
	static const WORD b_6_6 =      9;
	static const WORD b_6_7 =      4;
	static const WORD b_6_8 =     -2;
	static const WORD b_6_9 =     -7;
	static const WORD b_6_10 =    -14;
	static const WORD b_6_11 =    -21;
	static const WORD b_6_12 =    -30;
	static const WORD b_7_1 =    -12;
	static const WORD b_7_2 =     -8;
	static const WORD b_7_3 =     -4;
	static const WORD b_7_4 =     -1;
	static const WORD b_7_5 =      1;
	static const WORD b_7_6 =      2;
	static const WORD b_7_7 =      2;
	static const WORD b_7_8 =      2;
	static const WORD b_7_10 =     -3;
	static const WORD b_7_11 =     -6;
	static const WORD b_7_12 =    -10;
	static const WORD b_8_1 =    -32;
	static const WORD b_8_2 =    -36;
	static const WORD b_8_3 =    -37;
	static const WORD b_8_4 =    -35;
	static const WORD b_8_5 =    -31;
	static const WORD b_8_6 =    -24;
	static const WORD b_8_7 =    -16;
	static const WORD b_8_8 =     -7;
	static const WORD b_8_9 =      2;
	static const WORD b_8_10 =      9;
	static const WORD b_8_11 =     13;
	static const WORD b_8_12 =     13;
	static const WORD c_1_1 =     11;
	static const WORD c_1_2 =     -7;
	static const WORD c_1_3 =    -26;
	static const WORD c_1_4 =     -3;
	static const WORD c_1_5 =    -15;
	static const WORD c_1_6 =      9;
	static const WORD c_1_7 =     -9;
	static const WORD c_1_8 =     -1;
	static const WORD c_2_1 =      8;
	static const WORD c_2_2 =     -8;
	static const WORD c_2_3 =    -21;
	static const WORD c_2_4 =     -7;
	static const WORD c_2_5 =    -12;
	static const WORD c_2_6 =      7;
	static const WORD c_2_7 =    -13;
	static const WORD c_2_8 =     -5;
	static const WORD c_3_1 =      5;
	static const WORD c_3_2 =    -10;
	static const WORD c_3_3 =    -16;
	static const WORD c_3_4 =     -9;
	static const WORD c_3_5 =    -10;
	static const WORD c_3_6 =      6;
	static const WORD c_3_7 =    -15;
	static const WORD c_3_8 =     -8;
	static const WORD c_4_1 =      1;
	static const WORD c_4_2 =    -11;
	static const WORD c_4_3 =    -11;
	static const WORD c_4_4 =    -11;
	static const WORD c_4_5 =     -9;
	static const WORD c_4_6 =      6;
	static const WORD c_4_7 =    -16;
	static const WORD c_4_8 =     -9;
	static const WORD c_5_1 =     -3;
	static const WORD c_5_2 =    -13;
	static const WORD c_5_3 =     -6;
	static const WORD c_5_4 =    -13;
	static const WORD c_5_5 =     -9;
	static const WORD c_5_6 =      5;
	static const WORD c_5_7 =    -15;
	static const WORD c_5_8 =    -10;
	static const WORD c_6_1 =     -6;
	static const WORD c_6_2 =    -13;
	static const WORD c_6_3 =     -2;
	static const WORD c_6_4 =    -14;
	static const WORD c_6_5 =     -9;
	static const WORD c_6_6 =      5;
	static const WORD c_6_7 =    -12;
	static const WORD c_6_8 =    -10;
	static const WORD c_7_1 =     -9;
	static const WORD c_7_2 =    -13;
	static const WORD c_7_3 =      2;
	static const WORD c_7_4 =    -15;
	static const WORD c_7_5 =    -10;
	static const WORD c_7_6 =      5;
	static const WORD c_7_7 =     -9;
	static const WORD c_7_8 =     -9;
	static const WORD c_8_1 =    -11;
	static const WORD c_8_2 =    -12;
	static const WORD c_8_3 =      5;
	static const WORD c_8_4 =    -15;
	static const WORD c_8_5 =    -11;
	static const WORD c_8_6 =      4;
	static const WORD c_8_7 =     -5;
	static const WORD c_8_8 =     -8;
	static const WORD c_9_1 =    -12;
	static const WORD c_9_2 =    -10;
	static const WORD c_9_3 =      6;
	static const WORD c_9_4 =    -15;
	static const WORD c_9_5 =    -12;
	static const WORD c_9_6 =      3;
	static const WORD c_9_7 =     -1;
	static const WORD c_9_8 =     -7;
	static const WORD c_10_1 =    -13;
	static const WORD c_10_2 =     -7;
	static const WORD c_10_3 =      8;
	static const WORD c_10_4 =    -15;
	static const WORD c_10_5 =    -13;
	static const WORD c_10_6 =      2;
	static const WORD c_10_7 =      3;
	static const WORD c_10_8 =     -6;
	static const WORD c_11_1 =    -12;
	static const WORD c_11_2 =     -4;
	static const WORD c_11_3 =      8;
	static const WORD c_11_4 =    -14;
	static const WORD c_11_5 =    -14;
	static const WORD c_11_6 =      1;
	static const WORD c_11_7 =      6;
	static const WORD c_11_8 =     -4;
	static const WORD c_12_1 =    -11;
	static const WORD c_12_3 =      7;
	static const WORD c_12_4 =    -13;
	static const WORD c_12_5 =    -14;
	static const WORD c_12_6 =     -1;
	static const WORD c_12_7 =      8;
	static const WORD c_12_8 =     -3;
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
	mac += b_7_5*u[4];
	mac += b_7_6*u[5];
	mac += b_7_7*u[6];
	mac += b_7_8*u[7];
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
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

diff -Bb test.cc ellip8ABCD12.cc
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.cc"; fail; fi


#
# this much worked
#
pass
