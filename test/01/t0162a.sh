#!/bin/sh

prog=labudde_test.m

descr="labudde_test.m (mfile)"

depends="test/labudde_test.m labudde.m test_common.m check_octave_file.m tf2Abcd.m"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED ${0#$here"/"} $descr 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED ${0#$here"/"} $descr
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
Using labudde mfile
d=[  1.0000000000000000
-10.1056655234449586
 46.8017429779240715
-131.0797709418646377
 246.6262448531584255
-327.2492857402048116
 312.4364383270706185
-214.6036226093469281
 103.9185724124888139
-33.7843355785909765
 6.6363989830178109
-0.5967165560107490
]
max(max(abs(A)))=327.249
rcond(A)=5.54491e-06
poly(A)=[  1.0000000000000000
-10.1056655234449710
 46.8017429779241922
-131.0797709418651209
 246.6262448531596760
-327.2492857402065738
 312.4364383270723238
-214.6036226093478660
 103.9185724124893113
-33.7843355785911115
 6.6363989830178385
-0.5967165560107505
]
norm(d-poly(A))=2.99522e-12
warning: Using m-file version of function labudde()!
warning: called from
    labudde at line 14 column 3
    labudde_test at line 29 column 1

labudde(A)=[ -10.1056655234449586
 46.8017429779240715
-131.0797709418646377
 246.6262448531584255
-327.2492857402048116
 312.4364383270706185
-214.6036226093469281
 103.9185724124888139
-33.7843355785909765
 6.6363989830178109
-0.5967165560107490
]
norm(d(2:end)-labudde(A))=0
poly(A)=[  1.0000000000000000
-0.0000000000000095
 1.8669208760999940
-0.0000000000000157
 2.2147829705999902
-0.0000000000000137
 2.2883188634999905
-0.0000000000000085
 2.0751642793999956
-0.0000000000000037
 1.5701398180999981
-0.0000000000000009
 1.0247030921999996
 0.0000000000000002
 0.5684534800999999
 0.0000000000000003
 0.2633896209999994
 0.0000000000000001
 0.0887207127999999
-0.0000000000000000
 0.0197382406999999
]
norm(d0-poly(A))=2.92264e-14
warning: Using m-file version of function labudde()!
warning: called from
    labudde at line 14 column 3
    labudde_test at line 50 column 1

labudde(A)=[ -0.0000000000000000
 1.8669208761000000
 0.0000000000000000
 2.2147829706000000
 0.0000000000000000
 2.2883188634999998
 0.0000000000000000
 2.0751642794000000
 0.0000000000000000
 1.5701398180999999
 0.0000000000000000
 1.0247030922000002
 0.0000000000000000
 0.5684534801000001
 0.0000000000000000
 0.2633896210000000
 0.0000000000000000
 0.0887207128000000
 0.0000000000000000
 0.0197382407000000
]
norm(d0(2:end)-labudde(A))=2.57768e-16
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $descr"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $descr"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

