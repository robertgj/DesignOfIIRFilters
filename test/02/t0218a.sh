#!/bin/sh

prog=schurNSlattice_slb_update_constraints_test.m
depends="schurNSlattice_slb_update_constraints_test.m test_common.m \
schurNSlattice_slb_update_constraints.m \
schurNSlatticeAsq.m schurNSlatticeT.m schurNSlatticeEsq.m \
schurNSlattice2Abcd.oct schurNSscale.oct \
schurNSlattice_slb_set_empty_constraints.m \
schurNSlattice_slb_show_constraints.m \
schurNSlattice_slb_constraints_are_empty.m tf2schurNSlattice.m \
schurNSlattice2tf.m local_max.m x2tf.m print_polynomial.m \
Abcd2tf.m H2Asq.m H2T.m schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct Abcd2H.oct"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
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
maxiter =  2000
tol =  0.0000050000
verbose = 1
fap =  0.15000
dBap =  0.10000
Wap =  1
fas =  0.30000
dBas =  50
Was =  10
ftp =  0.25000
tp =  6
tpr =  0.010000
Wtp =  0.10000
al=[ 1 301 ]
au=[ 191 601 655 ]
tl=[ 1 246 443 ]
tu=[ 126 355 498 ]
al=[ 1 301 ]
f(al)=[ 0.000000 0.150000 ](fs=1)
Asql=[ -0.184653 -0.786008 ](dB)
au=[ 191 601 655 ]
f(au)=[ 0.095000 0.300000 0.327000 ](fs=1)
Asqu=[ 0.000041 -39.996706 -45.040025 ](dB)
tl=[ 1 246 443 ]
f(tl)=[ 0.000000 0.122500 0.221000 ](fs=1)
Tl=[ 5.987503 5.987303 5.987335 ](Samples)
tu=[ 126 355 498 ]
f(tu)=[ 0.062500 0.177000 0.248500 ](fs=1)
Tu=[ 6.012534 6.012795 6.008982 ](Samples)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. Suppress m-file warnings
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog >test.out 
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.out test.ok
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

