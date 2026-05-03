#!/bin/sh

prog=affineFIRsymmetric_lowpass_test.m

depends="test/affineFIRsymmetric_lowpass_test.m affineFIRsymmetric_lowpass.m \
test_common.m print_polynomial.m frefine.m local_max.m directFIRsymmetricA.m \
qroots.oct \
"

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
cat > test_hM.ok << 'EOF'
hM = [  -0.0016551520,  -0.0027783777,  -0.0005171370,   0.0026235094, ... 
         0.0019336938,  -0.0030846807,  -0.0039371316,   0.0024321630, ... 
         0.0066450125,  -0.0005630072,  -0.0091657174,  -0.0032011321, ... 
         0.0109865752,   0.0087729793,  -0.0109051505,  -0.0161695147, ... 
         0.0078856054,   0.0247709211,  -0.0003890766,  -0.0338934586, ... 
        -0.0135529949,   0.0424814655,   0.0384072308,  -0.0495724194, ... 
        -0.0898700098,   0.0542201599,   0.3127176041,   0.4441450570 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok affineFIRsymmetric_lowpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

#
# this much worked
#
pass

