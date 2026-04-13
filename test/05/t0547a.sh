#!/bin/sh

prog=schurNSlattice_sqp_slb_bandpass_R2_test.m
depends="test/schurNSlattice_sqp_slb_bandpass_R2_test.m \
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
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct qroots.oct \
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
s10_2 = [   2.2803563599,  -0.9555019636,  -1.3602221952,  -0.5393568040, ... 
            0.6731850137,   1.0007716084,   0.6475502615,  -0.0800191166, ... 
           -0.4187840518,  -0.1614445533,   0.2003929962,  -0.3527693940, ... 
           -0.4911017323,  -0.2059245875,   0.1711867718,   0.1585242748, ... 
           -0.0662183309,  -0.0069927966,   0.1152787251,   0.0076970123 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi

cat > test.s11.ok << 'EOF'
s11_2 = [   2.2438510908,   0.6062981322,   0.7505437972,   1.1531350082, ... 
            1.3007092251,   1.0061479250,   1.0182761006,   1.0854881958, ... 
            1.3394605544,   1.2412666701,   2.8213448592,   0.9424124884, ... 
            0.7394759407,   0.9694463090,   1.6773885153,   1.2243866218, ... 
            1.5486437970,   0.8350170329,   0.4454508163,   0.1632850804 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s11.ok"; fail; fi

cat > test.s20.ok << 'EOF'
s20_2 = [   0.0000000000,  -0.0435661060,   0.0000000000,   0.6311086588, ... 
            0.0000000000,   0.2937491270,   0.0000000000,   0.4410527237, ... 
            0.0000000000,   0.1256087729,   0.0000000000,   0.3733365337, ... 
            0.0000000000,  -0.3874871574,   0.0000000000,   0.4632415139, ... 
            0.0000000000,   0.2958558243,   0.0000000000,   0.1215766546 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s20.ok"; fail; fi

cat > test.s00.ok << 'EOF'
s00_2 = [   1.0000000000,   0.2383088949,   1.0000000000,   0.4694251365, ... 
            1.0000000000,   0.7362085195,   1.0000000000,   0.9304132068, ... 
            1.0000000000,   0.8919681044,   1.0000000000,   0.8326151744, ... 
            1.0000000000,   0.9388998322,   1.0000000000,   0.9675817154, ... 
            1.0000000000,   0.9322007362,   1.0000000000,   0.5383002787 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s00.ok"; fail; fi

cat > test.s02.ok << 'EOF'
s02_2 = [  -0.0000000000,  -0.9990007583,  -0.0000000000,   0.6225461379, ... 
           -0.0000000000,  -0.3310398249,  -0.0000000000,  -0.5179923661, ... 
           -0.0000000000,  -0.3435564333,  -0.0000000000,  -0.7588241971, ... 
           -0.0000000000,  -0.1875794170,  -0.0000000000,  -0.5092126948, ... 
           -0.0000000000,  -0.0287826886,  -0.0000000000,  -0.2745973478 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s02.ok"; fail; fi

cat > test.s22.ok << 'EOF'
s22_2 = [   1.0000000000,  -0.9983659440,   1.0000000000,  -0.9986338449, ... 
            1.0000000000,   0.9990000000,   1.0000000000,   0.9990000000, ... 
            1.0000000000,   0.9990000000,   1.0000000000,   0.9609394856, ... 
            1.0000000000,   0.9990000000,   1.0000000000,   0.7658127457, ... 
            1.0000000000,   0.5750843070,   1.0000000000,   0.9925820455 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s22.ok"; fail; fi


# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurNSlattice_sqp_slb_bandpass_R2_test"

diff -Bb test.s10.ok $nstr"_s10_2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s10.ok"; fail; fi

diff -Bb test.s11.ok $nstr"_s11_2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s11.ok"; fail; fi

diff -Bb test.s20.ok $nstr"_s20_2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s20.ok"; fail; fi

diff -Bb test.s00.ok $nstr"_s00_2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s00.ok"; fail; fi

diff -Bb test.s02.ok $nstr"_s02_2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s02.ok"; fail; fi

diff -Bb test.s22.ok $nstr"_s22_2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s22.ok"; fail; fi

#
# this much worked
#
pass

