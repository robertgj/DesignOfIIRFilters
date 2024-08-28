#!/bin/sh

prog=schurOneMPAlatticeDelay_socp_slb_lowpass_test.m
depends="test/schurOneMPAlatticeDelay_socp_slb_lowpass_test.m test_common.m \
schurOneMPAlatticeAsq.m \
schurOneMPAlatticeT.m \
schurOneMPAlatticeP.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlattice_slb.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMPAlattice_socp_mmse.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlattice2tf.m \
schurOneMAPlattice2tf.m \
schurOneMAPlattice2Abcd.m \
tf2schurOneMlattice.m \
schurOneMPAlatticeDelay_wise_lowpass.m \
schurOneMscale.m local_max.m tf2pa.m print_polynomial.m \
H2Asq.m H2T.m H2P.m WISEJ_DA.m delayz.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
qroots.m qzsolve.oct Abcd2tf.oct"

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
cat > test_m_12_A1k0_coef.m << 'EOF'
A1k0 = [  -0.4492691343,   0.5684256170,   0.2696696406,   0.0320010324, ... 
          -0.0944885667,  -0.1045315661,  -0.0521127082,   0.0029394135, ... 
           0.0284695149,   0.0260929611,   0.0131969934,   0.0034481329 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_m_12_A1k0_coef.m"; fail; fi

cat > test_m_12_A1k_coef.m << 'EOF'
A1k = [  -0.4530542361,   0.5781728907,   0.2628131000,   0.0076641040, ... 
         -0.1283105496,  -0.1389062973,  -0.0795356965,  -0.0125620789, ... 
          0.0241394981,   0.0278898111,   0.0160165189,   0.0049058482 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_m_12_A1k_coef.m"; fail; fi

cat > test_m_5_A1k0_coef.m << 'EOF'
A1k0 = [  -0.5887890122,   0.3794825489,   0.2077136416,   0.0867433777, ... 
           0.0216280074 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_m_5_A1k0_coef.m"; fail; fi

cat > test_m_5_A1k_coef.m << 'EOF'
A1k = [  -0.5662109737,   0.4317358628,   0.2428077171,   0.1078009224, ... 
          0.0303444618 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_m_5_A1k_coef.m"; fail; fi

cat > test_m_4_A1k0_coef.m << 'EOF'
A1k0 = [  -0.6638132441,   0.2505320693,   0.1181636675,   0.0344485236 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_m_4_A1k0_coef.m"; fail;
fi

cat > test_m_4_A1k_coef.m << 'EOF'
A1k = [  -0.5566685968,   0.3859785252,   0.1963580494,   0.0681598694 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_m_4_A1k_coef.m"; fail;
fi

#
# run and see if the results match
#
echo "Running $prog"

nstr="schurOneMPAlatticeDelay_socp_slb_lowpass_test"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_m_12_A1k0_coef.m $nstr"_m_12_A1k0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_m_12_A1k0_coef.m"; fail; fi

diff -Bb test_m_12_A1k_coef.m $nstr"_m_12_A1k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_m_12_A1k_coef.m"; fail; fi

diff -Bb test_m_5_A1k0_coef.m $nstr"_m_5_A1k0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_m_5_A1k0_coef.m"; fail; fi

diff -Bb test_m_5_A1k_coef.m $nstr"_m_5_A1k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_m_5_A1k_coef.m"; fail; fi

diff -Bb test_m_4_A1k0_coef.m $nstr"_m_4_A1k0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_m_4_A1k0_coef.m"; fail; fi

diff -Bb test_m_4_A1k_coef.m $nstr"_m_4_A1k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_m_4_A1k_coef.m"; fail; fi

#
# this much worked
#
pass

