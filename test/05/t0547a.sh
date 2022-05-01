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
s10_2 = [  -1.0288718839,  -1.1184794631,  -1.1305457940,  -0.3994118796, ... 
            0.6495260150,   0.8797786923,   0.5194872510,   0.0278874028, ... 
           -0.2700374795,  -0.2673294818,  -0.2407350786,  -0.3134865057, ... 
           -0.4015144379,  -0.4770528066,   0.1494433523,   0.3518122386, ... 
           -0.0566241397,  -0.0910429986,   0.1104601241,   0.0086479547 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi

cat > test.s11.ok << 'EOF'
s11_2 = [   1.1033956479,   0.4797080289,   0.8457931473,   1.1934368535, ... 
            1.2303035527,   1.0265299446,   1.0018319758,   1.0976199212, ... 
            1.2693578049,   1.1762342259,   2.2694270202,   0.9573677643, ... 
            0.8675724098,   1.7054864742,   1.8834394983,   1.3741435787, ... 
            0.9218328193,   0.9084074375,   0.5361121243,   0.1624653802 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s11.ok"; fail; fi

cat > test.s20.ok << 'EOF'
s20_2 = [   0.0000000000,   0.2789289002,   0.0000000000,   0.4738160345, ... 
            0.0000000000,   0.1110715048,   0.0000000000,   0.7524109233, ... 
            0.0000000000,  -0.3545256505,   0.0000000000,   0.6841646396, ... 
            0.0000000000,   0.6388185752,   0.0000000000,   0.0893236895, ... 
            0.0000000000,   0.4171639517,   0.0000000000,   0.1215766546 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s20.ok"; fail; fi

cat > test.s00.ok << 'EOF'
s00_2 = [   1.0000000000,   0.6851052221,   1.0000000000,   0.6642376480, ... 
            1.0000000000,   0.8261828590,   1.0000000000,   0.9166217056, ... 
            1.0000000000,   0.8817659936,   1.0000000000,   0.9581917334, ... 
            1.0000000000,   0.9999000000,   1.0000000000,   0.9999000000, ... 
            1.0000000000,   0.6817184047,   1.0000000000,   0.3982839595 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s00.ok"; fail; fi

cat > test.s02.ok << 'EOF'
s02_2 = [  -0.0000000000,  -0.5445240481,  -0.0000000000,  -0.9076894482, ... 
           -0.0000000000,  -0.2935210590,  -0.0000000000,  -0.4210212698, ... 
           -0.0000000000,  -0.2908939533,  -0.0000000000,  -0.7051997903, ... 
           -0.0000000000,  -0.6246296284,  -0.0000000000,  -0.2698032687, ... 
           -0.0000000000,  -0.1379674421,  -0.0000000000,  -0.2855884344 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s02.ok"; fail; fi

cat > test.s22.ok << 'EOF'
s22_2 = [   1.0000000000,   0.3787908750,   1.0000000000,   0.1979577816, ... 
            1.0000000000,   0.6636797152,   1.0000000000,   0.8251418597, ... 
            1.0000000000,   0.9868092822,   1.0000000000,   0.9931978328, ... 
            1.0000000000,   0.6709070229,   1.0000000000,   0.9999000000, ... 
            1.0000000000,   0.9999000000,   1.0000000000,   0.9925820455 ];
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

