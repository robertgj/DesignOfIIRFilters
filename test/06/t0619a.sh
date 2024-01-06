#!/bin/sh

prog=sv_feedback_symbolic_test.m

depends="test/sv_feedback_symbolic_test.m test_common.m"

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
x1p = (sym) A₁⋅x₁ + B₁⋅u₁ + B₂⋅u₂
y1 = (sym) C₁⋅x₁ + D₁₁⋅u₁ + D₁₂⋅u₂
y2 = (sym) C₂⋅x₁ + D₂₁⋅u₁ + D₂₂⋅u₂
x2p = (sym) A₂⋅x₂ + b₁⋅w₁ + b₂⋅w₂
v1 = (sym) c₁⋅x₂ + d₁₁⋅w₁ + d₁₂⋅w₂
v2 = (sym) c₂⋅x₂ + d₂₁⋅w₁ + d₂₂⋅w₂
I = 1
M1 = (sym 5×4 matrix)
  ⎡0  c₁  0  d₁₂⎤
  ⎢             ⎥
  ⎢1  0   0   0 ⎥
  ⎢             ⎥
  ⎢0  1   0   0 ⎥
  ⎢             ⎥
  ⎢0  0   1   0 ⎥
  ⎢             ⎥
  ⎣0  0   0   1 ⎦
M2 = (sym 8×5 matrix)
  ⎡B₂   A₁  0  B₁   0⎤
  ⎢                  ⎥
  ⎢D₁₂  C₁  0  D₁₁  0⎥
  ⎢                  ⎥
  ⎢D₂₂  C₂  0  D₂₁  0⎥
  ⎢                  ⎥
  ⎢ 1   0   0   0   0⎥
  ⎢                  ⎥
  ⎢ 0   1   0   0   0⎥
  ⎢                  ⎥
  ⎢ 0   0   1   0   0⎥
  ⎢                  ⎥
  ⎢ 0   0   0   1   0⎥
  ⎢                  ⎥
  ⎣ 0   0   0   0   1⎦
M3 = (sym 10×8 matrix)
  ⎡0  0  b₁   0  0  A₂  0  b₂ ⎤
  ⎢                           ⎥
  ⎢0  0  d₂₁  0  0  c₂  0  d₂₂⎥
  ⎢                           ⎥
  ⎢1  0   0   0  0  0   0   0 ⎥
  ⎢                           ⎥
  ⎢0  1   0   0  0  0   0   0 ⎥
  ⎢                           ⎥
  ⎢0  0   1   0  0  0   0   0 ⎥
  ⎢                           ⎥
  ⎢0  0   0   1  0  0   0   0 ⎥
  ⎢                           ⎥
  ⎢0  0   0   0  1  0   0   0 ⎥
  ⎢                           ⎥
  ⎢0  0   0   0  0  1   0   0 ⎥
  ⎢                           ⎥
  ⎢0  0   0   0  0  0   1   0 ⎥
  ⎢                           ⎥
  ⎣0  0   0   0  0  0   0   1 ⎦
M4 =
   0   0   1   0   0   0   0   0   0   0
   1   0   0   0   0   0   0   0   0   0
   0   0   0   1   0   0   0   0   0   0
   0   1   0   0   0   0   0   0   0   0

MAbcd = (sym 4×4 matrix)
  ⎡  A₁         B₂⋅c₁         B₁          B₂⋅d₁₂      ⎤
  ⎢                                                   ⎥
  ⎢C₂⋅b₁   A₂ + D₂₂⋅b₁⋅c₁   D₂₁⋅b₁    D₂₂⋅b₁⋅d₁₂ + b₂ ⎥
  ⎢                                                   ⎥
  ⎢  C₁        D₁₂⋅c₁         D₁₁         D₁₂⋅d₁₂     ⎥
  ⎢                                                   ⎥
  ⎣C₂⋅d₂₁  D₂₂⋅c₁⋅d₂₁ + c₂  D₂₁⋅d₂₁  D₂₂⋅d₁₂⋅d₂₁ + d₂₂⎦
x1p = (sym) A⋅x₁ + B₁⋅u₁ + B₂⋅u₂
y1 = (sym) C₁⋅x₁ + D₁₁⋅u₁ + D₁₂⋅u₂
y2 = (sym) C₂⋅x₁ + D₂₁⋅u₁ + D₂₂⋅u₂
x2p = (sym) a⋅x₂ + b⋅w
v = (sym) c⋅x₂ + d⋅w
N1 = (sym 4×3 matrix)
  ⎡0  c  0⎤
  ⎢       ⎥
  ⎢1  0  0⎥
  ⎢       ⎥
  ⎢0  1  0⎥
  ⎢       ⎥
  ⎣0  0  1⎦
N2 = (sym 7×4 matrix)
  ⎡B₂   A   0  B₁ ⎤
  ⎢               ⎥
  ⎢D₁₂  C₁  0  D₁₁⎥
  ⎢               ⎥
  ⎢D₂₂  C₂  0  D₂₁⎥
  ⎢               ⎥
  ⎢ 1   0   0   0 ⎥
  ⎢               ⎥
  ⎢ 0   1   0   0 ⎥
  ⎢               ⎥
  ⎢ 0   0   1   0 ⎥
  ⎢               ⎥
  ⎣ 0   0   0   1 ⎦
N3 = (sym 8×7 matrix)
  ⎡0  0  b  0  0  a  0⎤
  ⎢                   ⎥
  ⎢1  0  0  0  0  0  0⎥
  ⎢                   ⎥
  ⎢0  1  0  0  0  0  0⎥
  ⎢                   ⎥
  ⎢0  0  1  0  0  0  0⎥
  ⎢                   ⎥
  ⎢0  0  0  1  0  0  0⎥
  ⎢                   ⎥
  ⎢0  0  0  0  1  0  0⎥
  ⎢                   ⎥
  ⎢0  0  0  0  0  1  0⎥
  ⎢                   ⎥
  ⎣0  0  0  0  0  0  1⎦
N4 =
   0   1   0   0   0   0   0   0
   1   0   0   0   0   0   0   0
   0   0   1   0   0   0   0   0
   0   0   0   1   0   0   0   0

NAbcd = (sym 4×3 matrix)
  ⎡ A       B₂⋅c       B₁  ⎤
  ⎢                        ⎥
  ⎢C₂⋅b  D₂₂⋅b⋅c + a  D₂₁⋅b⎥
  ⎢                        ⎥
  ⎢ C₁      D₁₂⋅c      D₁₁ ⎥
  ⎢                        ⎥
  ⎣ C₂      D₂₂⋅c      D₂₁ ⎦
x1p = (sym) A⋅x₁ + B₁⋅u₁ + B₂⋅u₂
y1 = (sym) C₁⋅x₁ + D₁₁⋅u₁ + D₁₂⋅u₂
y2 = (sym) C₂⋅x₁ + D₂₁⋅u₁ + D₂₂⋅u₂
x2p = (sym) a⋅x₂ + b⋅w
v = (sym) c⋅x₂ + d⋅w
O1 = (sym 4×3 matrix)
  ⎡C₂  0  D₂₁⎤
  ⎢          ⎥
  ⎢1   0   0 ⎥
  ⎢          ⎥
  ⎢0   1   0 ⎥
  ⎢          ⎥
  ⎣0   0   1 ⎦
O2 = (sym 6×4 matrix)
  ⎡b  0  a  0⎤
  ⎢          ⎥
  ⎢d  0  c  0⎥
  ⎢          ⎥
  ⎢1  0  0  0⎥
  ⎢          ⎥
  ⎢0  1  0  0⎥
  ⎢          ⎥
  ⎢0  0  1  0⎥
  ⎢          ⎥
  ⎣0  0  0  1⎦
O3 = (sym 8×6 matrix)
  ⎡B₂   0  0  A   0  B₁ ⎤
  ⎢                     ⎥
  ⎢D₁₂  0  0  C₁  0  D₁₁⎥
  ⎢                     ⎥
  ⎢ 1   0  0  0   0   0 ⎥
  ⎢                     ⎥
  ⎢ 0   1  0  0   0   0 ⎥
  ⎢                     ⎥
  ⎢ 0   0  1  0   0   0 ⎥
  ⎢                     ⎥
  ⎢ 0   0  0  1   0   0 ⎥
  ⎢                     ⎥
  ⎢ 0   0  0  0   1   0 ⎥
  ⎢                     ⎥
  ⎣ 0   0  0  0   0   1 ⎦
O4 =
   1   0   0   0   0   0   0   0
   0   0   1   0   0   0   0   0
   0   1   0   0   0   0   0   0
   0   0   0   0   1   0   0   0

OAbcd = (sym 4×3 matrix)
  ⎡ A + B₂⋅C₂⋅b   B₂⋅a    B₁ + B₂⋅D₂₁⋅b ⎤
  ⎢                                     ⎥
  ⎢    C₂⋅b         a         D₂₁⋅b     ⎥
  ⎢                                     ⎥
  ⎢C₁ + C₂⋅D₁₂⋅b  D₁₂⋅a  D₁₁ + D₁₂⋅D₂₁⋅b⎥
  ⎢                                     ⎥
  ⎣     C₂          0          D₂₁      ⎦
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
sed -i -e "/Symbolic/d" test.out
diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test.ok"; fail; fi

#
# this much worked
#
pass

