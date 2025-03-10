#!/bin/sh

prog=minphase_test.m
descr="minphase_test.m (octfile)"
depends="test/minphase_test.m test_common.m print_polynomial.m direct_form_scale.m \
complementaryFIRlatticeFilter.m crossWelch.m qroots.oct \
complementaryFIRdecomp.oct minphase.oct"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED ${0#$here"/"} $descr 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED ${0#$here"/"} $descr
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15

# If minphase.oct does not exist then return the aet code for "pass"
if ! test -f src/minphase.oct; then 
    echo SKIPPED $descr minphase.oct not found! ; exit 0; 
fi

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
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

cat > test.brz.ok << 'EOF'
brz = [ -0.005108333779,  0.003660671781, -0.012383396144, -0.006947750356, ... 
         0.021448945190,  0.042973631538,  0.025415530577, -0.008724449666, ... 
        -0.004783022289,  0.027072600200,  0.000746818465, -0.110359730794, ... 
        -0.181875048113, -0.073706903519,  0.156538506093,  0.277521749504, ... 
         0.156538506093, -0.073706903519, -0.181875048113, -0.110359730794, ... 
         0.000746818465,  0.027072600200, -0.004783022289, -0.008724449666, ... 
         0.025415530577,  0.042973631538,  0.021448945190, -0.006947750356, ... 
        -0.012383396144,  0.003660671781, -0.005108333779 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.brz.ok"; fail; fi

cat > test.brzc.ok << 'EOF'
brzc = [  0.702278449711, -0.284747156084,  0.195991006805,  0.310333250487, ... 
          0.135915842568, -0.007622198978,  0.013539413531,  0.068315148258, ... 
          0.019358423458, -0.088556184091, -0.123568394332, -0.052846068647, ... 
          0.035521732713,  0.060100582689,  0.029846895882,  0.000251446373, ... 
         -0.003826320098,  0.001544786019, -0.000527786304, -0.006517762892, ... 
         -0.006982385805, -0.002252609065,  0.001415579686,  0.001682492421, ... 
          0.000733967882,  0.000312597856,  0.000190007106, -0.000036513340, ... 
         -0.000173379620,  0.000038188995, -0.000037157731 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.bzrc.ok"; fail; fi

cat > test.k.ok << 'EOF'
k = [  0.999973545923,  0.999997439113,  0.999892198493,  0.999912068374, ... 
       0.999560459108,  0.996590306039,  0.997582105030,  0.999848632343, ... 
       0.997255806605,  0.999503325227,  0.999993493612,  0.993567986373, ... 
       0.962834846979,  0.987076261545,  0.964636964496,  0.863342898565, ... 
       0.964636964496,  0.987076261545,  0.962834846979,  0.993567986373, ... 
       0.999993493612,  0.999503325227,  0.997255806605,  0.999848632343, ... 
       0.997582105030,  0.996590306039,  0.999560459108,  0.999912068374, ... 
       0.999892198493,  0.999997439113, -0.007273751095 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k.ok"; fail; fi

cat > test.khat.ok << 'EOF'
khat = [  0.007273751095, -0.002263132077,  0.014683030793,  0.013261052728, ... 
         -0.029646055167, -0.082509162577, -0.069497796536,  0.017398632169, ... 
          0.074032804834,  0.031513534540, -0.003607316752,  0.113237169053, ... 
          0.270090831837,  0.160251221194, -0.263582106238, -0.504617716195, ... 
         -0.263582106238,  0.160251221194,  0.270090831837,  0.113237169053, ... 
         -0.003607316752,  0.031513534540,  0.074032804834,  0.017398632169, ... 
         -0.069497796536, -0.082509162577, -0.029646055167,  0.013261052728, ... 
          0.014683030793, -0.002263132077,  0.999973545923 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.khat.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $descr"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

diff -Bb test.brz.ok minphase_test_brz_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.brz.ok"; fail; fi

diff -Bb test.brzc.ok minphase_test_brzc_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.brzc.ok"; fail; fi

diff -Bb test.k.ok minphase_test_k_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k.ok"; fail; fi

diff -Bb test.khat.ok minphase_test_khat_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.khat.ok"; fail; fi

#
# this much worked
#
pass

