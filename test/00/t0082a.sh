#!/bin/sh

prog=parallel_allpass_slb_exchange_constraints_test.m

depends="parallel_allpass_slb_exchange_constraints_test.m \
parallel_allpass_slb_exchange_constraints.m \
parallel_allpass_slb_show_constraints.m \
parallel_allpass_slb_update_constraints.m \
parallel_allpassAsq.m parallel_allpassT.m \
test_common.m allpassP.m allpassT.m tf2a.m a2tf.m local_max.m"
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
verbose =  1
tol =    1.0000e-06
maxiter =  2000
polyphase = 0
Ra =  1
ma =  11
mb =  12
Rb =  1
td =  11.500
tdr =  0.040000
fap =  0.17500
Wap =  1
dBap =  1
ftp =  0.20000
Wtp =  5
fas =  0.25000
Was =  500
dBas =  50
vRab0 before exchange constraints:
Current constraints:
al=[ 351 ]
f(al)=[ 0.175000 ](fs=1)
Asql=[ -2.082911 ](dB)
au=[ 1 107 501 543 ]
f(au)=[ 0.000000 0.053000 0.250000 0.271000 ](fs=1)
Asqu=[ 0.000000 -0.006984 -38.880646 -47.802617 ](dB)
tl=[ 289 ]
f(tl)=[ 0.144000 ](fs=1)
Tl=[ 11.476069 ](Samples)
tu=[ 333 401 ]
f(tu)=[ 0.166000 0.200000 ](fs=1)
Tu=[ 11.522271 11.527620 ](Samples)
vSab1 before exchange constraints:
Current constraints:
al=[ 351 ]
f(al)=[ 0.175000 ](fs=1)
Asql=[ -2.082911 ](dB)
au=[ 1 97 140 275 501 547 659 697 776 922 965 ]
f(au)=[ 0.000000 0.048000 0.069500 0.137000 0.250000 0.273000 0.329000 0.348000 0.387500 0.460500 0.482000 ](fs=1)
Asqu=[ 0.000000 -0.007625 -0.020102 -0.246901 -38.880646 -47.944035 -55.927378 -63.304949 -85.319980 -57.616208 -56.889028 ](dB)
tl=[ 132 200 296 378 ]
f(tl)=[ 0.065500 0.099500 0.147500 0.188500 ](fs=1)
Tl=[ 11.492883 11.493026 11.478988 11.485693 ](Samples)
tu=[ 83 247 342 401 ]
f(tu)=[ 0.041000 0.123000 0.170500 0.200000 ](fs=1)
Tu=[ 11.509780 11.516601 11.517986 11.527620 ](Samples)
Exchanged constraint from vR.au(1) to vS
vRab1 after exchange constraints:
Current constraints:
al=[ 351 ]
f(al)=[ 0.175000 ](fs=1)
Asql=[ -1.066736 ](dB)
au=[ 107 501 543 ]
f(au)=[ 0.053000 0.250000 0.271000 ](fs=1)
Asqu=[ -0.000593 -34.550322 -40.097663 ](dB)
tl=[ 289 ]
f(tl)=[ 0.144000 ](fs=1)
Tl=[ 11.438747 ](Samples)
tu=[ 333 401 ]
f(tu)=[ 0.166000 0.200000 ](fs=1)
Tu=[ 11.535894 11.575651 ](Samples)
vSab1 after exchange constraints:
Current constraints:
al=[ 351 ]
f(al)=[ 0.175000 ](fs=1)
Asql=[ -1.066736 ](dB)
au=[ 1 97 140 275 501 547 659 697 776 922 965 ]
f(au)=[ 0.000000 0.048000 0.069500 0.137000 0.250000 0.273000 0.329000 0.348000 0.387500 0.460500 0.482000 ](fs=1)
Asqu=[ 0.000000 -0.000000 -0.000000 -0.042285 -34.550322 -40.014811 -43.277032 -44.001819 -45.206264 -46.377013 -46.518275 ](dB)
tl=[ 132 200 296 378 ]
f(tl)=[ 0.065500 0.099500 0.147500 0.188500 ](fs=1)
Tl=[ 11.473012 11.479364 11.431741 11.471335 ](Samples)
tu=[ 83 247 342 401 ]
f(tu)=[ 0.041000 0.123000 0.170500 0.200000 ](fs=1)
Tu=[ 11.537656 11.555707 11.546648 11.575651 ](Samples)
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

