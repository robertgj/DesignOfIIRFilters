#!/bin/sh

prog=directFIRnonsymmetric_sdp_minimum_phase_test.m
depends="test/directFIRnonsymmetric_sdp_minimum_phase_test.m test_common.m \
print_polynomial.m direct_form_scale.m qroots.m \
qzsolve.oct"

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
g = [  -0.7022907826,   0.2847332477,  -0.1959905123,  -0.3103282544, ... 
       -0.1359076605,   0.0076346931,  -0.0135270106,  -0.0683103330, ... 
       -0.0193634994,   0.0885466430,   0.1235617100,   0.0528449801, ... 
       -0.0355194918,  -0.0600982301,  -0.0298456541,  -0.0002509196, ... 
        0.0038265729,  -0.0015448186,   0.0005274575,   0.0065173714, ... 
        0.0069821670,   0.0022525893,  -0.0014155052,  -0.0016824109, ... 
       -0.0007339162,  -0.0003125879,  -0.0001900286,   0.0000364893, ... 
        0.0001733736,  -0.0000381845,   0.0000371610 ]';
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

