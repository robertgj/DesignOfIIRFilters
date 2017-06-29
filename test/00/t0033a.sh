#!/bin/sh

prog=parallel_allpass_socp_mmse_test.m

depends="parallel_allpass_socp_mmse_test.m test_common.m \
parallel_allpass_socp_mmse.m parallel_allpass_mmse_error.m \
parallel_allpass_delay_slb_set_empty_constraints.m \
allpassP.m allpassT.m parallel_allpassAsq.m parallel_allpassT.m \
print_polynomial.m print_pole_zero.m \
aConstraints.m a2tf.m tf2a.m SeDuMi_1_3/"
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
cat > test_Da1_coef.m << 'EOF'
Da1 = [   1.0000000000,   0.7229576739,  -0.2816591307,  -0.3285253771, ... 
         -0.1924973613,   0.0577977599,   0.0838020701,  -0.1178345579, ... 
          0.1895202429,   0.0534234360,  -0.1357082191,   0.0439309164 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m"; fail; fi
cat > test_Db1_coef.m << 'EOF'
Db1 = [   1.0000000000,   0.1709182107,  -0.3265896682,   0.2981184369, ... 
          0.1446578144,   0.0951139794,  -0.0715856883,  -0.1964754593, ... 
          0.2843687908,  -0.0840177772,  -0.1446568802,   0.1374904898, ... 
         -0.0572641385 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_Da1_coef.m parallel_allpass_socp_mmse_test_Da1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da1_coef.m"; fail; fi
diff -Bb test_Db1_coef.m parallel_allpass_socp_mmse_test_Db1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db1_coef.m"; fail; fi

#
# this much worked
#
pass

