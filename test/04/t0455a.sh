#!/bin/sh

prog=lagrange_interp_test.m

depends="lagrange_interp_test.m test_common.m print_polynomial.m \
lagrange_interp.m"

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
cat > test.ok << 'EOF'
Caught error: Refusing to extrapolate
Caught error: Refusing to extrapolate
Caught error: any(size(xk)~=size(fk))
Caught error: all(size(xk)~=1)
Caught error: max(size(xk))<2)
Caught error: length(xk)~=length(unique(xk))
Caught error: all(size(x)~=1)
Caught error: any(size(wk)~=size(xk))
Caught error: any(size(wk)~=size(xk))
Caught error: any(size(wk)~=size(xk))
warning: norm(f-fun(x))(187.855)>0.1
warning: called from
    lagrange_interp_test at line 226 column 3
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

cat > test_n_20_Cheby_2_w.ok << 'EOF'
w = [  13107.20000000, -26214.40000000,  26214.40000000, -26214.40000000, ... 
       26214.40000000, -26214.40000000,  26214.40000000, -26214.40000000, ... 
       26214.40000000, -26214.40000000,  26214.40000000, -26214.40000000, ... 
       26214.40000000, -26214.40000000,  26214.40000000, -26214.40000000, ... 
       26214.40000000, -26214.40000000,  26214.40000000, -26214.40000000, ... 
       13107.20000000 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_n_20_Cheby_2_w.ok"; fail; fi

cat > test_n_20_Cheby_2_p.ok << 'EOF'
p = [  -2063.11802338,     -0.00000000,  11373.19076658,      0.00000000, ... 
      -26965.13438364,     -0.00000000,  35935.03194835,     -0.00000000, ... 
      -29520.87287378,     -0.00000000,  15426.88499636,     -0.00000000, ... 
       -5110.36366313,     -0.00000000,   1039.07995328,     -0.00000000, ... 
        -122.53721585,     -0.00000000,      7.83849523,      0.50000000, ... 
          -0.00000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_n_20_Cheby_2_p.ok"; fail; fi

cat > test_n_20_Cheby_1_w.ok << 'EOF'
w = [   3731.43726726, -11110.95765925,  18242.27761743, -24966.09523810, ... 
       31132.21154637, -36602.88569313,  41255.91185796, -44987.34912522, ... 
       47713.84335238, -49374.48916380,  49932.19047619, -49374.48916380, ... 
       47713.84335238, -44987.34912522,  41255.91185796, -36602.88569313, ... 
       31132.21154637, -24966.09523810,  18242.27761743, -11110.95765925, ... 
        3731.43726726 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_n_20_Cheby_1_w.ok"; fail; fi

cat > test_n_20_Cheby_1_p.ok << 'EOF'
p = [  -3763.03338566,     -0.00000000,  19799.66370419,      0.00000000, ... 
      -44682.59129587,     -0.00000000,  56503.21565872,      0.00000000, ... 
      -43893.18388521,     -0.00000000,  21604.95910569,     -0.00000000, ... 
       -6710.99518096,     -0.00000000,   1272.90731854,     -0.00000000, ... 
        -139.18736871,     -0.00000000,      8.24178045,      0.50000000, ... 
           0.00000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_n_20_Cheby_1_p.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

diff -Bb test_n_20_Cheby_2_w.ok lagrange_interp_test_n_20_Chebyshev_2_w_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_n_20_Cheby_2_w.ok"; fail; fi

diff -Bb test_n_20_Cheby_2_p.ok lagrange_interp_test_n_20_Chebyshev_2_p_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_n_20_Cheby_2_p.ok"; fail; fi

diff -Bb test_n_20_Cheby_1_w.ok lagrange_interp_test_n_20_Chebyshev_1_w_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_n_20_Cheby_1_w.ok"; fail; fi

diff -Bb test_n_20_Cheby_1_p.ok lagrange_interp_test_n_20_Chebyshev_1_p_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_n_20_Cheby_1_p.ok"; fail; fi

#
# this much worked
#
pass

