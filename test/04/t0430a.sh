#!/bin/sh

prog=zahradnik_halfband_test.m

depends="zahradnik_halfband_test.m test_common.m print_polynomial.m \
zahradnik_halfband.m local_max.m chebychevP.m chebychevU.m \
chebychevP_backward_recurrence.m chebychevU_backward_recurrence.m"

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
                 0.0000020880,  -0.0000025215,   0.0000030284,  -0.0000036187, ... 
                 0.0000043034,  -0.0000050944,   0.0000060053,  -0.0000070504, ... 
                 0.0000082458,  -0.0000096088,   0.0000111583,  -0.0000129147, ... 
                 0.0000149005,  -0.0000171395,   0.0000196577,  -0.0000224829, ... 
                 0.0000256454,  -0.0000291771,   0.0000331126,  -0.0000374887, ... 
                 0.0000423448,  -0.0000477228,   0.0000536673,  -0.0000602256, ... 
                 0.0000674479,  -0.0000753876,   0.0000841008,  -0.0000936469, ... 
                 0.0001040887,  -0.0001154922,   0.0001279269,  -0.0001414659, ... 
                 0.0001561858,  -0.0001721672,   0.0001894944,  -0.0002082556, ... 
                 0.0002285434,  -0.0002504543,   0.0002740894,  -0.0002995540, ... 
                 0.0003269583,  -0.0003564172,   0.0003880506,  -0.0004219838, ... 
                 0.0004583473,  -0.0004972775,   0.0005389165,  -0.0005834133, ... 
                 0.0006309232,  -0.0006816088,   0.0007356406,  -0.0007931971, ... 
                 0.0008544659,  -0.0009196444,   0.0009889404,  -0.0010625737, ... 
                 0.0011407764,  -0.0012237953,   0.0013118926,  -0.0014053481, ... 
                 0.0015044613,  -0.0016095538,   0.0017209721,  -0.0018390909, ... 
                 0.0019643169,  -0.0020970936,   0.0022379061,  -0.0023872876, ... 
                 0.0025458268,  -0.0027141762,   0.0028930629,  -0.0030833007, ... 
                 0.0032858047,  -0.0035016094,   0.0037318904,  -0.0039779905, ... 
                 0.0042414520,  -0.0045240574,   0.0048278784,  -0.0051553390, ... 
                 0.0055092950,  -0.0058931349,   0.0063109117,  -0.0067675141, ... 
                 0.0072688942,  -0.0078223721,   0.0084370522,  -0.0091244006, ... 
                 0.0098990608,  -0.0107800319,   0.0117924135,  -0.0129700591, ... 
                 0.0143597466,  -0.0160279835,   0.0180726133,  -0.0206437094, ... 
                 0.0239837543,  -0.0285116494,   0.0350187397,  -0.0452008789, ... 
                 0.0634674497,  -0.1059864667,   0.3182709026,   0.5000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed cat test_fp_0_225_as_140.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
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
