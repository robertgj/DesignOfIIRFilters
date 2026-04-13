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
cat > test_h_coef.ok << 'EOF'
h = [ -0.0016663357, -0.0005569311,  0.0015609866,  0.0026312639, ... 
       0.0006608813, -0.0030961389, -0.0042912454, -0.0002068808, ... 
       0.0057854560,  0.0064118109, -0.0011565520, -0.0099072521, ... 
      -0.0088172230,  0.0040467379,  0.0159839250,  0.0112961453, ... 
      -0.0095007109, -0.0250744703, -0.0136006325,  0.0197719665, ... 
       0.0400835342,  0.0154765990, -0.0421443857, -0.0730442881, ... 
      -0.0166989583,  0.1272992425,  0.2831702822,  0.3504661835, ... 
       0.2831702822,  0.1272992425, -0.0166989583, -0.0730442881, ... 
      -0.0421443857,  0.0154765990,  0.0400835342,  0.0197719665, ... 
      -0.0136006325, -0.0250744703, -0.0095007109,  0.0112961453, ... 
       0.0159839250,  0.0040467379, -0.0088172230, -0.0099072521, ... 
      -0.0011565520,  0.0064118109,  0.0057854560, -0.0002068808, ... 
      -0.0042912454, -0.0030961389,  0.0006608813,  0.0026312639, ... 
       0.0015609866, -0.0005569311, -0.0016663357 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRsymmetric_kyp_lowpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.ok"; fail; fi

#
# this much worked
#
pass
