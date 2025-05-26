#!/bin/sh

prog=qp_hilbert_test.m
depends="test/qp_hilbert_test.m test_common.m directFIRhilbertEsqPW.m \
print_polynomial.m"

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
cat > test_hM_coef.m << 'EOF'
hM = [  0.0002574103,  0.0003585881,  0.0004787633,  0.0006199268, ... 
        0.0007841803,  0.0009737426,  0.0011909593,  0.0014383152, ... 
        0.0017184501,  0.0020341802,  0.0023885252,  0.0027847429, ... 
        0.0032263738,  0.0037172976,  0.0042618057,  0.0048646933, ... 
        0.0055313780,  0.0062680520,  0.0070818794,  0.0079812534, ... 
        0.0089761354,  0.0100785059,  0.0113029719,  0.0126675974, ... 
        0.0141950568,  0.0159142667,  0.0178627437,  0.0200900946, ... 
        0.0226633273,  0.0256751956,  0.0292578122,  0.0336058698, ... 
        0.0390184331,  0.0459793040,  0.0553250507,  0.0686370642, ... 
        0.0893056970,  0.1261483151,  0.2114995129,  0.6363837968 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM_coef.m qp_hilbert_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM_coef.m"; fail; fi

#
# this much worked
#
pass

