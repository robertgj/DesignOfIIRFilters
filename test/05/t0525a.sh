#!/bin/sh

prog=directFIRnonsymmetric_slb_update_constraints_test.m
depends="test/directFIRnonsymmetric_slb_update_constraints_test.m test_common.m \
directFIRnonsymmetric_slb_update_constraints.m \
directFIRnonsymmetric_slb_set_empty_constraints.m \
directFIRnonsymmetric_slb_show_constraints.m \
directFIRnonsymmetric_slb_constraints_are_empty.m \
directFIRnonsymmetricAsq.m \
directFIRnonsymmetricT.m \
directFIRnonsymmetricP.m \
local_max.m"

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
cat > test.ok << 'EOF'
maxiter = 2000
tol = 1.0000e-08
verbose = 1
vR0 after update constraints:
al=[ 45 158 201 ]
f(al)=[ 0.022000 0.078500 0.100000 ](fs=1)
Al=[ -0.045148 -0.062015 -0.030436 ](dB)
au=[ 103 401 ]
f(au)=[ 0.051000 0.200000 ](fs=1)
Au=[ 0.084920 -57.566773 ](dB)
tl=[ 55 147 ]
f(tl)=[ 0.027000 0.073000 ](fs=1)
Tl=[ 9.917202 9.828983 ](Samples)
tu=[ 1 100 201 ]
f(tu)=[ 0.000000 0.049500 0.100000 ](fs=1)
Tu=[ 10.117776 10.054322 11.128868 ](Samples)
pl=[ 31 201 ]
f(pl)=[ 0.015000 0.100000 ](fs=1)
Pl=[ -0.302227 -2.013230 ](rad./pi)
pu=[ 166 ]
f(pu)=[ 0.082500 ](fs=1)
Pu=[ -1.645684 ](rad./pi)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.out test.ok
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

