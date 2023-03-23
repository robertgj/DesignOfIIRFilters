#!/bin/sh

prog=Abcd2cc_test.m

depends="test/Abcd2cc_test.m test_common.m \
Abcd2cc.m KW.m tf2Abcd.m optKW.m sv2block.m svf.m crossWelch.m \
p2n60.m qroots.m qzsolve.oct"

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
ngABCDoptf = 1.1994
est_nvABCDoptf = 0.4281
nvABCDoptf = 0.4447
Ab =
 Columns 1 through 6:
  -5.6776e-01  -8.7132e-02  -1.7779e-02  -1.1086e-01   1.4279e-01  -1.6543e-02
   9.5975e-03  -5.6301e-01   1.1645e-01  -3.8747e-01   5.6884e-02   1.5496e-01
   2.5370e-01  -2.2871e-01  -3.5271e-01   6.5396e-02   3.3437e-01   1.6669e-02
   2.5556e-01   7.7901e-02   2.4366e-01  -5.3591e-01  -5.0292e-02   4.5261e-01
  -5.6484e-02  -2.4487e-01   1.4976e-01   4.7299e-01  -3.9138e-01   2.2670e-01
  -2.1470e-01  -2.9773e-01  -1.6496e-01  -1.3690e-01   1.9710e-01  -3.4274e-01
  -1.1243e-01  -3.4017e-01   2.7141e-01  -1.9925e-02  -2.3327e-01   1.6680e-01
  -9.3197e-02   1.0799e-01  -1.3805e-01   2.0835e-01  -3.6581e-02   3.6634e-01
 Columns 7 and 8:
   2.1897e-01  -2.1040e-01
   1.1019e-02  -8.6927e-02
  -1.9831e-01   2.6478e-01
   7.2469e-02  -8.3616e-02
   1.3207e-01   1.0951e-02
  -3.5969e-02   1.6912e-01
  -5.4792e-01   1.5118e-01
   6.6927e-02  -3.3676e-01

Bb =
 Columns 1 through 6:
  -1.0429e-01  -1.6748e-01  -2.2270e-01  -2.6545e-01  -2.9184e-01  -2.9873e-01
  -6.2674e-02  -3.2156e-02   5.4856e-03   4.9242e-02   9.7383e-02   1.4740e-01
  -1.1532e-01  -1.3494e-01  -1.5572e-01  -1.7478e-01  -1.8897e-01  -1.9515e-01
   5.2620e-02   5.9874e-02   5.3719e-02   3.3268e-02  -9.9069e-04  -4.7122e-02
  -3.0573e-01  -2.6878e-01  -2.1834e-01  -1.5943e-01  -9.8071e-02  -4.0611e-02
   4.9124e-02   2.4463e-02  -4.6257e-03  -3.7467e-02  -7.3681e-02  -1.1327e-01
  -1.4830e-01  -1.4008e-01  -1.3074e-01  -1.2147e-01  -1.1297e-01  -1.0536e-01
  -2.4114e-01  -2.7605e-01  -2.9763e-01  -3.0415e-01  -2.9513e-01  -2.7168e-01
 Columns 7 through 12:
  -2.8393e-01  -2.4627e-01  -1.8562e-01  -1.0285e-01   2.0827e-04   1.2092e-01
   1.9603e-01   2.3936e-01   2.7304e-01   2.9259e-01   2.9378e-01   2.7311e-01
  -1.9044e-01  -1.7233e-01  -1.3878e-01  -8.8097e-02  -1.8721e-02   7.1186e-02
  -1.0179e-01  -1.6042e-01  -2.1738e-01  -2.6631e-01  -3.0044e-01  -3.1288e-01
   6.9621e-03   3.9823e-02   5.5109e-02   5.2665e-02   3.5670e-02   1.1099e-02
  -1.5662e-01  -2.0450e-01  -2.5785e-01  -3.1768e-01  -3.8473e-01  -4.5929e-01
  -9.8206e-02  -9.0661e-02  -8.1648e-02  -7.0163e-02  -5.5579e-02  -3.7943e-02
  -2.3656e-01  -1.9432e-01  -1.5114e-01  -1.1461e-01  -9.3309e-02  -9.6158e-02

Cb =
 Columns 1 through 6:
   3.6284e-02  -3.8132e-02  -2.0116e-01  -5.5648e-02  -1.5804e-01  -1.0552e-02
   2.6554e-02  -3.7212e-02  -1.5920e-01  -4.6181e-02  -1.3253e-01  -1.9685e-02
   6.3959e-03  -3.0195e-02  -1.1818e-01  -4.0975e-02  -1.1084e-01  -2.4257e-02
  -1.9760e-02  -1.7888e-02  -7.9358e-02  -3.9642e-02  -9.2871e-02  -2.7019e-02
  -4.7793e-02  -1.4223e-03  -4.4166e-02  -4.1336e-02  -7.8049e-02  -2.9815e-02
  -7.4099e-02   1.7874e-02  -1.3986e-02  -4.4965e-02  -6.5536e-02  -3.3732e-02
  -9.5749e-02   3.8571e-02   1.0044e-02  -4.9390e-02  -5.4407e-02  -3.9254e-02
  -1.1060e-01   5.9226e-02   2.7181e-02  -5.3574e-02  -4.3812e-02  -4.6408e-02
  -1.1735e-01   7.8446e-02   3.7181e-02  -5.6694e-02  -3.3100e-02  -5.4886e-02
  -1.1554e-01   9.4957e-02   4.0340e-02  -5.8202e-02  -2.1908e-02  -6.4155e-02
  -1.0547e-01   1.0765e-01   3.7469e-02  -5.7845e-02  -1.0193e-02  -7.3549e-02
  -8.8154e-02   1.1566e-01   2.9817e-02  -5.5648e-02   1.7786e-03  -8.2337e-02
 Columns 7 and 8:
  -5.9588e-02  -3.4370e-02
  -9.8099e-02  -7.0461e-02
  -1.2590e-01  -9.5467e-02
  -1.4139e-01  -1.1143e-01
  -1.4417e-01  -1.2017e-01
  -1.3504e-01  -1.2320e-01
  -1.1578e-01  -1.2174e-01
  -8.8937e-02  -1.1665e-01
  -5.7545e-02  -1.0855e-01
  -2.4798e-02  -9.7896e-02
   6.2481e-03  -8.5005e-02
   3.2940e-02  -7.0205e-02

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
nvbf = 0.3075
nvccbf = 0.3075
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
	static const WORD A_1_1 =    -73;
	static const WORD A_1_2 =    -11;
	static const WORD A_1_3 =     -2;
	static const WORD A_1_4 =    -14;
	static const WORD A_1_5 =     18;
	static const WORD A_1_6 =     -2;
	static const WORD A_1_7 =     28;
	static const WORD A_1_8 =    -27;
	static const WORD A_2_1 =      1;
	static const WORD A_2_2 =    -72;
	static const WORD A_2_3 =     15;
	static const WORD A_2_4 =    -50;
	static const WORD A_2_5 =      7;
	static const WORD A_2_6 =     20;
	static const WORD A_2_7 =      1;
	static const WORD A_2_8 =    -11;
	static const WORD A_3_1 =     32;
	static const WORD A_3_2 =    -29;
	static const WORD A_3_3 =    -45;
	static const WORD A_3_4 =      8;
	static const WORD A_3_5 =     43;
	static const WORD A_3_6 =      2;
	static const WORD A_3_7 =    -25;
	static const WORD A_3_8 =     34;
	static const WORD A_4_1 =     33;
	static const WORD A_4_2 =     10;
	static const WORD A_4_3 =     31;
	static const WORD A_4_4 =    -69;
	static const WORD A_4_5 =     -6;
	static const WORD A_4_6 =     58;
	static const WORD A_4_7 =      9;
	static const WORD A_4_8 =    -11;
	static const WORD A_5_1 =     -7;
	static const WORD A_5_2 =    -31;
	static const WORD A_5_3 =     19;
	static const WORD A_5_4 =     61;
	static const WORD A_5_5 =    -50;
	static const WORD A_5_6 =     29;
	static const WORD A_5_7 =     17;
	static const WORD A_5_8 =      1;
	static const WORD A_6_1 =    -27;
	static const WORD A_6_2 =    -38;
	static const WORD A_6_3 =    -21;
	static const WORD A_6_4 =    -18;
	static const WORD A_6_5 =     25;
	static const WORD A_6_6 =    -44;
	static const WORD A_6_7 =     -5;
	static const WORD A_6_8 =     22;
	static const WORD A_7_1 =    -14;
	static const WORD A_7_2 =    -44;
	static const WORD A_7_3 =     35;
	static const WORD A_7_4 =     -3;
	static const WORD A_7_5 =    -30;
	static const WORD A_7_6 =     21;
	static const WORD A_7_7 =    -70;
	static const WORD A_7_8 =     19;
	static const WORD A_8_1 =    -12;
	static const WORD A_8_2 =     14;
	static const WORD A_8_3 =    -18;
	static const WORD A_8_4 =     27;
	static const WORD A_8_5 =     -5;
	static const WORD A_8_6 =     47;
	static const WORD A_8_7 =      9;
	static const WORD A_8_8 =    -43;
	static const WORD b_1_1 =    -13;
	static const WORD b_1_2 =    -21;
	static const WORD b_1_3 =    -29;
	static const WORD b_1_4 =    -34;
	static const WORD b_1_5 =    -37;
	static const WORD b_1_6 =    -38;
	static const WORD b_1_7 =    -36;
	static const WORD b_1_8 =    -32;
	static const WORD b_1_9 =    -24;
	static const WORD b_1_10 =    -13;
	static const WORD b_1_12 =     15;
	static const WORD b_2_1 =     -8;
	static const WORD b_2_2 =     -4;
	static const WORD b_2_3 =      1;
	static const WORD b_2_4 =      6;
	static const WORD b_2_5 =     12;
	static const WORD b_2_6 =     19;
	static const WORD b_2_7 =     25;
	static const WORD b_2_8 =     31;
	static const WORD b_2_9 =     35;
	static const WORD b_2_10 =     37;
	static const WORD b_2_11 =     38;
	static const WORD b_2_12 =     35;
	static const WORD b_3_1 =    -15;
	static const WORD b_3_2 =    -17;
	static const WORD b_3_3 =    -20;
	static const WORD b_3_4 =    -22;
	static const WORD b_3_5 =    -24;
	static const WORD b_3_6 =    -25;
	static const WORD b_3_7 =    -24;
	static const WORD b_3_8 =    -22;
	static const WORD b_3_9 =    -18;
	static const WORD b_3_10 =    -11;
	static const WORD b_3_11 =     -2;
	static const WORD b_3_12 =      9;
	static const WORD b_4_1 =      7;
	static const WORD b_4_2 =      8;
	static const WORD b_4_3 =      7;
	static const WORD b_4_4 =      4;
	static const WORD b_4_6 =     -6;
	static const WORD b_4_7 =    -13;
	static const WORD b_4_8 =    -21;
	static const WORD b_4_9 =    -28;
	static const WORD b_4_10 =    -34;
	static const WORD b_4_11 =    -38;
	static const WORD b_4_12 =    -40;
	static const WORD b_5_1 =    -39;
	static const WORD b_5_2 =    -34;
	static const WORD b_5_3 =    -28;
	static const WORD b_5_4 =    -20;
	static const WORD b_5_5 =    -13;
	static const WORD b_5_6 =     -5;
	static const WORD b_5_7 =      1;
	static const WORD b_5_8 =      5;
	static const WORD b_5_9 =      7;
	static const WORD b_5_10 =      7;
	static const WORD b_5_11 =      5;
	static const WORD b_5_12 =      1;
	static const WORD b_6_1 =      6;
	static const WORD b_6_2 =      3;
	static const WORD b_6_3 =     -1;
	static const WORD b_6_4 =     -5;
	static const WORD b_6_5 =     -9;
	static const WORD b_6_6 =    -14;
	static const WORD b_6_7 =    -20;
	static const WORD b_6_8 =    -26;
	static const WORD b_6_9 =    -33;
	static const WORD b_6_10 =    -41;
	static const WORD b_6_11 =    -49;
	static const WORD b_6_12 =    -59;
	static const WORD b_7_1 =    -19;
	static const WORD b_7_2 =    -18;
	static const WORD b_7_3 =    -17;
	static const WORD b_7_4 =    -16;
	static const WORD b_7_5 =    -14;
	static const WORD b_7_6 =    -13;
	static const WORD b_7_7 =    -13;
	static const WORD b_7_8 =    -12;
	static const WORD b_7_9 =    -10;
	static const WORD b_7_10 =     -9;
	static const WORD b_7_11 =     -7;
	static const WORD b_7_12 =     -5;
	static const WORD b_8_1 =    -31;
	static const WORD b_8_2 =    -35;
	static const WORD b_8_3 =    -38;
	static const WORD b_8_4 =    -39;
	static const WORD b_8_5 =    -38;
	static const WORD b_8_6 =    -35;
	static const WORD b_8_7 =    -30;
	static const WORD b_8_8 =    -25;
	static const WORD b_8_9 =    -19;
	static const WORD b_8_10 =    -15;
	static const WORD b_8_11 =    -12;
	static const WORD b_8_12 =    -12;
	static const WORD c_1_1 =      5;
	static const WORD c_1_2 =     -5;
	static const WORD c_1_3 =    -26;
	static const WORD c_1_4 =     -7;
	static const WORD c_1_5 =    -20;
	static const WORD c_1_6 =     -1;
	static const WORD c_1_7 =     -8;
	static const WORD c_1_8 =     -4;
	static const WORD c_2_1 =      3;
	static const WORD c_2_2 =     -5;
	static const WORD c_2_3 =    -20;
	static const WORD c_2_4 =     -6;
	static const WORD c_2_5 =    -17;
	static const WORD c_2_6 =     -3;
	static const WORD c_2_7 =    -13;
	static const WORD c_2_8 =     -9;
	static const WORD c_3_1 =      1;
	static const WORD c_3_2 =     -4;
	static const WORD c_3_3 =    -15;
	static const WORD c_3_4 =     -5;
	static const WORD c_3_5 =    -14;
	static const WORD c_3_6 =     -3;
	static const WORD c_3_7 =    -16;
	static const WORD c_3_8 =    -12;
	static const WORD c_4_1 =     -3;
	static const WORD c_4_2 =     -2;
	static const WORD c_4_3 =    -10;
	static const WORD c_4_4 =     -5;
	static const WORD c_4_5 =    -12;
	static const WORD c_4_6 =     -3;
	static const WORD c_4_7 =    -18;
	static const WORD c_4_8 =    -14;
	static const WORD c_5_1 =     -6;
	static const WORD c_5_3 =     -6;
	static const WORD c_5_4 =     -5;
	static const WORD c_5_5 =    -10;
	static const WORD c_5_6 =     -4;
	static const WORD c_5_7 =    -18;
	static const WORD c_5_8 =    -15;
	static const WORD c_6_1 =     -9;
	static const WORD c_6_2 =      2;
	static const WORD c_6_3 =     -2;
	static const WORD c_6_4 =     -6;
	static const WORD c_6_5 =     -8;
	static const WORD c_6_6 =     -4;
	static const WORD c_6_7 =    -17;
	static const WORD c_6_8 =    -16;
	static const WORD c_7_1 =    -12;
	static const WORD c_7_2 =      5;
	static const WORD c_7_3 =      1;
	static const WORD c_7_4 =     -6;
	static const WORD c_7_5 =     -7;
	static const WORD c_7_6 =     -5;
	static const WORD c_7_7 =    -15;
	static const WORD c_7_8 =    -16;
	static const WORD c_8_1 =    -14;
	static const WORD c_8_2 =      8;
	static const WORD c_8_3 =      3;
	static const WORD c_8_4 =     -7;
	static const WORD c_8_5 =     -6;
	static const WORD c_8_6 =     -6;
	static const WORD c_8_7 =    -11;
	static const WORD c_8_8 =    -15;
	static const WORD c_9_1 =    -15;
	static const WORD c_9_2 =     10;
	static const WORD c_9_3 =      5;
	static const WORD c_9_4 =     -7;
	static const WORD c_9_5 =     -4;
	static const WORD c_9_6 =     -7;
	static const WORD c_9_7 =     -7;
	static const WORD c_9_8 =    -14;
	static const WORD c_10_1 =    -15;
	static const WORD c_10_2 =     12;
	static const WORD c_10_3 =      5;
	static const WORD c_10_4 =     -7;
	static const WORD c_10_5 =     -3;
	static const WORD c_10_6 =     -8;
	static const WORD c_10_7 =     -3;
	static const WORD c_10_8 =    -13;
	static const WORD c_11_1 =    -14;
	static const WORD c_11_2 =     14;
	static const WORD c_11_3 =      5;
	static const WORD c_11_4 =     -7;
	static const WORD c_11_5 =     -1;
	static const WORD c_11_6 =     -9;
	static const WORD c_11_7 =      1;
	static const WORD c_11_8 =    -11;
	static const WORD c_12_1 =    -11;
	static const WORD c_12_2 =     15;
	static const WORD c_12_3 =      4;
	static const WORD c_12_4 =     -7;
	static const WORD c_12_6 =    -11;
	static const WORD c_12_7 =      4;
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
	mac += c_12_2*ellip8ABCD12_x_2;
	mac += c_12_3*ellip8ABCD12_x_3;
	mac += c_12_4*ellip8ABCD12_x_4;
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
