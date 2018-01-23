#!/bin/sh

prog=directFIRhilbert_slb_test.m
depends="test_common.m \
directFIRhilbert_slb_test.m \
directFIRhilbert_slb_exchange_constraints.m \
directFIRhilbert_slb_update_constraints.m \
directFIRhilbert_slb_set_empty_constraints.m \
directFIRhilbert_slb_show_constraints.m \
directFIRhilbert_slb_constraints_are_empty.m \
directFIRhilbert_slb.m \
directFIRhilbert_mmsePW.m \
directFIRhilbertA.m \
directFIRhilbertEsqPW.m \
print_polynomial.m local_max.m"

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
cat > test_hM0.ok << 'EOF'
hM0 = [   0.6309928360,   0.1957554916,   0.1012941390,   0.0572722744, ... 
          0.0318492703,   0.0164616963,   0.0077140676,   0.0037704345 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM0.ok"; fail; fi

cat > test_hM1.ok << 'EOF'
hM1 = [   0.6314916389,   0.2055412904,   0.1171329391,   0.0757677257, ... 
          0.0497936915,   0.0316700530,   0.0184601232,   0.0088822580 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1.ok"; fail; fi

cat > test_hM2.ok << 'EOF'
hM2 = [   0.6215201682,   0.1953915021,   0.1089947924,   0.0711146078, ... 
          0.0497051406,   0.0355023200,   0.0253928197,   0.0176413081 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM2.ok"; fail; fi

#
# run and see if the results match. Suppress m-file warnings
#
echo "Running octave-cli -q " $prog
echo "warning('off');" >> .octaverc

octave-cli -q $prog >test.out 
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM0.ok directFIRhilbert_slb_test_hM0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM0.ok"; fail; fi

diff -Bb test_hM1.ok directFIRhilbert_slb_test_hM1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1.ok"; fail; fi

diff -Bb test_hM2.ok directFIRhilbert_slb_test_hM2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM2.ok"; fail; fi

#
# this much worked
#
pass

