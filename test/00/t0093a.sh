#!/bin/sh

prog=parallel_allpass_socp_slb_flat_delay_test.m

depends="parallel_allpass_socp_slb_flat_delay_test.m test_common.m \
parallel_allpassAsq.m parallel_allpassT.m parallel_allpass_slb.m \
parallel_allpass_slb_constraints_are_empty.m \
parallel_allpass_slb_exchange_constraints.m \
parallel_allpass_slb_set_empty_constraints.m \
parallel_allpass_slb_show_constraints.m \
parallel_allpass_slb_update_constraints.m \
parallel_allpass_socp_mmse.m allpassP.m allpassT.m tf2a.m a2tf.m \
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
Da1 = [   1.0000000000,   0.3931432341,  -0.2660133321,  -0.0850275861, ... 
         -0.2707651069,  -0.0298153197,   0.1338823243,  -0.0589362474, ... 
          0.1650490792,   0.0296371262,  -0.1113859180,   0.0372881323 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m.ok"; fail; fi
cat > test_Db1_coef.m.ok << 'EOF'
Db1 = [   1.0000000000,  -0.1344939785,  -0.0918734630,   0.4461033862, ... 
         -0.1115261080,   0.1180340147,   0.0396352218,  -0.2006006436, ... 
          0.2105512466,  -0.0838522576,  -0.1001537312,   0.1080994566, ... 
         -0.0610732672 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
diff -Bb test_Da1_coef.m.ok parallel_allpass_socp_slb_flat_delay_test_Da1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_Da1_coef.m"; fail; fi
diff -Bb test_Db1_coef.m.ok parallel_allpass_socp_slb_flat_delay_test_Db1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_Db1_coef.m"; fail; fi

#
# this much worked
#
pass

