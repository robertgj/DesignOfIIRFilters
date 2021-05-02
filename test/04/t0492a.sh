#!/bin/sh

prog=saramakiFIRcascade_ApproxII_multiband_test.m

depends="saramakiFIRcascade_ApproxII_multiband_test.m test_common.m \
mcclellanFIRsymmetric.m selesnickFIRsymmetric_lowpass.m directFIRsymmetricA.m \
halleyFIRsymmetricA.m directFIRsymmetricEsq.m chebyshevT.m chebyshevP.m \
lagrange_interp.m print_polynomial.m local_max.m local_peak.m xfr2tf.m"

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
cat > test_tap_coef.ok << 'EOF'
aN = [   0.3129835955,   1.2067627712,   0.9218208532,  -1.2698545571, ... 
        -1.4214818200,   0.5675813761,   0.6921669615 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_tap_coef.m "; fail; fi

cat > test_prototype_coef.ok << 'EOF'
hN = [   0.0108151088,   0.0177369180,  -0.0239519611,  -0.0700472296, ... 
         0.0373113899,   0.3045551067,   0.4571405151 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_prototype_coef.m "; fail; fi

cat > test_subfilter_coef.ok << 'EOF'
hM = [   0.0387992748,   0.0340758453,   0.0666153212,  -0.0563330856, ... 
        -0.0901452151,   0.0304951584,  -0.0471249545,   0.0082373858, ... 
        -0.0481509242,   0.0254690581,   0.0214454822,  -0.0595864252, ... 
        -0.0073808648,   0.0235659319,   0.1153460758,   0.1064478219, ... 
        -0.0027298992,   0.1310680361,  -0.0288847206,  -0.1033224269, ... 
        -0.2393709560,  -0.2025373728,   0.2770127253,  -0.1806058042, ... 
        -0.0554313449,  -0.0464020739 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_subfilter_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_tap_coef.ok \
     saramakiFIRcascade_ApproxII_multiband_test_tap_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_tap_coef.m"; fail; fi

diff -Bb test_prototype_coef.ok \
     saramakiFIRcascade_ApproxII_multiband_test_prototype_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_prototype_coef.m"; fail; fi

diff -Bb test_subfilter_coef.ok \
     saramakiFIRcascade_ApproxII_multiband_test_subfilter_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_subfilter_coef.m"; fail; fi

#
# this much worked
#
pass

