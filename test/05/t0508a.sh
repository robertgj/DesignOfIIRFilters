#!/bin/sh

prog=directFIRnonsymmetric_sdp_minimum_phase_test.m
depends="test/directFIRnonsymmetric_sdp_minimum_phase_test.m test_common.m \
print_polynomial.m direct_form_scale.m"

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
cat > test_h.ok << 'EOF'
h = [  -0.0051083338,   0.0036606718,  -0.0123833961,  -0.0069477504, ... 
        0.0214489452,   0.0429736315,   0.0254155306,  -0.0087244497, ... 
       -0.0047830223,   0.0270726002,   0.0007468185,  -0.1103597308, ... 
       -0.1818750481,  -0.0737069035,   0.1565385061,   0.2775217495, ... 
        0.1565385061,  -0.0737069035,  -0.1818750481,  -0.1103597308, ... 
        0.0007468185,   0.0270726002,  -0.0047830223,  -0.0087244497, ... 
        0.0254155306,   0.0429736315,   0.0214489452,  -0.0069477504, ... 
       -0.0123833961,   0.0036606718,  -0.0051083338 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h.ok"; fail; fi

cat > test_g.ok << 'EOF'
g = [  -0.7022904930,   0.2847335775,  -0.1959905192,  -0.3103283722, ... 
       -0.1359078591,   0.0076343920,  -0.0135273063,  -0.0683104460, ... 
       -0.0193633770,   0.0885468715,   0.1235618707,   0.0528450070, ... 
       -0.0355195460,  -0.0600982885,  -0.0298456856,  -0.0002509322, ... 
        0.0038265683,  -0.0015448166,   0.0005274657,   0.0065173804, ... 
        0.0069821719,   0.0022525897,  -0.0014155070,  -0.0016824130, ... 
       -0.0007339175,  -0.0003125881,  -0.0001900280,   0.0000364900, ... 
        0.0001733738,  -0.0000381846,   0.0000371609 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_g.ok"; fail; fi


#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

name_str="directFIRnonsymmetric_sdp_minimum_phase_test"

diff -Bb test_h.ok $name_str"_h_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h.ok"; fail; fi

diff -Bb test_g.ok $name_str"_g_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_g.ok"; fail; fi

#
# this much worked
#
pass

