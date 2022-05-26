#!/bin/sh

prog=minphase_test.m
descr="minphase_test.m (mfile)"
depends="test/minphase_test.m test_common.m print_polynomial.m direct_form_scale.m \
complementaryFIRlatticeFilter.m crossWelch.m minphase.m qroots.m \
qzsolve.oct complementaryFIRdecomp.oct"

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
brzc = [  0.702278455158, -0.284747150190,  0.195991006199,  0.310333248307, ... 
          0.135915839465, -0.007622203880,  0.013539408392,  0.068315146105, ... 
          0.019358425439, -0.088556180208, -0.123568391645, -0.052846068256, ... 
          0.035521731841,  0.060100581877,  0.029846895503,  0.000251446156, ... 
         -0.003826320303,  0.001544785942, -0.000527786189, -0.006517762705, ... 
         -0.006982385693, -0.002252609052,  0.001415579659,  0.001682492398, ... 
          0.000733967870,  0.000312597850,  0.000190007105, -0.000036513338, ... 
         -0.000173379619,  0.000038188995, -0.000037157731 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.brzc.ok"; fail; fi

cat > test.k.ok << 'EOF'
k = [  0.999973545923,  0.999997439113,  0.999892198494,  0.999912068377, ... 
       0.999560459113,  0.996590306134,  0.997582105159,  0.999848632328, ... 
       0.997255806727,  0.999503325334,  0.999993493602,  0.993567986529, ... 
       0.962834847250,  0.987076261596,  0.964636965455,  0.863342901944, ... 
       0.964636965455,  0.987076261596,  0.962834847250,  0.993567986529, ... 
       0.999993493602,  0.999503325334,  0.997255806727,  0.999848632328, ... 
       0.997582105159,  0.996590306134,  0.999560459113,  0.999912068377, ... 
       0.999892198494,  0.999997439113, -0.007273751039 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k.ok"; fail; fi

cat > test.khat.ok << 'EOF'
khat = [  0.007273751039, -0.002263132143,  0.014683030694,  0.013261052526, ... 
         -0.029646055025, -0.082509161431, -0.069497794685,  0.017398633019, ... 
          0.074032803197,  0.031513531157, -0.003607319586,  0.113237167684, ... 
          0.270090830870,  0.160251220882, -0.263582102727, -0.504617710413, ... 
         -0.263582102727,  0.160251220882,  0.270090830870,  0.113237167684, ... 
         -0.003607319586,  0.031513531157,  0.074032803197,  0.017398633019, ... 
         -0.069497794685, -0.082509161431, -0.029646055025,  0.013261052526, ... 
          0.014683030694, -0.002263132143,  0.999973545923 ]';
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

