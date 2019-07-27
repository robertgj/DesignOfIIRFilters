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

   1.0374e-02  -6.9387e-02   2.1331e-01  -3.9420e-01   4.7983e-01  -3.9420e-01

 Columns 7 through 9:

   2.1331e-01  -6.9387e-02   1.0374e-02

d =

 Columns 1 through 6:

   1.0000e+00  -7.2403e+00   2.3185e+01  -4.2863e+01   5.0014e+01  -3.7707e+01

 Columns 7 through 9:

   1.7932e+01  -4.9177e+00   5.9536e-01

ngABCDopt =    1.4657e+00
ngABCDoptf =    1.8223e+00
est_nvABCDoptf =    4.8497e-01
nvABCDoptf =    4.5047e-01
Ab =

 Columns 1 through 6:

  -5.3517e-01  -2.0388e-01   6.9798e-02  -1.2387e-01   5.4265e-03   3.9617e-02
   9.1596e-03  -5.6591e-01   1.1350e-01  -3.9018e-01  -5.2236e-02   1.5249e-01
   1.5552e-01  -2.3014e-01  -3.5164e-01  -3.8697e-02   3.4165e-01   2.2622e-02
   2.5011e-01   1.3489e-01   2.0699e-01  -6.3381e-01  -1.1766e-01   3.7062e-01
   6.0484e-02  -2.2196e-01   2.0731e-01   4.0604e-01  -2.9051e-01   3.3734e-01
  -2.0459e-01  -2.9632e-01  -1.7802e-01  -1.8708e-01   1.5507e-01  -3.4182e-01
  -1.2134e-01  -2.9120e-01   2.5057e-01   8.7098e-02  -2.4969e-01   1.6787e-01
  -5.9100e-02   1.0963e-01  -1.3791e-01   2.0738e-01   1.4761e-02   3.6775e-01

 Columns 7 and 8:

   2.1858e-01  -1.5044e-01
   1.6288e-02  -9.7904e-02
  -2.7232e-01   2.5950e-01
  -5.9336e-02  -8.1918e-02
   1.3616e-01  -9.9744e-03
   4.7812e-02   1.6239e-01
  -5.8677e-01   2.1886e-01
   1.0020e-01  -3.3254e-01

Bb =

 Columns 1 through 6:

  -1.4432e-01  -1.9996e-01  -2.4790e-01  -2.8446e-01  -3.0628e-01  -3.1052e-01
  -6.0941e-02  -3.0064e-02   7.9721e-03   5.2091e-02   1.0049e-01   1.5061e-01
  -1.1784e-01  -1.3872e-01  -1.6053e-01  -1.8026e-01  -1.9466e-01  -2.0051e-01
   1.3279e-01   1.3032e-01   1.1130e-01   7.6183e-02   2.7013e-02  -3.2671e-02
  -2.8337e-01  -2.4667e-01  -2.0039e-01  -1.4956e-01  -9.9766e-02  -5.6566e-02
   4.9688e-02   2.5276e-02  -3.5973e-03  -3.6274e-02  -7.2389e-02  -1.1195e-01
  -1.0074e-01  -6.9963e-02  -4.1047e-02  -1.6739e-02   8.7596e-04   1.0519e-02
  -2.4021e-01  -2.7536e-01  -2.9727e-01  -3.0417e-01  -2.9557e-01  -2.7254e-01

 Columns 7 through 12:

  -2.9502e-01  -2.5839e-01  -2.0013e-01  -1.2074e-01  -2.1739e-02   9.4287e-02
   1.9912e-01   2.4209e-01   2.7517e-01   2.9391e-01   2.9415e-01   2.7242e-01
  -1.9486e-01  -1.7522e-01  -1.3958e-01  -8.6355e-02  -1.4121e-02   7.8764e-02
  -9.8061e-02  -1.6343e-01  -2.2256e-01  -2.6921e-01  -2.9763e-01  -3.0295e-01
  -2.4794e-02  -7.8359e-03  -6.9221e-03  -2.0485e-02  -4.3636e-02  -6.7814e-02
  -1.5536e-01  -2.0334e-01  -2.5682e-01  -3.1673e-01  -3.8373e-01  -4.5797e-01
   1.1755e-02   4.9078e-03  -9.1293e-03  -2.9161e-02  -5.3999e-02  -8.2760e-02
  -2.3781e-01  -1.9588e-01  -1.5293e-01  -1.1651e-01  -9.5187e-02  -9.7881e-02

Cb =

 Columns 1 through 6:

   1.9486e-02  -3.4527e-02  -2.0020e-01  -1.0826e-02  -1.6791e-01  -1.1382e-02
  -5.2325e-03  -3.4034e-02  -1.5891e-01  -8.2695e-03  -1.4075e-01  -1.9856e-02
  -3.5622e-02  -2.7599e-02  -1.1865e-01  -8.9580e-03  -1.1852e-01  -2.3895e-02
  -6.6938e-02  -1.5981e-02  -8.0550e-02  -1.2513e-02  -1.0097e-01  -2.6274e-02
  -9.5180e-02  -2.5077e-04  -4.5946e-02  -1.8233e-02  -8.7263e-02  -2.8843e-02
  -1.1726e-01   1.8324e-02  -1.6148e-02  -2.5253e-02  -7.6278e-02  -3.2682e-02
  -1.3111e-01   3.8374e-02   7.7457e-03  -3.2688e-02  -6.6792e-02  -3.8259e-02
  -1.3566e-01   5.8502e-02   2.5002e-02  -3.9737e-02  -5.7696e-02  -4.5573e-02
  -1.3083e-01   7.7354e-02   3.5360e-02  -4.5757e-02  -4.8141e-02  -5.4285e-02
  -1.1737e-01   9.3672e-02   3.9075e-02  -5.0303e-02  -3.7632e-02  -6.3828e-02
  -9.6720e-02   1.0636e-01   3.6904e-02  -5.3136e-02  -2.6065e-02  -7.3504e-02
  -7.0810e-02   1.1451e-01   3.0030e-02  -5.4209e-02  -1.3713e-02  -8.2554e-02

 Columns 7 and 8:

  -7.0263e-02  -3.4385e-02
  -1.0248e-01  -7.0374e-02
  -1.2079e-01  -9.5350e-02
  -1.2538e-01  -1.1136e-01
  -1.1744e-01  -1.2021e-01
  -9.9053e-02  -1.2341e-01
  -7.2977e-02  -1.2212e-01
  -4.2390e-02  -1.1721e-01
  -1.0596e-02  -1.0927e-01
   1.9259e-02  -9.8730e-02
   4.4449e-02  -8.5901e-02
   6.2879e-02  -7.1106e-02

Db =

 Columns 1 through 6:

   1.0374e-02   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   5.7230e-03   1.0374e-02   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   1.4231e-02   5.7230e-03   1.0374e-02   0.0000e+00   0.0000e+00   0.0000e+00
   2.0802e-02   1.4231e-02   5.7230e-03   1.0374e-02   0.0000e+00   0.0000e+00
   2.6938e-02   2.0802e-02   1.4231e-02   5.7230e-03   1.0374e-02   0.0000e+00
   3.3475e-02   2.6938e-02   2.0802e-02   1.4231e-02   5.7230e-03   1.0374e-02
   4.0731e-02   3.3475e-02   2.6938e-02   2.0802e-02   1.4231e-02   5.7230e-03
   4.8648e-02   4.0731e-02   3.3475e-02   2.6938e-02   2.0802e-02   1.4231e-02
   5.6918e-02   4.8648e-02   4.0731e-02   3.3475e-02   2.6938e-02   2.0802e-02
   6.5082e-02   5.6918e-02   4.8648e-02   4.0731e-02   3.3475e-02   2.6938e-02
   7.2622e-02   6.5082e-02   5.6918e-02   4.8648e-02   4.0731e-02   3.3475e-02
   7.9017e-02   7.2622e-02   6.5082e-02   5.6918e-02   4.8648e-02   4.0731e-02

 Columns 7 through 12:

   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   1.0374e-02   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   5.7230e-03   1.0374e-02   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   1.4231e-02   5.7230e-03   1.0374e-02   0.0000e+00   0.0000e+00   0.0000e+00
   2.0802e-02   1.4231e-02   5.7230e-03   1.0374e-02   0.0000e+00   0.0000e+00
   2.6938e-02   2.0802e-02   1.4231e-02   5.7230e-03   1.0374e-02   0.0000e+00
   3.3475e-02   2.6938e-02   2.0802e-02   1.4231e-02   5.7230e-03   1.0374e-02

ngABCDbf =    1.2214e-01
est_nvABCDbf =    3.0580e-01
nvbf =    3.0512e-01
nvccbf =    3.0512e-01
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
	static const WORD A_1_1 =    -69;
	static const WORD A_1_2 =    -26;
	static const WORD A_1_3 =      9;
	static const WORD A_1_4 =    -16;
	static const WORD A_1_5 =      1;
	static const WORD A_1_6 =      5;
	static const WORD A_1_7 =     28;
	static const WORD A_1_8 =    -19;
	static const WORD A_2_1 =      1;
	static const WORD A_2_2 =    -72;
	static const WORD A_2_3 =     15;
	static const WORD A_2_4 =    -50;
	static const WORD A_2_5 =     -7;
	static const WORD A_2_6 =     20;
	static const WORD A_2_7 =      2;
	static const WORD A_2_8 =    -13;
	static const WORD A_3_1 =     20;
	static const WORD A_3_2 =    -29;
	static const WORD A_3_3 =    -45;
	static const WORD A_3_4 =     -5;
	static const WORD A_3_5 =     44;
	static const WORD A_3_6 =      3;
	static const WORD A_3_7 =    -35;
	static const WORD A_3_8 =     33;
	static const WORD A_4_1 =     32;
	static const WORD A_4_2 =     17;
	static const WORD A_4_3 =     26;
	static const WORD A_4_4 =    -81;
	static const WORD A_4_5 =    -15;
	static const WORD A_4_6 =     47;
	static const WORD A_4_7 =     -8;
	static const WORD A_4_8 =    -10;
	static const WORD A_5_1 =      8;
	static const WORD A_5_2 =    -28;
	static const WORD A_5_3 =     27;
	static const WORD A_5_4 =     52;
	static const WORD A_5_5 =    -37;
	static const WORD A_5_6 =     43;
	static const WORD A_5_7 =     17;
	static const WORD A_5_8 =     -1;
	static const WORD A_6_1 =    -26;
	static const WORD A_6_2 =    -38;
	static const WORD A_6_3 =    -23;
	static const WORD A_6_4 =    -24;
	static const WORD A_6_5 =     20;
	static const WORD A_6_6 =    -44;
	static const WORD A_6_7 =      6;
	static const WORD A_6_8 =     21;
	static const WORD A_7_1 =    -16;
	static const WORD A_7_2 =    -37;
	static const WORD A_7_3 =     32;
	static const WORD A_7_4 =     11;
	static const WORD A_7_5 =    -32;
	static const WORD A_7_6 =     21;
	static const WORD A_7_7 =    -75;
	static const WORD A_7_8 =     28;
	static const WORD A_8_1 =     -8;
	static const WORD A_8_2 =     14;
	static const WORD A_8_3 =    -18;
	static const WORD A_8_4 =     27;
	static const WORD A_8_5 =      2;
	static const WORD A_8_6 =     47;
	static const WORD A_8_7 =     13;
	static const WORD A_8_8 =    -43;
	static const WORD b_1_1 =    -18;
	static const WORD b_1_2 =    -26;
	static const WORD b_1_3 =    -32;
	static const WORD b_1_4 =    -36;
	static const WORD b_1_5 =    -39;
	static const WORD b_1_6 =    -40;
	static const WORD b_1_7 =    -38;
	static const WORD b_1_8 =    -33;
	static const WORD b_1_9 =    -26;
	static const WORD b_1_10 =    -15;
	static const WORD b_1_11 =     -3;
	static const WORD b_1_12 =     12;
	static const WORD b_2_1 =     -8;
	static const WORD b_2_2 =     -4;
	static const WORD b_2_3 =      1;
	static const WORD b_2_4 =      7;
	static const WORD b_2_5 =     13;
	static const WORD b_2_6 =     19;
	static const WORD b_2_7 =     25;
	static const WORD b_2_8 =     31;
	static const WORD b_2_9 =     35;
	static const WORD b_2_10 =     38;
	static const WORD b_2_11 =     38;
	static const WORD b_2_12 =     35;
	static const WORD b_3_1 =    -15;
	static const WORD b_3_2 =    -18;
	static const WORD b_3_3 =    -21;
	static const WORD b_3_4 =    -23;
	static const WORD b_3_5 =    -25;
	static const WORD b_3_6 =    -26;
	static const WORD b_3_7 =    -25;
	static const WORD b_3_8 =    -22;
	static const WORD b_3_9 =    -18;
	static const WORD b_3_10 =    -11;
	static const WORD b_3_11 =     -2;
	static const WORD b_3_12 =     10;
	static const WORD b_4_1 =     17;
	static const WORD b_4_2 =     17;
	static const WORD b_4_3 =     14;
	static const WORD b_4_4 =     10;
	static const WORD b_4_5 =      3;
	static const WORD b_4_6 =     -4;
	static const WORD b_4_7 =    -13;
	static const WORD b_4_8 =    -21;
	static const WORD b_4_9 =    -28;
	static const WORD b_4_10 =    -34;
	static const WORD b_4_11 =    -38;
	static const WORD b_4_12 =    -39;
	static const WORD b_5_1 =    -36;
	static const WORD b_5_2 =    -32;
	static const WORD b_5_3 =    -26;
	static const WORD b_5_4 =    -19;
	static const WORD b_5_5 =    -13;
	static const WORD b_5_6 =     -7;
	static const WORD b_5_7 =     -3;
	static const WORD b_5_8 =     -1;
	static const WORD b_5_9 =     -1;
	static const WORD b_5_10 =     -3;
	static const WORD b_5_11 =     -6;
	static const WORD b_5_12 =     -9;
	static const WORD b_6_1 =      6;
	static const WORD b_6_2 =      3;
	static const WORD b_6_4 =     -5;
	static const WORD b_6_5 =     -9;
	static const WORD b_6_6 =    -14;
	static const WORD b_6_7 =    -20;
	static const WORD b_6_8 =    -26;
	static const WORD b_6_9 =    -33;
	static const WORD b_6_10 =    -41;
	static const WORD b_6_11 =    -49;
	static const WORD b_6_12 =    -59;
	static const WORD b_7_1 =    -13;
	static const WORD b_7_2 =     -9;
	static const WORD b_7_3 =     -5;
	static const WORD b_7_4 =     -2;
	static const WORD b_7_6 =      1;
	static const WORD b_7_7 =      2;
	static const WORD b_7_8 =      1;
	static const WORD b_7_9 =     -1;
	static const WORD b_7_10 =     -4;
	static const WORD b_7_11 =     -7;
	static const WORD b_7_12 =    -11;
	static const WORD b_8_1 =    -31;
	static const WORD b_8_2 =    -35;
	static const WORD b_8_3 =    -38;
	static const WORD b_8_4 =    -39;
	static const WORD b_8_5 =    -38;
	static const WORD b_8_6 =    -35;
	static const WORD b_8_7 =    -30;
	static const WORD b_8_8 =    -25;
	static const WORD b_8_9 =    -20;
	static const WORD b_8_10 =    -15;
	static const WORD b_8_11 =    -12;
	static const WORD b_8_12 =    -13;
	static const WORD c_1_1 =      2;
	static const WORD c_1_2 =     -4;
	static const WORD c_1_3 =    -26;
	static const WORD c_1_4 =     -1;
	static const WORD c_1_5 =    -21;
	static const WORD c_1_6 =     -1;
	static const WORD c_1_7 =     -9;
	static const WORD c_1_8 =     -4;
	static const WORD c_2_1 =     -1;
	static const WORD c_2_2 =     -4;
	static const WORD c_2_3 =    -20;
	static const WORD c_2_4 =     -1;
	static const WORD c_2_5 =    -18;
	static const WORD c_2_6 =     -3;
	static const WORD c_2_7 =    -13;
	static const WORD c_2_8 =     -9;
	static const WORD c_3_1 =     -5;
	static const WORD c_3_2 =     -4;
	static const WORD c_3_3 =    -15;
	static const WORD c_3_4 =     -1;
	static const WORD c_3_5 =    -15;
	static const WORD c_3_6 =     -3;
	static const WORD c_3_7 =    -15;
	static const WORD c_3_8 =    -12;
	static const WORD c_4_1 =     -9;
	static const WORD c_4_2 =     -2;
	static const WORD c_4_3 =    -10;
	static const WORD c_4_4 =     -2;
	static const WORD c_4_5 =    -13;
	static const WORD c_4_6 =     -3;
	static const WORD c_4_7 =    -16;
	static const WORD c_4_8 =    -14;
	static const WORD c_5_1 =    -12;
	static const WORD c_5_3 =     -6;
	static const WORD c_5_4 =     -2;
	static const WORD c_5_5 =    -11;
	static const WORD c_5_6 =     -4;
	static const WORD c_5_7 =    -15;
	static const WORD c_5_8 =    -15;
	static const WORD c_6_1 =    -15;
	static const WORD c_6_2 =      2;
	static const WORD c_6_3 =     -2;
	static const WORD c_6_4 =     -3;
	static const WORD c_6_5 =    -10;
	static const WORD c_6_6 =     -4;
	static const WORD c_6_7 =    -13;
	static const WORD c_6_8 =    -16;
	static const WORD c_7_1 =    -17;
	static const WORD c_7_2 =      5;
	static const WORD c_7_3 =      1;
	static const WORD c_7_4 =     -4;
	static const WORD c_7_5 =     -9;
	static const WORD c_7_6 =     -5;
	static const WORD c_7_7 =     -9;
	static const WORD c_7_8 =    -16;
	static const WORD c_8_1 =    -17;
	static const WORD c_8_2 =      7;
	static const WORD c_8_3 =      3;
	static const WORD c_8_4 =     -5;
	static const WORD c_8_5 =     -7;
	static const WORD c_8_6 =     -6;
	static const WORD c_8_7 =     -5;
	static const WORD c_8_8 =    -15;
	static const WORD c_9_1 =    -17;
	static const WORD c_9_2 =     10;
	static const WORD c_9_3 =      5;
	static const WORD c_9_4 =     -6;
	static const WORD c_9_5 =     -6;
	static const WORD c_9_6 =     -7;
	static const WORD c_9_7 =     -1;
	static const WORD c_9_8 =    -14;
	static const WORD c_10_1 =    -15;
	static const WORD c_10_2 =     12;
	static const WORD c_10_3 =      5;
	static const WORD c_10_4 =     -6;
	static const WORD c_10_5 =     -5;
	static const WORD c_10_6 =     -8;
	static const WORD c_10_7 =      2;
	static const WORD c_10_8 =    -13;
	static const WORD c_11_1 =    -12;
	static const WORD c_11_2 =     14;
	static const WORD c_11_3 =      5;
	static const WORD c_11_4 =     -7;
	static const WORD c_11_5 =     -3;
	static const WORD c_11_6 =     -9;
	static const WORD c_11_7 =      6;
	static const WORD c_11_8 =    -11;
	static const WORD c_12_1 =     -9;
	static const WORD c_12_2 =     15;
	static const WORD c_12_3 =      4;
	static const WORD c_12_4 =     -7;
	static const WORD c_12_5 =     -2;
	static const WORD c_12_6 =    -11;
	static const WORD c_12_7 =      8;
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

