#!/bin/sh

prog=tarczynski_deczky1_test.m

depends="test/tarczynski_deczky1_test.m \
test_common.m print_polynomial.m WISEJ_ND.m tf2Abcd.m \
print_pole_zero.m tf2x.m zp2x.m qroots.m qzsolve.oct"

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
cat > test.ok.N0 << 'EOF'
N0 = [   0.0095464949,   0.0109503074,  -0.0258320215,   0.0045737228, ... 
         0.0146527019,   0.0073737664,  -0.0548435644,   0.0103418898, ... 
         0.2235254396,   0.4134711499,   0.3934579911,   0.2137205587, ... 
         0.0573632623 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.N0"; fail; fi

cat > test.ok.D0 << 'EOF'
D0 = [   1.0000000000,  -0.5051173405,   1.2074588592,  -0.7847927441, ... 
         0.5547830564,  -0.2687929885,   0.0798434108 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.D0"; fail; fi
cat > test.ok.x0 << 'EOF'
Ux0=2,Vx0=0,Mx0=10,Qx0=6,Rx0=1
x0 = [   0.0095464949, ...
        -2.3508396993,  -0.7663131415, ...
         0.8136447409,   0.8903220512,   0.9700093843,   1.5552274112, ... 
         1.6712003340, ...
         2.5087425561,   2.1063540461,   1.9141050631,   1.0029490555, ... 
         0.3215243678, ...
         0.4636068272,   0.6933237907,   0.8790905568, ...
         0.5711952054,   1.4853491527,   1.7963715283 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.x0"; fail; fi
#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok.N0 tarczynski_deczky1_test_N0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.N0"; fail; fi

diff -Bb test.ok.D0 tarczynski_deczky1_test_D0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.D0"; fail; fi

diff -Bb test.ok.x0 tarczynski_deczky1_test_x0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.x0"; fail; fi

#
# this much worked
#
pass
