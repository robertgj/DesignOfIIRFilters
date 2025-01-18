#!/bin/sh

prog=yalmip_dualize_test.m

depends="test/yalmip_dualize_test.m test_common.m"

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
Xa=
   9.0000  -4.7029   9.0000
  -4.7029   2.4575  -4.7029
   9.0000  -4.7029   9.0000
isdefinite(Xa)=0
Ya=
   2.4575  -0.7623  -0.7623
  -0.7623   0.2364   0.2364
  -0.7623   0.2364   0.2364
isdefinite(Ya)=0
Xb=
   9.0000  -4.7029   9.0000
  -4.7029   2.4575  -4.7029
   9.0000  -4.7029   9.0000
isdefinite(Xb)=1
Yb=
   2.4575  -0.7623  -0.7623
  -0.7623   0.2364   0.2364
  -0.7623   0.2364   0.2364
isdefinite(Yb)=1
norm(Xa-Xb)= 9.34e-06
norm(Ya-Yb)=1.468e-05
ta=    2.549
tb=    2.549
tc=    2.549
norm(ta-tb)=1.436e-09
norm(ta-tc)=3.004e-09
norm(tb-tc)=1.568e-09
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok yalmip_dualize_test.results
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

