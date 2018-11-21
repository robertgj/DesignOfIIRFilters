#!/bin/sh

prog=surmaaho_parallel_allpass_lowpass_test.m
depends="surmaaho_parallel_allpass_lowpass_test.m test_common.m \
surmaahoFAvLogNewton.m local_max.m print_polynomial.m print_pole_zero.m \
print_allpass_pole.m x2tf.m x2zp.m zp2x.m a2p.m p2a.m tf2a.m x2pa.m \
iirA.m iirP.m fixResultNaN.m aConstraints.m allpassP.m parallel_allpassAsq.m \
parallel_allpassP.m allpass_phase_socp_mmse.m \
qroots.m qzsolve.oct spectralfactor.oct SeDuMi_1_3/"

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
cat > test_x_coef.ok << 'EOF'
Ux=1,Vx=1,Mx=14,Qx=14,Rx=1
x = [   0.0058222626, ...
       -1.0000000000, ...
        0.7359977165, ...
        0.7374611222,   0.7830853394,   1.0000000000,   1.0000000000, ... 
        1.0000000000,   1.2770000276,   1.3560036860, ...
        0.1197954011,   0.4101589036,   0.7934970297,   0.8762250168, ... 
        1.2220444840,   0.4101589036,   0.1197954011, ...
        0.7287526070,   0.7669920299,   0.7748861032,   0.7909231867, ... 
        0.7953147527,   0.8897749264,   0.9687752446, ...
        0.2165874205,   0.1168506371,   0.6178959150,   0.3839260815, ... 
        0.4347709403,   0.7064801538,   0.7162074994 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x_coef.ok"; fail; fi

cat > test_a1_coef.ok << 'EOF'
% All-pass single-vector representation
Va1=0,Qa1=8,Ra1=1
a1 = [   0.7669920320,   0.7748861031,   0.7909231866,   0.9687752446, ...
         0.1168506350,   0.6178959150,   0.3839260800,   0.7162074992 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.ok"; fail; fi

cat > test_a2_coef.ok << 'EOF'
% All-pass single-vector representation
Va2=1,Qa2=6,Ra2=1
a2 = [   0.7359977172, ...
         0.7287526079,   0.7953147533,   0.8897749265, ...
         0.2165874204,   0.4347709395,   0.7064801537 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a2_coef.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog
octave-cli -q $prog
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
