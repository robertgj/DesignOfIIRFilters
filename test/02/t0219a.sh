#!/bin/sh

prog=schurNSlattice_sqp_slb_lowpass_test.m
depends="test_common.m \
schurNSlattice_sqp_slb_lowpass_test.m \
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
schurNSlattice_sqp_slb_lowpass_plot.m \
schurNSlattice2tf.m \
schurNSlatticeFilter.m \
tf2schurNSlattice.m local_max.m x2tf.m tf2pa.m print_polynomial.m Abcd2tf.m \
sqp_bfgs.m armijo_kim.m updateWbfgs.m invSVD.m H2Asq.m H2T.m KW.m \
schurNSlattice2Abcd.oct schurNSscale.oct Abcd2H.oct \
spectralfactor.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct"

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
cat > test.s10.ok << 'EOF'
s10_2 = [   1.2139419930,   0.4304059022,  -0.0656959400,  -0.1192121543, ... 
           -0.0293251799,   0.0362480031,   0.0262194473,  -0.0035242832, ... 
           -0.0110231645,  -0.0028759874 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi
cat > test.s11.ok << 'EOF'
s11_2 = [   0.8918954144,   0.9504763204,   1.0238373543,   0.9815439037, ... 
            1.0024084992,   0.9973992486,   0.9866505979,   0.9783213860, ... 
            0.9798049050,   0.6733483509 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi
cat > test.s20.ok << 'EOF'
s20_2 = [  -0.5844231610,   0.7162389926,  -0.5418612137,  -0.1260675215, ... 
            0.9382494796,   0.0441000000,   0.0000000000,   0.0000000000, ... 
            0.0000000000,   0.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s20.ok"; fail; fi
cat > test.s00.ok << 'EOF'
s00_2 = [   0.7911075018,   0.6134592163,   0.7865004248,   0.8636902299, ... 
            0.9721392269,   0.9982843062,   1.0000000000,   1.0000000000, ... 
            1.0000000000,   1.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s00.ok"; fail; fi
cat > test.s02.ok << 'EOF'
s02_2 = [   0.8659540042,  -0.7738757952,   0.6742106097,  -0.5215937537, ... 
            0.3939031824,  -0.2505335707,  -0.0000000000,  -0.0000000000, ... 
           -0.0000000000,  -0.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s02.ok"; fail; fi
cat > test.s22.ok << 'EOF'
s22_2 = [   0.7710592513,   0.9130240184,   0.9672016120,   0.9355766734, ... 
            0.6110847951,   0.9990271218,   1.0000000000,   1.0000000000, ... 
            1.0000000000,   1.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s22.ok"; fail; fi


# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog 
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.s10.ok schurNSlattice_sqp_slb_lowpass_test_s10_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s10.ok"; fail; fi
diff -Bb test.s11.ok schurNSlattice_sqp_slb_lowpass_test_s11_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s11.ok"; fail; fi
diff -Bb test.s20.ok schurNSlattice_sqp_slb_lowpass_test_s20_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s20.ok"; fail; fi
diff -Bb test.s00.ok schurNSlattice_sqp_slb_lowpass_test_s00_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s00.ok"; fail; fi
diff -Bb test.s02.ok schurNSlattice_sqp_slb_lowpass_test_s02_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s02.ok"; fail; fi
diff -Bb test.s22.ok schurNSlattice_sqp_slb_lowpass_test_s22_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s22.ok"; fail; fi

#
# this much worked
#
pass

