#!/bin/sh

prog=schurOneMPAlattice_socp_slb_multiband_test.m

depends="test/schurOneMPAlattice_socp_slb_multiband_test.m \
../tarczynski_parallel_allpass_multiband_test_Da0_coef.m \
../tarczynski_parallel_allpass_multiband_test_Db0_coef.m \
test_common.m delayz.m print_polynomial.m \
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
schurOneMPAlatticedAsqdw.m \
schurOneMPAlattice2tf.m \
schurOneMAPlattice2tf.m \
schurOneMAPlattice2Abcd.m \
tf2schurOneMlattice.m \
schurOneMscale.m \
H2Asq.m H2T.m H2P.m H2dAsqdw.m tf2pa.m qroots.m local_max.m \
complex_zhong_inverse.oct qzsolve.oct Abcd2H.oct \
schurdecomp.oct schurexpand.oct schurOneMlattice2Abcd.oct \
schurOneMAPlattice2H.oct schurOneMlattice2H.oct Abcd2tf.oct"

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
cat > test_A1k.ok << 'EOF'
A1k = [   0.6031452083,   0.5440660093,  -0.0600898532,   0.2166836446, ... 
          0.3743962960,   0.0757780883,   0.2037729229,   0.2688706633, ... 
          0.1116357531,  -0.3415396895,  -0.0347541624,  -0.0222614364, ... 
         -0.3273844955,  -0.2944588366,   0.0117804500,  -0.0902161260, ... 
         -0.3388127296,   0.0060648305,  -0.0669455372,  -0.2332499671 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1k.ok"; fail; fi

cat > test_A1epsilon.ok << 'EOF'
A1epsilon = [  1, -1,  1,  1, ... 
               1, -1, -1, -1, ... 
               1, -1,  1,  1, ... 
               1, -1, -1,  1, ... 
               1,  1, -1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1epsilon.ok"; fail; fi

cat > test_A2k.ok << 'EOF'
A2k = [   0.5323422513,   0.3492266545,  -0.1070427954,   0.3785967333, ... 
          0.3888443681,  -0.2142787199,  -0.1538846661,   0.1390614611, ... 
          0.1826900119,  -0.2863430665,  -0.0386052136,   0.0208341494, ... 
         -0.2369483687,  -0.2174748333,   0.0388758936,  -0.1059565139, ... 
         -0.3583641735,  -0.0186421279,  -0.1150223144,  -0.2431656040 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2k.ok"; fail; fi

cat > test_A2epsilon.ok << 'EOF'
A2epsilon = [  1, -1,  1,  1, ... 
              -1, -1,  1, -1, ... 
               1, -1,  1, -1, ... 
               1, -1, -1,  1, ... 
              -1,  1,  1,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2epsilon.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMPAlattice_socp_slb_multiband_test"

diff -Bb test_A1k.ok $nstr"_A1k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1k.ok"; fail; fi

diff -Bb test_A1epsilon.ok $nstr"_A1epsilon_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A1epsilon.ok"; fail; fi

diff -Bb test_A2k.ok $nstr"_A2k_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2k.ok"; fail; fi

diff -Bb test_A2epsilon.ok $nstr"_A2epsilon_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_A2epsilon.ok"; fail; fi

#
# this much worked
#
pass

