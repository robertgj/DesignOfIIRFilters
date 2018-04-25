#!/bin/sh

prog=parallel_allpass_socp_mmse_test.m

depends="parallel_allpass_socp_mmse_test.m test_common.m \
parallel_allpass_socp_mmse.m parallel_allpass_mmse_error.m \
parallel_allpass_delay_slb_set_empty_constraints.m \
allpassP.m allpassT.m parallel_allpassAsq.m \
parallel_allpassT.m parallel_allpassP.m \
print_polynomial.m print_pole_zero.m aConstraints.m a2tf.m tf2a.m SeDuMi_1_3/"
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
cat > test_a1_coef.m << 'EOF'
Ua1=0,Va1=1,Ma1=0,Qa1=10,Ra1=1
a1 = [   1.0000000000, ...
        -0.8725346286, ...
         0.9370759613,   0.9175385670,   0.7484363369,   0.6898092692, ... 
         0.5054873493, ...
         2.7577077724,   1.9987960303,   1.2933025702,   0.3169851637, ... 
         0.4079147752 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi

cat > test_b1_coef.m << 'EOF'
Ub1=0,Vb1=2,Mb1=0,Qb1=10,Rb1=1
b1 = [   1.0000000000, ...
        -0.8734715744,   0.6936496296, ...
         0.9374486726,   0.9162731465,   0.7096002960,   0.7013081978, ... 
         0.7192014919, ...
         2.7579923587,   1.9988786175,   1.2101188949,   0.6315610615, ... 
         0.9165394629 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m"; fail; fi

cat > test_Da1_coef.m << 'EOF'
Da1 = [   1.0000000000,   0.7229595533,  -0.2816591075,  -0.3285282094, ... 
         -0.1924980722,   0.0577996132,   0.0838022721,  -0.1178367417, ... 
          0.1895201891,   0.0534243613,  -0.1357086319,   0.0439308175 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m"; fail; fi

cat > test_Db1_coef.m << 'EOF'
Db1 = [   1.0000000000,   0.1709197510,  -0.3265911954,   0.2981160753, ... 
          0.1446593601,   0.0951158929,  -0.0715867488,  -0.1964769435, ... 
          0.2843708284,  -0.0840170179,  -0.1446580196,   0.1374909561, ... 
         -0.0572638331 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.m parallel_allpass_socp_mmse_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m parallel_allpass_socp_mmse_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_b1_coef.m"; fail; fi

diff -Bb test_Da1_coef.m parallel_allpass_socp_mmse_test_Da1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da1_coef.m"; fail; fi

diff -Bb test_Db1_coef.m parallel_allpass_socp_mmse_test_Db1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db1_coef.m"; fail; fi

#
# this much worked
#
pass

