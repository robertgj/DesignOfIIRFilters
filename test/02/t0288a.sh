#!/bin/sh

prog=schurOneMPAlattice_slb_update_constraints_test.m
depends="schurOneMPAlattice_slb_update_constraints_test.m test_common.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlatticeAsq.m schurOneMPAlatticeT.m schurOneMPAlatticeP.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMscale.m tf2schurOneMlattice.m schurOneMAPlattice2Abcd.m \
local_max.m print_polynomial.m H2Asq.m H2T.m H2P.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct"

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
maxiter =  2000
tol =  0.0000050000
verbose = 1
vR0 after update constraints:
al=[ 148 301 ]
f(al)=[ 0.073500 0.150000 ](fs=1)
Asql=[ -0.510871 -3.042037 ](dB)
au=[ 1 225 401 439 ]
f(au)=[ 0.000000 0.112000 0.200000 0.219000 ](fs=1)
Asqu=[ 0.000000 -0.000006 -30.392258 -39.549602 ](dB)
tl=[ 55 ]
f(tl)=[ 0.027000 ](fs=1)
Tl=[ 11.479110 ](Samples)
tu=[ 1 351 ]
f(tu)=[ 0.000000 0.175000 ](fs=1)
Tu=[ 11.523894 11.532802 ](Samples)
pl=[ 29 311 351 ]
f(pl)=[ 0.014000 0.155000 0.175000 ](fs=1)
Pl=[ -1.012924 -11.200626 -12.645780 ](rad./pi)
pu=[ 84 ]
f(pu)=[ 0.041500 ](fs=1)
Pu=[ -2.997700 ](rad./pi)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. Suppress m-file warnings
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog >test.out 
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.out test.ok
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

