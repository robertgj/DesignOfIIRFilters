#!/bin/sh

prog=minphase_test.m
descr="minphase_test.m (mfile)"
depends="test/minphase_test.m test_common.m print_polynomial.m direct_form_scale.m \
complementaryFIRlatticeFilter.m crossWelch.m minphase.m qroots.oct \
complementaryFIRdecomp.oct"

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
brzc = [  0.702278449012, -0.284747156840,  0.195991006882,  0.310333250766, ... 
          0.135915842966, -0.007622198349,  0.013539414190,  0.068315148534, ... 
          0.019358423204, -0.088556184589, -0.123568394677, -0.052846068697, ... 
          0.035521732824,  0.060100582793,  0.029846895931,  0.000251446401, ... 
         -0.003826320072,  0.001544786029, -0.000527786319, -0.006517762915, ... 
         -0.006982385819, -0.002252609067,  0.001415579689,  0.001682492424, ... 
          0.000733967884,  0.000312597857,  0.000190007106, -0.000036513340, ... 
         -0.000173379620,  0.000038188995, -0.000037157731 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.brzc.ok"; fail; fi

cat > test.k.ok << 'EOF'
k = [  0.999973545923,  0.999997439113,  0.999892198493,  0.999912068374, ... 
       0.999560459108,  0.996590306027,  0.997582105014,  0.999848632345, ... 
       0.997255806590,  0.999503325214,  0.999993493613,  0.993567986353, ... 
       0.962834846944,  0.987076261539,  0.964636964373,  0.863342898132, ... 
       0.964636964373,  0.987076261539,  0.962834846944,  0.993567986353, ... 
       0.999993493613,  0.999503325214,  0.997255806590,  0.999848632345, ... 
       0.997582105014,  0.996590306027,  0.999560459108,  0.999912068374, ... 
       0.999892198493,  0.999997439113, -0.007273751102 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k.ok"; fail; fi

cat > test.khat.ok << 'EOF'
khat = [  0.007273751102, -0.002263132068,  0.014683030806,  0.013261052754, ... 
         -0.029646055186, -0.082509162724, -0.069497796773,  0.017398632060, ... 
          0.074032805044,  0.031513534974, -0.003607316388,  0.113237169229, ... 
          0.270090831961,  0.160251221234, -0.263582106688, -0.504617716936, ... 
         -0.263582106688,  0.160251221234,  0.270090831961,  0.113237169229, ... 
         -0.003607316388,  0.031513534974,  0.074032805044,  0.017398632060, ... 
         -0.069497796773, -0.082509162724, -0.029646055186,  0.013261052754, ... 
          0.014683030806, -0.002263132068,  0.999973545923 ]';
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

