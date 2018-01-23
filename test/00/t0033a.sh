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
        -0.8725343570, ...
         0.9370755086,   0.9175377013,   0.7484370752,   0.6898106795, ... 
         0.5054872646, ...
         2.7577078109,   1.9987960373,   1.2933034737,   0.3169854071, ... 
         0.4079186136 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi

cat > test_b1_coef.m << 'EOF'
Ub1=0,Vb1=2,Mb1=0,Qb1=10,Rb1=1
b1 = [   1.0000000000, ...
        -0.8734714048,   0.6936513055, ...
         0.9374482525,   0.9162722623,   0.7096005261,   0.7013091384, ... 
         0.7192025101, ...
         2.7579923852,   1.9988786635,   1.2101212046,   0.6315615177, ... 
         0.9165405964 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m"; fail; fi

cat > test_Da1_coef.m << 'EOF'
Da1 = [   1.0000000000,   0.7229577778,  -0.2816591113,  -0.3285254619, ... 
         -0.1924973798,   0.0577978333,   0.0838020756,  -0.1178346342, ... 
          0.1895202867,   0.0534234601,  -0.1357082538,   0.0439309301 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m"; fail; fi

cat > test_Db1_coef.m << 'EOF'
Db1 = [   1.0000000000,   0.1709183061,  -0.3265897206,   0.2981183665, ... 
          0.1446578646,   0.0951140426,  -0.0715857473,  -0.1964755257, ... 
          0.2843688918,  -0.0840177977,  -0.1446569299,   0.1374905324, ... 
         -0.0572641514 ]';
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

