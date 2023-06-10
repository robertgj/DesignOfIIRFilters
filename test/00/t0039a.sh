#!/bin/sh

prog=tarczynski_parallel_allpass_test.m
depends="test/tarczynski_parallel_allpass_test.m \
test_common.m delayz.m print_polynomial.m print_pole_zero.m WISEJ_PA.m"
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
Da0 = [   1.0000000000,   0.6973099810,  -0.2973939289,  -0.3128675483, ... 
         -0.1821715791,   0.0543112432,   0.0871665873,  -0.1041484796, ... 
          0.1846938273,   0.0438722946,  -0.1319683752,   0.0451561282 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_flat_Da0_coef.m"; fail; fi

cat > test_flat_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,   0.1561749378,  -0.3134786484,   0.3175874445, ... 
          0.1302018065,   0.0786710500,  -0.0643338343,  -0.1837369481, ... 
          0.2691862974,  -0.0895905859,  -0.1359552548,   0.1337901195, ... 
         -0.0581833340 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_flat_Db0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

strn="tarczynski_parallel_allpass_test";

diff -Bb test_Da0_coef.m $strn"_Da0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0_coef.m"; fail; fi

diff -Bb test_Db0_coef.m $strn"_Db0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db0_coef.m"; fail; fi

diff -Bb test_flat_Da0_coef.m $strn"_flat_delay_Da0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_flat_Da0_coef.m"; fail; fi

diff -Bb test_flat_Db0_coef.m $strn"_flat_delay_Db0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_flat_Db0_coef.m"; fail; fi


#
# this much worked
#
pass

