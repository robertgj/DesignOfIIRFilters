#!/bin/sh

prog=contfrac_test.m

depends="contfrac_test.m test_common.m contfrac.m \
Abcd2tf.m tf2Abcd.m KW.m optKW.m svf.m crossWelch.m p2n60.m qroots.m \
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
cat > test.ok << 'EOF'
N = 5
fc = 0.050000
n60 = 211
Acf =
   1.1807   0.3007        0        0        0
   1.0000   0.1114  -0.7030        0        0
        0   1.0000   1.2927   0.0152        0
        0        0   1.0000   0.7376  -0.2019
        0        0        0   1.0000   1.0175

Bcf =
   0.016346
          0
          0
          0
          0

Ccf =
   1   0   0   0   0

Dcf = 8.3020e-03
max(abs(b-bcf))=0.000000
max(abs(a-acf))=0.000000
ngcf = 126.69
ngdir = 5.8334e+05
ngoptdir = 0.9282
ngopt = 0.9282
est_varydcf = 42.312
varydcf = 47.585
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

