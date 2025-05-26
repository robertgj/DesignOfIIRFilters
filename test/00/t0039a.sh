#!/bin/sh

prog=tarczynski_parallel_allpass_test.m
depends="test/tarczynski_parallel_allpass_test.m \
test_common.m delayz.m print_polynomial.m print_pole_zero.m WISEJ_PA.m qroots.oct \
"

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
cat > test_Da0_coef.m << 'EOF'
Da0 = [   1.0000000000,   0.0378264328,  -0.7375434486,   0.6800053019, ... 
          0.2901115998,  -0.3306625780 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi

cat > test_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,  -0.5411566151,  -0.4260111354,   1.3158395720, ... 
         -0.2735786482,  -0.4212378143,   0.3472651093 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db0_coef.m"; fail; fi

cat > test_flat_Da0_coef.m << 'EOF'
Da0 = [   1.0000000000,   0.6973409198,  -0.2974608989,  -0.3128606924, ... 
         -0.1820511243,   0.0542695017,   0.0871859340,  -0.1041276751, ... 
          0.1847312949,   0.0438740863,  -0.1320191658,   0.0451974766 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_flat_Da0_coef.m"; fail; fi

cat > test_flat_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,   0.1562112487,  -0.3135615487,   0.3176257041, ... 
          0.1302677354,   0.0785120276,  -0.0642939823,  -0.1837526280, ... 
          0.2691906835,  -0.0896233538,  -0.1360089735,   0.1338554467, ... 
         -0.0582274130 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_flat_Db0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="tarczynski_parallel_allpass_test";

diff -Bb test_Da0_coef.m $nstr"_Da0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0_coef.m"; fail; fi

diff -Bb test_Db0_coef.m $nstr"_Db0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db0_coef.m"; fail; fi

diff -Bb test_flat_Da0_coef.m $nstr"_flat_delay_Da0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_flat_Da0_coef.m"; fail; fi

diff -Bb test_flat_Db0_coef.m $nstr"_flat_delay_Db0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_flat_Db0_coef.m"; fail; fi


#
# this much worked
#
pass

