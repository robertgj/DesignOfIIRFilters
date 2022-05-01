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
spectralfactor.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
p2n60.m qroots.m qzsolve.oct"

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
s10_1 = [   0.7939583338,   0.2022123501,  -0.1414060189,  -0.1229253079, ... 
            0.0424433024,   0.0401619080,  -0.0093821333,  -0.0106186261, ... 
           -0.0085040378,   0.0065400527 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi

cat > test.s11.ok << 'EOF'
s11_1 = [   0.9281856517,   0.9833517191,   1.0902072804,   1.0996086831, ... 
            1.0931901800,   1.1009353461,   1.0970627465,   1.0628123938, ... 
            1.0588495387,   0.7225863026 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s11.ok"; fail; fi

cat > test.s20.ok << 'EOF'
s20_1 = [  -0.4667857537,   0.8241951697,  -0.6821207082,   0.4258885406, ... 
           -0.1790473822,   0.0441000000,   0.0000000000,   0.0000000000, ... 
            0.0000000000,   0.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s20.ok"; fail; fi

cat > test.s00.ok << 'EOF'
s00_1 = [   0.5782556253,   0.6397479884,   0.8359015501,   0.9990000000, ... 
            0.9990000000,   0.3875583284,   1.0000000000,   1.0000000000, ... 
            1.0000000000,   1.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s00.ok"; fail; fi

cat > test.s02.ok << 'EOF'
s02_1 = [   0.4667857537,  -0.8241951697,   0.6821207082,  -0.4258885406, ... 
            0.1790473822,  -0.0441000000,  -0.0000000000,  -0.0000000000, ... 
           -0.0000000000,  -0.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s02.ok"; fail; fi

cat > test.s22.ok << 'EOF'
s22_1 = [   0.5782556253,   0.6397479884,   0.8359015501,   0.9990000000, ... 
            0.9990000000,   0.3875583284,   1.0000000000,   1.0000000000, ... 
            1.0000000000,   1.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s22.ok"; fail; fi


# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
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

