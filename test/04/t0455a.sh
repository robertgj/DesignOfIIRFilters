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
Caught error: any(diff(xk)==0)
Caught error: all(size(x)~=1)
Caught error: any(size(wk)~=size(xk))
Caught error: any(size(wk)~=size(xk))
Caught error: any(size(wk)~=size(xk))
warning: norm(f-fun(x))(187.855)>0.1
warning: called from
    lagrange_interp_test at line 204 column 3
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

cat > test_n_20_Cheby_2_w.ok << 'EOF'
w = [  13107.19679956, -26214.41104009,  26214.39298271, -26214.40323476, ... 
       26214.39895990, -26214.40022061,  26214.39997231, -26214.40000164, ... 
       26214.39999999, -26214.40000000,  26214.40000000, -26214.40000000, ... 
       26214.40000000, -26214.40000000,  26214.39999999, -26214.39999989, ... 
       26214.40000034, -26214.40000411,  26214.39998187, -26214.39999613, ... 
       13107.19999220 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_n_20_Cheby_2_w.ok"; fail; fi

cat > test_n_20_Cheby_2_p.ok << 'EOF'
p = [  -2063.13133833,     -0.01274353,  11373.25180426,      0.05834910, ... 
      -26965.25170053,     -0.11201486,  35935.15466479,      0.11703073, ... 
      -29520.94873347,     -0.07226164,  15426.91315695,      0.02679632, ... 
       -5110.36975846,     -0.00579466,   1039.08066187,      0.00067315, ... 
        -122.53725294,     -0.00003521,      7.83849579,      0.50000053, ... 
          -0.00000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_n_20_Cheby_2_p.ok"; fail; fi

cat > test_n_20_Cheby_1_w.ok << 'EOF'
w = [   3731.43725562, -11110.95773900,  18242.27749867, -24966.09533534, ... 
       31132.21149511, -36602.88571242,  41255.91185314, -44987.34912590, ... 
       47713.84335234, -49374.48916380,  49932.19047619, -49374.48916380, ... 
       47713.84335238, -44987.34912522,  41255.91185795, -36602.88569311, ... 
       31132.21154663, -24966.09523905,  18242.27761676, -11110.95766044, ... 
        3731.43726719 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_n_20_Cheby_1_w.ok"; fail; fi

cat > test_n_20_Cheby_1_p.ok << 'EOF'
p = [  -3763.03358995,     -0.00018286,  19799.66461507,      0.00081241, ... 
      -44682.59299284,     -0.00150779,  56503.21737203,      0.00151630, ... 
      -43893.18490225,     -0.00089645,  21604.95946596,      0.00031629, ... 
       -6710.99525481,     -0.00006459,   1272.90732659,      0.00000702, ... 
        -139.18736910,     -0.00000034,      8.24178046,      0.50000000, ... 
           0.00000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_n_20_Cheby_1_p.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
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

