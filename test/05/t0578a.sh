#!/bin/sh

prog=kyp_symbolic_frequency_transformation_test.m
depends="test/kyp_symbolic_frequency_transformation_test.m test_common.m"

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
ans = (sym 2×2 matrix)
  ⎡    0      p⋅s - q⋅r⎤
  ⎢                    ⎥
  ⎣p⋅s - q⋅r      0    ⎦
detReJUJp = (sym)
                2
  -B⋅(p⋅s - q⋅r) 
Phi = (sym 2×2 matrix)
  ⎡1  0 ⎤
  ⎢     ⎥
  ⎣0  -1⎦
Psi_o = (sym 2×2 matrix)
  ⎡  g           ⎤
  ⎢- ─ - 1    0  ⎥
  ⎢  2           ⎥
  ⎢              ⎥
  ⎢             g⎥
  ⎢   0     1 - ─⎥
  ⎣             2⎦
ans = (sym)
   2    
  g     
  ── - 1
  4     
Psi_o = (sym 2×2 matrix)
  ⎡g           ⎤
  ⎢─ + 1    0  ⎥
  ⎢2           ⎥
  ⎢            ⎥
  ⎢       g    ⎥
  ⎢  0    ─ - 1⎥
  ⎣       2    ⎦
ans = (sym)
   2    
  g     
  ── - 1
  4     
Psi_o = (sym 2×2 matrix)
  ⎡       ⎛w₁ - w₂⎞        ⎛w₁ + w₂⎞                ⎛w₁ + w₂⎞          ⎤
  ⎢- 2⋅cos⎜───────⎟ - 2⋅cos⎜───────⎟           2⋅sin⎜───────⎟          ⎥
  ⎢       ⎝   2   ⎠        ⎝   2   ⎠                ⎝   2   ⎠          ⎥
  ⎢                                                                    ⎥
  ⎢              ⎛w₁ + w₂⎞                   ⎛w₁ - w₂⎞        ⎛w₁ + w₂⎞⎥
  ⎢         2⋅sin⎜───────⎟            - 2⋅cos⎜───────⎟ + 2⋅cos⎜───────⎟⎥
  ⎣              ⎝   2   ⎠                   ⎝   2   ⎠        ⎝   2   ⎠⎦
ans = (sym)
         2⎛w₁   w₂⎞        2⎛w₁   w₂⎞        2⎛w₁   w₂⎞
  - 4⋅sin ⎜── + ──⎟ + 4⋅cos ⎜── - ──⎟ - 4⋅cos ⎜── + ──⎟
          ⎝2    2 ⎠         ⎝2    2 ⎠         ⎝2    2 ⎠

EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test.ok"; fail;
fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

cat test.out | grep -v Symbolic | grep -v Waiting > test.out.ok

diff -Bb test.ok test.out.ok
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass
