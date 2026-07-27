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
al=[ 35 201 ]
f(al)=[ 0.017000 0.100000 ](fs=1)
Al=[ -0.063214 -0.603571 ](dB)
au=[ 97 401 425 469 522 578 ]
f(au)=[ 0.048000 0.200000 0.212000 0.234000 0.260500 0.288500 ](fs=1)
Au=[ 0.121254 -46.367412 -54.160832 -56.744953 -58.461383 -59.740975 ](dB)
tl=[ 51 136 ]
f(tl)=[ 0.025000 0.067500 ](fs=1)
Tl=[ 9.934498 9.708159 ](Samples)
tu=[ 1 201 ]
f(tu)=[ 0.000000 0.100000 ](fs=1)
Tu=[ 10.150683 11.462969 ](Samples)
pl=[ 32 100 201 ]
f(pl)=[ 0.015500 0.049500 0.100000 ](fs=1)
Pl=[ -0.312912 -0.991847 -2.022994 ](rad./pi)
pu=[ 158 ]
f(pu)=[ 0.078500 ](fs=1)
Pu=[ -1.561637 ](rad./pi)
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

