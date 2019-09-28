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
allpassP.m allpassT.m tf2a.m a2tf.m aConstraints.m \
print_polynomial.m print_allpass_pole.m local_max.m \
qroots.m qzsolve.oct SeDuMi_1_3/"

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
% All-pass single-vector representation
Va1=0,Qa1=12,Ra1=1
a1 = [   0.5316405017,   0.5398202393,   0.5614243416,   0.6187175840, ... 
         0.7248003461,   0.9258450551, ...
         2.8852658056,   2.3751023899,   1.8730720048,   1.3846291152, ... 
         0.2701802361,   0.9710210883 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out

diff -Bb test_a1_coef.m.ok parallel_allpass_delay_socp_slb_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

#
# this much worked
#
pass

