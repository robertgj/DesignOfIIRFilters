#!/bin/sh

prog=mps_roots_test.m

depends="mps_roots_test.m test_common.m tf2x.m qroots.m print_pole_zero.m"

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

# If package mpsolve is not found then return the aet code for "pass"
octave-cli --eval "pkg load mpsolve"
if test $? -ne 0; then 
    echo SKIPPED $descr "octave mpsolve package not found!" ; exit 0; 
fi

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
if [ $? -ne 0 ]; then echo "Failed output cat of test.ok"; fail; fi

cat > test.coef << 'EOF'
Ux=0,Vx=2,Mx=0,Qx=8,Rx=1
x = [  1.0000000000, ...
      -0.1307212017, -0.0668061890, ...
       0.5476073344,  0.7118255059,  0.7878154723,  0.9216278425, ...
       1.5186811109,  0.9636442613,  0.7282955096,  1.3538908874 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat of test.coef"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

LD_LIBRARY_PATH=/usr/local/octave/lib octave-cli -q $prog > test.out

if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

diff -Bb test.coef mps_roots_test_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.coef"; fail; fi

#
# this much worked
#
pass

