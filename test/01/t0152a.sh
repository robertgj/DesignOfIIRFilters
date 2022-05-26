#!/bin/sh

prog=svcascf_test.m

depends="test/svcascf_test.m test_common.m \
svcascf.m pq2svcasc.m butter2pq.m pq2blockKWopt.m KW.m optKW.m optKW2.m \
svcasc2Abcd.m svf.m svcasc2noise.m"

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
est_varydf=  15.893, varydf=  15.458
est_varydfx=   5.333, varydfx=   5.409
std(xx1)=[  31.6  31.8  31.9  31.5  31.8  31.8  31.9  31.9  32.1  32.6 ]
std(xx2)=[  31.6  31.8  32.0  31.3  32.0  31.8  31.9  32.0  32.4   0.0 ]
std(y)=[ 168.7 312.3 392.5 365.5 296.6 208.1 139.6  93.5  66.8  58.3 ]
std(xx1f)=[  31.6  31.8  32.0  31.5  31.9  31.9  32.0  32.0  32.2  32.7 ]
std(xx2f)=[  31.6  31.9  32.1  31.4  32.0  31.9  32.0  32.1  32.5   0.0 ]
std(yf)=[ 168.9 312.7 393.2 366.2 297.3 208.8 140.1  93.8  67.1  58.6 ]
std(xx1fx)=[  63.2  63.5  63.9  63.0  63.7  63.7  31.9  31.9  32.1  32.6 ]
std(xx2fx)=[  63.2  63.6  64.0  62.6  64.0  63.6  32.0  32.0  32.4   0.0 ]
std(yfx)=[ 168.7 312.3 392.6 365.6 296.7 208.3 139.7  93.6  66.9  58.4 ]
EOF

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.out"; fail; fi

#
# this much worked
#
pass

