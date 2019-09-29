#!/bin/sh

prog=Abcd2cc_test.m

depends="Abcd2cc_test.m test_common.m \
Abcd2cc.m KW.m tf2Abcd.m optKW.m sv2block.m svf.m crossWelch.m"

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
bits =  8
scale =  128
delta =  1
N =  8
P =  12
dbap =  0.10000
dbas =  40
fc =  0.050000
n =
 Columns 1 through 7:
   0.010374  -0.069387   0.213314  -0.394202   0.479825  -0.394202   0.213314
 Columns 8 and 9:
  -0.069387   0.010374

d =
 Columns 1 through 7:
    1.00000   -7.24033   23.18509  -42.86262   50.01446  -37.70652   17.93232
 Columns 8 and 9:
   -4.91773    0.59536

ngABCDopt =  1.4657
ngABCDoptf =  1.8223
est_nvABCDoptf =  0.48497
nvABCDoptf =  0.45047
Ab =
 Columns 1 through 6:
  -0.5351694  -0.2038804   0.0697984  -0.1238718   0.0054265   0.0396165
   0.0091596  -0.5659074   0.1135045  -0.3901819  -0.0522356   0.1524862
   0.1555229  -0.2301352  -0.3516374  -0.0386973   0.3416492   0.0226220
   0.2501129   0.1348904   0.2069903  -0.6338126  -0.1176623   0.3706228
   0.0604835  -0.2219623   0.2073077   0.4060380  -0.2905139   0.3373370
  -0.2045857  -0.2963165  -0.1780177  -0.1870837   0.1550722  -0.3418166
  -0.1213379  -0.2912005   0.2505742   0.0870977  -0.2496877   0.1678705
  -0.0590997   0.1096338  -0.1379069   0.2073752   0.0147613   0.3677473
 Columns 7 and 8:
   0.2185769  -0.1504433
   0.0162884  -0.0979036
  -0.2723190   0.2595002
  -0.0593359  -0.0819180
   0.1361618  -0.0099744
   0.0478119   0.1623932
  -0.5867745   0.2188614
   0.1002009  -0.3325416

Bb =
 Columns 1 through 6:
  -0.14432023  -0.19995764  -0.24790387  -0.28446155  -0.30628010  -0.31052397
  -0.06094099  -0.03006370   0.00797210   0.05209140   0.10049350   0.15060696
  -0.11783524  -0.13871549  -0.16052818  -0.18026055  -0.19465967  -0.20050694
   0.13279149   0.13031780   0.11129884   0.07618291   0.02701264  -0.03267132
  -0.28337265  -0.24667145  -0.20039245  -0.14955974  -0.09976557  -0.05656594
   0.04968767   0.02527645  -0.00359727  -0.03627421  -0.07238871  -0.11194993
  -0.10074292  -0.06996283  -0.04104671  -0.01673870   0.00087596   0.01051921
  -0.24021385  -0.27536475  -0.29726977  -0.30416654  -0.29557227  -0.27253600
 Columns 7 through 12:
  -0.29502069  -0.25838687  -0.20013241  -0.12074287  -0.02173940   0.09428668
   0.19911836   0.24208979   0.27517250   0.29391407   0.29414510   0.27242000
  -0.19485980  -0.17521858  -0.13958091  -0.08635541  -0.01412100   0.07876421
  -0.09806132  -0.16342902  -0.22255624  -0.26921170  -0.29763007  -0.30294950
  -0.02479390  -0.00783586  -0.00692207  -0.02048470  -0.04363606  -0.06781443
  -0.15535675  -0.20333843  -0.25682101  -0.31672776  -0.38372964  -0.45796718
   0.01175526   0.00490779  -0.00912928  -0.02916097  -0.05399939  -0.08276006
  -0.23780598  -0.19588213  -0.15292656  -0.11651091  -0.09518732  -0.09788119

Cb =
 Columns 1 through 6:
   0.01948603  -0.03452703  -0.20019645  -0.01082552  -0.16791412  -0.01138217
  -0.00523254  -0.03403370  -0.15891063  -0.00826953  -0.14074654  -0.01985587
  -0.03562196  -0.02759947  -0.11864862  -0.00895804  -0.11852001  -0.02389494
  -0.06693821  -0.01598126  -0.08055048  -0.01251343  -0.10096594  -0.02627402
  -0.09518038  -0.00025077  -0.04594640  -0.01823278  -0.08726299  -0.02884288
  -0.11726341   0.01832409  -0.01614775  -0.02525270  -0.07627775  -0.03268220
  -0.13110977   0.03837353   0.00774572  -0.03268769  -0.06679162  -0.03825911
  -0.13566318   0.05850215   0.02500172  -0.03973694  -0.05769588  -0.04557288
  -0.13083159   0.07735413   0.03535964  -0.04575724  -0.04814097  -0.05428458
  -0.11737041   0.09367241   0.03907511  -0.05030293  -0.03763157  -0.06382825
  -0.09671964   0.10635540   0.03690384  -0.05313559  -0.02606457  -0.07350382
  -0.07081038   0.11451189   0.03002991  -0.05420881  -0.01371269  -0.08255391
 Columns 7 and 8:
  -0.07026283  -0.03438548
  -0.10247941  -0.07037369
  -0.12079321  -0.09535027
  -0.12538180  -0.11135923
  -0.11744106  -0.12020983
  -0.09905289  -0.12340559
  -0.07297705  -0.12211889
  -0.04238987  -0.11720864
  -0.01059606  -0.10927350
   0.01925876  -0.09872979
   0.04444872  -0.08590101
   0.06287911  -0.07110584

Db =
 Columns 1 through 7:
   0.010374   0.000000   0.000000   0.000000   0.000000   0.000000   0.000000
   0.005723   0.010374   0.000000   0.000000   0.000000   0.000000   0.000000
   0.014231   0.005723   0.010374   0.000000   0.000000   0.000000   0.000000
   0.020802   0.014231   0.005723   0.010374   0.000000   0.000000   0.000000
   0.026938   0.020802   0.014231   0.005723   0.010374   0.000000   0.000000
   0.033475   0.026938   0.020802   0.014231   0.005723   0.010374   0.000000
   0.040731   0.033475   0.026938   0.020802   0.014231   0.005723   0.010374
   0.048648   0.040731   0.033475   0.026938   0.020802   0.014231   0.005723
   0.056918   0.048648   0.040731   0.033475   0.026938   0.020802   0.014231
   0.065082   0.056918   0.048648   0.040731   0.033475   0.026938   0.020802
   0.072622   0.065082   0.056918   0.048648   0.040731   0.033475   0.026938
   0.079017   0.072622   0.065082   0.056918   0.048648   0.040731   0.033475
 Columns 8 through 12:
   0.000000   0.000000   0.000000   0.000000   0.000000
   0.000000   0.000000   0.000000   0.000000   0.000000
   0.000000   0.000000   0.000000   0.000000   0.000000
   0.000000   0.000000   0.000000   0.000000   0.000000
   0.000000   0.000000   0.000000   0.000000   0.000000
   0.000000   0.000000   0.000000   0.000000   0.000000
   0.000000   0.000000   0.000000   0.000000   0.000000
   0.010374   0.000000   0.000000   0.000000   0.000000
   0.005723   0.010374   0.000000   0.000000   0.000000
   0.014231   0.005723   0.010374   0.000000   0.000000
   0.020802   0.014231   0.005723   0.010374   0.000000
   0.026938   0.020802   0.014231   0.005723   0.010374

ngABCDbf =  0.12214
est_nvABCDbf =  0.30580
nvbf =  0.30512
nvccbf =  0.30512
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
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi
diff -Bb test.cc ellip8ABCD12.cc
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.cc"; fail; fi


#
# this much worked
#
pass

