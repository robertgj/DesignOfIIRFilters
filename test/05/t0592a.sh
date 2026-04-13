#!/bin/sh

prog=schurNSPAlattice_socp_slb_lowpass_test.m
depends="test/schurNSPAlattice_socp_slb_lowpass_test.m test_common.m \
../tarczynski_parallel_allpass_test_flat_delay_Da0_coef.m \
../tarczynski_parallel_allpass_test_flat_delay_Db0_coef.m \
schurNSPAlatticeAsq.m \
schurNSPAlatticeT.m \
schurNSPAlatticeP.m \
schurNSPAlatticeEsq.m \
schurNSPAlattice_slb.m \
schurNSPAlattice_slb_constraints_are_empty.m \
schurNSPAlattice_socp_mmse.m \
schurNSPAlattice_slb_exchange_constraints.m \
schurNSPAlattice_slb_set_empty_constraints.m \
schurNSPAlattice_slb_show_constraints.m \
schurNSPAlattice_slb_update_constraints.m \
schurNSPAlattice2tf.m schurNSAPlattice2tf.m schurNSAPlattice2Abcd.m \
tf2schurNSlattice.m local_max.m tf2pa.m print_polynomial.m \
H2Asq.m H2T.m H2P.m \
schurNSscale.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurNSlattice2Abcd.oct Abcd2H.oct Abcd2tf.oct qroots.oct"

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
cat > test_A1s20_coef.m << 'EOF'
A1s20 = [   0.7826304168,  -0.0715436216,  -0.2753677418,  -0.1033031425, ... 
           -0.1063148934,   0.2250369572,  -0.1250591316,   0.0241863033, ... 
            0.1771541431,  -0.1634725706,   0.0455574230 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s20_coef.m"; fail; fi

cat > test_A1s00_coef.m << 'EOF'
A1s00 = [   0.6217787365,   0.9969203549,   0.9612290786,   0.9949596001, ... 
            0.9952094269,   0.9744198794,   0.9927385142,   0.9989872588, ... 
            0.9841731476,   0.9870063706,   0.9989687718 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1s00_coef.m"; fail; fi

cat > test_A2s20_coef.m << 'EOF'
A2s20 = [   0.3670220827,  -0.2966570969,   0.2227826994,   0.2137472062, ... 
           -0.0177139324,   0.0462668007,  -0.1985751936,   0.1845506980, ... 
            0.0089906276,  -0.1825098617,   0.1437228647,  -0.0577824281 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s20_coef.m"; fail; fi

cat > test_A2s00_coef.m << 'EOF'
A2s00 = [   0.9296525005,   0.9539993203,   0.9749972911,   0.9773576196, ... 
            0.9989577418,   0.9988040496,   0.9816631290,   0.9832844929, ... 
            0.9989612678,   0.9835331982,   0.9897782035,   0.9987342674 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2s00_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr=schurNSPAlattice_socp_slb_lowpass_test

diff -Bb test_A1s20_coef.m $nstr"_A1s20_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1s20_coef.m"; fail; fi

diff -Bb test_A1s00_coef.m $nstr"_A1s00_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1s00_coef.m"; fail; fi

diff -Bb test_A2s20_coef.m $nstr"_A2s20_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2s20_coef.m"; fail; fi

diff -Bb test_A2s00_coef.m $nstr"_A2s00_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2s00_coef.m"; fail; fi

#
# this much worked
#
pass

