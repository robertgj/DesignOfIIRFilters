#!/bin/sh

prog=qp_lowpass_test.m
depends="test/qp_lowpass_test.m test_common.m directFIRnonsymmetricEsqPW.m \
directFIRsymmetricEsqPW.m mcclellanFIRsymmetric.m local_max.m \
delayz.m print_polynomial.m lagrange_interp.m xfr2tf.m directFIRsymmetricA.m"

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
cat > test_h_coef.m << 'EOF'
h = [ -0.0011416422, -0.0064608157,  0.0006753211,  0.0126461978, ... 
       0.0066188281, -0.0171074193, -0.0218078604,  0.0130944715, ... 
       0.0434468525,  0.0086576279, -0.0666514847, -0.0664970801, ... 
       0.0846011495,  0.3038505994,  0.4086342531,  0.3038505994, ... 
       0.0846011495, -0.0664970801, -0.0666514847,  0.0086576279, ... 
       0.0434468525,  0.0130944715, -0.0218078604, -0.0171074193, ... 
       0.0066188281,  0.0126461978,  0.0006753211, -0.0064608157, ... 
      -0.0011416422 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m"; fail; fi

cat > test_hPM_coef.m << 'EOF'
hPM = [ -0.0020635021, -0.0059268488, -0.0016828636,  0.0086378543, ... 
         0.0092366641, -0.0095751683, -0.0221620427,  0.0023748967, ... 
         0.0391203496,  0.0202373167, -0.0564064614, -0.0755218675, ... 
         0.0694063134,  0.3072652182,  0.4257585421 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hPM_coef.m"; fail; fi

cat > test_hd_coef.m << 'EOF'
hd = [ -0.0064568376,  0.0176100874,  0.0172866593, -0.0343904802, ... 
       -0.0617718242,  0.0535160208,  0.2862616171,  0.4308766500, ... 
        0.3289847569,  0.0755113812, -0.0911385497, -0.0697468599, ... 
        0.0256869785,  0.0532070232,  0.0067851239, -0.0310934802, ... 
       -0.0197169928,  0.0101206833,  0.0190744260,  0.0043894934, ... 
       -0.0112491933, -0.0104888468,  0.0024066303,  0.0097488053, ... 
        0.0033589647, -0.0057520650, -0.0049210939,  0.0020153765, ... 
        0.0033685316 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hd_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr=qp_lowpass_test

diff -Bb test_h_coef.m $nstr"_h_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

diff -Bb test_hPM_coef.m $nstr"_hPM_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hPM_coef.m"; fail; fi

diff -Bb test_hd_coef.m $nstr"_hd_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hd_coef.m"; fail; fi

#
# this much worked
#
pass

