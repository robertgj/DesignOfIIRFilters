#!/bin/sh

prog=schurOneMlattice_socp_slb_lowpass_test.m

depends="schurOneMlattice_socp_slb_lowpass_test.m test_common.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticeEsq.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_socp_mmse.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMlattice_socp_slb_lowpass_plot.m \
schurOneMlattice2Abcd.oct \
schurOneMscale.m \
tf2schurOneMlattice.m \
schurOneMlattice2tf.m \
local_max.m tf2pa.m x2tf.m print_polynomial.m Abcd2tf.m H2Asq.m H2T.m H2P.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2H.oct qroots.m qzsolve.oct"

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
cat > test.k2.ok << 'EOF'
k2 = [  -0.6631682809,   0.6512632407,  -0.5324236207,   0.3544054773, ... 
        -0.1741481051,   0.0475035201,   0.0000000000,   0.0000000000, ... 
         0.0000000000,   0.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi

cat > test.epsilon2.ok << 'EOF'
epsilon2 = [ -1, -1, -1, -1, ... 
              1, -1, -1, -1, ... 
             -1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon2.ok"; fail; fi

cat > test.p2.ok << 'EOF'
p2 = [   1.0207387596,   0.4593598149,   0.9995678820,   0.5521399302, ... 
         0.7997303689,   0.9535729966,   1.0000000000,   1.0000000000, ... 
         1.0000000000,   1.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p2.ok"; fail; fi

cat > test.c2.ok << 'EOF'
c2 = [   0.4475725859,   0.8865147894,   0.0987203220,  -0.1374367914, ... 
        -0.0510576335,   0.0175974728,   0.0222771171,   0.0003591311, ... 
        -0.0078383316,  -0.0034880757,  -0.0000523229 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k2.ok schurOneMlattice_socp_slb_lowpass_test_k2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of k2.coef"; fail; fi

diff -Bb test.epsilon2.ok schurOneMlattice_socp_slb_lowpass_test_epsilon2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of epsilon2.coef"; fail; fi

diff -Bb test.p2.ok schurOneMlattice_socp_slb_lowpass_test_p2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of p2.coef"; fail; fi

diff -Bb test.c2.ok schurOneMlattice_socp_slb_lowpass_test_c2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of c2.coef"; fail; fi

#
# this much worked
#
pass
