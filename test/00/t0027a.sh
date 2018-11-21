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
N=[  -0.0579053233  -0.0707481442  -0.0092422690  -0.0274613547  -0.1104158723  -0.4893868686   0.8949311635   1.0529927756  -0.8682444068  -0.4994993662   0.1864046274   0.0312445612 ]';
R=2,D=[   1.0000000000  -1.4115609553   0.4594959495  -0.0092778518   0.0011187859   0.0014496979  -0.0018385332 ]';
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

