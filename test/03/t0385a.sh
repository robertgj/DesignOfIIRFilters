#!/bin/sh

prog=surmaaho_lowpass_test.m
depends="surmaaho_lowpass_test.m test_common.m surmaahoFAvLogNewton.m \
local_max.m print_polynomial.m print_pole_zero.m tf2a.m x2zp.m zp2x.m a2p.m \
iirA.m iirP.m fixResultNaN.m aConstraints.m allpassP.m \
allpass_phase_socp_mmse.m qroots.m qzsolve.oct SeDuMi_1_3/"

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
Ux=1,Vx=1,Mx=10,Qx=10,Rx=1
x = [   0.0011676867, ...
       -1.0000000000, ...
        0.8292402381, ...
        1.0000000000,   1.0000000000,   1.0000000000,   1.2132533884, ... 
        1.2955253028, ...
        0.7950661045,   0.8940993950,   1.2939773298,   0.3403350176, ... 
        0.1022103056, ...
        0.8307487200,   0.8522658190,   0.8566164877,   0.9130582446, ... 
        0.9737984530, ...
        0.1658364238,   0.4787379723,   0.3290091013,   0.6074256121, ... 
        0.6535665939 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog
octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok surmaaho_lowpass_test_x_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass
