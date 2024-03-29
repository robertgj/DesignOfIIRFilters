#!/bin/sh

prog=zahradnik_halfband_test.m

depends="test/zahradnik_halfband_test.m test_common.m print_polynomial.m \
zahradnik_halfband.m local_max.m chebyshevP.m chebyshevU.m \
chebyshevP_backward_recurrence.m chebyshevU_backward_recurrence.m"

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
cat > test_fp_0_225_as_60.ok << 'EOF'
h_distinct = [   0.0004166638,  -0.0005345064,   0.0008638372,  -0.0013139663, ... 
                 0.0019120741,  -0.0026894267,   0.0036825974,  -0.0049355871, ... 
                 0.0065034751,  -0.0084587454,   0.0109024800,  -0.0139849238, ... 
                 0.0179454307,  -0.0231963316,   0.0305188545,  -0.0415949294, ... 
                 0.0608149679,  -0.1043155277,   0.3174635636,   0.5000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed cat test_fp_0_225_as_60.ok"; fail; fi

cat > test_fp_0_225_as_120.ok << 'EOF'
h_distinct = [  -0.0000006998,   0.0000015766,  -0.0000033003,   0.0000062081, ... 
                -0.0000108529,   0.0000179632,  -0.0000284769,   0.0000435784, ... 
                -0.0000647359,   0.0000937408,  -0.0001327467,   0.0001843083, ... 
                -0.0002514196,   0.0003375516,  -0.0004466893,   0.0005833703, ... 
                -0.0007527256,   0.0009605279,  -0.0012132508,   0.0015181488, ... 
                -0.0018833670,   0.0023180996,  -0.0028328184,   0.0034396083, ... 
                -0.0041526609,   0.0049890067,  -0.0059696131,   0.0071210531, ... 
                -0.0084780922,   0.0100878026,  -0.0120163253,   0.0143604491, ... 
                -0.0172684939,   0.0209804968,  -0.0259122479,   0.0328513589, ... 
                -0.0434893890,   0.0622309418,  -0.1052388518,   0.3180205186, ... 
                 0.5000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed cat test_fp_0_225_as_120.ok"; fail; fi

cat > test_fp_0_240_as_140.ok << 'EOF'
h_distinct = [   0.0000000341,  -0.0000000357,   0.0000000541,  -0.0000000788, ... 
                 0.0000001110,  -0.0000001527,   0.0000002058,  -0.0000002725, ... 
                 0.0000003557,  -0.0000004584,   0.0000005841,  -0.0000007368, ... 
                 0.0000009212,  -0.0000011424,   0.0000014061,  -0.0000017189, ... 
                 0.0000020880,  -0.0000025215,   0.0000030285,  -0.0000036188, ... 
                 0.0000043034,  -0.0000050945,   0.0000060053,  -0.0000070505, ... 
                 0.0000082459,  -0.0000096088,   0.0000111583,  -0.0000129148, ... 
                 0.0000149006,  -0.0000171396,   0.0000196578,  -0.0000224831, ... 
                 0.0000256455,  -0.0000291772,   0.0000331128,  -0.0000374889, ... 
                 0.0000423450,  -0.0000477230,   0.0000536675,  -0.0000602259, ... 
                 0.0000674483,  -0.0000753879,   0.0000841011,  -0.0000936473, ... 
                 0.0001040891,  -0.0001154927,   0.0001279274,  -0.0001414664, ... 
                 0.0001561864,  -0.0001721678,   0.0001894950,  -0.0002082563, ... 
                 0.0002285441,  -0.0002504550,   0.0002740901,  -0.0002995548, ... 
                 0.0003269591,  -0.0003564181,   0.0003880516,  -0.0004219848, ... 
                 0.0004583483,  -0.0004972785,   0.0005389176,  -0.0005834144, ... 
                 0.0006309244,  -0.0006816100,   0.0007356418,  -0.0007931984, ... 
                 0.0008544672,  -0.0009196457,   0.0009889418,  -0.0010625751, ... 
                 0.0011407779,  -0.0012237969,   0.0013118941,  -0.0014053497, ... 
                 0.0015044629,  -0.0016095554,   0.0017209738,  -0.0018390926, ... 
                 0.0019643187,  -0.0020970954,   0.0022379079,  -0.0023872894, ... 
                 0.0025458286,  -0.0027141780,   0.0028930647,  -0.0030833024, ... 
                 0.0032858064,  -0.0035016112,   0.0037318922,  -0.0039779922, ... 
                 0.0042414538,  -0.0045240591,   0.0048278800,  -0.0051553407, ... 
                 0.0055092966,  -0.0058931364,   0.0063109132,  -0.0067675156, ... 
                 0.0072688957,  -0.0078223735,   0.0084370535,  -0.0091244019, ... 
                 0.0098990619,  -0.0107800330,   0.0117924146,  -0.0129700600, ... 
                 0.0143597475,  -0.0160279843,   0.0180726140,  -0.0206437101, ... 
                 0.0239837549,  -0.0285116499,   0.0350187401,  -0.0452008792, ... 
                 0.0634674499,  -0.1059864668,   0.3182709027,   0.5000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed cat test_fp_0_225_as_140.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_fp_0_225_as_60.ok zahradnik_halfband_test_fp_0_225_as_60_coef.m 
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_fp_0_225_as_60.ok"; fail; fi

diff -Bb test_fp_0_225_as_120.ok zahradnik_halfband_test_fp_0_225_as_120_coef.m 
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_fp_0_225_as_120.ok"; fail; fi

diff -Bb test_fp_0_240_as_140.ok zahradnik_halfband_test_fp_0_240_as_140_coef.m 
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_fp_0_240_as_140.ok"; fail; fi

#
# this much worked
#
pass

