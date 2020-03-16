#!/bin/sh

prog=tarczynski_parallel_allpass_multiband_test.m

depends="tarczynski_parallel_allpass_multiband_test.m \
test_common.m print_polynomial.m WISEJ_PAB.m"

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
for file in $depends;do \
  cp -R src/$file $tmp; \
  if [ $? -ne 0 ]; then echo "Failed cp "$file; fail; fi \
done
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# the output should look like this
#
cat > test_Da0.ok << 'EOF'
Da0 = [   1.0000000000,  -0.0843617653,   0.3718175094,   0.8525282013, ... 
         -0.1690942815,   0.2911381975,   0.4612879091,  -0.0015542485, ... 
          0.4894561423,   0.3261828195,  -0.0368168319,   0.3218938944, ... 
         -0.0823328537 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1kpcls.ok"; fail; fi

cat > test_Db0.ok << 'EOF'
Db0 = [   1.0000000000,   0.1992508988,   0.6322714450,   0.9692661219, ... 
          0.0734010927,   0.5136872253,   0.6493622016,   0.2196559576, ... 
          0.5571223462,   0.3077330992,  -0.0425977260,   0.2158948645, ... 
         -0.1557843895 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2epsilon0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="tarczynski_parallel_allpass_multiband_test"

diff -Bb test_Da0.ok $nstr"_Da0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0.ok"; fail; fi

diff -Bb test_Db0.ok $nstr"_Db0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db0.ok"; fail; fi

#
# this much worked
#
pass

