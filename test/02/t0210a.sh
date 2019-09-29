#!/bin/sh

prog=schurOneMlattice_sqp_mmse_test.m
depends="schurOneMlattice_sqp_mmse_test.m test_common.m \
schurOneMlatticeAsq.m schurOneMlatticeT.m schurOneMlatticeP.m \
schurOneMlatticeEsq.m \
schurOneMlattice_sqp_mmse.m schurOneMlattice2Abcd.oct schurOneMscale.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_sqp_slb_lowpass_plot.m \
schurOneMlattice_slb_constraints_are_empty.m tf2schurOneMlattice.m \
schurOneMlattice2tf.m local_max.m x2tf.m tf2pa.m print_polynomial.m \
Abcd2tf.m sqp_bfgs.m armijo_kim.m updateWbfgs.m invSVD.m H2Asq.m H2T.m H2P.m \
spectralfactor.oct schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct schurOneMlattice2H.oct qroots.m qzsolve.oct"

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
cat > test_c1_coef.m << 'EOF'
c1 = [   0.4235666622,   1.4256617929,   0.2134457942,  -0.1144663495, ... 
        -0.0958080838,  -0.0108274736,   0.0226812644,   0.0170747376, ... 
        -0.0004555453,  -0.0074631233,  -0.0042243988 ]';
EOF
cat > test_k1_coef.m << 'EOF'
k1 = [  -0.7432402594,   0.7412708564,  -0.6637630565,   0.5224790139, ... 
        -0.3134962086,   0.1008754402,   0.0000000000,   0.0000000000, ... 
         0.0000000000,   0.0000000000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_c1_coef.m schurOneMlattice_sqp_mmse_test_c1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_c1_coef.m"; fail; fi
diff -Bb test_k1_coef.m schurOneMlattice_sqp_mmse_test_k1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k1_coef.m"; fail; fi

#
# this much worked
#
pass

