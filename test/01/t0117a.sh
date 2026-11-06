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

ngABCDopt = 1.4613
ngABCDoptf = 1.5200
est_nvABCDoptf = 0.4583
nvABCDoptf = 0.4480
Ab =
 Columns 1 through 6:
  -4.9338e-01  -5.0408e-02  -8.3501e-02  -1.1168e-01  -8.4596e-02  -2.0373e-01
   1.3003e-01  -6.2391e-01   1.2787e-01  -7.1448e-02   3.0035e-01   2.0328e-01
   6.9162e-02   1.2079e-01  -3.8884e-01  -1.2116e-01   4.2066e-01  -1.1526e-01
   1.9292e-01   1.7069e-01   2.4025e-01  -6.2810e-01  -2.4523e-02   4.1866e-01
  -2.4269e-02  -7.6484e-03  -1.7042e-02   4.8879e-01  -1.0643e-01   5.2294e-02
  -7.3118e-02  -1.9607e-01  -2.1769e-01  -3.6294e-01   2.1541e-01  -5.4581e-01
   1.9052e-01  -4.0165e-01   1.8723e-01   6.6701e-02   1.0272e-01   8.2450e-02
  -1.3308e-01  -4.3298e-02  -1.6081e-01   1.0290e-01   7.5578e-02   3.3215e-01
 Columns 7 and 8:
   5.3679e-02  -8.5220e-02
   2.5075e-01  -1.5007e-01
  -2.7226e-01   1.9812e-01
  -5.6078e-02   2.1952e-02
   4.6157e-02   1.5350e-01
  -4.6331e-04   6.9010e-02
  -5.9678e-01   2.2543e-01
   1.1196e-01  -2.5492e-01

Bb =
 Columns 1 through 6:
   6.9624e-02  -2.4240e-03  -7.8219e-02  -1.5201e-01  -2.1753e-01  -2.6840e-01
  -2.5333e-01  -2.5322e-01  -2.3943e-01  -2.1297e-01  -1.7574e-01  -1.3032e-01
  -1.2794e-01  -1.4293e-01  -1.5713e-01  -1.6771e-01  -1.7177e-01  -1.6662e-01
   1.2003e-01   1.1752e-01   9.9124e-02   6.5254e-02   1.7848e-02  -3.9700e-02
  -1.6752e-01  -1.7317e-01  -1.7791e-01  -1.8383e-01  -1.9298e-01  -2.0702e-01
   1.4678e-01   1.3172e-01   1.0893e-01   7.9208e-02   4.3356e-02   2.0292e-03
  -9.0068e-02  -5.7473e-02  -2.7309e-02  -2.3806e-03   1.5224e-02   2.4285e-02
  -2.2228e-01  -2.6570e-01  -2.9663e-01  -3.1276e-01  -3.1311e-01  -2.9834e-01
 Columns 7 through 12:
  -2.9861e-01  -3.0298e-01  -2.7778e-01  -2.2120e-01  -1.3388e-01  -1.9342e-02
  -7.9644e-02  -2.6650e-02   2.6136e-02   7.7001e-02   1.2542e-01   1.7235e-01
  -1.5004e-01  -1.2040e-01  -7.6715e-02  -1.8441e-02   5.4793e-02   1.4368e-01
  -1.0275e-01  -1.6575e-01  -2.2265e-01  -2.6731e-01  -2.9401e-01  -2.9782e-01
  -2.2685e-01  -2.5216e-01  -2.8110e-01  -3.0991e-01  -3.3277e-01  -3.4166e-01
  -4.4350e-02  -9.5637e-02  -1.5195e-01  -2.1363e-01  -2.8110e-01  -3.5481e-01
   2.4485e-02   1.6321e-02   9.0131e-04  -2.0338e-02  -4.5964e-02  -7.4867e-02
  -2.7098e-01  -2.3550e-01  -1.9825e-01  -1.6720e-01  -1.5153e-01  -1.6093e-01

Cb =
 Columns 1 through 6:
   9.5875e-02  -6.3737e-02  -2.0005e-01  -1.5314e-02  -1.2882e-01   2.8743e-02
   7.0842e-02  -7.0127e-02  -1.6032e-01  -1.2654e-02  -1.0775e-01   2.2237e-02
   4.0470e-02  -8.0328e-02  -1.2037e-01  -1.3391e-02  -9.2345e-02   1.9588e-02
   8.4196e-03  -9.1016e-02  -8.1399e-02  -1.7049e-02  -8.2967e-02   1.8464e-02
  -2.2329e-02  -9.9274e-02  -4.4861e-02  -2.2830e-02  -7.9164e-02   1.7202e-02
  -4.9528e-02  -1.0280e-01  -1.2265e-02  -2.9791e-02  -7.9926e-02   1.4701e-02
  -7.1645e-02  -1.0006e-01   1.5044e-02  -3.6986e-02  -8.3909e-02   1.0325e-02
  -8.7802e-02  -9.0360e-02   3.6058e-02  -4.3581e-02  -8.9626e-02   3.8147e-03
  -9.7676e-02  -7.3880e-02   5.0223e-02  -4.8926e-02  -9.5616e-02  -4.7869e-03
  -1.0139e-01  -5.1578e-02   5.7498e-02  -5.2599e-02  -1.0056e-01  -1.5195e-02
  -9.9404e-02  -2.5070e-02   5.8356e-02  -5.4409e-02  -1.0339e-01  -2.6933e-02
  -9.2405e-02   3.5605e-03   5.3728e-02  -5.4376e-02  -1.0333e-01  -3.9371e-02
 Columns 7 and 8:
  -6.8351e-02  -2.3690e-02
  -9.9323e-02  -6.5830e-02
  -1.1658e-01  -9.5738e-02
  -1.2029e-01  -1.1560e-01
  -1.1167e-01  -1.2735e-01
  -9.2816e-02  -1.3260e-01
  -6.6499e-02  -1.3265e-01
  -3.5907e-02  -1.2848e-01
  -4.3417e-03  -1.2084e-01
   2.5063e-02  -1.1030e-01
   4.9606e-02  -9.7308e-02
   6.7232e-02  -8.2297e-02

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

ngABCDbf = 0.1218
est_nvABCDbf = 0.3057
ans = 0
nvbf = 0.3056
nvccbf = 0.3056
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
	static const WORD A_1_4 =    -14;
	static const WORD A_1_5 =    -11;
	static const WORD A_1_6 =    -26;
	static const WORD A_1_7 =      7;
	static const WORD A_1_8 =    -11;
	static const WORD A_2_1 =     17;
	static const WORD A_2_2 =    -80;
	static const WORD A_2_3 =     16;
	static const WORD A_2_4 =     -9;
	static const WORD A_2_5 =     38;
	static const WORD A_2_6 =     26;
	static const WORD A_2_7 =     32;
	static const WORD A_2_8 =    -19;
	static const WORD A_3_1 =      9;
	static const WORD A_3_2 =     15;
	static const WORD A_3_3 =    -50;
	static const WORD A_3_4 =    -16;
	static const WORD A_3_5 =     54;
	static const WORD A_3_6 =    -15;
	static const WORD A_3_7 =    -35;
	static const WORD A_3_8 =     25;
	static const WORD A_4_1 =     25;
	static const WORD A_4_2 =     22;
	static const WORD A_4_3 =     31;
	static const WORD A_4_4 =    -80;
	static const WORD A_4_5 =     -3;
	static const WORD A_4_6 =     54;
	static const WORD A_4_7 =     -7;
	static const WORD A_4_8 =      3;
	static const WORD A_5_1 =     -3;
	static const WORD A_5_2 =     -1;
	static const WORD A_5_3 =     -2;
	static const WORD A_5_4 =     63;
	static const WORD A_5_5 =    -14;
	static const WORD A_5_6 =      7;
	static const WORD A_5_7 =      6;
	static const WORD A_5_8 =     20;
	static const WORD A_6_1 =     -9;
	static const WORD A_6_2 =    -25;
	static const WORD A_6_3 =    -28;
	static const WORD A_6_4 =    -46;
	static const WORD A_6_5 =     28;
	static const WORD A_6_6 =    -70;
	static const WORD A_6_8 =      9;
	static const WORD A_7_1 =     24;
	static const WORD A_7_2 =    -51;
	static const WORD A_7_3 =     24;
	static const WORD A_7_4 =      9;
	static const WORD A_7_5 =     13;
	static const WORD A_7_6 =     11;
	static const WORD A_7_7 =    -76;
	static const WORD A_7_8 =     29;
	static const WORD A_8_1 =    -17;
	static const WORD A_8_2 =     -6;
	static const WORD A_8_3 =    -21;
	static const WORD A_8_4 =     13;
	static const WORD A_8_5 =     10;
	static const WORD A_8_6 =     43;
	static const WORD A_8_7 =     14;
	static const WORD A_8_8 =    -33;
	static const WORD b_1_1 =      9;
	static const WORD b_1_3 =    -10;
	static const WORD b_1_4 =    -19;
	static const WORD b_1_5 =    -28;
	static const WORD b_1_6 =    -34;
	static const WORD b_1_7 =    -38;
	static const WORD b_1_8 =    -39;
	static const WORD b_1_9 =    -36;
	static const WORD b_1_10 =    -28;
	static const WORD b_1_11 =    -17;
	static const WORD b_1_12 =     -2;
	static const WORD b_2_1 =    -32;
	static const WORD b_2_2 =    -32;
	static const WORD b_2_3 =    -31;
	static const WORD b_2_4 =    -27;
	static const WORD b_2_5 =    -22;
	static const WORD b_2_6 =    -17;
	static const WORD b_2_7 =    -10;
	static const WORD b_2_8 =     -3;
	static const WORD b_2_9 =      3;
	static const WORD b_2_10 =     10;
	static const WORD b_2_11 =     16;
	static const WORD b_2_12 =     22;
	static const WORD b_3_1 =    -16;
	static const WORD b_3_2 =    -18;
	static const WORD b_3_3 =    -20;
	static const WORD b_3_4 =    -21;
	static const WORD b_3_5 =    -22;
	static const WORD b_3_6 =    -21;
	static const WORD b_3_7 =    -19;
	static const WORD b_3_8 =    -15;
	static const WORD b_3_9 =    -10;
	static const WORD b_3_10 =     -2;
	static const WORD b_3_11 =      7;
	static const WORD b_3_12 =     18;
	static const WORD b_4_1 =     15;
	static const WORD b_4_2 =     15;
	static const WORD b_4_3 =     13;
	static const WORD b_4_4 =      8;
	static const WORD b_4_5 =      2;
	static const WORD b_4_6 =     -5;
	static const WORD b_4_7 =    -13;
	static const WORD b_4_8 =    -21;
	static const WORD b_4_9 =    -28;
	static const WORD b_4_10 =    -34;
	static const WORD b_4_11 =    -38;
	static const WORD b_4_12 =    -38;
	static const WORD b_5_1 =    -21;
	static const WORD b_5_2 =    -22;
	static const WORD b_5_3 =    -23;
	static const WORD b_5_4 =    -24;
	static const WORD b_5_5 =    -25;
	static const WORD b_5_6 =    -26;
	static const WORD b_5_7 =    -29;
	static const WORD b_5_8 =    -32;
	static const WORD b_5_9 =    -36;
	static const WORD b_5_10 =    -40;
	static const WORD b_5_11 =    -43;
	static const WORD b_5_12 =    -44;
	static const WORD b_6_1 =     19;
	static const WORD b_6_2 =     17;
	static const WORD b_6_3 =     14;
	static const WORD b_6_4 =     10;
	static const WORD b_6_5 =      6;
	static const WORD b_6_7 =     -6;
	static const WORD b_6_8 =    -12;
	static const WORD b_6_9 =    -19;
	static const WORD b_6_10 =    -27;
	static const WORD b_6_11 =    -36;
	static const WORD b_6_12 =    -45;
	static const WORD b_7_1 =    -12;
	static const WORD b_7_2 =     -7;
	static const WORD b_7_3 =     -3;
	static const WORD b_7_5 =      2;
	static const WORD b_7_6 =      3;
	static const WORD b_7_7 =      3;
	static const WORD b_7_8 =      2;
	static const WORD b_7_10 =     -3;
	static const WORD b_7_11 =     -6;
	static const WORD b_7_12 =    -10;
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
	static const WORD b_8_11 =    -19;
	static const WORD b_8_12 =    -21;
	static const WORD c_1_1 =     12;
	static const WORD c_1_2 =     -8;
	static const WORD c_1_3 =    -26;
	static const WORD c_1_4 =     -2;
	static const WORD c_1_5 =    -16;
	static const WORD c_1_6 =      4;
	static const WORD c_1_7 =     -9;
	static const WORD c_1_8 =     -3;
	static const WORD c_2_1 =      9;
	static const WORD c_2_2 =     -9;
	static const WORD c_2_3 =    -21;
	static const WORD c_2_4 =     -2;
	static const WORD c_2_5 =    -14;
	static const WORD c_2_6 =      3;
	static const WORD c_2_7 =    -13;
	static const WORD c_2_8 =     -8;
	static const WORD c_3_1 =      5;
	static const WORD c_3_2 =    -10;
	static const WORD c_3_3 =    -15;
	static const WORD c_3_4 =     -2;
	static const WORD c_3_5 =    -12;
	static const WORD c_3_6 =      3;
	static const WORD c_3_7 =    -15;
	static const WORD c_3_8 =    -12;
	static const WORD c_4_1 =      1;
	static const WORD c_4_2 =    -12;
	static const WORD c_4_3 =    -10;
	static const WORD c_4_4 =     -2;
	static const WORD c_4_5 =    -11;
	static const WORD c_4_6 =      2;
	static const WORD c_4_7 =    -15;
	static const WORD c_4_8 =    -15;
	static const WORD c_5_1 =     -3;
	static const WORD c_5_2 =    -13;
	static const WORD c_5_3 =     -6;
	static const WORD c_5_4 =     -3;
	static const WORD c_5_5 =    -10;
	static const WORD c_5_6 =      2;
	static const WORD c_5_7 =    -14;
	static const WORD c_5_8 =    -16;
	static const WORD c_6_1 =     -6;
	static const WORD c_6_2 =    -13;
	static const WORD c_6_3 =     -2;
	static const WORD c_6_4 =     -4;
	static const WORD c_6_5 =    -10;
	static const WORD c_6_6 =      2;
	static const WORD c_6_7 =    -12;
	static const WORD c_6_8 =    -17;
	static const WORD c_7_1 =     -9;
	static const WORD c_7_2 =    -13;
	static const WORD c_7_3 =      2;
	static const WORD c_7_4 =     -5;
	static const WORD c_7_5 =    -11;
	static const WORD c_7_6 =      1;
	static const WORD c_7_7 =     -9;
	static const WORD c_7_8 =    -17;
	static const WORD c_8_1 =    -11;
	static const WORD c_8_2 =    -12;
	static const WORD c_8_3 =      5;
	static const WORD c_8_4 =     -6;
	static const WORD c_8_5 =    -11;
	static const WORD c_8_7 =     -5;
	static const WORD c_8_8 =    -16;
	static const WORD c_9_1 =    -13;
	static const WORD c_9_2 =     -9;
	static const WORD c_9_3 =      6;
	static const WORD c_9_4 =     -6;
	static const WORD c_9_5 =    -12;
	static const WORD c_9_6 =     -1;
	static const WORD c_9_7 =     -1;
	static const WORD c_9_8 =    -15;
	static const WORD c_10_1 =    -13;
	static const WORD c_10_2 =     -7;
	static const WORD c_10_3 =      7;
	static const WORD c_10_4 =     -7;
	static const WORD c_10_5 =    -13;
	static const WORD c_10_6 =     -2;
	static const WORD c_10_7 =      3;
	static const WORD c_10_8 =    -14;
	static const WORD c_11_1 =    -13;
	static const WORD c_11_2 =     -3;
	static const WORD c_11_3 =      7;
	static const WORD c_11_4 =     -7;
	static const WORD c_11_5 =    -13;
	static const WORD c_11_6 =     -3;
	static const WORD c_11_7 =      6;
	static const WORD c_11_8 =    -12;
	static const WORD c_12_1 =    -12;
	static const WORD c_12_3 =      7;
	static const WORD c_12_4 =     -7;
	static const WORD c_12_5 =    -13;
	static const WORD c_12_6 =     -5;
	static const WORD c_12_7 =      9;
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
	mac += A_6_8*x_8_tmp;
	mac += b_6_1*u[0];
	mac += b_6_2*u[1];
	mac += b_6_3*u[2];
	mac += b_6_4*u[3];
	mac += b_6_5*u[4];
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
