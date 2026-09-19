#!/bin/sh

prog=directFIRsymmetric_kyp_lowpass_test.m
depends="test/directFIRsymmetric_kyp_lowpass_test.m \
test_common.m print_polynomial.m directFIRsymmetricEsqPW.m \
mcclellanFIRsymmetric.m local_max.m lagrange_interp.m xfr2tf.m \
directFIRsymmetricA.m"

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
cat > test_hM_coef.ok << 'EOF'
hM = [ -0.0019872047, -0.0008797393,  0.0014350253,  0.0027093396, ... 
        0.0008791462, -0.0030039612, -0.0044885565, -0.0005166492, ... 
        0.0057162767,  0.0067124007, -0.0007719917, -0.0098692061, ... 
       -0.0092197279,  0.0036031976,  0.0159964961,  0.0118010915, ... 
       -0.0090204161, -0.0251576404, -0.0142002835,  0.0192836776, ... 
        0.0402527646,  0.0161531411, -0.0416772606, -0.0733049145, ... 
       -0.0174297418,  0.1268772329,  0.2835127105,  0.3512067393 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM_coef.ok directFIRsymmetric_kyp_lowpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM_coef.ok"; fail; fi

#
# this much worked
#
pass
