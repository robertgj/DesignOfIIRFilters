#!/bin/sh

prog=selesnickFIRsymmetric_halfband_test.m

depends="selesnickFIRsymmetric_halfband_test.m test_common.m \
selesnickFIRsymmetric_lowpass.m lagrange_interp.m print_polynomial.m \
local_max.m local_peak.m xfr2tf.m directFIRsymmetricA.m"

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
cat > test_hM.ok << 'EOF'
hM = [ -0.000000748558,  0.000000000000,  0.000000603215,  0.000000000000, ... 
       -0.000000843471,  0.000000000000,  0.000001144926,  0.000000000000, ... 
       -0.000001518383,  0.000000000000,  0.000001975976,  0.000000000000, ... 
       -0.000002531273,  0.000000000000,  0.000003199387,  0.000000000000, ... 
       -0.000003997086,  0.000000000000,  0.000004942909,  0.000000000000, ... 
       -0.000006057285,  0.000000000000,  0.000007362648,  0.000000000000, ... 
       -0.000008883565,  0.000000000000,  0.000010646856,  0.000000000000, ... 
       -0.000012681718,  0.000000000000,  0.000015019857,  0.000000000000, ... 
       -0.000017695606,  0.000000000000,  0.000020746059,  0.000000000000, ... 
       -0.000024211195,  0.000000000000,  0.000028134007,  0.000000000000, ... 
       -0.000032560623,  0.000000000000,  0.000037540439,  0.000000000000, ... 
       -0.000043126237,  0.000000000000,  0.000049374311,  0.000000000000, ... 
       -0.000056344588,  0.000000000000,  0.000064100749,  0.000000000000, ... 
       -0.000072710348,  0.000000000000,  0.000082244931,  0.000000000000, ... 
       -0.000092780151,  0.000000000000,  0.000104395888,  0.000000000000, ... 
       -0.000117176362,  0.000000000000,  0.000131210254,  0.000000000000, ... 
       -0.000146590824,  0.000000000000,  0.000163416029,  0.000000000000, ... 
       -0.000181788657,  0.000000000000,  0.000201816450,  0.000000000000, ... 
       -0.000223612244,  0.000000000000,  0.000247294122,  0.000000000000, ... 
       -0.000272985565,  0.000000000000,  0.000300815635,  0.000000000000, ... 
       -0.000330919162,  0.000000000000,  0.000363436959,  0.000000000000, ... 
       -0.000398516066,  0.000000000000,  0.000436310020,  0.000000000000, ... 
       -0.000476979166,  0.000000000000,  0.000520691015,  0.000000000000, ... 
       -0.000567620643,  0.000000000000,  0.000617951169,  0.000000000000, ... 
       -0.000671874287,  0.000000000000,  0.000729590893,  0.000000000000, ... 
       -0.000791311804,  0.000000000000,  0.000857258593,  0.000000000000, ... 
       -0.000927664555,  0.000000000000,  0.001002775826,  0.000000000000, ... 
       -0.001082852685,  0.000000000000,  0.001168171059,  0.000000000000, ... 
       -0.001259024280,  0.000000000000,  0.001355725119,  0.000000000000, ... 
       -0.001458608168,  0.000000000000,  0.001568032601,  0.000000000000, ... 
       -0.001684385417,  0.000000000000,  0.001808085218,  0.000000000000, ... 
       -0.001939586653,  0.000000000000,  0.002079385630,  0.000000000000, ... 
       -0.002228025473,  0.000000000000,  0.002386104185,  0.000000000000, ... 
       -0.002554283079,  0.000000000000,  0.002733297041,  0.000000000000, ... 
       -0.002923966807,  0.000000000000,  0.003127213709,  0.000000000000, ... 
       -0.003344077459,  0.000000000000,  0.003575737742,  0.000000000000, ... 
       -0.003823540551,  0.000000000000,  0.004089030545,  0.000000000000, ... 
       -0.004373991051,  0.000000000000,  0.004680493905,  0.000000000000, ... 
       -0.005010962059,  0.000000000000,  0.005368248902,  0.000000000000, ... 
       -0.005755739754,  0.000000000000,  0.006177483074,  0.000000000000, ... 
       -0.006638362059,  0.000000000000,  0.007144321892,  0.000000000000, ... 
       -0.007702674910,  0.000000000000,  0.008322516718,  0.000000000000, ... 
       -0.009015303348,  0.000000000000,  0.009795667219,  0.000000000000, ... 
       -0.010682595676,  0.000000000000,  0.011701175158,  0.000000000000, ... 
       -0.012885245283,  0.000000000000,  0.014281569434,  0.000000000000, ... 
       -0.015956639253,  0.000000000000,  0.018008282147,  0.000000000000, ... 
       -0.020586554565,  0.000000000000,  0.023933921137,  0.000000000000, ... 
       -0.028469265238,  0.000000000000,  0.034983913239,  0.000000000000, ... 
       -0.045173699724,  0.000000000000,  0.063447988407,  0.000000000000, ... 
       -0.105974775276,  0.000000000000,  0.318267024988,  0.500000000000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok selesnickFIRsymmetric_halfband_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

#
# this much worked
#
pass
