#!/bin/sh

prog=goldensection_test.m
depends="goldensection_test.m test_common.m goldstein.m armijo.m \
goldensection.m quadratic.m"

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

With goldstein()
tau =  1
iter = 0
ans =  4.4100
fiter =  4
tau =  0.25000
iter =  2
ans = 0
fiter =  10
tau =  0.12500
iter =  3
ans =  0.062500
fiter =  17

With armijo()
tau =  1
iter = 0
ans =  4.4100
fiter =  20
tau =  0.25000
iter =  2
ans = 0
fiter =  25
tau =  0.12500
iter =  3
ans =  0.062500
fiter =  31

With goldensection()

Initial point:
gxf= [ -6.200000 ]
x= [ -4.100000 ]
d= [ 1.000000 ]
alphak= [ 0.000000 ] falphak = 9.610000
betak=  [ 0.190983 ] fbetak  = 8.462380
gammak= [ 0.309017 ] fgammak = 7.789586
deltak= [ 0.500000 ] fdeltak = 6.760000

Current point:
x= [ -4.100000 ]
d= [ 1.000000 ]
alphak= [ 0.309017 ] falphak = 7.789586
betak=  [ 0.381966 ] fbetak  = 7.387709
gammak= [ 0.427051 ] fgammak = 7.144656
deltak= [ 0.500000 ] fdeltak = 6.760000

Current point:
x= [ -4.100000 ]
d= [ 1.000000 ]
alphak= [ 0.427051 ] falphak = 7.144656
betak=  [ 0.454915 ] fbetak  = 6.996475
gammak= [ 0.472136 ] fgammak = 6.905669
deltak= [ 0.500000 ] fdeltak = 6.760000

Current point:
x= [ -4.100000 ]
d= [ 1.000000 ]
alphak= [ 0.472136 ] falphak = 6.905669
betak=  [ 0.482779 ] fbetak  = 6.849845
gammak= [ 0.489357 ] fgammak = 6.815457
deltak= [ 0.500000 ] fdeltak = 6.760000

Current point:
x= [ -4.100000 ]
d= [ 1.000000 ]
alphak= [ 0.489357 ] falphak = 6.815457
betak=  [ 0.493422 ] fbetak  = 6.794248
gammak= [ 0.495935 ] fgammak = 6.781156
deltak= [ 0.500000 ] fdeltak = 6.760000

Current point:
x= [ -4.100000 ]
d= [ 1.000000 ]
alphak= [ 0.495935 ] falphak = 6.781156
betak=  [ 0.497488 ] fbetak  = 6.773071
gammak= [ 0.498447 ] fgammak = 6.768077
deltak= [ 0.500000 ] fdeltak = 6.760000

Current point:
x= [ -4.100000 ]
d= [ 1.000000 ]
alphak= [ 0.498447 ] falphak = 6.768077
betak=  [ 0.499040 ] fbetak  = 6.764991
gammak= [ 0.499407 ] fgammak = 6.763085
deltak= [ 0.500000 ] fdeltak = 6.760000

Current point:
x= [ -4.100000 ]
d= [ 1.000000 ]
alphak= [ 0.499407 ] falphak = 6.763085
betak=  [ 0.499633 ] fbetak  = 6.761906
gammak= [ 0.499773 ] fgammak = 6.761178
deltak= [ 0.500000 ] fdeltak = 6.760000

Current point:
x= [ -4.100000 ]
d= [ 1.000000 ]
alphak= [ 0.499773 ] falphak = 6.761178
betak=  [ 0.499860 ] fbetak  = 6.760728
gammak= [ 0.499913 ] fgammak = 6.760450
deltak= [ 0.500000 ] fdeltak = 6.760000

Current point:
x= [ -4.100000 ]
d= [ 1.000000 ]
alphak= [ 0.499913 ] falphak = 6.760450
betak=  [ 0.499947 ] fbetak  = 6.760278
gammak= [ 0.499967 ] fgammak = 6.760172
deltak= [ 0.500000 ] fdeltak = 6.760000
tau =  0.50000
iter =  9
ans =  6.7600
fiter =  55

Initial point:
gxf= [ -1.000000 ]
x= [ -1.500000 ]
d= [ 2.000000 ]
alphak= [ 0.000000 ] falphak = 0.250000
betak=  [ 0.190983 ] fbetak  = 0.013932
gammak= [ 0.309017 ] fgammak = 0.013932
deltak= [ 0.500000 ] fdeltak = 0.250000

Current point:
x= [ -1.500000 ]
d= [ 2.000000 ]
alphak= [ 0.190983 ] falphak = 0.013932
betak=  [ 0.236068 ] fbetak  = 0.000776
gammak= [ 0.263932 ] fgammak = 0.000776
deltak= [ 0.309017 ] fdeltak = 0.013932

Current point:
x= [ -1.500000 ]
d= [ 2.000000 ]
alphak= [ 0.236068 ] falphak = 0.000776
betak=  [ 0.246711 ] fbetak  = 0.000043
gammak= [ 0.253289 ] fgammak = 0.000043
deltak= [ 0.263932 ] fdeltak = 0.000776
tau =  0.24671
iter =  2
ans =  0.000043268
fiter =  65

Initial point:
gxf= [ -2.000000 ]
x= [ -2.000000 ]
d= [ 10.000000 ]
alphak= [ 0.000000 ] falphak = 1.000000
betak=  [ 0.190983 ] fbetak  = 0.827791
gammak= [ 0.309017 ] fgammak = 4.368810
deltak= [ 0.500000 ] fdeltak = 16.000000

Current point:
x= [ -2.000000 ]
d= [ 10.000000 ]
alphak= [ 0.000000 ] falphak = 1.000000
betak=  [ 0.118034 ] fbetak  = 0.032522
gammak= [ 0.190983 ] fgammak = 0.827791
deltak= [ 0.309017 ] fdeltak = 4.368810

Current point:
x= [ -2.000000 ]
d= [ 10.000000 ]
alphak= [ 0.000000 ] falphak = 1.000000
betak=  [ 0.072949 ] fbetak  = 0.073176
gammak= [ 0.118034 ] fgammak = 0.032522
deltak= [ 0.190983 ] fdeltak = 0.827791

Current point:
x= [ -2.000000 ]
d= [ 10.000000 ]
alphak= [ 0.072949 ] falphak = 0.073176
betak=  [ 0.118034 ] fbetak  = 0.032522
gammak= [ 0.145898 ] fgammak = 0.210663
deltak= [ 0.190983 ] fdeltak = 0.827791

Current point:
x= [ -2.000000 ]
d= [ 10.000000 ]
alphak= [ 0.072949 ] falphak = 0.073176
betak=  [ 0.100813 ] fbetak  = 0.000066
gammak= [ 0.118034 ] fgammak = 0.032522
deltak= [ 0.145898 ] fdeltak = 0.210663

Current point:
x= [ -2.000000 ]
d= [ 10.000000 ]
alphak= [ 0.072949 ] falphak = 0.073176
betak=  [ 0.090170 ] fbetak  = 0.009663
gammak= [ 0.100813 ] fgammak = 0.000066
deltak= [ 0.118034 ] fdeltak = 0.032522

Current point:
x= [ -2.000000 ]
d= [ 10.000000 ]
alphak= [ 0.090170 ] falphak = 0.009663
betak=  [ 0.100813 ] fbetak  = 0.000066
gammak= [ 0.107391 ] fgammak = 0.005462
deltak= [ 0.118034 ] fdeltak = 0.032522

Current point:
x= [ -2.000000 ]
d= [ 10.000000 ]
alphak= [ 0.090170 ] falphak = 0.009663
betak=  [ 0.096748 ] fbetak  = 0.001058
gammak= [ 0.100813 ] fgammak = 0.000066
deltak= [ 0.107391 ] fdeltak = 0.005462

Current point:
x= [ -2.000000 ]
d= [ 10.000000 ]
alphak= [ 0.096748 ] falphak = 0.001058
betak=  [ 0.100813 ] fbetak  = 0.000066
gammak= [ 0.103326 ] fgammak = 0.001106
deltak= [ 0.107391 ] fdeltak = 0.005462

Current point:
x= [ -2.000000 ]
d= [ 10.000000 ]
alphak= [ 0.096748 ] falphak = 0.001058
betak=  [ 0.099260 ] fbetak  = 0.000055
gammak= [ 0.100813 ] fgammak = 0.000066
deltak= [ 0.103326 ] fdeltak = 0.001106

Current point:
x= [ -2.000000 ]
d= [ 10.000000 ]
alphak= [ 0.096748 ] falphak = 0.001058
betak=  [ 0.098301 ] fbetak  = 0.000289
gammak= [ 0.099260 ] fgammak = 0.000055
deltak= [ 0.100813 ] fdeltak = 0.000066

Current point:
x= [ -2.000000 ]
d= [ 10.000000 ]
alphak= [ 0.098301 ] falphak = 0.000289
betak=  [ 0.099260 ] fbetak  = 0.000055
gammak= [ 0.099853 ] fgammak = 0.000002
deltak= [ 0.100813 ] fdeltak = 0.000066
tau =  0.099853
iter =  11
ans =  0.0000021500
fiter =  82
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. Suppress m-file warnings
#
echo "Running octave-cli -q " $prog
echo "warning('off');" >> .octaverc

octave-cli -q $prog > test.out 2> /dev/null
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

