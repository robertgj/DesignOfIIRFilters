#!/bin/sh

prog=schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test.m
depends="test/schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test.m \
test_common.m \
WISEJ_PA.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeP.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticedAsqdw.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlatticeDoublyPipelinedAsq.m \
schurOneMPAlatticeDoublyPipelinedT.m \
schurOneMPAlatticeDoublyPipelinedP.m \
schurOneMPAlatticeDoublyPipelineddAsqdw.m \
schurOneMPAlatticeDoublyPipelinedEsq.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedT.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedP.m \
schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw.m \
schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq.m \
schurOneMPAlatticeDoublyPipelinedAntiAliased_slb.m \
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_mmse.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlattice2tf.m \
schurOneMAPlattice2tf.m \
schurOneMAPlattice2Abcd.m \
schurOneMAPlatticeDoublyPipelined2Abcd.m \
schurOneMAPlatticeDoublyPipelined2H.m \
tf2schurOneMlattice.m \
schurOneMscale.m \
delayz.m local_max.m tf2pa.m print_polynomial.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
spectralfactor.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct Abcd2H.oct Abcd2tf.oct \
qroots.oct" 

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
cat > test_A1k2_coef.m << 'EOF'
A1k2 = [  -0.4760206713,   0.1877445243,   0.0185339753 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k2_coef.m"; fail; fi

cat > test_A2k2_coef.m << 'EOF'
A2k2 = [  -0.3577672060,   0.3079349406,  -0.2422022688,   0.0465366304 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k2_coef.m"; fail; fi

cat > test_Aaa1k2_coef.m << 'EOF'
Aaa1k2 = [   0.0000000000,   0.0890749848 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Aaa1k2_coef.m"; fail; fi

cat > test_Aaa2k2_coef.m << 'EOF'
Aaa2k2 = [   0.0000000000,   0.5244553627,   0.0000000000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Aaa2k2_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test"

diff -Bb test_A1k2_coef.m $nstr"_A1k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k2_coef.m"; fail; fi

diff -Bb test_A2k2_coef.m $nstr"_A2k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k2_coef.m"; fail; fi

diff -Bb test_Aaa1k2_coef.m $nstr"_Aaa1k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Aaa1k2_coef.m"; fail; fi

diff -Bb test_Aaa2k2_coef.m $nstr"_Aaa2k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Aaa2k2_coef.m"; fail; fi


#
# this much worked
#
pass

