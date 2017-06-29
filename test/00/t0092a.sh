#!/bin/sh

prog=parallel_allpass_delay_socp_slb_test.m

depends="parallel_allpass_delay_socp_slb_test.m test_common.m \
parallel_allpass_delayAsq.m \
parallel_allpass_delayT.m \
parallel_allpass_delay_slb.m \
parallel_allpass_delay_slb_constraints_are_empty.m \
parallel_allpass_delay_slb_exchange_constraints.m \
parallel_allpass_delay_slb_set_empty_constraints.m \
parallel_allpass_delay_slb_show_constraints.m \
parallel_allpass_delay_slb_update_constraints.m \
parallel_allpass_delay_socp_mmse.m \
allpassP.m allpassT.m tf2a.m a2tf.m \
aConstraints.m print_polynomial.m local_max.m SeDuMi_1_3/"

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
cat > test_Da1_coef.m.ok << 'EOF'
Da1 = [   1.0000000000,  -0.5309207779,   0.3596778262,   0.1918749899, ... 
          0.0368764697,  -0.0537876390,  -0.0708690080,  -0.0412674263, ... 
         -0.0028480451,   0.0194176547,   0.0215207341,   0.0129527154, ... 
          0.0044735847 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
diff -Bb test_Da1_coef.m.ok parallel_allpass_delay_socp_slb_test_Da1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_Da1_coef.m"; fail; fi

#
# this much worked
#
pass

