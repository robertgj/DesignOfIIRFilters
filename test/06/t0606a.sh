#!/bin/sh

prog=sv_symbolic_test.m
depends="test/sv_symbolic_test.m test_common.m"

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
ans = (sym 3×3 matrix)
  ⎡A₁⋅I    0    B₁⋅I ⎤
  ⎢                  ⎥
  ⎢B₂⋅C₁  A₂⋅I  B₂⋅D₁⎥
  ⎢                  ⎥
  ⎣C₁⋅D₂  C₂⋅I  D₁⋅D₂⎦
ans = (sym 4×4 matrix)
  ⎡      3              2                 3               2           ⎤
  ⎢  A₁⋅I           B₂⋅I ⋅c₁          B₁⋅I            B₂⋅I ⋅d₁₂       ⎥
  ⎢                                                                   ⎥
  ⎢    2          3                      2                       3    ⎥
  ⎢C₂⋅I ⋅b₁   A₂⋅I  + D₂₂⋅I⋅b₁⋅c₁   D₂₁⋅I ⋅b₁    D₂₂⋅I⋅b₁⋅d₁₂ + I ⋅b₂ ⎥
  ⎢                                                                   ⎥
  ⎢      3              2                  3               2          ⎥
  ⎢  C₁⋅I          D₁₂⋅I ⋅c₁          D₁₁⋅I           D₁₂⋅I ⋅d₁₂      ⎥
  ⎢                                                                   ⎥
  ⎢    2                      3          2                       3    ⎥
  ⎣C₂⋅I ⋅d₂₁  D₂₂⋅I⋅c₁⋅d₂₁ + I ⋅c₂  D₂₁⋅I ⋅d₂₁  D₂₂⋅I⋅d₁₂⋅d₂₁ + I ⋅d₂₂⎦
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
