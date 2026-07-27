#!/bin/sh

prog=directFIRnonsymmetric_slb_exchange_constraints_test.m
depends="test/directFIRnonsymmetric_slb_exchange_constraints_test.m \
test_common.m \
directFIRnonsymmetric_slb_exchange_constraints.m \
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
vR0 before exchange constraints:
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
vS1 before exchange constraints:
au=[ 401 423 471 528 589 652 715 778 842 905 969 ]
f(au)=[ 0.200000 0.211000 0.235000 0.263500 0.294000 0.325500 0.357000 0.388500 0.420500 0.452000 0.484000 ](fs=1)
Au=[ -41.881511 -42.360869 -43.335560 -44.321402 -45.281548 -46.062265 -46.607286 -47.164470 -47.520633 -47.659411 -47.867708 ](dB)
tu=[ 201 ]
f(tu)=[ 0.100000 ](fs=1)
Tu=[ 10.063686 ](Samples)
Exchanged constraint from vR.tu(201) to vS
vR1 after exchange constraints:
al=[ 35 201 ]
f(al)=[ 0.017000 0.100000 ](fs=1)
Al=[ -0.004874 -0.004069 ](dB)
au=[ 97 401 425 469 522 578 ]
f(au)=[ 0.048000 0.200000 0.212000 0.234000 0.260500 0.288500 ](fs=1)
Au=[ -0.004647 -41.881511 -42.485150 -43.363669 -44.594760 -46.002599 ](dB)
tl=[ 51 136 ]
f(tl)=[ 0.025000 0.067500 ](fs=1)
Tl=[ 9.997112 10.000838 ](Samples)
tu=[ 1 ]
f(tu)=[ 0.000000 ](fs=1)
Tu=[ 10.001391 ](Samples)
pl=[ 32 100 201 ]
f(pl)=[ 0.015500 0.049500 0.100000 ](fs=1)
Pl=[ -0.309989 -0.990021 -2.000195 ](rad./pi)
pu=[ 158 ]
f(pu)=[ 0.078500 ](fs=1)
Pu=[ -1.570075 ](rad./pi)
vS1 after exchange constraints:
au=[ 401 423 471 528 589 652 715 778 842 905 969 ]
f(au)=[ 0.200000 0.211000 0.235000 0.263500 0.294000 0.325500 0.357000 0.388500 0.420500 0.452000 0.484000 ](fs=1)
Au=[ -41.881511 -42.360869 -43.335560 -44.321402 -45.281548 -46.062265 -46.607286 -47.164470 -47.520633 -47.659411 -47.867708 ](dB)
tu=[ 201 ]
f(tu)=[ 0.100000 ](fs=1)
Tu=[ 10.063686 ](Samples)
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

