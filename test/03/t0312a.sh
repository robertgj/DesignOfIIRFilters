#!/bin/sh

prog=directFIRhilbert_slb_test.m
depends="test_common.m \
directFIRhilbert_slb_test.m \
directFIRhilbert_slb_exchange_constraints.m \
directFIRhilbert_slb_update_constraints.m \
directFIRhilbert_slb_set_empty_constraints.m \
directFIRhilbert_slb_show_constraints.m \
directFIRhilbert_slb_constraints_are_empty.m \
directFIRhilbert_slb.m \
directFIRhilbert_mmsePW.m \
directFIRhilbertA.m \
directFIRhilbertEsqPW.m \
print_polynomial.m local_max.m"

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
cat > test_hM0.ok << 'EOF'
hM0 = [  -0.0026805043,  -0.0039292198,  -0.0075119166,  -0.0141233532, ... 
         -0.0247168597,  -0.0408841815,  -0.0659156017,  -0.1084226527, ... 
         -0.2004414172,  -0.6326257470 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM0.ok"; fail; fi

cat > test_hM1.ok << 'EOF'
hM1 = [  -0.0054928008,  -0.0108833008,  -0.0165796126,  -0.0240921177, ... 
         -0.0354459246,  -0.0523473570,  -0.0776282962,  -0.1187884154, ... 
         -0.2072170369,  -0.6334287637 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1.ok"; fail; fi

cat > test_hM2.ok << 'EOF'
hM2 = [  -0.0086302951,  -0.0133649396,  -0.0194607169,  -0.0273205074, ... 
         -0.0379833788,  -0.0525480847,  -0.0750429861,  -0.1138083316, ... 
         -0.2013619122,  -0.6286182035 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM2.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM0.ok directFIRhilbert_slb_test_hM0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM0.ok"; fail; fi

diff -Bb test_hM1.ok directFIRhilbert_slb_test_hM1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1.ok"; fail; fi

diff -Bb test_hM2.ok directFIRhilbert_slb_test_hM2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM2.ok"; fail; fi

#
# this much worked
#
pass

