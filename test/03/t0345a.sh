#!/bin/sh

prog=parallel_allpass_socp_slb_bandpass_hilbert_test.m

depends="parallel_allpass_socp_slb_bandpass_hilbert_test.m test_common.m \
parallel_allpassAsq.m parallel_allpassT.m parallel_allpassP.m \
parallel_allpass_slb.m \
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
Ua1=0,Va1=2,Ma1=0,Qa1=10,Ra1=1
a1 = [   1.0000000000, ...
        -0.7257854627,   0.0046848933, ...
         0.4694995666,   0.6534120695,   0.9172438273,   0.7854664871, ... 
         0.7180191852, ...
         2.9757094174,   1.6152175272,   1.3495291976,   0.7244916931, ... 
         0.9450058998 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi
cat > test_b1_coef.m.ok << 'EOF'
Ub1=0,Vb1=2,Mb1=0,Qb1=10,Rb1=1
b1 = [   1.0000000000, ...
        -0.7416267668,  -0.0401085124, ...
         0.4968183357,   0.6988504401,   0.9270587724,   0.7768938934, ... 
         0.7163992700, ...
         2.8246898215,   1.6121432217,   0.5551855407,   1.1248643500, ... 
         0.8734789955 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
diff -Bb test_a1_coef.m.ok \
     parallel_allpass_socp_slb_bandpass_hilbert_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi
diff -Bb test_b1_coef.m.ok \
     parallel_allpass_socp_slb_bandpass_hilbert_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_b1_coef.m"; fail; fi

#
# this much worked
#
pass

