#!/bin/sh

prog=schurOneMAPlattice_frm_hilbert_socp_mmse_test.m

depends=" schurOneMAPlattice_frm_hilbert_socp_mmse_test.m test_common.m \
schurOneMAPlattice_frm_hilbert_socp_mmse.m \
schurOneMAPlattice_frm_hilbert_socp_slb_plot.m schurOneMAPlattice2tf.m \
schurOneMAPlattice_frm_hilbert_slb_set_empty_constraints.m \
schurOneMAPlattice_frm_hilbertEsq.m schurOneMAPlattice_frm_hilbertT.m \
schurOneMAPlattice_frm_hilbertAsq.m schurOneMAPlattice_frm_hilbertP.m \
schurOneMAPlatticeP.m schurOneMAPlatticeT.m tf2schurOneMlattice.m \
schurOneMAPlattice2Abcd.m Abcd2tf.m tf2pa.m schurOneMscale.m \
H2Asq.m H2P.m H2T.m schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
spectralfactor.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
print_polynomial.m print_pole_zero.m SeDuMi_1_3/"

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
cat > test_k1_coef.m << 'EOF'
k1 = [  -0.5099436936,  -0.0872481086,  -0.0155261159,   0.0041218037, ... 
         0.0081475994 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1_coef.m"; fail; fi
cat > test_u1_coef.m << 'EOF'
u1 = [  -0.0009414887,  -0.0035972631,  -0.0084814488,  -0.0139396820, ... 
        -0.0260180195,  -0.0354290819,  -0.0470579278,  -0.0524673226, ... 
         0.4454570642 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_u1_coef.m"; fail; fi
cat > test_v1_coef.m << 'EOF'
v1 = [   0.0030475646,   0.0038389396,   0.0045772678,  -0.0005084086, ... 
        -0.0120880182,  -0.0353881633,  -0.0848593896,  -0.3122680937 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_v1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_k1_coef.m schurOneMAPlattice_frm_hilbert_socp_mmse_test_k1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k1_coef.m"; fail; fi
diff -Bb test_u1_coef.m schurOneMAPlattice_frm_hilbert_socp_mmse_test_u1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_u1_coef.m"; fail; fi
diff -Bb test_v1_coef.m schurOneMAPlattice_frm_hilbert_socp_mmse_test_v1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_v1_coef.m"; fail; fi

#
# this much worked
#
pass

