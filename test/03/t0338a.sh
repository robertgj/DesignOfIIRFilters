#!/bin/sh

prog=tarczynski_deczky1_test.m

depends="test/tarczynski_deczky1_test.m \
test_common.m delayz.m print_polynomial.m WISEJ_ND.m tf2Abcd.m \
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
N0 = [   0.0095346386,   0.0109670290,  -0.0258532603,   0.0045898614, ... 
         0.0146493792,   0.0073780778,  -0.0548470462,   0.0103589056, ... 
         0.2235215374,   0.4134373795,   0.3933473742,   0.2136323163, ... 
         0.0573177584 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.N0"; fail; fi

cat > test.ok.D0 << 'EOF'
D0 = [   1.0000000000,  -0.5052547264,   1.2073573355,  -0.7847886208, ... 
         0.5547370290,  -0.2687640804,   0.0798491211 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.D0"; fail; fi
cat > test.ok.x0 << 'EOF'
Ux0=2,Vx0=0,Mx0=10,Qx0=6,Rx0=1
x0 = [   0.0095346386, ...
        -2.3546568871,  -0.7656994967, ...
         0.8136334280,   0.8900707451,   0.9700217164,   1.5552854341, ... 
         1.6713007632, ...
         2.5090808932,   2.1063560821,   1.9141568639,   1.0029719898, ... 
         0.3215362533, ...
         0.4636735881,   0.6933154064,   0.8790060433, ...
         0.5712117317,   1.4853416371,   1.7963793559 ]';
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
