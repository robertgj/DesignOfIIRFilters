#!/bin/sh

prog=x2pa_test.m
depends="test/x2pa_test.m test_common.m x2tf.m x2pa.m zp2x.m x2zp.m p2a.m a2p.m \
print_pole_zero.m print_allpass_pole.m spectralfactor.oct qroots.m qzsolve.oct"

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
cat > test.ok << 'EOF'
Caught print_usage: '[a1,V1,Q1,a2,V2,Q2]=x2pa(x,U,V,M,Q,R,tol)' not found
Caught x2pa: function called with too many inputs
Caught print_usage: '[a1,V1,Q1,a2,V2,Q2]=x2pa(x,U,V,M,Q,R,tol)' not found
warning: Caught exception!
expect odd filter order!
warning: Called x2pa at line 38
warning: Called x2pa_test at line 63
Expected failure : x2pa() failed
Ux1=1,Vx1=1,Mx1=2,Qx1=2,Rx1=1
x1 = [   0.0089352554, ...
        -1.0000000000, ...
         0.7945765292, ...
         1.0000000000, ...
         0.7178656135, ...
         0.9013584415, ...
         0.1922386153 ]';
% All-pass single-vector representation
Va1=0,Qa1=2,Ra1=1
a1 = [   0.9013584415, ...
         0.1922386153 ]';
% All-pass single-vector representation
Va2=1,Qa2=0,Ra2=1
a2 = [   0.7945765292 ];
Ux1=1,Vx1=1,Mx1=4,Qx1=4,Rx1=1
x1 = [   0.0118253230, ...
        -1.0000000000, ...
         0.5924047696, ...
         1.0000000000,   1.0000000000, ...
         0.6584170731,   1.0099599353, ...
         0.7148811742,   0.9070588614, ...
         0.3218216480,   0.3928196824 ]';
% All-pass single-vector representation
Va1=0,Qa1=2,Ra1=1
a1 = [   0.7148811742, ...
         0.3218216480 ]';
% All-pass single-vector representation
Va2=1,Qa2=2,Ra2=1
a2 = [   0.5924047696, ...
         0.9070588614, ...
         0.3928196824 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

cat > test_N1_a1_coef.ok << 'EOF'
% All-pass single-vector representation
Va1=0,Qa1=0,Ra1=1
a1 = [ ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N1_a1_coef.ok"; fail; fi

cat > test_N1_a2_coef.ok << 'EOF'
% All-pass single-vector representation
Va2=1,Qa2=0,Ra2=1
a2 = [  -0.5954685460 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N1_a2_coef.ok"; fail; fi

cat > test_N3_a1_coef.ok << 'EOF'
% All-pass single-vector representation
Va1=0,Qa1=2,Ra1=1
a1 = [   0.9013584415, ...
         0.1922386153 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N3_a1_coef.ok"; fail; fi

cat > test_N3_a2_coef.ok << 'EOF'
% All-pass single-vector representation
Va2=1,Qa2=0,Ra2=1
a2 = [   0.7945765292 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N3_a2_coef.ok"; fail; fi

cat > test_N5_a1_coef.ok << 'EOF'
% All-pass single-vector representation
Va1=0,Qa1=2,Ra1=1
a1 = [   0.7148811742, ...
         0.3218216480 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N5_a1_coef.ok"; fail; fi

cat > test_N5_a2_coef.ok << 'EOF'
% All-pass single-vector representation
Va2=1,Qa2=2,Ra2=1
a2 = [   0.5924047696, ...
         0.9070588614, ...
         0.3928196824 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N5_a2_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.out test.ok
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

diff -Bb test_N1_a1_coef.ok x2pa_test_N1_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N1_a1_coef.ok"; fail; fi

diff -Bb test_N1_a2_coef.ok x2pa_test_N1_a2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N1_a2_coef.ok"; fail; fi

diff -Bb test_N3_a1_coef.ok x2pa_test_N3_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N3_a1_coef.ok"; fail; fi

diff -Bb test_N3_a2_coef.ok x2pa_test_N3_a2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N3_a2_coef.ok"; fail; fi

diff -Bb test_N5_a1_coef.ok x2pa_test_N5_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N5_a1_coef.ok"; fail; fi

diff -Bb test_N5_a2_coef.ok x2pa_test_N5_a2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N5_a2_coef.ok"; fail; fi

#
# this much worked
#
pass

