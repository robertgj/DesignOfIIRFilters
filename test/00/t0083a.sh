#!/bin/sh

prog=parallel_allpass_slb_update_constraints_test.m 

depends="parallel_allpass_slb_update_constraints_test.m test_common.m \
parallel_allpass_slb_update_constraints.m \
parallel_allpass_slb_show_constraints.m \
parallel_allpassAsq.m parallel_allpassT.m allpassP.m allpassT.m \
local_max.m tf2a.m a2tf.m"
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
verbose =  1
tol =    1.0000e-05
tol =    1.0000e-06
maxiter =  2000
polyphase = 0
Ra =  1
ma =  11
Rb =  1
mb =  12
td =  11.500
tdr =  0.040000
fap =  0.17500
Wap =  1
dBap =  1
ftp =  0.20000
Wtp =  5
fas =  0.25000
Wat =  1
Was =  500
dBas =  50
al=[ 351 ]
au=[ 1 107 501 543 ]
tl=[ 289 ]
tu=[ 333 401 ]
Current constraints:
al=[ 351 ]
f(al)=[ 0.175000 ](fs=1)
Asql=[ -2.082908 ](dB)
au=[ 1 107 501 543 ]
f(au)=[ 0.000000 0.053000 0.250000 0.271000 ](fs=1)
Asqu=[ 0.000000 -0.006984 -38.880570 -47.803240 ](dB)
tl=[ 289 ]
f(tl)=[ 0.144000 ](fs=1)
Tl=[ 11.476067 ](Samples)
tu=[ 333 401 ]
f(tu)=[ 0.166000 0.200000 ](fs=1)
Tu=[ 11.522268 11.527615 ](Samples)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

