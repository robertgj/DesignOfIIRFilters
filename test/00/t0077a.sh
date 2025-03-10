#!/bin/sh

prog=iir_frm_parallel_allpass_slb_update_constraints_test.m 

depends="test/iir_frm_parallel_allpass_slb_update_constraints_test.m test_common.m \
iir_frm_parallel_allpass_slb_update_constraints.m \
iir_frm_parallel_allpass_slb_show_constraints.m \
iir_frm_parallel_allpass_struct_to_vec.m \
iir_frm_parallel_allpass_vec_to_struct.m \
iir_frm_parallel_allpass.m allpassP.m allpassT.m \
local_max.m tf2a.m a2tf.m qroots.oct"

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
verbose = 1
tol = 1.0000e-05
tol = 1.0000e-05
mr = 7
ms = 6
na = 17
nc = 17
Mmodel = 9
Dmodel = 6.5000
dmask = 4.5000
fap = 0.3000
dBap = 0.1000
Wap = 1
tpr = 2
Wtp = 0.025000
fas = 0.3100
dBas = 40
Was = 50
al=[ 44 79 146 180 266 301 371 400 490 524 601 ]
au=[ 1 61 110 163 226 283 330 385 446 507 551 621 662 710 732 772 824 ]
tl=[ 152 374 494 ]
tu=[ 61 283 410 507 601 ]
Current constraints:
al=[ 44 79 146 180 266 301 371 400 490 524 601 ]
f(al)=[ 0.021500 0.039000 0.072500 0.089500 0.132500 0.150000 0.185000 0.199500 0.244500 0.261500 0.300000 ](fs=1)
Asql=[ -0.223329 -0.139787 -0.193923 -0.284133 -0.169007 -0.128047 -0.269298 -0.344732 -0.330738 -0.211399 -1.930115 ](dB)
au=[ 1 61 110 163 226 283 330 385 446 507 551 621 662 710 732 772 824 ]
f(au)=[ 0.000000 0.030000 0.054500 0.081000 0.112500 0.141000 0.164500 0.192000 0.222500 0.253000 0.275000 0.310000 0.330500 0.354500 0.365500 0.385500 0.411500 ](fs=1)
Asqu=[ 0.057626 0.292217 0.133947 0.199041 0.075175 0.354918 0.165827 0.005319 0.231350 0.372947 0.227185 -25.202200 -36.092067 -35.369908 -33.756197 -36.025483 -36.089753 ](dB)
tl=[ 152 374 494 ]
f(tl)=[ 0.075500 0.186500 0.246500 ](fs=1)
Tl=[ 61.897658 61.811023 61.138356 ](Samples)
tu=[ 61 283 410 507 601 ]
f(tu)=[ 0.030000 0.141000 0.204500 0.253000 0.300000 ](fs=1)
Tu=[ 64.010974 64.153571 64.057333 65.539324 72.076352 ](Samples)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

