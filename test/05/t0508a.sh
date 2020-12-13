#!/bin/sh

prog=directFIRnonsymmetric_sdp_minimum_phase_test.m
depends="directFIRnonsymmetric_sdp_minimum_phase_test.m test_common.m \
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
g = [  -0.7022909484,   0.2847330285,  -0.1959905565,  -0.3103281845, ... 
       -0.1359074843,   0.0076349413,  -0.0135268001,  -0.0683102725, ... 
       -0.0193636018,   0.0885464727,   0.1235615871,   0.0528449545, ... 
       -0.0355194468,  -0.0600981700,  -0.0298456162,  -0.0002509105, ... 
        0.0038265647,  -0.0015448306,   0.0005274493,   0.0065173677, ... 
        0.0069821659,   0.0022525896,  -0.0014155034,  -0.0016824081, ... 
       -0.0007339142,  -0.0003125880,  -0.0001900302,   0.0000364879, ... 
        0.0001733733,  -0.0000381841,   0.0000371612 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_g.ok"; fail; fi


#
# run and see if the results match. 
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
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

