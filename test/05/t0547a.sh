#!/bin/sh

prog=schurNSlattice_sqp_slb_bandpass_test.m
depends="schurNSlattice_sqp_slb_bandpass_test.m \
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
s10_2 = [   1.3507071547,  -1.1820186779,  -1.6437276195,  -0.6380884326, ... 
            0.9272982801,   0.9861605953,   0.6154409027,  -0.1139088806, ... 
           -0.4659695764,  -0.2674966421,   0.0903048044,  -0.7035690227, ... 
           -0.5433156193,  -0.3103331374,   0.2207050416,   0.1445594437, ... 
           -0.3011949729,  -0.0550808850,   0.1208662286,   0.0034907888 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi

cat > test.s11.ok << 'EOF'
s11_2 = [   2.2304566168,   0.4194937020,   0.8585195304,   1.2143640329, ... 
            1.4247109681,   0.9355494463,   1.0127998365,   1.1176643194, ... 
            1.4575950818,   1.3025932727,   3.0164777518,   0.9601971808, ... 
            0.5184476060,   1.5323890850,   1.5734520136,   1.2372118495, ... 
            1.4810941494,   0.8150901337,   0.6003197163,   0.1793359191 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s11.ok"; fail; fi

cat > test.s20.ok << 'EOF'
s20_2 = [   0.0000000000,  -0.0103649490,   0.0000000000,   0.4562501142, ... 
            0.0000000000,   0.3013742707,   0.0000000000,   0.3161227445, ... 
            0.0000000000,   0.1976081866,   0.0000000000,   0.1526246705, ... 
            0.0000000000,   0.4817726007,   0.0000000000,   0.9995000000, ... 
            0.0000000000,  -0.4893175223,   0.0000000000,   0.1215766546 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s20.ok"; fail; fi

cat > test.s00.ok << 'EOF'
s00_2 = [   1.0000000000,   0.6439903342,   1.0000000000,   0.5628274523, ... 
            1.0000000000,   0.6302257235,   1.0000000000,   0.9408796863, ... 
            1.0000000000,   0.9995000000,   1.0000000000,   0.9833424566, ... 
            1.0000000000,   0.6334137245,   1.0000000000,   0.9995000000, ... 
            1.0000000000,   0.5851065461,   1.0000000000,   0.4652669135 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s00.ok"; fail; fi

cat > test.s02.ok << 'EOF'
s02_2 = [  -0.0000000000,  -0.9961709211,  -0.0000000000,  -0.5526613224, ... 
           -0.0000000000,  -0.1915872102,  -0.0000000000,  -0.5348203616, ... 
           -0.0000000000,  -0.1077532145,  -0.0000000000,  -0.7235143011, ... 
           -0.0000000000,  -0.4342404272,  -0.0000000000,  -0.3969491302, ... 
           -0.0000000000,  -0.1181655975,  -0.0000000000,  -0.3495541241 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s02.ok"; fail; fi

cat > test.s22.ok << 'EOF'
s22_2 = [   1.0000000000,   0.6598661199,   1.0000000000,   0.5971500059, ... 
            1.0000000000,   0.8696260047,   1.0000000000,   0.9995000000, ... 
            1.0000000000,   0.9951059199,   1.0000000000,   0.9995000000, ... 
            1.0000000000,   0.9995000000,   1.0000000000,   0.7824300935, ... 
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

