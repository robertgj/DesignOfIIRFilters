#!/bin/sh

prog=surmaaho_parallel_allpass_lowpass_test.m
depends="test/surmaaho_parallel_allpass_lowpass_test.m test_common.m \
surmaahoFAvLogNewton.m local_max.m print_polynomial.m print_pole_zero.m \
print_allpass_pole.m x2tf.m x2zp.m zp2x.m a2p.m p2a.m tf2a.m x2pa.m \
iirA.m iirP.m fixResultNaN.m aConstraints.m allpassP.m parallel_allpassAsq.m \
parallel_allpassP.m allpass_phase_socp_mmse.m \
qroots.m qzsolve.oct spectralfactor.oct"

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
cat > test_x_coef.ok << 'EOF'
Ux=1,Vx=1,Mx=14,Qx=14,Rx=1
x = [   0.0058222631, ...
       -1.0000000000, ...
        0.7359976359, ...
        0.7374611692,   0.7830853230,   1.0000000000,   1.0000000000, ... 
        1.0000000000,   1.2770000542,   1.3560035996, ...
        0.1197954841,   0.4101589301,   0.7934970298,   0.8762250189, ... 
        1.2220444984,   0.4101589301,   0.1197954841, ...
        0.7287526515,   0.7669920494,   0.7748861071,   0.7909231674, ... 
        0.7953147511,   0.8897749259,   0.9687752445, ...
        0.2165873655,   0.1168506815,   0.6178959041,   0.3839260889, ... 
        0.4347709628,   0.7064801515,   0.7162074985 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x_coef.ok"; fail; fi

cat > test_a1_coef.ok << 'EOF'
% All-pass single-vector representation
Va1=0,Qa1=8,Ra1=1
a1 = [   0.7669920485,   0.7748861074,   0.7909231683,   0.9687752451, ...
         0.1168506831,   0.6178959041,   0.3839260909,   0.7162074987 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.ok"; fail; fi

cat > test_a2_coef.ok << 'EOF'
% All-pass single-vector representation
Va2=1,Qa2=6,Ra2=1
a2 = [   0.7359976401, ...
         0.7287526518,   0.7953147496,   0.8897749256, ...
         0.2165873617,   0.4347709611,   0.7064801511 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a2_coef.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x_coef.ok surmaaho_parallel_allpass_lowpass_test_x_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x_coef.ok"; fail; fi

diff -Bb test_a1_coef.ok surmaaho_parallel_allpass_lowpass_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1_coef.ok"; fail; fi

diff -Bb test_a2_coef.ok surmaaho_parallel_allpass_lowpass_test_a2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a2_coef.ok"; fail; fi

#
# this much worked
#
pass
