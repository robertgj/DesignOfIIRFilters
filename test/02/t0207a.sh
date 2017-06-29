#!/bin/sh

prog=spectralfactor_test.m
descr="spectralfactor_test.m (octfile)"
depends="spectralfactor_test.m test_common.m spectralfactor.oct \
print_polynomial.m"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $descr 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $descr
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
q = [   0.5917998530,  -7.4348525716,  43.3620602699, -155.4416670444, ... 
      382.0923169709, -680.0769447401, 901.6923564871, -901.6923564871, ... 
      680.0769447401, -382.0923169709, 155.4416670444, -43.3620602699, ... 
        7.4348525716,  -0.5917998530 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. Suppress m-file warnings
#
echo "Running octave-cli -q " $prog
echo "warning('off');" >> .octaverc

octave-cli -q $prog >test.out
if [ $? -ne 0 ]; then echo "Failed running $descr"; fail; fi

diff -Bb spectralfactor_test_q_coef.m test.ok
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

