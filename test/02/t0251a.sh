#!/bin/sh

prog=tarczynski_frm_halfband_test.m

depends="tarczynski_frm_halfband_test.m \
test_common.m print_polynomial.m frm_lowpass_vectors.m"
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
cat > test.r1.ok << 'EOF'
r1 = [   1.0000000000,   0.4655696134,  -0.0754582312,   0.0125871458, ... 
         0.0020733256,  -0.0103286864 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.r1.ok"; fail; fi

cat > test.aa1.ok << 'EOF'
aa1 = [  -0.0017247025,   0.0038867843,   0.0037981075,  -0.0055507359, ... 
         -0.0072155190,   0.0065647986,   0.0124716268,  -0.0002280133, ... 
         -0.0274271511,  -0.0106519008,   0.0373388101,   0.0334377051, ... 
         -0.0500625588,  -0.0817182746,   0.0553051515,   0.3116130352, ... 
          0.4436282767,   0.3116130352,   0.0553051515,  -0.0817182746, ... 
         -0.0500625588,   0.0334377051,   0.0373388101,  -0.0106519008, ... 
         -0.0274271511,  -0.0002280133,   0.0124716268,   0.0065647986, ... 
         -0.0072155190,  -0.0055507359,   0.0037981075,   0.0038867843, ... 
         -0.0017247025 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.aa1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.r1.ok tarczynski_frm_halfband_test_r1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.r1.ok"; fail; fi
diff -Bb test.aa1.ok tarczynski_frm_halfband_test_aa1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.aa1.ok"; fail; fi


#
# this much worked
#
pass

