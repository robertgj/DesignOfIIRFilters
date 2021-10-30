#!/bin/sh

prog=surmaaho_parallel_allpass_lowpass_test.m
depends="surmaaho_parallel_allpass_lowpass_test.m test_common.m \
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
        0.7374611691,   0.7830853231,   1.0000000000,   1.0000000000, ... 
        1.0000000000,   1.2770000542,   1.3560035997, ...
        0.1197954840,   0.4101589300,   0.7934970298,   0.8762250189, ... 
        1.2220444984,   0.4101589300,   0.1197954840, ...
        0.7287526514,   0.7669920493,   0.7748861071,   0.7909231675, ... 
        0.7953147511,   0.8897749259,   0.9687752445, ...
        0.2165873656,   0.1168506814,   0.6178959041,   0.3839260889, ... 
        0.4347709627,   0.7064801515,   0.7162074985 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x_coef.ok"; fail; fi

cat > test_a1_coef.ok << 'EOF'
% All-pass single-vector representation
Va1=0,Qa1=8,Ra1=1
a1 = [   0.7669920499,   0.7748861069,   0.7909231663,   0.9687752441, ...
         0.1168506796,   0.6178959042,   0.3839260876,   0.7162074984 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.ok"; fail; fi

cat > test_a2_coef.ok << 'EOF'
% All-pass single-vector representation
Va2=1,Qa2=6,Ra2=1
a2 = [   0.7359976311, ...
         0.7287526513,   0.7953147525,   0.8897749262, ...
         0.2165873697,   0.4347709639,   0.7064801517 ]';
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
