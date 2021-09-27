#!/bin/sh

prog=tarczynski_deczky1_test.m

depends="tarczynski_deczky1_test.m \
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
N0 = [  0.0095388870,   0.0109615805,  -0.0258441278,   0.0045803250, ... 
        0.0146589014,   0.0073677413,  -0.0548520813,   0.0103722296, ... 
        0.2235286461,   0.4134532912,   0.3933283747,   0.2136173518, ... 
        0.0573001763 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.N0"; fail; fi

cat > test.ok.D0 << 'EOF'
D0 = [  1.0000000000,  -0.5052407885,   1.2073036709,  -0.7847282772, ... 
        0.5546883460,  -0.2687313692,   0.0798447060 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.D0"; fail; fi
cat > test.ok.x0 << 'EOF'
Ux0=2,Vx0=0,Mx0=10,Qx0=6,Rx0=1
x0 = [  0.0095388870, ...
       -2.3531881769,  -0.7653603739, ...
        0.8137956055,   0.8900673800,   0.9700261953,   1.5552649717, ... 
        1.6712512015, ...
        2.5093003620,   2.1064573184,   1.9141307301,   1.0029823273, ... 
        0.3215378006, ...
        0.4636837869,   0.6933028950,   0.8789782702, ...
        0.5712442818,   1.4853635199,   1.7963763404 ]';
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
