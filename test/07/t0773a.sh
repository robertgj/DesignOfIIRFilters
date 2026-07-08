#!/bin/sh

prog=tridiagonal_inverse_symbolic_test.m
depends="test/tridiagonal_inverse_symbolic_test.m test_common.m"

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
Symbolic pkg v3.2.2: Python communication link active, SymPy v1.14.0.
(sym)
  c₁₂
  ───
  d₁₁
u = (sym 1×2 matrix)
  ⎡       c₁₂⋅e₁₁      ⎤
  ⎢d₁₁  - ─────── + d₁₂⎥
  ⎣         d₁₁        ⎦
L = (sym 2×2 matrix)
  ⎡ 1   0⎤
  ⎢      ⎥
  ⎣l₁₂  1⎦
invL = (sym 2×2 matrix)
  ⎡ 1    0⎤
  ⎢       ⎥
  ⎣-l₁₂  1⎦
U = (sym 2×2 matrix)
  ⎡u₁₁  e₁₁⎤
  ⎢        ⎥
  ⎣ 0   u₁₂⎦
invU = (sym 2×2 matrix)
  ⎡ 1    -e₁₁  ⎤
  ⎢───  ───────⎥
  ⎢u₁₁  u₁₁⋅u₁₂⎥
  ⎢            ⎥
  ⎢        1   ⎥
  ⎢ 0     ───  ⎥
  ⎣       u₁₂  ⎦
(sym 1×2 matrix)
  ⎡c₁₂        c₁₃      ⎤
  ⎢───  ───────────────⎥
  ⎢d₁₁    c₁₂⋅e₁₁      ⎥
  ⎢     - ─────── + d₁₂⎥
  ⎣         d₁₁        ⎦
u = (sym 1×3 matrix)
  ⎡       c₁₂⋅e₁₁              c₁₃⋅e₁₂          ⎤
  ⎢d₁₁  - ─────── + d₁₂  - ─────────────── + d₁₃⎥
  ⎢         d₁₁              c₁₂⋅e₁₁            ⎥
  ⎢                        - ─────── + d₁₂      ⎥
  ⎣                            d₁₁              ⎦
L = (sym 3×3 matrix)
  ⎡ 1    0   0⎤
  ⎢           ⎥
  ⎢l₁₂   1   0⎥
  ⎢           ⎥
  ⎣ 0   l₁₃  1⎦
invL = (sym 3×3 matrix)
  ⎡   1      0    0⎤
  ⎢                ⎥
  ⎢ -l₁₂     1    0⎥
  ⎢                ⎥
  ⎣l₁₂⋅l₁₃  -l₁₃  1⎦
U = (sym 3×3 matrix)
  ⎡u₁₁  e₁₁   0 ⎤
  ⎢             ⎥
  ⎢ 0   u₁₂  e₁₂⎥
  ⎢             ⎥
  ⎣ 0    0   u₁₃⎦
invU = (sym 3×3 matrix)
  ⎡ 1    -e₁₁      e₁₁⋅e₁₂  ⎤
  ⎢───  ───────  ───────────⎥
  ⎢u₁₁  u₁₁⋅u₁₂  u₁₁⋅u₁₂⋅u₁₃⎥
  ⎢                         ⎥
  ⎢        1        -e₁₂    ⎥
  ⎢ 0     ───      ───────  ⎥
  ⎢       u₁₂      u₁₂⋅u₁₃  ⎥
  ⎢                         ⎥
  ⎢                   1     ⎥
  ⎢ 0      0         ───    ⎥
  ⎣                  u₁₃    ⎦
(sym 1×3 matrix)
  ⎡c₁₂        c₁₃                  c₁₄          ⎤
  ⎢───  ───────────────  ───────────────────────⎥
  ⎢d₁₁    c₁₂⋅e₁₁              c₁₃⋅e₁₂          ⎥
  ⎢     - ─────── + d₁₂  - ─────────────── + d₁₃⎥
  ⎢         d₁₁              c₁₂⋅e₁₁            ⎥
  ⎢                        - ─────── + d₁₂      ⎥
  ⎣                            d₁₁              ⎦
u = (sym 1×4 matrix)
  ⎡       c₁₂⋅e₁₁              c₁₃⋅e₁₂                      c₁₄⋅e₁₃              ⎤
  ⎢d₁₁  - ─────── + d₁₂  - ─────────────── + d₁₃  - ─────────────────────── + d₁₄⎥
  ⎢         d₁₁              c₁₂⋅e₁₁                      c₁₃⋅e₁₂                ⎥
  ⎢                        - ─────── + d₁₂          - ─────────────── + d₁₃      ⎥
  ⎢                            d₁₁                      c₁₂⋅e₁₁                  ⎥
  ⎢                                                   - ─────── + d₁₂            ⎥
  ⎣                                                       d₁₁                    ⎦
L = (sym 4×4 matrix)
  ⎡ 1    0    0   0⎤
  ⎢                ⎥
  ⎢l₁₂   1    0   0⎥
  ⎢                ⎥
  ⎢ 0   l₁₃   1   0⎥
  ⎢                ⎥
  ⎣ 0    0   l₁₄  1⎦
invL = (sym 4×4 matrix)
  ⎡     1           0      0    0⎤
  ⎢                              ⎥
  ⎢    -l₁₂         1      0    0⎥
  ⎢                              ⎥
  ⎢  l₁₂⋅l₁₃      -l₁₃     1    0⎥
  ⎢                              ⎥
  ⎣-l₁₂⋅l₁₃⋅l₁₄  l₁₃⋅l₁₄  -l₁₄  1⎦
U = (sym 4×4 matrix)
  ⎡u₁₁  e₁₁   0    0 ⎤
  ⎢                  ⎥
  ⎢ 0   u₁₂  e₁₂   0 ⎥
  ⎢                  ⎥
  ⎢ 0    0   u₁₃  e₁₃⎥
  ⎢                  ⎥
  ⎣ 0    0    0   u₁₄⎦
invU = (sym 4×4 matrix)
  ⎡ 1    -e₁₁      e₁₁⋅e₁₂     -e₁₁⋅e₁₂⋅e₁₃  ⎤
  ⎢───  ───────  ───────────  ───────────────⎥
  ⎢u₁₁  u₁₁⋅u₁₂  u₁₁⋅u₁₂⋅u₁₃  u₁₁⋅u₁₂⋅u₁₃⋅u₁₄⎥
  ⎢                                          ⎥
  ⎢        1        -e₁₂          e₁₂⋅e₁₃    ⎥
  ⎢ 0     ───      ───────      ───────────  ⎥
  ⎢       u₁₂      u₁₂⋅u₁₃      u₁₂⋅u₁₃⋅u₁₄  ⎥
  ⎢                                          ⎥
  ⎢                   1            -e₁₃      ⎥
  ⎢ 0      0         ───          ───────    ⎥
  ⎢                  u₁₃          u₁₃⋅u₁₄    ⎥
  ⎢                                          ⎥
  ⎢                                  1       ⎥
  ⎢ 0      0          0             ───      ⎥
  ⎣                                 u₁₄      ⎦
(sym 1×4 matrix)
  ⎡c₁₂        c₁₃                  c₁₄                          c₁₅              ⎤
  ⎢───  ───────────────  ───────────────────────  ───────────────────────────────⎥
  ⎢d₁₁    c₁₂⋅e₁₁              c₁₃⋅e₁₂                      c₁₄⋅e₁₃              ⎥
  ⎢     - ─────── + d₁₂  - ─────────────── + d₁₃  - ─────────────────────── + d₁₄⎥
  ⎢         d₁₁              c₁₂⋅e₁₁                      c₁₃⋅e₁₂                ⎥
  ⎢                        - ─────── + d₁₂          - ─────────────── + d₁₃      ⎥
  ⎢                            d₁₁                      c₁₂⋅e₁₁                  ⎥
  ⎢                                                   - ─────── + d₁₂            ⎥
  ⎣                                                       d₁₁                    ⎦
u = (sym 1×5 matrix)
  ⎡       c₁₂⋅e₁₁              c₁₃⋅e₁₂                      c₁₄⋅e₁₃              ↪
  ⎢d₁₁  - ─────── + d₁₂  - ─────────────── + d₁₃  - ─────────────────────── + d₁ ↪
  ⎢         d₁₁              c₁₂⋅e₁₁                      c₁₃⋅e₁₂                ↪
  ⎢                        - ─────── + d₁₂          - ─────────────── + d₁₃      ↪
  ⎢                            d₁₁                      c₁₂⋅e₁₁                  ↪
  ⎢                                                   - ─────── + d₁₂            ↪
  ⎢                                                       d₁₁                    ↪
  ⎢                                                                              ↪
  ⎣                                                                              ↪
  
  ↪                  c₁₅⋅e₁₄                  ⎤
  ↪ ₄  - ─────────────────────────────── + d₁₅⎥
  ↪                c₁₄⋅e₁₃                    ⎥
  ↪      - ─────────────────────── + d₁₄      ⎥
  ↪              c₁₃⋅e₁₂                      ⎥
  ↪        - ─────────────── + d₁₃            ⎥
  ↪            c₁₂⋅e₁₁                        ⎥
  ↪          - ─────── + d₁₂                  ⎥
  ↪              d₁₁                          ⎦
L = (sym 5×5 matrix)
  ⎡ 1    0    0    0   0⎤
  ⎢                     ⎥
  ⎢l₁₂   1    0    0   0⎥
  ⎢                     ⎥
  ⎢ 0   l₁₃   1    0   0⎥
  ⎢                     ⎥
  ⎢ 0    0   l₁₄   1   0⎥
  ⎢                     ⎥
  ⎣ 0    0    0   l₁₅  1⎦
invL = (sym 5×5 matrix)
  ⎡       1              0           0      0    0⎤
  ⎢                                               ⎥
  ⎢     -l₁₂             1           0      0    0⎥
  ⎢                                               ⎥
  ⎢    l₁₂⋅l₁₃          -l₁₃         1      0    0⎥
  ⎢                                               ⎥
  ⎢ -l₁₂⋅l₁₃⋅l₁₄      l₁₃⋅l₁₄      -l₁₄     1    0⎥
  ⎢                                               ⎥
  ⎣l₁₂⋅l₁₃⋅l₁₄⋅l₁₅  -l₁₃⋅l₁₄⋅l₁₅  l₁₄⋅l₁₅  -l₁₅  1⎦
U = (sym 5×5 matrix)
  ⎡u₁₁  e₁₁   0    0    0 ⎤
  ⎢                       ⎥
  ⎢ 0   u₁₂  e₁₂   0    0 ⎥
  ⎢                       ⎥
  ⎢ 0    0   u₁₃  e₁₃   0 ⎥
  ⎢                       ⎥
  ⎢ 0    0    0   u₁₄  e₁₄⎥
  ⎢                       ⎥
  ⎣ 0    0    0    0   u₁₅⎦
invU = (sym 5×5 matrix)
  ⎡ 1    -e₁₁      e₁₁⋅e₁₂     -e₁₁⋅e₁₂⋅e₁₃      e₁₁⋅e₁₂⋅e₁₃⋅e₁₄  ⎤
  ⎢───  ───────  ───────────  ───────────────  ───────────────────⎥
  ⎢u₁₁  u₁₁⋅u₁₂  u₁₁⋅u₁₂⋅u₁₃  u₁₁⋅u₁₂⋅u₁₃⋅u₁₄  u₁₁⋅u₁₂⋅u₁₃⋅u₁₄⋅u₁₅⎥
  ⎢                                                               ⎥
  ⎢        1        -e₁₂          e₁₂⋅e₁₃         -e₁₂⋅e₁₃⋅e₁₄    ⎥
  ⎢ 0     ───      ───────      ───────────      ───────────────  ⎥
  ⎢       u₁₂      u₁₂⋅u₁₃      u₁₂⋅u₁₃⋅u₁₄      u₁₂⋅u₁₃⋅u₁₄⋅u₁₅  ⎥
  ⎢                                                               ⎥
  ⎢                   1            -e₁₃              e₁₃⋅e₁₄      ⎥
  ⎢ 0      0         ───          ───────          ───────────    ⎥
  ⎢                  u₁₃          u₁₃⋅u₁₄          u₁₃⋅u₁₄⋅u₁₅    ⎥
  ⎢                                                               ⎥
  ⎢                                  1                -e₁₄        ⎥
  ⎢ 0      0          0             ───              ───────      ⎥
  ⎢                                 u₁₄              u₁₄⋅u₁₅      ⎥
  ⎢                                                               ⎥
  ⎢                                                     1         ⎥
  ⎢ 0      0          0              0                 ───        ⎥
  ⎣                                                    u₁₅        ⎦

EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h1_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

