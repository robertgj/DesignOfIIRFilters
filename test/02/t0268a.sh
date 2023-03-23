#!/bin/sh

prog=schurOneMAPlattice_frm_hilbert_socp_slb_test.m

depends="test/schurOneMAPlattice_frm_hilbert_socp_slb_test.m test_common.m \
../tarczynski_frm_halfband_test_r0_coef.m \
../tarczynski_frm_halfband_test_aa0_coef.m \
schurOneMAPlattice_frm_hilbert_socp_mmse.m \
schurOneMAPlattice_frm_hilbert_slb.m \
schurOneMAPlattice_frm_hilbert_slb_constraints_are_empty.m \
schurOneMAPlattice_frm_hilbert_slb_exchange_constraints.m \
schurOneMAPlattice_frm_hilbert_slb_set_empty_constraints.m \
schurOneMAPlattice_frm_hilbert_slb_show_constraints.m \
schurOneMAPlattice_frm_hilbert_slb_update_constraints.m \
schurOneMAPlattice_frm_hilbert_socp_slb_plot.m schurOneMAPlattice2tf.m \
schurOneMAPlattice_frm_hilbertEsq.m schurOneMAPlattice_frm_hilbertT.m \
schurOneMAPlattice_frm_hilbertAsq.m schurOneMAPlattice_frm_hilbertP.m \
schurOneMAPlatticeP.m schurOneMAPlatticeT.m tf2schurOneMlattice.m \
schurOneMAPlattice2Abcd.m Abcd2tf.m tf2pa.m H2Asq.m H2P.m H2T.m \
schurOneMscale.m local_max.m print_polynomial.m print_pole_zero.m \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct spectralfactor.oct \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
qroots.m qzsolve.oct"

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
cat > test_k2_coef.m << 'EOF'
k2 = [  -0.5737973427,  -0.1357905114,  -0.0532786375,  -0.0211277419, ... 
        -0.0087726879 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2_coef.m"; fail; fi

cat > test_epsilon2_coef.m << 'EOF'
epsilon2 = [ -1,  1,  1,  1, ... 
              1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_epsilon2_coef.m"; fail; fi

cat > test_u2_coef.m << 'EOF'
u2 = [  -0.0009286412,  -0.0025491082,  -0.0071011297,  -0.0128201595, ... 
        -0.0309917540,  -0.0342912227,  -0.0517524688,  -0.0569899755, ... 
         0.4399047223 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_u2_coef.m"; fail; fi

cat > test_v2_coef.m << 'EOF'
v2 = [   0.0065502342,   0.0043736075,   0.0072012541,   0.0020581423, ... 
        -0.0078892530,  -0.0311821987,  -0.0808713504,  -0.3144298329 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_v2_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_k2_coef.m schurOneMAPlattice_frm_hilbert_socp_slb_test_k2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k2_coef.m"; fail; fi

diff -Bb test_epsilon2_coef.m \
     schurOneMAPlattice_frm_hilbert_socp_slb_test_epsilon2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_epsilon2_coef.m"; fail; fi

diff -Bb test_u2_coef.m schurOneMAPlattice_frm_hilbert_socp_slb_test_u2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_u2_coef.m"; fail; fi

diff -Bb test_v2_coef.m schurOneMAPlattice_frm_hilbert_socp_slb_test_v2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_v2_coef.m"; fail; fi

#
# this much worked
#
pass

