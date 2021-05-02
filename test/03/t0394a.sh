#!/bin/sh

prog=johanssonOneMlattice_slb_update_constraints_test.m
depends="johanssonOneMlattice_slb_update_constraints_test.m \
johanssonOneMlattice_slb_update_constraints.m \
johanssonOneMlattice_slb_set_empty_constraints.m \
johanssonOneMlattice_slb_show_constraints.m \
test_common.m johanssonOneMlatticeAzp.m \
tf2schurOneMlattice.m phi2p.m tfp2g.m tf2pa.m local_max.m \
qroots.m schurOneMAPlatticeP.m schurOneMscale.m schurOneMAPlattice2Abcd.m H2P.m \
qzsolve.oct schurOneMlattice2Abcd.oct complex_zhong_inverse.oct \
schurOneMAPlattice2H.oct schurdecomp.oct schurexpand.oct spectralfactor.oct"

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
tol = 5.0000e-06
verbose = 1
fapl = 0.1500
fasl = 0.1750
fasu = 0.2725
fapu = 0.3000
Wap = 1
Was = 1
delta_p = 1.0000e-06
delta_s = 1.0000e-06
nf = 2000
al=[ 799 877 1018 ]
au=[ 1 557 701 1091 1201 2001 ]
al=[ 799 877 1018 ]
f(al)=[ 0.199500 0.219000 0.254250 ](fs=1)
Al=[ -0.040000 -0.040000 -0.039997 ]
au=[ 1 557 701 1091 1201 2001 ]
f(au)=[ 0.000000 0.139000 0.175000 0.272500 0.300000 0.500000 ](fs=1)
Au=[ 1.040000 1.040000 0.943488 0.968832 1.039957 1.040000 ]
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

