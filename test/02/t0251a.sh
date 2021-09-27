#!/bin/sh

prog=tarczynski_frm_halfband_test.m

depends="tarczynski_frm_halfband_test.m \
test_common.m print_polynomial.m frm_lowpass_vectors.m"
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
cat > test.r0.ok << 'EOF'
r0 = [   1.0000000000,   0.4615435307,  -0.0731152247,   0.0075725940, ... 
         0.0043778996,  -0.0114133361 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.r0.ok"; fail; fi

cat > test.aa0.ok << 'EOF'
aa0 = [  -0.0022381197,   0.0033809201,   0.0052969686,  -0.0044030583, ... 
         -0.0086521850,   0.0058518996,   0.0124531664,   0.0019942483, ... 
         -0.0261970985,  -0.0149769995,   0.0358615703,   0.0364553730, ... 
         -0.0495178000,  -0.0816212210,   0.0520015973,   0.3113874695, ... 
          0.4492496823,   0.3113874695,   0.0520015973,  -0.0816212210, ... 
         -0.0495178000,   0.0364553730,   0.0358615703,  -0.0149769995, ... 
         -0.0261970985,   0.0019942483,   0.0124531664,   0.0058518996, ... 
         -0.0086521850,  -0.0044030583,   0.0052969686,   0.0033809201, ... 
         -0.0022381197 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.aa0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.r0.ok tarczynski_frm_halfband_test_r0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.r0.ok"; fail; fi
diff -Bb test.aa0.ok tarczynski_frm_halfband_test_aa0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.aa0.ok"; fail; fi


#
# this much worked
#
pass

