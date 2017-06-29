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
s10_2 = [   1.2139594607,   0.4304107497,  -0.0657111836,  -0.1192373164, ... 
           -0.0293352869,   0.0362349326,   0.0262123098,  -0.0035236357, ... 
           -0.0110221712,  -0.0028759866 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi
cat > test.s11.ok << 'EOF'
s11_2 = [   0.8919273371,   0.9504891000,   1.0238729354,   0.9816052186, ... 
            1.0024899597,   0.9974867686,   0.9867379008,   0.9784074832, ... 
            0.9798971101,   0.6734090254 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi
cat > test.s20.ok << 'EOF'
s20_2 = [  -0.5844569147,   0.7162787641,  -0.5418853725,  -0.1260310922, ... 
            0.9385382288,   0.0441000000,   0.0000000000,   0.0000000000, ... 
            0.0000000000,   0.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s20.ok"; fail; fi
cat > test.s00.ok << 'EOF'
s00_2 = [   0.7910940345,   0.6134643655,   0.7865221075,   0.8637318641, ... 
            0.9722121569,   0.9974928780,   1.0000000000,   1.0000000000, ... 
            1.0000000000,   1.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s00.ok"; fail; fi
cat > test.s02.ok << 'EOF'
s02_2 = [   0.8659608466,  -0.7738763974,   0.6742136699,  -0.5215951411, ... 
            0.3939054328,  -0.2505521537,  -0.0000000000,  -0.0000000000, ... 
           -0.0000000000,  -0.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s02.ok"; fail; fi
cat > test.s22.ok << 'EOF'
s22_2 = [   0.7710543164,   0.9130256527,   0.9672191401,   0.9355878103, ... 
            0.6110976463,   0.9990271218,   1.0000000000,   1.0000000000, ... 
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

