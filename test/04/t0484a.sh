#!/bin/sh

prog=schurOneMPAlattice_socp_slb_multiband_test.m

depends="schurOneMPAlattice_socp_slb_multiband_test.m \
../tarczynski_parallel_allpass_multiband_test_Da0_coef.m \
../tarczynski_parallel_allpass_multiband_test_Db0_coef.m \
test_common.m print_polynomial.m \
schurOneMPAlattice_slb.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlattice_socp_slb_lowpass_plot.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticeP.m \
schurOneMPAlattice2tf.m \
schurOneMAPlattice2tf.m \
schurOneMAPlattice2Abcd.m \
tf2schurOneMlattice.m \
schurOneMscale.m \
H2Asq.m H2T.m H2P.m tf2pa.m qroots.m local_max.m \
complex_zhong_inverse.oct qzsolve.oct Abcd2H.oct \
schurdecomp.oct schurexpand.oct schurOneMlattice2Abcd.oct \
schurOneMAPlattice2H.oct schurOneMlattice2H.oct"

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
cat > test_A1kpcls.ok << 'EOF'
A1kpcls = [  -0.2254153593,   0.5413552388,   0.7603120559,  -0.1739725315, ... 
              0.3354327431,   0.3197288879,  -0.0590239839,   0.2032569461, ... 
              0.3448962116,   0.1860738716,   0.0742055681,   0.2957810649 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1kpcls.ok"; fail; fi

cat > test_A1epsilon0.ok << 'EOF'
A1epsilon0 = [ -1, -1,  1,  1, ... 
               -1, -1, -1, -1, ... 
                1, -1, -1,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon0.ok"; fail; fi

cat > test_A2kpcls.ok << 'EOF'
A2kpcls = [  -0.0151136014,   0.6692940959,   0.7883609206,  -0.1989819311, ... 
              0.2387353034,   0.2194296106,  -0.1770162343,   0.1277756550, ... 
              0.3407386299,   0.2029305733,   0.0357158301,   0.3014251287 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2kpcls.ok"; fail; fi

cat > test_A2epsilon0.ok << 'EOF'
A2epsilon0 = [ -1, -1,  1,  1, ... 
               -1, -1,  1, -1, ... 
                1, -1, -1,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2epsilon0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMPAlattice_socp_slb_multiband_test"

diff -Bb test_A1kpcls.ok $nstr"_A1kpcls_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1kpcls.ok"; fail; fi

diff -Bb test_A1epsilon0.ok $nstr"_A1epsilon0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1epsilon0.ok"; fail; fi

diff -Bb test_A2kpcls.ok $nstr"_A2kpcls_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2kpcls.ok"; fail; fi

diff -Bb test_A2epsilon0.ok $nstr"_A2epsilon0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2epsilon0.ok"; fail; fi

#
# this much worked
#
pass

