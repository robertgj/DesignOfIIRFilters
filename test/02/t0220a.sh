#!/bin/sh

prog=schurNSlattice_sqp_mmse_test.m
depends="test_common.m \
schurNSlattice_sqp_mmse_test.m \
schurNSlatticeAsq.m \
schurNSlatticeT.m \
schurNSlatticeEsq.m \
schurNSlattice_slb_constraints_are_empty.m \
schurNSlattice_sqp_mmse.m \
schurNSlattice_slb_set_empty_constraints.m \
schurNSlattice_sqp_slb_lowpass_plot.m \
schurNSlattice2tf.m \
schurNSlatticeFilter.m \
tf2schurNSlattice.m local_max.m x2tf.m tf2pa.m print_polynomial.m Abcd2tf.m \
sqp_bfgs.m armijo_kim.m updateWbfgs.m invSVD.m H2Asq.m H2T.m svf.m \
crossWelch.m schurNSlattice2Abcd.oct schurNSscale.oct Abcd2H.oct \
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
s10_1 = [   0.7855089310,   0.1945543434,  -0.1437054127,  -0.0682346234, ... 
            0.0182732845,   0.0310669018,   0.0031044251,  -0.0116835861, ... 
           -0.0051724249,   0.0025323276 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi
cat > test.s11.ok << 'EOF'
s11_1 = [   0.7465996197,   0.8765349021,   0.8701165742,   0.8416807572, ... 
            0.9610514126,   0.9989856164,   1.0312744701,   1.0434862346, ... 
            1.0317992739,   0.6942909617 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi
cat > test.s20.ok << 'EOF'
s20_1 = [  -0.8584627477,   0.6832248673,  -0.4149637129,   0.2541129173, ... 
           -0.1508929628,   0.0441000000,   0.0000000000,   0.0000000000, ... 
            0.0000000000,   0.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s20.ok"; fail; fi
cat > test.s00.ok << 'EOF'
s00_1 = [   0.8225851545,   0.9990000000,   0.9458479042,   0.8304099195, ... 
            0.8914614492,   0.9990000000,   1.0000000000,   1.0000000000, ... 
            1.0000000000,   1.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s00.ok"; fail; fi
cat > test.s02.ok << 'EOF'
s02_1 = [   0.8584627477,  -0.6832248673,   0.4149637129,  -0.2541129173, ... 
            0.1508929628,  -0.0441000000,  -0.0000000000,  -0.0000000000, ... 
           -0.0000000000,  -0.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s02.ok"; fail; fi
cat > test.s22.ok << 'EOF'
s22_1 = [   0.8225851545,   0.9990000000,   0.9458479042,   0.8304099195, ... 
            0.8914614492,   0.9990000000,   1.0000000000,   1.0000000000, ... 
            1.0000000000,   1.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s22.ok"; fail; fi


# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog 
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.s10.ok schurNSlattice_sqp_mmse_test_s10_1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s10.ok"; fail; fi
diff -Bb test.s11.ok schurNSlattice_sqp_mmse_test_s11_1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s11.ok"; fail; fi
diff -Bb test.s20.ok schurNSlattice_sqp_mmse_test_s20_1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s20.ok"; fail; fi
diff -Bb test.s00.ok schurNSlattice_sqp_mmse_test_s00_1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s00.ok"; fail; fi
diff -Bb test.s02.ok schurNSlattice_sqp_mmse_test_s02_1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s02.ok"; fail; fi
diff -Bb test.s22.ok schurNSlattice_sqp_mmse_test_s22_1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s22.ok"; fail; fi

#
# this much worked
#
pass

