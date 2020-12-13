#!/bin/sh

prog=complementaryFIRlattice_slb_exchange_constraints_test.m
depends="complementaryFIRlattice_slb_exchange_constraints_test.m test_common.m \
complementaryFIRlattice_slb_exchange_constraints.m \
complementaryFIRlattice_slb_update_constraints.m \
complementaryFIRlattice_slb_set_empty_constraints.m \
complementaryFIRlattice_slb_show_constraints.m \
complementaryFIRlattice_slb_constraints_are_empty.m \
complementaryFIRlatticeAsq.m complementaryFIRlatticeT.m \
complementaryFIRlatticeP.m complementaryFIRlatticeEsq.m \
complementaryFIRlattice.m complementaryFIRlattice2Abcd.m \
H2Asq.m H2T.m H2P.m minphase.m local_max.m x2tf.m print_polynomial.m \
direct_form_scale.m Abcd2H.oct complementaryFIRdecomp.oct"

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
maxiter =  2000
tol =  0.00010000
verbose = 1
vR0 before exchange constraints:
al=[ 206 411 ]
f(al)=[ 0.100098 0.200195 ](fs=1)
Asql=[ -2.629177 -2.549261 ](dB)
au=[ 50 103 514 564 667 783 903 1024 ]
f(au)=[ 0.023926 0.049805 0.250488 0.274902 0.325195 0.381836 0.440430 0.499512 ](fs=1)
Asqu=[ -24.997986 -25.277376 -25.736908 -24.941592 -24.969492 -24.903060 -24.948348 -25.003005 ](dB)
tl=[ 107 ]
f(tl)=[ 0.051758 ](fs=1)
Tl=[ 4.367470 ](Samples)
tu=[ 1 207 ]
f(tu)=[ 0.000000 0.100586 ](fs=1)
Tu=[ 5.473691 5.765574 ](Samples)
pu=[ 159 ]
f(pu)=[ 0.077148 ](fs=1)
Pu=[ -1.204283 ](Samples)
vS1 before exchange constraints:
al=[ 206 411 ]
f(al)=[ 0.100098 0.200195 ](fs=1)
Asql=[ -2.565554 -2.484237 ](dB)
au=[ 50 103 302 514 564 667 783 903 1024 ]
f(au)=[ 0.023926 0.049805 0.146973 0.250488 0.274902 0.325195 0.381836 0.440430 0.499512 ](fs=1)
Asqu=[ -24.958624 -25.176958 0.061899 -25.634593 -24.880957 -24.920055 -24.855126 -24.905993 -24.969157 ](dB)
tl=[ 107 ]
f(tl)=[ 0.051758 ](fs=1)
Tl=[ 4.366980 ](Samples)
tu=[ 1 207 ]
f(tu)=[ 0.000000 0.100586 ](fs=1)
Tu=[ 5.473921 5.764304 ](Samples)
pu=[ 159 ]
f(pu)=[ 0.077148 ](fs=1)
Pu=[ -1.204206 ](Samples)
Exchanged constraint from vR.tu(207) to vS
vR1 after exchange constraints:
al=[ 206 411 ]
f(al)=[ 0.100098 0.200195 ](fs=1)
Asql=[ -2.565554 -2.484237 ](dB)
au=[ 50 103 514 564 667 783 903 1024 ]
f(au)=[ 0.023926 0.049805 0.250488 0.274902 0.325195 0.381836 0.440430 0.499512 ](fs=1)
Asqu=[ -24.958624 -25.176958 -25.634593 -24.880957 -24.920055 -24.855126 -24.905993 -24.969157 ](dB)
tl=[ 107 ]
f(tl)=[ 0.051758 ](fs=1)
Tl=[ 4.366980 ](Samples)
tu=[ 1 ]
f(tu)=[ 0.000000 ](fs=1)
Tu=[ 5.473921 ](Samples)
pu=[ 159 ]
f(pu)=[ 0.077148 ](fs=1)
Pu=[ -1.204206 ](Samples)
vS1 after exchange constraints:
al=[ 206 411 ]
f(al)=[ 0.100098 0.200195 ](fs=1)
Asql=[ -2.565554 -2.484237 ](dB)
au=[ 50 103 302 514 564 667 783 903 1024 ]
f(au)=[ 0.023926 0.049805 0.146973 0.250488 0.274902 0.325195 0.381836 0.440430 0.499512 ](fs=1)
Asqu=[ -24.958624 -25.176958 0.061899 -25.634593 -24.880957 -24.920055 -24.855126 -24.905993 -24.969157 ](dB)
tl=[ 107 ]
f(tl)=[ 0.051758 ](fs=1)
Tl=[ 4.366980 ](Samples)
tu=[ 1 207 ]
f(tu)=[ 0.000000 0.100586 ](fs=1)
Tu=[ 5.473921 5.764304 ](Samples)
pu=[ 159 ]
f(pu)=[ 0.077148 ](fs=1)
Pu=[ -1.204206 ](Samples)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.out test.ok
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

