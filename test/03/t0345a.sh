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
Ua1=0,Va1=2,Ma1=0,Qa1=8,Ra1=1
a1 = [   1.0000000000, ...
        -0.0734679994,  -0.0731134699, ...
         0.6608650890,   0.9190531846,   0.7843782358,   0.7107985764, ...
         1.4652176624,   1.3656319076,   0.7247291609,   0.9395582738 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi
cat > test_b1_coef.m.ok << 'EOF'
Ub1=0,Vb1=2,Mb1=0,Qb1=8,Rb1=1
b1 = [   1.0000000000, ...
        -0.0983966983,  -0.0966252313, ...
         0.7140377820,   0.9272346585,   0.7672285350,   0.7123803035, ...
         1.5036422599,   0.5550387518,   1.1209610264,   0.8737575883 ]';
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

