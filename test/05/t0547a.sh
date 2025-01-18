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
tf2schurNSlattice.m local_max.m x2tf.m tf2pa.m print_polynomial.m \
sqp_bfgs.m armijo_kim.m updateWbfgs.m invSVD.m H2Asq.m H2T.m KW.m p2n60.m \
schurNSlattice2Abcd.oct schurNSscale.oct Abcd2H.oct spectralfactor.oct \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct qroots.m qzsolve.oct \
Abcd2tf.oct"

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
s10_2 = [  -0.5455641117,  -1.1796608296,  -1.3183659915,  -0.5084196176, ... 
            1.2799086240,   1.1512930556,   0.5867343115,  -0.2816699622, ... 
           -0.5804802866,  -0.1720577660,   0.2529169056,  -0.5956111812, ... 
           -0.4479295193,  -0.3962827696,   1.4947394695,   1.3216001293, ... 
           -0.8396431811,   0.0394447506,   0.4937516994,   0.0075536940 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi

cat > test.s11.ok << 'EOF'
s11_2 = [   0.9963187340,   0.7647178626,   0.8944538664,   1.1350207335, ... 
            1.2318043678,   0.7191083680,   1.0720298252,   1.1512028559, ... 
            1.4296188213,   1.3570146852,   3.1238499960,   0.7589154197, ... 
            0.5872098698,   2.3587807001,   2.7512852828,   1.9451040265, ... 
            0.9817414197,   0.3753096910,   1.1618664685,   0.0441168299 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s11.ok"; fail; fi

cat > test.s20.ok << 'EOF'
s20_2 = [   0.0000000000,   0.2296789714,   0.0000000000,   0.5310880322, ... 
            0.0000000000,   0.4654455866,   0.0000000000,   0.5323578456, ... 
            0.0000000000,  -0.1539912632,   0.0000000000,  -0.3284837727, ... 
            0.0000000000,   0.5727035520,   0.0000000000,   0.9990000000, ... 
            0.0000000000,  -0.4549281392,   0.0000000000,   0.1215766546 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s20.ok"; fail; fi

cat > test.s00.ok << 'EOF'
s00_2 = [   1.0000000000,   0.4304707389,   1.0000000000,   0.8136550353, ... 
            1.0000000000,   0.8570125954,   1.0000000000,   0.9192785414, ... 
            1.0000000000,   0.9990000000,   1.0000000000,   0.7186802702, ... 
            1.0000000000,   0.9032048197,   1.0000000000,   0.9990000000, ... 
            1.0000000000,   0.5590235947,   1.0000000000,   0.7757650757 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s00.ok"; fail; fi

cat > test.s02.ok << 'EOF'
s02_2 = [  -0.0000000000,  -0.7435495124,  -0.0000000000,  -0.9990000000, ... 
           -0.0000000000,  -0.3589102359,  -0.0000000000,  -0.5249601199, ... 
           -0.0000000000,  -0.3017501791,  -0.0000000000,  -0.5507362580, ... 
           -0.0000000000,  -0.3199724996,  -0.0000000000,  -0.5403694270, ... 
           -0.0000000000,   0.0116215565,  -0.0000000000,  -0.6715374450 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s02.ok"; fail; fi

cat > test.s22.ok << 'EOF'
s22_2 = [   1.0000000000,   0.2013078460,   1.0000000000,   0.3317443588, ... 
            1.0000000000,   0.6024974813,   1.0000000000,   0.9635435061, ... 
            1.0000000000,   0.8673252673,   1.0000000000,   0.9900208878, ... 
            1.0000000000,   0.9976768984,   1.0000000000,   0.0257515147, ... 
            1.0000000000,   0.9990000000,   1.0000000000,   0.9925820455 ];
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

