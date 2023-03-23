#!/bin/sh

prog=schurNSlattice_sqp_slb_bandpass_test.m
depends="test/schurNSlattice_sqp_slb_bandpass_test.m \
test_common.m \
schurNSlatticeAsq.m \
schurNSlatticeT.m \
schurNSlatticeEsq.m \
schurNSlattice_slb.m \
schurNSlattice_slb_constraints_are_empty.m \
schurNSlattice_sqp_mmse.m \
schurNSlattice_slb_exchange_constraints.m \
schurNSlattice_slb_set_empty_constraints.m \
schurNSlattice_slb_show_constraints.m \
schurNSlattice_slb_update_constraints.m \
schurNSlattice_sqp_slb_bandpass_plot.m \
schurNSlattice2tf.m \
schurNSlatticeFilter.m \
crossWelch.m \
tf2schurNSlattice.m local_max.m x2tf.m tf2pa.m print_polynomial.m Abcd2tf.m \
sqp_bfgs.m armijo_kim.m updateWbfgs.m invSVD.m H2Asq.m H2T.m KW.m p2n60.m \
schurNSlattice2Abcd.oct schurNSscale.oct Abcd2H.oct spectralfactor.oct \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct qroots.m qzsolve.oct"

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
cat > test.s10.ok << 'EOF'
s10_2 = [   1.1982748037,  -1.2597728611,  -1.6233410972,  -0.5997049897, ... 
            0.9982265097,   1.0120343898,   0.5933868988,  -0.1607613690, ... 
           -0.4898843328,  -0.2741564072,   0.0998863662,  -0.8176734627, ... 
           -0.5334533481,  -0.2914227863,   0.2576370075,   0.1553509410, ... 
           -0.2955846923,  -0.0549844725,   0.1408984852,   0.0030518433 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi

cat > test.s11.ok << 'EOF'
s11_2 = [   2.3547789567,   0.4526484852,   0.8658658676,   1.2313287402, ... 
            1.4233264123,   0.9447810730,   1.0144989253,   1.1159644303, ... 
            1.4676479655,   1.3115770244,   2.9847622369,   0.9593530290, ... 
            0.5071572859,   1.5230072404,   1.5813201875,   1.2442750840, ... 
            1.5031333885,   0.7951123219,   0.6012008211,   0.1760856374 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s11.ok"; fail; fi

cat > test.s20.ok << 'EOF'
s20_2 = [   0.0000000000,  -0.0616903588,   0.0000000000,   0.4788369334, ... 
            0.0000000000,   0.2806806733,   0.0000000000,   0.3214029581, ... 
            0.0000000000,   0.1771552795,   0.0000000000,   0.1085226405, ... 
            0.0000000000,   0.5623312263,   0.0000000000,   0.9995000000, ... 
            0.0000000000,  -0.4579827469,   0.0000000000,   0.1215766546 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s20.ok"; fail; fi

cat > test.s00.ok << 'EOF'
s00_2 = [   1.0000000000,   0.6015702535,   1.0000000000,   0.5651781546, ... 
            1.0000000000,   0.6367949055,   1.0000000000,   0.9419804568, ... 
            1.0000000000,   0.9995000000,   1.0000000000,   0.9940995400, ... 
            1.0000000000,   0.6377660448,   1.0000000000,   0.9995000000, ... 
            1.0000000000,   0.5989182413,   1.0000000000,   0.4577769299 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s00.ok"; fail; fi

cat > test.s02.ok << 'EOF'
s02_2 = [  -0.0000000000,  -0.9995000000,  -0.0000000000,  -0.4935228884, ... 
           -0.0000000000,  -0.2375465427,  -0.0000000000,  -0.4724957994, ... 
           -0.0000000000,  -0.1109187578,  -0.0000000000,  -0.7354877589, ... 
           -0.0000000000,  -0.4396317784,  -0.0000000000,  -0.3799666368, ... 
           -0.0000000000,  -0.1018439118,  -0.0000000000,  -0.3478706620 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s02.ok"; fail; fi

cat > test.s22.ok << 'EOF'
s22_2 = [   1.0000000000,   0.8758284602,   1.0000000000,   0.5073522918, ... 
            1.0000000000,   0.8285926520,   1.0000000000,   0.9977995890, ... 
            1.0000000000,   0.9959146745,   1.0000000000,   0.9995000000, ... 
            1.0000000000,   0.9995000000,   1.0000000000,   0.7222364027, ... 
            1.0000000000,   0.9995000000,   1.0000000000,   0.9925820455 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s22.ok"; fail; fi


# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.s10.ok schurNSlattice_sqp_slb_bandpass_test_s10_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s10.ok"; fail; fi

diff -Bb test.s11.ok schurNSlattice_sqp_slb_bandpass_test_s11_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s11.ok"; fail; fi

diff -Bb test.s20.ok schurNSlattice_sqp_slb_bandpass_test_s20_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s20.ok"; fail; fi

diff -Bb test.s00.ok schurNSlattice_sqp_slb_bandpass_test_s00_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s00.ok"; fail; fi

diff -Bb test.s02.ok schurNSlattice_sqp_slb_bandpass_test_s02_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s02.ok"; fail; fi

diff -Bb test.s22.ok schurNSlattice_sqp_slb_bandpass_test_s22_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s22.ok"; fail; fi

#
# this much worked
#
pass

