#!/bin/sh

prog=tarczynski_hilbert_test.m

depends="tarczynski_hilbert_test.m test_common.m"
tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
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
N=[  -0.0579060329  -0.0707485922  -0.0092411885  -0.0274591873  -0.1104148108  -0.4893876574   0.8949321301   1.0529986698  -0.8682556384  -0.4995082652   0.1864128112   0.0312466802 ]';
R=2,D=[   1.0000000000  -1.4115743676   0.4595123498  -0.0092821060   0.0011188759   0.0014499657  -0.0018384568 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok tarczynski_hilbert_test.coef
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

