#!/bin/sh

prog=qzsolve_test.m
depends="qzsolve_test.m test_common.m qroots.m print_pole_zero.m \
tf2x.m zp2x.m qzsolve.oct"

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
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

cat > test.coef << 'EOF'
Ux=0,Vx=2,Mx=0,Qx=8,Rx=1
x = [  1.0000000000, ...
      -0.1307212017, -0.0668061890, ...
       0.5476073344,  0.7118255059,  0.7878154723,  0.9216278425, ...
       1.5186811109,  0.9636442613,  0.7282955096,  1.3538908874 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.coef"; fail; fi

#
# run and see if the results match. Suppress m-file warnings
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

diff -Bb test.coef qzsolve_test_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.coef"; fail; fi

#
# this much worked
#
pass

