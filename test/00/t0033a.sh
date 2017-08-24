#!/bin/sh

prog=parallel_allpass_socp_mmse_test.m

depends="parallel_allpass_socp_mmse_test.m test_common.m \
parallel_allpass_socp_mmse.m parallel_allpass_mmse_error.m \
parallel_allpass_delay_slb_set_empty_constraints.m \
allpassP.m allpassT.m parallel_allpassAsq.m parallel_allpassT.m \
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
        -0.8725343873, ...
         0.9370755631,   0.9175377520,   0.7484370702,   0.6898106833, ... 
         0.5054872962, ...
         2.7577078122,   1.9987960357,   1.2933034535,   0.3169853918, ... 
         0.4079186930 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi

cat > test_b1_coef.m << 'EOF'
Ub1=0,Vb1=2,Mb1=0,Qb1=10,Rb1=1
b1 = [   1.0000000000, ...
        -0.8734714345,   0.6936513129, ...
         0.9374483065,   0.9162723142,   0.7096005350,   0.7013091367, ... 
         0.7192025077, ...
         2.7579923861,   1.9988786615,   1.2101211722,   0.6315615092, ... 
         0.9165405847 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m"; fail; fi

cat > test_Da1_coef.m << 'EOF'
Da1 = [   1.0000000000,   0.7229578832,  -0.2816590971,  -0.3285255429, ... 
         -0.1924974014,   0.0577978906,   0.0838021111,  -0.1178347273, ... 
          0.1895203229,   0.0534235040,  -0.1357083020,   0.0439309470 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m"; fail; fi

cat > test_Db1_coef.m << 'EOF'
Db1 = [   1.0000000000,   0.1709184047,  -0.3265897761,   0.2981183055, ... 
          0.1446579099,   0.0951140931,  -0.0715857675,  -0.1964756310, ... 
          0.2843690014,  -0.0840177954,  -0.1446570078,   0.1374905899, ... 
         -0.0572641678 ]';
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

