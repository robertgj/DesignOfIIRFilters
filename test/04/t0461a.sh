#!/bin/sh

prog=selesnickFIRsymmetric_lowpass_test.m

depends="selesnickFIRsymmetric_lowpass_test.m test_common.m \
selesnickFIRsymmetric_lowpass.m selesnickFIRsymmetric_lowpass_exchange.m \
lagrange_interp.m print_polynomial.m local_max.m directFIRsymmetricA.m"

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
hM = [  0.000000074413,  0.000000247838,  0.000000351579,  0.000000023516, ... 
       -0.000000838770, -0.000001520922, -0.000000771302,  0.000001669843, ... 
        0.000003690044,  0.000002010481, -0.000003765989, -0.000008366625, ... 
       -0.000004534987,  0.000007819951,  0.000016917906,  0.000008487591, ... 
       -0.000015802659, -0.000031828070, -0.000014058771,  0.000030580941, ... 
        0.000056148130,  0.000020592980, -0.000056762238, -0.000093752489, ... 
       -0.000026260610,  0.000100943188,  0.000148894331,  0.000027133592, ... 
       -0.000172212448, -0.000225731941, -0.000016290572,  0.000282318415, ... 
        0.000327372824, -0.000017303050, -0.000445639890, -0.000454610601, ... 
        0.000089875699,  0.000678714253,  0.000604260331, -0.000223852273, ... 
       -0.000999309701, -0.000767211015,  0.000448605198,  0.001424974491, ... 
        0.000926267670, -0.000800885522, -0.001971127439, -0.001053911669, ... 
        0.001324918907,  0.002648813076,  0.001110038773, -0.002072332856, ... 
       -0.003462347570, -0.001039601828,  0.003102341144,  0.004407144896, ... 
        0.000769765234, -0.004483063340, -0.005468054273, -0.000205552454, ... 
        0.006295656777,  0.006618528438, -0.000778326102, -0.008644565075, ... 
       -0.007820881733,  0.002354658465,  0.011680949688,  0.009027783079, ... 
       -0.004782350617, -0.015656348251, -0.010184977935,  0.008499766894, ... 
        0.021054256080,  0.011235062952, -0.014377842711, -0.028960879784, ... 
       -0.012121975206,  0.024551726472,  0.042388310953,  0.012795731702, ... 
       -0.046257391451, -0.073542504282, -0.013216885309,  0.130212085072, ... 
        0.281849465100,  0.346693502846 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok selesnickFIRsymmetric_lowpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

#
# this much worked
#
pass

