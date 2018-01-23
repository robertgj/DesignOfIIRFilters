#!/bin/sh

prog=parallel_allpass_socp_slb_bandpass_alternate_test.m

depends="parallel_allpass_socp_slb_bandpass_alternate_test.m test_common.m \
parallel_allpassAsq.m parallel_allpassT.m parallel_allpass_slb.m \
parallel_allpass_slb_constraints_are_empty.m \
parallel_allpass_slb_exchange_constraints.m \
parallel_allpass_slb_set_empty_constraints.m \
parallel_allpass_slb_show_constraints.m \
parallel_allpass_slb_update_constraints.m \
parallel_allpass_socp_mmse.m allpassP.m allpassT.m tf2a.m a2tf.m \
aConstraints.m print_polynomial.m print_pole_zero.m local_max.m \
SeDuMi_1_3/"

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
cat > test_a1_coef.m.ok << 'EOF'
Ua1=0,Va1=2,Ma1=0,Qa1=14,Ra1=1
a1 = [                  1, ...
          -0.650694750904,     0.641976793648, ...
           0.545417190455,     0.535020961632,     0.823215031041,     0.701327202289, ... 
           0.797839324473,     0.818569922763,     0.858593896168, ...
            2.70723008441,      2.09181927976,     0.342396891307,      0.86708920612, ... 
            1.09100961832,      1.29791573439,      1.57186255143 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi
cat > test_b1_coef.m.ok << 'EOF'
Ub1=0,Vb1=2,Mb1=0,Qb1=14,Rb1=1
b1 = [                  1, ...
          -0.613680342429,     0.324785993319, ...
           0.329464143575,     0.396441031918,     0.775947618468,     0.801155464136, ... 
           0.776974657704,     0.869233005775,     0.535780641379, ...
            2.82022974385,      2.26266999398,     0.371334255285,     0.622560016029, ... 
           0.852208331102,      1.57330469257,      1.23369429349 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
diff -Bb test_a1_coef.m.ok parallel_allpass_socp_slb_bandpass_alternate_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi
diff -Bb test_b1_coef.m.ok parallel_allpass_socp_slb_bandpass_alternate_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_b1_coef.m"; fail; fi

#
# this much worked
#
pass

