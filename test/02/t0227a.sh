#!/bin/sh

prog=bin2SDul_test.m
depends="bin2SDul_test.m test_common.m bin2SDul.m bin2SD.oct bin2SPT.oct"

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
Caught sd=bin2SDul([6:7],4,1): x is not a scalar
Caught [yu,yl]=bin2SDul(1,51,52):Expected 0<=ndigits(52)<=nbits(51)
Caught [yu,yl]=bin2SDul(1,52,51):Expected 0<nbits(52)<=51
Caught [yu,yl]=bin2SDul(1,8,9):Expected 0<=ndigits(9)<=nbits(8)
Caught [yu,yl]=bin2SDul(1,8,0):yu(0)<x(1)
Caught [yu,yl]=bin2SDul(1,8,-1):Expected 0<=ndigits(-1)<=nbits(8)
Caught [yu,yl]=bin2SDul(1,0,8):Expected 0<nbits(0)<=51
Caught [yu,yl]=bin2SDul(1,0,0):yu(0)<x(1)
x=     0, yu=0, spt(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=     0, yl=0, sptl(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=     0, yu=0, spt(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=     0, yl=0, sptl(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=0.499999, yu=1, spt(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=0.499999, yl=0, sptl(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=-0.499999, yu=0, spt(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=-0.499999, yl=-1, sptl(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=   0.5, yu=1, spt(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=   0.5, yl=0, sptl(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=  -0.5, yu=0, spt(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=  -0.5, yl=-1, sptl(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=0.500001, yu=1, spt(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=0.500001, yl=0, sptl(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=-0.500001, yu=0, spt(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=-0.500001, yl=-1, sptl(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=     0, yu=0, spt(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=     0, yl=0, sptl(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=     0, yu=0, spt(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=     0, yl=0, sptl(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=     0, yu=0, spt(1:-1:1)=[  0 ], ndigits=0
x=     0, yl=0, sptl(1:-1:1)=[  0 ], ndigits=0
Caught [yu,yl]=bin2SDul(1,1,1):x=1,round(x)=1 is out of range for a 1 bits 2s complement number!
Caught [yu,yl]=bin2SDul(2,1,1):x=2,round(x)=2 is out of range for a 1 bits 2s complement number!
x=    -1, yu=-1, spt(1:-1:1)=[ -1 ], ndigits=1
x=    -1, yl=-1, sptl(1:-1:1)=[ -1 ], ndigits=1
x=     0, yu=0, spt(2:-1:1)=[  0  0 ], ndigits=0
x=     0, yl=0, sptl(2:-1:1)=[  0  0 ], ndigits=0
x=     1, yu=1, spt(2:-1:1)=[  0  1 ], ndigits=1
x=     1, yl=1, sptl(2:-1:1)=[  0  1 ], ndigits=1
x=    -1, yu=-1, spt(2:-1:1)=[  0 -1 ], ndigits=1
x=    -1, yl=-1, sptl(2:-1:1)=[  0 -1 ], ndigits=1
x=    -2, yu=-2, spt(2:-1:1)=[ -1  0 ], ndigits=1
x=    -2, yl=-2, sptl(2:-1:1)=[ -1  0 ], ndigits=1
x=     1, yu=1, spt(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=     1, yl=1, sptl(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=     1, yu=1, spt(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=     1, yl=1, sptl(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=     1, yu=1, spt(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=     1, yl=1, sptl(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=     1, yu=1, spt(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=     1, yl=1, sptl(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=    -1, yu=-1, spt(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=    -1, yl=-1, sptl(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=    -1, yu=-1, spt(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=    -1, yl=-1, sptl(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=    -1, yu=-1, spt(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=    -1, yl=-1, sptl(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=    -1, yu=-1, spt(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=    -1, yl=-1, sptl(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=   1.5, yu=2, spt(8:-1:1)=[  0  0  0  0  0  0  1  0 ], ndigits=1
x=   1.5, yl=1, sptl(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=  -1.5, yu=-1, spt(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=  -1.5, yl=-2, sptl(8:-1:1)=[  0  0  0  0  0  0 -1  0 ], ndigits=1
x=   1.5, yu=2, spt(8:-1:1)=[  0  0  0  0  0  0  1  0 ], ndigits=1
x=   1.5, yl=1, sptl(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=  -1.5, yu=-1, spt(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=  -1.5, yl=-2, sptl(8:-1:1)=[  0  0  0  0  0  0 -1  0 ], ndigits=1
x=   1.5, yu=2, spt(8:-1:1)=[  0  0  0  0  0  0  1  0 ], ndigits=1
x=   1.5, yl=1, sptl(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=  -1.5, yu=-1, spt(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=  -1.5, yl=-2, sptl(8:-1:1)=[  0  0  0  0  0  0 -1  0 ], ndigits=1
x=   -43, yu=-32, spt(7:-1:1)=[  0 -1  0  0  0  0  0 ], ndigits=1
x=   -43, yl=-64, sptl(7:-1:1)=[ -1  0  0  0  0  0  0 ], ndigits=1
x=   -43, yu=-40, spt(7:-1:1)=[  0 -1  0 -1  0  0  0 ], ndigits=2
x=   -43, yl=-48, sptl(7:-1:1)=[ -1  0  1  0  0  0  0 ], ndigits=2
x=   -43, yu=-42, spt(7:-1:1)=[  0 -1  0 -1  0 -1  0 ], ndigits=3
x=   -43, yl=-44, sptl(7:-1:1)=[ -1  0  1  0  1  0  0 ], ndigits=3
x=   -43, yu=-43, spt(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x=   -43, yl=-43, sptl(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x=   -43, yu=-43, spt(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x=   -43, yl=-43, sptl(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x=    43, yu=64, spt(7:-1:1)=[  1  0  0  0  0  0  0 ], ndigits=1
x=    43, yl=32, sptl(7:-1:1)=[  0  1  0  0  0  0  0 ], ndigits=1
x=    43, yu=48, spt(7:-1:1)=[  1  0 -1  0  0  0  0 ], ndigits=2
x=    43, yl=40, sptl(7:-1:1)=[  0  1  0  1  0  0  0 ], ndigits=2
x=    43, yu=44, spt(7:-1:1)=[  1  0 -1  0 -1  0  0 ], ndigits=3
x=    43, yl=42, sptl(7:-1:1)=[  0  1  0  1  0  1  0 ], ndigits=3
x=    43, yu=43, spt(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x=    43, yl=43, sptl(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x=    43, yu=43, spt(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x=    43, yl=43, sptl(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x= -43.4, yu=-32, spt(7:-1:1)=[  0 -1  0  0  0  0  0 ], ndigits=1
x= -43.4, yl=-64, sptl(7:-1:1)=[ -1  0  0  0  0  0  0 ], ndigits=1
x= -43.4, yu=-40, spt(7:-1:1)=[  0 -1  0 -1  0  0  0 ], ndigits=2
x= -43.4, yl=-48, sptl(7:-1:1)=[ -1  0  1  0  0  0  0 ], ndigits=2
x= -43.4, yu=-42, spt(7:-1:1)=[  0 -1  0 -1  0 -1  0 ], ndigits=3
x= -43.4, yl=-44, sptl(7:-1:1)=[ -1  0  1  0  1  0  0 ], ndigits=3
x= -43.4, yu=-43, spt(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x= -43.4, yl=-44, sptl(7:-1:1)=[ -1  0  1  0  1  0  0 ], ndigits=3
x= -43.4, yu=-43, spt(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x= -43.4, yl=-44, sptl(7:-1:1)=[ -1  0  1  0  1  0  0 ], ndigits=3
x=  43.4, yu=64, spt(7:-1:1)=[  1  0  0  0  0  0  0 ], ndigits=1
x=  43.4, yl=32, sptl(7:-1:1)=[  0  1  0  0  0  0  0 ], ndigits=1
x=  43.4, yu=48, spt(7:-1:1)=[  1  0 -1  0  0  0  0 ], ndigits=2
x=  43.4, yl=40, sptl(7:-1:1)=[  0  1  0  1  0  0  0 ], ndigits=2
x=  43.4, yu=44, spt(7:-1:1)=[  1  0 -1  0 -1  0  0 ], ndigits=3
x=  43.4, yl=42, sptl(7:-1:1)=[  0  1  0  1  0  1  0 ], ndigits=3
x=  43.4, yu=44, spt(7:-1:1)=[  1  0 -1  0 -1  0  0 ], ndigits=3
x=  43.4, yl=43, sptl(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x=  43.4, yu=44, spt(7:-1:1)=[  1  0 -1  0 -1  0  0 ], ndigits=3
x=  43.4, yl=43, sptl(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x= -43.6, yu=-32, spt(7:-1:1)=[  0 -1  0  0  0  0  0 ], ndigits=1
x= -43.6, yl=-64, sptl(7:-1:1)=[ -1  0  0  0  0  0  0 ], ndigits=1
x= -43.6, yu=-40, spt(7:-1:1)=[  0 -1  0 -1  0  0  0 ], ndigits=2
x= -43.6, yl=-48, sptl(7:-1:1)=[ -1  0  1  0  0  0  0 ], ndigits=2
x= -43.6, yu=-42, spt(7:-1:1)=[  0 -1  0 -1  0 -1  0 ], ndigits=3
x= -43.6, yl=-44, sptl(7:-1:1)=[ -1  0  1  0  1  0  0 ], ndigits=3
x= -43.6, yu=-43, spt(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x= -43.6, yl=-44, sptl(7:-1:1)=[ -1  0  1  0  1  0  0 ], ndigits=3
x= -43.6, yu=-43, spt(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x= -43.6, yl=-44, sptl(7:-1:1)=[ -1  0  1  0  1  0  0 ], ndigits=3
x=  43.6, yu=64, spt(7:-1:1)=[  1  0  0  0  0  0  0 ], ndigits=1
x=  43.6, yl=32, sptl(7:-1:1)=[  0  1  0  0  0  0  0 ], ndigits=1
x=  43.6, yu=48, spt(7:-1:1)=[  1  0 -1  0  0  0  0 ], ndigits=2
x=  43.6, yl=40, sptl(7:-1:1)=[  0  1  0  1  0  0  0 ], ndigits=2
x=  43.6, yu=44, spt(7:-1:1)=[  1  0 -1  0 -1  0  0 ], ndigits=3
x=  43.6, yl=42, sptl(7:-1:1)=[  0  1  0  1  0  1  0 ], ndigits=3
x=  43.6, yu=44, spt(7:-1:1)=[  1  0 -1  0 -1  0  0 ], ndigits=3
x=  43.6, yl=43, sptl(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x=  43.6, yu=44, spt(7:-1:1)=[  1  0 -1  0 -1  0  0 ], ndigits=3
x=  43.6, yl=43, sptl(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x= -42.9, yu=-32, spt(7:-1:1)=[  0 -1  0  0  0  0  0 ], ndigits=1
x= -42.9, yl=-64, sptl(7:-1:1)=[ -1  0  0  0  0  0  0 ], ndigits=1
x= -42.9, yu=-40, spt(7:-1:1)=[  0 -1  0 -1  0  0  0 ], ndigits=2
x= -42.9, yl=-48, sptl(7:-1:1)=[ -1  0  1  0  0  0  0 ], ndigits=2
x= -42.9, yu=-42, spt(7:-1:1)=[  0 -1  0 -1  0 -1  0 ], ndigits=3
x= -42.9, yl=-44, sptl(7:-1:1)=[ -1  0  1  0  1  0  0 ], ndigits=3
x= -42.9, yu=-42, spt(7:-1:1)=[  0 -1  0 -1  0 -1  0 ], ndigits=3
x= -42.9, yl=-43, sptl(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x= -42.9, yu=-42, spt(7:-1:1)=[  0 -1  0 -1  0 -1  0 ], ndigits=3
x= -42.9, yl=-43, sptl(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x=  42.9, yu=64, spt(7:-1:1)=[  1  0  0  0  0  0  0 ], ndigits=1
x=  42.9, yl=32, sptl(7:-1:1)=[  0  1  0  0  0  0  0 ], ndigits=1
x=  42.9, yu=48, spt(7:-1:1)=[  1  0 -1  0  0  0  0 ], ndigits=2
x=  42.9, yl=40, sptl(7:-1:1)=[  0  1  0  1  0  0  0 ], ndigits=2
x=  42.9, yu=44, spt(7:-1:1)=[  1  0 -1  0 -1  0  0 ], ndigits=3
x=  42.9, yl=42, sptl(7:-1:1)=[  0  1  0  1  0  1  0 ], ndigits=3
x=  42.9, yu=43, spt(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x=  42.9, yl=42, sptl(7:-1:1)=[  0  1  0  1  0  1  0 ], ndigits=3
x=  42.9, yu=43, spt(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x=  42.9, yl=42, sptl(7:-1:1)=[  0  1  0  1  0  1  0 ], ndigits=3
x=   141, yu=141, spt(9:-1:1)=[  0  1  0  0  1  0 -1  0  1 ], ndigits=4
x=   141, yl=141, sptl(9:-1:1)=[  0  1  0  0  1  0 -1  0  1 ], ndigits=4
x=  -141, yu=-141, spt(9:-1:1)=[  0 -1  0  0 -1  0  1  0 -1 ], ndigits=4
x=  -141, yl=-141, sptl(9:-1:1)=[  0 -1  0  0 -1  0  1  0 -1 ], ndigits=4
x=   170, yu=256, spt(9:-1:1)=[  1  0  0  0  0  0  0  0  0 ], ndigits=1
x=   170, yl=128, sptl(9:-1:1)=[  0  1  0  0  0  0  0  0  0 ], ndigits=1
x=   170, yu=192, spt(9:-1:1)=[  1  0 -1  0  0  0  0  0  0 ], ndigits=2
x=   170, yl=160, sptl(9:-1:1)=[  0  1  0  1  0  0  0  0  0 ], ndigits=2
x=   170, yu=176, spt(9:-1:1)=[  1  0 -1  0 -1  0  0  0  0 ], ndigits=3
x=   170, yl=168, sptl(9:-1:1)=[  0  1  0  1  0  1  0  0  0 ], ndigits=3
x=   170, yu=170, spt(9:-1:1)=[  0  1  0  1  0  1  0  1  0 ], ndigits=4
x=   170, yl=170, sptl(9:-1:1)=[  0  1  0  1  0  1  0  1  0 ], ndigits=4
x=   170, yu=170, spt(9:-1:1)=[  0  1  0  1  0  1  0  1  0 ], ndigits=4
x=   170, yl=170, sptl(9:-1:1)=[  0  1  0  1  0  1  0  1  0 ], ndigits=4
x=  -170, yu=-128, spt(9:-1:1)=[  0 -1  0  0  0  0  0  0  0 ], ndigits=1
x=  -170, yl=-256, sptl(9:-1:1)=[ -1  0  0  0  0  0  0  0  0 ], ndigits=1
x=  -170, yu=-160, spt(9:-1:1)=[  0 -1  0 -1  0  0  0  0  0 ], ndigits=2
x=  -170, yl=-192, sptl(9:-1:1)=[ -1  0  1  0  0  0  0  0  0 ], ndigits=2
x=  -170, yu=-168, spt(9:-1:1)=[  0 -1  0 -1  0 -1  0  0  0 ], ndigits=3
x=  -170, yl=-176, sptl(9:-1:1)=[ -1  0  1  0  1  0  0  0  0 ], ndigits=3
x=  -170, yu=-170, spt(9:-1:1)=[  0 -1  0 -1  0 -1  0 -1  0 ], ndigits=4
x=  -170, yl=-170, sptl(9:-1:1)=[  0 -1  0 -1  0 -1  0 -1  0 ], ndigits=4
x=  -170, yu=-170, spt(9:-1:1)=[  0 -1  0 -1  0 -1  0 -1  0 ], ndigits=4
x=  -170, yl=-170, sptl(9:-1:1)=[  0 -1  0 -1  0 -1  0 -1  0 ], ndigits=4
Caught [yu,yl]=bin2SDul(128,8,1):x=128,round(x)=128 is out of range for a 8 bits 2s complement number!
x=   128, yu=128, spt(9:-1:1)=[  0  1  0  0  0  0  0  0  0 ], ndigits=1
x=   128, yl=128, sptl(9:-1:1)=[  0  1  0  0  0  0  0  0  0 ], ndigits=1
x=  -128, yu=-128, spt(8:-1:1)=[ -1  0  0  0  0  0  0  0 ], ndigits=1
x=  -128, yl=-128, sptl(8:-1:1)=[ -1  0  0  0  0  0  0  0 ], ndigits=1
x=   127, yu=128, spt(8:-1:1)=[  1  0  0  0  0  0  0  0 ], ndigits=1
x=   127, yl=64, sptl(8:-1:1)=[  0  1  0  0  0  0  0  0 ], ndigits=1
x=   127, yu=127, spt(8:-1:1)=[  1  0  0  0  0  0  0 -1 ], ndigits=2
x=   127, yl=127, sptl(8:-1:1)=[  1  0  0  0  0  0  0 -1 ], ndigits=2
x=   127, yu=127, spt(8:-1:1)=[  1  0  0  0  0  0  0 -1 ], ndigits=2
x=   127, yl=127, sptl(8:-1:1)=[  1  0  0  0  0  0  0 -1 ], ndigits=2
x=   127, yu=127, spt(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0 -1 ], ndigits=2
x=   127, yl=127, sptl(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0 -1 ], ndigits=2
x=   127, yu=127, spt(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0 -1 ], ndigits=2
x=   127, yl=127, sptl(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0 -1 ], ndigits=2
x=  -128, yu=-128, spt(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0 ], ndigits=1
x=  -128, yl=-128, sptl(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0 ], ndigits=1
x=  -128, yu=-128, spt(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0 ], ndigits=1
x=  -128, yl=-128, sptl(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0 ], ndigits=1
Caught [yu,yl]=bin2SDul(128,8,2):x=128,round(x)=128 is out of range for a 8 bits 2s complement number!
Caught [yu,yl]=bin2SDul(-129,8,2):x=-129,round(x)=-129 is out of range for a 8 bits 2s complement number!
Caught [yu,yl]=bin2SDul(63.49,7,2):x=64.49,round(x)=64 is out of range for a 7 bits 2s complement number!
Caught [yu,yl]=bin2SDul(63.51,7,2):x=63.51,round(x)=64 is out of range for a 7 bits 2s complement number!
k=-128, yu=-128, k-yu= 0, sptu(8:-1:1)=[-1  0  0  0  0  0  0  0 ], ndigits=1
k=-128, yl=-128, k-yl= 0, sptl(8:-1:1)=[-1  0  0  0  0  0  0  0 ], ndigits=1
k=-127.75, yu=-127, k-yu=-0.75, sptu(8:-1:1)=[-1  0  0  0  0  0  0  1 ], ndigits=2
k=-127.75, yl=-128, k-yl=0.25, sptl(8:-1:1)=[-1  0  0  0  0  0  0  0 ], ndigits=1
k=-127.5, yu=-127, k-yu=-0.5, sptu(8:-1:1)=[-1  0  0  0  0  0  0  1 ], ndigits=2
k=-127.5, yl=-128, k-yl=0.5, sptl(8:-1:1)=[-1  0  0  0  0  0  0  0 ], ndigits=1
k=-127.25, yu=-127, k-yu=-0.25, sptu(8:-1:1)=[-1  0  0  0  0  0  0  1 ], ndigits=2
k=-127.25, yl=-128, k-yl=0.75, sptl(8:-1:1)=[-1  0  0  0  0  0  0  0 ], ndigits=1
k=-127, yu=-127, k-yu= 0, sptu(8:-1:1)=[-1  0  0  0  0  0  0  1 ], ndigits=2
k=-127, yl=-127, k-yl= 0, sptl(8:-1:1)=[-1  0  0  0  0  0  0  1 ], ndigits=2
k=-126.75, yu=-126, k-yu=-0.75, sptu(8:-1:1)=[-1  0  0  0  0  0  1  0 ], ndigits=2
k=-126.75, yl=-127, k-yl=0.25, sptl(8:-1:1)=[-1  0  0  0  0  0  0  1 ], ndigits=2
k=-126.5, yu=-126, k-yu=-0.5, sptu(8:-1:1)=[-1  0  0  0  0  0  1  0 ], ndigits=2
k=-126.5, yl=-127, k-yl=0.5, sptl(8:-1:1)=[-1  0  0  0  0  0  0  1 ], ndigits=2
k=-126.25, yu=-126, k-yu=-0.25, sptu(8:-1:1)=[-1  0  0  0  0  0  1  0 ], ndigits=2
k=-126.25, yl=-127, k-yl=0.75, sptl(8:-1:1)=[-1  0  0  0  0  0  0  1 ], ndigits=2
k=-126, yu=-126, k-yu= 0, sptu(8:-1:1)=[-1  0  0  0  0  0  1  0 ], ndigits=2
k=-126, yl=-126, k-yl= 0, sptl(8:-1:1)=[-1  0  0  0  0  0  1  0 ], ndigits=2
k=-125.75, yu=-124, k-yu=-1.75, sptu(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-125.75, yl=-126, k-yl=0.25, sptl(8:-1:1)=[-1  0  0  0  0  0  1  0 ], ndigits=2
k=-125.5, yu=-124, k-yu=-1.5, sptu(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-125.5, yl=-126, k-yl=0.5, sptl(8:-1:1)=[-1  0  0  0  0  0  1  0 ], ndigits=2
k=-125.25, yu=-124, k-yu=-1.25, sptu(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-125.25, yl=-126, k-yl=0.75, sptl(8:-1:1)=[-1  0  0  0  0  0  1  0 ], ndigits=2
k=-125, yu=-124, k-yu=-1, sptu(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-125, yl=-126, k-yl= 1, sptl(8:-1:1)=[-1  0  0  0  0  0  1  0 ], ndigits=2
k=-124.75, yu=-124, k-yu=-0.75, sptu(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-124.75, yl=-126, k-yl=1.25, sptl(8:-1:1)=[-1  0  0  0  0  0  1  0 ], ndigits=2
k=-124.5, yu=-124, k-yu=-0.5, sptu(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-124.5, yl=-126, k-yl=1.5, sptl(8:-1:1)=[-1  0  0  0  0  0  1  0 ], ndigits=2
k=-124.25, yu=-124, k-yu=-0.25, sptu(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-124.25, yl=-126, k-yl=1.75, sptl(8:-1:1)=[-1  0  0  0  0  0  1  0 ], ndigits=2
k=-124, yu=-124, k-yu= 0, sptu(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-124, yl=-124, k-yl= 0, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-123.75, yu=-120, k-yu=-3.75, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-123.75, yl=-124, k-yl=0.25, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-123.5, yu=-120, k-yu=-3.5, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-123.5, yl=-124, k-yl=0.5, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-123.25, yu=-120, k-yu=-3.25, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-123.25, yl=-124, k-yl=0.75, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-123, yu=-120, k-yu=-3, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-123, yl=-124, k-yl= 1, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-122.75, yu=-120, k-yu=-2.75, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-122.75, yl=-124, k-yl=1.25, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-122.5, yu=-120, k-yu=-2.5, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-122.5, yl=-124, k-yl=1.5, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-122.25, yu=-120, k-yu=-2.25, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-122.25, yl=-124, k-yl=1.75, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-122, yu=-120, k-yu=-2, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-122, yl=-124, k-yl= 2, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-121.75, yu=-120, k-yu=-1.75, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-121.75, yl=-124, k-yl=2.25, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-121.5, yu=-120, k-yu=-1.5, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-121.5, yl=-124, k-yl=2.5, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-121.25, yu=-120, k-yu=-1.25, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-121.25, yl=-124, k-yl=2.75, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-121, yu=-120, k-yu=-1, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-121, yl=-124, k-yl= 3, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-120.75, yu=-120, k-yu=-0.75, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-120.75, yl=-124, k-yl=3.25, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-120.5, yu=-120, k-yu=-0.5, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-120.5, yl=-124, k-yl=3.5, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-120.25, yu=-120, k-yu=-0.25, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-120.25, yl=-124, k-yl=3.75, sptl(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-120, yu=-120, k-yu= 0, sptu(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-120, yl=-120, k-yl= 0, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-119.75, yu=-112, k-yu=-7.75, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-119.75, yl=-120, k-yl=0.25, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-119.5, yu=-112, k-yu=-7.5, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-119.5, yl=-120, k-yl=0.5, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-119.25, yu=-112, k-yu=-7.25, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-119.25, yl=-120, k-yl=0.75, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-119, yu=-112, k-yu=-7, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-119, yl=-120, k-yl= 1, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-118.75, yu=-112, k-yu=-6.75, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-118.75, yl=-120, k-yl=1.25, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-118.5, yu=-112, k-yu=-6.5, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-118.5, yl=-120, k-yl=1.5, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-118.25, yu=-112, k-yu=-6.25, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-118.25, yl=-120, k-yl=1.75, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-118, yu=-112, k-yu=-6, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-118, yl=-120, k-yl= 2, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-117.75, yu=-112, k-yu=-5.75, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-117.75, yl=-120, k-yl=2.25, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-117.5, yu=-112, k-yu=-5.5, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-117.5, yl=-120, k-yl=2.5, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-117.25, yu=-112, k-yu=-5.25, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-117.25, yl=-120, k-yl=2.75, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-117, yu=-112, k-yu=-5, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-117, yl=-120, k-yl= 3, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-116.75, yu=-112, k-yu=-4.75, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-116.75, yl=-120, k-yl=3.25, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-116.5, yu=-112, k-yu=-4.5, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-116.5, yl=-120, k-yl=3.5, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-116.25, yu=-112, k-yu=-4.25, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-116.25, yl=-120, k-yl=3.75, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-116, yu=-112, k-yu=-4, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-116, yl=-120, k-yl= 4, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-115.75, yu=-112, k-yu=-3.75, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-115.75, yl=-120, k-yl=4.25, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-115.5, yu=-112, k-yu=-3.5, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-115.5, yl=-120, k-yl=4.5, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-115.25, yu=-112, k-yu=-3.25, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-115.25, yl=-120, k-yl=4.75, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-115, yu=-112, k-yu=-3, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-115, yl=-120, k-yl= 5, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-114.75, yu=-112, k-yu=-2.75, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-114.75, yl=-120, k-yl=5.25, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-114.5, yu=-112, k-yu=-2.5, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-114.5, yl=-120, k-yl=5.5, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-114.25, yu=-112, k-yu=-2.25, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-114.25, yl=-120, k-yl=5.75, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-114, yu=-112, k-yu=-2, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-114, yl=-120, k-yl= 6, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-113.75, yu=-112, k-yu=-1.75, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-113.75, yl=-120, k-yl=6.25, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-113.5, yu=-112, k-yu=-1.5, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-113.5, yl=-120, k-yl=6.5, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-113.25, yu=-112, k-yu=-1.25, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-113.25, yl=-120, k-yl=6.75, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-113, yu=-112, k-yu=-1, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-113, yl=-120, k-yl= 7, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-112.75, yu=-112, k-yu=-0.75, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-112.75, yl=-120, k-yl=7.25, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-112.5, yu=-112, k-yu=-0.5, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-112.5, yl=-120, k-yl=7.5, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-112.25, yu=-112, k-yu=-0.25, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-112.25, yl=-120, k-yl=7.75, sptl(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-112, yu=-112, k-yu= 0, sptu(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-112, yl=-112, k-yl= 0, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-111.75, yu= -96, k-yu=-15.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-111.75, yl=-112, k-yl=0.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-111.5, yu= -96, k-yu=-15.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-111.5, yl=-112, k-yl=0.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-111.25, yu= -96, k-yu=-15.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-111.25, yl=-112, k-yl=0.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-111, yu= -96, k-yu=-15, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-111, yl=-112, k-yl= 1, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-110.75, yu= -96, k-yu=-14.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-110.75, yl=-112, k-yl=1.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-110.5, yu= -96, k-yu=-14.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-110.5, yl=-112, k-yl=1.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-110.25, yu= -96, k-yu=-14.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-110.25, yl=-112, k-yl=1.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-110, yu= -96, k-yu=-14, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-110, yl=-112, k-yl= 2, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-109.75, yu= -96, k-yu=-13.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-109.75, yl=-112, k-yl=2.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-109.5, yu= -96, k-yu=-13.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-109.5, yl=-112, k-yl=2.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-109.25, yu= -96, k-yu=-13.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-109.25, yl=-112, k-yl=2.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-109, yu= -96, k-yu=-13, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-109, yl=-112, k-yl= 3, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-108.75, yu= -96, k-yu=-12.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-108.75, yl=-112, k-yl=3.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-108.5, yu= -96, k-yu=-12.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-108.5, yl=-112, k-yl=3.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-108.25, yu= -96, k-yu=-12.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-108.25, yl=-112, k-yl=3.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-108, yu= -96, k-yu=-12, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-108, yl=-112, k-yl= 4, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-107.75, yu= -96, k-yu=-11.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-107.75, yl=-112, k-yl=4.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-107.5, yu= -96, k-yu=-11.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-107.5, yl=-112, k-yl=4.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-107.25, yu= -96, k-yu=-11.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-107.25, yl=-112, k-yl=4.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-107, yu= -96, k-yu=-11, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-107, yl=-112, k-yl= 5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-106.75, yu= -96, k-yu=-10.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-106.75, yl=-112, k-yl=5.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-106.5, yu= -96, k-yu=-10.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-106.5, yl=-112, k-yl=5.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-106.25, yu= -96, k-yu=-10.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-106.25, yl=-112, k-yl=5.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-106, yu= -96, k-yu=-10, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-106, yl=-112, k-yl= 6, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-105.75, yu= -96, k-yu=-9.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-105.75, yl=-112, k-yl=6.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-105.5, yu= -96, k-yu=-9.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-105.5, yl=-112, k-yl=6.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-105.25, yu= -96, k-yu=-9.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-105.25, yl=-112, k-yl=6.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-105, yu= -96, k-yu=-9, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-105, yl=-112, k-yl= 7, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-104.75, yu= -96, k-yu=-8.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-104.75, yl=-112, k-yl=7.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-104.5, yu= -96, k-yu=-8.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-104.5, yl=-112, k-yl=7.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-104.25, yu= -96, k-yu=-8.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-104.25, yl=-112, k-yl=7.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-104, yu= -96, k-yu=-8, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-104, yl=-112, k-yl= 8, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-103.75, yu= -96, k-yu=-7.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-103.75, yl=-112, k-yl=8.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-103.5, yu= -96, k-yu=-7.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-103.5, yl=-112, k-yl=8.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-103.25, yu= -96, k-yu=-7.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-103.25, yl=-112, k-yl=8.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-103, yu= -96, k-yu=-7, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-103, yl=-112, k-yl= 9, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-102.75, yu= -96, k-yu=-6.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-102.75, yl=-112, k-yl=9.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-102.5, yu= -96, k-yu=-6.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-102.5, yl=-112, k-yl=9.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-102.25, yu= -96, k-yu=-6.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-102.25, yl=-112, k-yl=9.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-102, yu= -96, k-yu=-6, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-102, yl=-112, k-yl=10, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-101.75, yu= -96, k-yu=-5.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-101.75, yl=-112, k-yl=10.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-101.5, yu= -96, k-yu=-5.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-101.5, yl=-112, k-yl=10.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-101.25, yu= -96, k-yu=-5.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-101.25, yl=-112, k-yl=10.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-101, yu= -96, k-yu=-5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-101, yl=-112, k-yl=11, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-100.75, yu= -96, k-yu=-4.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-100.75, yl=-112, k-yl=11.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-100.5, yu= -96, k-yu=-4.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-100.5, yl=-112, k-yl=11.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-100.25, yu= -96, k-yu=-4.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-100.25, yl=-112, k-yl=11.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-100, yu= -96, k-yu=-4, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-100, yl=-112, k-yl=12, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-99.75, yu= -96, k-yu=-3.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-99.75, yl=-112, k-yl=12.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-99.5, yu= -96, k-yu=-3.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-99.5, yl=-112, k-yl=12.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-99.25, yu= -96, k-yu=-3.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-99.25, yl=-112, k-yl=12.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k= -99, yu= -96, k-yu=-3, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -99, yl=-112, k-yl=13, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-98.75, yu= -96, k-yu=-2.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-98.75, yl=-112, k-yl=13.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-98.5, yu= -96, k-yu=-2.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-98.5, yl=-112, k-yl=13.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-98.25, yu= -96, k-yu=-2.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-98.25, yl=-112, k-yl=13.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k= -98, yu= -96, k-yu=-2, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -98, yl=-112, k-yl=14, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-97.75, yu= -96, k-yu=-1.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-97.75, yl=-112, k-yl=14.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-97.5, yu= -96, k-yu=-1.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-97.5, yl=-112, k-yl=14.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-97.25, yu= -96, k-yu=-1.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-97.25, yl=-112, k-yl=14.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k= -97, yu= -96, k-yu=-1, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -97, yl=-112, k-yl=15, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-96.75, yu= -96, k-yu=-0.75, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-96.75, yl=-112, k-yl=15.25, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-96.5, yu= -96, k-yu=-0.5, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-96.5, yl=-112, k-yl=15.5, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-96.25, yu= -96, k-yu=-0.25, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-96.25, yl=-112, k-yl=15.75, sptl(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k= -96, yu= -96, k-yu= 0, sptu(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -96, yl= -96, k-yl= 0, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-95.75, yu= -80, k-yu=-15.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-95.75, yl= -96, k-yl=0.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-95.5, yu= -80, k-yu=-15.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-95.5, yl= -96, k-yl=0.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-95.25, yu= -80, k-yu=-15.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-95.25, yl= -96, k-yl=0.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -95, yu= -80, k-yu=-15, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -95, yl= -96, k-yl= 1, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-94.75, yu= -80, k-yu=-14.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-94.75, yl= -96, k-yl=1.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-94.5, yu= -80, k-yu=-14.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-94.5, yl= -96, k-yl=1.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-94.25, yu= -80, k-yu=-14.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-94.25, yl= -96, k-yl=1.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -94, yu= -80, k-yu=-14, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -94, yl= -96, k-yl= 2, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-93.75, yu= -80, k-yu=-13.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-93.75, yl= -96, k-yl=2.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-93.5, yu= -80, k-yu=-13.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-93.5, yl= -96, k-yl=2.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-93.25, yu= -80, k-yu=-13.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-93.25, yl= -96, k-yl=2.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -93, yu= -80, k-yu=-13, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -93, yl= -96, k-yl= 3, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-92.75, yu= -80, k-yu=-12.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-92.75, yl= -96, k-yl=3.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-92.5, yu= -80, k-yu=-12.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-92.5, yl= -96, k-yl=3.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-92.25, yu= -80, k-yu=-12.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-92.25, yl= -96, k-yl=3.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -92, yu= -80, k-yu=-12, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -92, yl= -96, k-yl= 4, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-91.75, yu= -80, k-yu=-11.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-91.75, yl= -96, k-yl=4.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-91.5, yu= -80, k-yu=-11.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-91.5, yl= -96, k-yl=4.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-91.25, yu= -80, k-yu=-11.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-91.25, yl= -96, k-yl=4.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -91, yu= -80, k-yu=-11, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -91, yl= -96, k-yl= 5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-90.75, yu= -80, k-yu=-10.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-90.75, yl= -96, k-yl=5.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-90.5, yu= -80, k-yu=-10.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-90.5, yl= -96, k-yl=5.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-90.25, yu= -80, k-yu=-10.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-90.25, yl= -96, k-yl=5.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -90, yu= -80, k-yu=-10, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -90, yl= -96, k-yl= 6, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-89.75, yu= -80, k-yu=-9.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-89.75, yl= -96, k-yl=6.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-89.5, yu= -80, k-yu=-9.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-89.5, yl= -96, k-yl=6.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-89.25, yu= -80, k-yu=-9.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-89.25, yl= -96, k-yl=6.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -89, yu= -80, k-yu=-9, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -89, yl= -96, k-yl= 7, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-88.75, yu= -80, k-yu=-8.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-88.75, yl= -96, k-yl=7.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-88.5, yu= -80, k-yu=-8.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-88.5, yl= -96, k-yl=7.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-88.25, yu= -80, k-yu=-8.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-88.25, yl= -96, k-yl=7.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -88, yu= -80, k-yu=-8, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -88, yl= -96, k-yl= 8, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-87.75, yu= -80, k-yu=-7.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-87.75, yl= -96, k-yl=8.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-87.5, yu= -80, k-yu=-7.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-87.5, yl= -96, k-yl=8.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-87.25, yu= -80, k-yu=-7.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-87.25, yl= -96, k-yl=8.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -87, yu= -80, k-yu=-7, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -87, yl= -96, k-yl= 9, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-86.75, yu= -80, k-yu=-6.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-86.75, yl= -96, k-yl=9.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-86.5, yu= -80, k-yu=-6.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-86.5, yl= -96, k-yl=9.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-86.25, yu= -80, k-yu=-6.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-86.25, yl= -96, k-yl=9.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -86, yu= -80, k-yu=-6, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -86, yl= -96, k-yl=10, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-85.75, yu= -80, k-yu=-5.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-85.75, yl= -96, k-yl=10.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-85.5, yu= -80, k-yu=-5.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-85.5, yl= -96, k-yl=10.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-85.25, yu= -80, k-yu=-5.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-85.25, yl= -96, k-yl=10.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -85, yu= -80, k-yu=-5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -85, yl= -96, k-yl=11, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-84.75, yu= -80, k-yu=-4.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-84.75, yl= -96, k-yl=11.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-84.5, yu= -80, k-yu=-4.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-84.5, yl= -96, k-yl=11.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-84.25, yu= -80, k-yu=-4.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-84.25, yl= -96, k-yl=11.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -84, yu= -80, k-yu=-4, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -84, yl= -96, k-yl=12, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-83.75, yu= -80, k-yu=-3.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-83.75, yl= -96, k-yl=12.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-83.5, yu= -80, k-yu=-3.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-83.5, yl= -96, k-yl=12.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-83.25, yu= -80, k-yu=-3.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-83.25, yl= -96, k-yl=12.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -83, yu= -80, k-yu=-3, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -83, yl= -96, k-yl=13, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-82.75, yu= -80, k-yu=-2.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-82.75, yl= -96, k-yl=13.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-82.5, yu= -80, k-yu=-2.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-82.5, yl= -96, k-yl=13.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-82.25, yu= -80, k-yu=-2.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-82.25, yl= -96, k-yl=13.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -82, yu= -80, k-yu=-2, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -82, yl= -96, k-yl=14, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-81.75, yu= -80, k-yu=-1.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-81.75, yl= -96, k-yl=14.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-81.5, yu= -80, k-yu=-1.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-81.5, yl= -96, k-yl=14.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-81.25, yu= -80, k-yu=-1.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-81.25, yl= -96, k-yl=14.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -81, yu= -80, k-yu=-1, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -81, yl= -96, k-yl=15, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-80.75, yu= -80, k-yu=-0.75, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-80.75, yl= -96, k-yl=15.25, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-80.5, yu= -80, k-yu=-0.5, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-80.5, yl= -96, k-yl=15.5, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-80.25, yu= -80, k-yu=-0.25, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-80.25, yl= -96, k-yl=15.75, sptl(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -80, yu= -80, k-yu= 0, sptu(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -80, yl= -80, k-yl= 0, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-79.75, yu= -72, k-yu=-7.75, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-79.75, yl= -80, k-yl=0.25, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-79.5, yu= -72, k-yu=-7.5, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-79.5, yl= -80, k-yl=0.5, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-79.25, yu= -72, k-yu=-7.25, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-79.25, yl= -80, k-yl=0.75, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -79, yu= -72, k-yu=-7, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -79, yl= -80, k-yl= 1, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-78.75, yu= -72, k-yu=-6.75, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-78.75, yl= -80, k-yl=1.25, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-78.5, yu= -72, k-yu=-6.5, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-78.5, yl= -80, k-yl=1.5, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-78.25, yu= -72, k-yu=-6.25, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-78.25, yl= -80, k-yl=1.75, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -78, yu= -72, k-yu=-6, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -78, yl= -80, k-yl= 2, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-77.75, yu= -72, k-yu=-5.75, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-77.75, yl= -80, k-yl=2.25, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-77.5, yu= -72, k-yu=-5.5, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-77.5, yl= -80, k-yl=2.5, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-77.25, yu= -72, k-yu=-5.25, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-77.25, yl= -80, k-yl=2.75, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -77, yu= -72, k-yu=-5, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -77, yl= -80, k-yl= 3, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-76.75, yu= -72, k-yu=-4.75, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-76.75, yl= -80, k-yl=3.25, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-76.5, yu= -72, k-yu=-4.5, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-76.5, yl= -80, k-yl=3.5, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-76.25, yu= -72, k-yu=-4.25, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-76.25, yl= -80, k-yl=3.75, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -76, yu= -72, k-yu=-4, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -76, yl= -80, k-yl= 4, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-75.75, yu= -72, k-yu=-3.75, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-75.75, yl= -80, k-yl=4.25, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-75.5, yu= -72, k-yu=-3.5, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-75.5, yl= -80, k-yl=4.5, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-75.25, yu= -72, k-yu=-3.25, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-75.25, yl= -80, k-yl=4.75, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -75, yu= -72, k-yu=-3, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -75, yl= -80, k-yl= 5, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-74.75, yu= -72, k-yu=-2.75, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-74.75, yl= -80, k-yl=5.25, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-74.5, yu= -72, k-yu=-2.5, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-74.5, yl= -80, k-yl=5.5, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-74.25, yu= -72, k-yu=-2.25, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-74.25, yl= -80, k-yl=5.75, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -74, yu= -72, k-yu=-2, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -74, yl= -80, k-yl= 6, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-73.75, yu= -72, k-yu=-1.75, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-73.75, yl= -80, k-yl=6.25, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-73.5, yu= -72, k-yu=-1.5, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-73.5, yl= -80, k-yl=6.5, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-73.25, yu= -72, k-yu=-1.25, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-73.25, yl= -80, k-yl=6.75, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -73, yu= -72, k-yu=-1, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -73, yl= -80, k-yl= 7, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-72.75, yu= -72, k-yu=-0.75, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-72.75, yl= -80, k-yl=7.25, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-72.5, yu= -72, k-yu=-0.5, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-72.5, yl= -80, k-yl=7.5, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k=-72.25, yu= -72, k-yu=-0.25, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-72.25, yl= -80, k-yl=7.75, sptl(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -72, yu= -72, k-yu= 0, sptu(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -72, yl= -72, k-yl= 0, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-71.75, yu= -68, k-yu=-3.75, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-71.75, yl= -72, k-yl=0.25, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-71.5, yu= -68, k-yu=-3.5, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-71.5, yl= -72, k-yl=0.5, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-71.25, yu= -68, k-yu=-3.25, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-71.25, yl= -72, k-yl=0.75, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -71, yu= -68, k-yu=-3, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k= -71, yl= -72, k-yl= 1, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-70.75, yu= -68, k-yu=-2.75, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-70.75, yl= -72, k-yl=1.25, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-70.5, yu= -68, k-yu=-2.5, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-70.5, yl= -72, k-yl=1.5, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-70.25, yu= -68, k-yu=-2.25, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-70.25, yl= -72, k-yl=1.75, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -70, yu= -68, k-yu=-2, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k= -70, yl= -72, k-yl= 2, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-69.75, yu= -68, k-yu=-1.75, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-69.75, yl= -72, k-yl=2.25, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-69.5, yu= -68, k-yu=-1.5, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-69.5, yl= -72, k-yl=2.5, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-69.25, yu= -68, k-yu=-1.25, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-69.25, yl= -72, k-yl=2.75, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -69, yu= -68, k-yu=-1, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k= -69, yl= -72, k-yl= 3, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-68.75, yu= -68, k-yu=-0.75, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-68.75, yl= -72, k-yl=3.25, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-68.5, yu= -68, k-yu=-0.5, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-68.5, yl= -72, k-yl=3.5, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k=-68.25, yu= -68, k-yu=-0.25, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-68.25, yl= -72, k-yl=3.75, sptl(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -68, yu= -68, k-yu= 0, sptu(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k= -68, yl= -68, k-yl= 0, sptl(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-67.75, yu= -66, k-yu=-1.75, sptu(8:-1:1)=[ 0 -1  0  0  0  0 -1  0 ], ndigits=2
k=-67.75, yl= -68, k-yl=0.25, sptl(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-67.5, yu= -66, k-yu=-1.5, sptu(8:-1:1)=[ 0 -1  0  0  0  0 -1  0 ], ndigits=2
k=-67.5, yl= -68, k-yl=0.5, sptl(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-67.25, yu= -66, k-yu=-1.25, sptu(8:-1:1)=[ 0 -1  0  0  0  0 -1  0 ], ndigits=2
k=-67.25, yl= -68, k-yl=0.75, sptl(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k= -67, yu= -66, k-yu=-1, sptu(8:-1:1)=[ 0 -1  0  0  0  0 -1  0 ], ndigits=2
k= -67, yl= -68, k-yl= 1, sptl(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-66.75, yu= -66, k-yu=-0.75, sptu(8:-1:1)=[ 0 -1  0  0  0  0 -1  0 ], ndigits=2
k=-66.75, yl= -68, k-yl=1.25, sptl(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-66.5, yu= -66, k-yu=-0.5, sptu(8:-1:1)=[ 0 -1  0  0  0  0 -1  0 ], ndigits=2
k=-66.5, yl= -68, k-yl=1.5, sptl(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k=-66.25, yu= -66, k-yu=-0.25, sptu(8:-1:1)=[ 0 -1  0  0  0  0 -1  0 ], ndigits=2
k=-66.25, yl= -68, k-yl=1.75, sptl(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k= -66, yu= -66, k-yu= 0, sptu(8:-1:1)=[ 0 -1  0  0  0  0 -1  0 ], ndigits=2
k= -66, yl= -66, k-yl= 0, sptl(8:-1:1)=[ 0 -1  0  0  0  0 -1  0 ], ndigits=2
k=-65.75, yu= -65, k-yu=-0.75, sptu(8:-1:1)=[ 0 -1  0  0  0  0  0 -1 ], ndigits=2
k=-65.75, yl= -66, k-yl=0.25, sptl(8:-1:1)=[ 0 -1  0  0  0  0 -1  0 ], ndigits=2
k=-65.5, yu= -65, k-yu=-0.5, sptu(8:-1:1)=[ 0 -1  0  0  0  0  0 -1 ], ndigits=2
k=-65.5, yl= -66, k-yl=0.5, sptl(8:-1:1)=[ 0 -1  0  0  0  0 -1  0 ], ndigits=2
k=-65.25, yu= -65, k-yu=-0.25, sptu(8:-1:1)=[ 0 -1  0  0  0  0  0 -1 ], ndigits=2
k=-65.25, yl= -66, k-yl=0.75, sptl(8:-1:1)=[ 0 -1  0  0  0  0 -1  0 ], ndigits=2
k= -65, yu= -65, k-yu= 0, sptu(8:-1:1)=[ 0 -1  0  0  0  0  0 -1 ], ndigits=2
k= -65, yl= -65, k-yl= 0, sptl(8:-1:1)=[ 0 -1  0  0  0  0  0 -1 ], ndigits=2
k=-64.75, yu= -64, k-yu=-0.75, sptu(8:-1:1)=[ 0 -1  0  0  0  0  0  0 ], ndigits=1
k=-64.75, yl= -65, k-yl=0.25, sptl(8:-1:1)=[ 0 -1  0  0  0  0  0 -1 ], ndigits=2
k=-64.5, yu= -64, k-yu=-0.5, sptu(8:-1:1)=[ 0 -1  0  0  0  0  0  0 ], ndigits=1
k=-64.5, yl= -65, k-yl=0.5, sptl(8:-1:1)=[ 0 -1  0  0  0  0  0 -1 ], ndigits=2
k=-64.25, yu= -64, k-yu=-0.25, sptu(8:-1:1)=[ 0 -1  0  0  0  0  0  0 ], ndigits=1
k=-64.25, yl= -65, k-yl=0.75, sptl(8:-1:1)=[ 0 -1  0  0  0  0  0 -1 ], ndigits=2
k= -64, yu= -64, k-yu= 0, sptu(8:-1:1)=[ 0 -1  0  0  0  0  0  0 ], ndigits=1
k= -64, yl= -64, k-yl= 0, sptl(8:-1:1)=[ 0 -1  0  0  0  0  0  0 ], ndigits=1
k=-63.75, yu= -63, k-yu=-0.75, sptu(8:-1:1)=[ 0 -1  0  0  0  0  0  1 ], ndigits=2
k=-63.75, yl= -64, k-yl=0.25, sptl(8:-1:1)=[ 0 -1  0  0  0  0  0  0 ], ndigits=1
k=-63.5, yu= -63, k-yu=-0.5, sptu(8:-1:1)=[ 0 -1  0  0  0  0  0  1 ], ndigits=2
k=-63.5, yl= -64, k-yl=0.5, sptl(8:-1:1)=[ 0 -1  0  0  0  0  0  0 ], ndigits=1
k=-63.25, yu= -63, k-yu=-0.25, sptu(8:-1:1)=[ 0 -1  0  0  0  0  0  1 ], ndigits=2
k=-63.25, yl= -64, k-yl=0.75, sptl(8:-1:1)=[ 0 -1  0  0  0  0  0  0 ], ndigits=1
k= -63, yu= -63, k-yu= 0, sptu(8:-1:1)=[ 0 -1  0  0  0  0  0  1 ], ndigits=2
k= -63, yl= -63, k-yl= 0, sptl(8:-1:1)=[ 0 -1  0  0  0  0  0  1 ], ndigits=2
k=-62.75, yu= -62, k-yu=-0.75, sptu(8:-1:1)=[ 0 -1  0  0  0  0  1  0 ], ndigits=2
k=-62.75, yl= -63, k-yl=0.25, sptl(8:-1:1)=[ 0 -1  0  0  0  0  0  1 ], ndigits=2
k=-62.5, yu= -62, k-yu=-0.5, sptu(8:-1:1)=[ 0 -1  0  0  0  0  1  0 ], ndigits=2
k=-62.5, yl= -63, k-yl=0.5, sptl(8:-1:1)=[ 0 -1  0  0  0  0  0  1 ], ndigits=2
k=-62.25, yu= -62, k-yu=-0.25, sptu(8:-1:1)=[ 0 -1  0  0  0  0  1  0 ], ndigits=2
k=-62.25, yl= -63, k-yl=0.75, sptl(8:-1:1)=[ 0 -1  0  0  0  0  0  1 ], ndigits=2
k= -62, yu= -62, k-yu= 0, sptu(8:-1:1)=[ 0 -1  0  0  0  0  1  0 ], ndigits=2
k= -62, yl= -62, k-yl= 0, sptl(8:-1:1)=[ 0 -1  0  0  0  0  1  0 ], ndigits=2
k=-61.75, yu= -60, k-yu=-1.75, sptu(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-61.75, yl= -62, k-yl=0.25, sptl(8:-1:1)=[ 0 -1  0  0  0  0  1  0 ], ndigits=2
k=-61.5, yu= -60, k-yu=-1.5, sptu(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-61.5, yl= -62, k-yl=0.5, sptl(8:-1:1)=[ 0 -1  0  0  0  0  1  0 ], ndigits=2
k=-61.25, yu= -60, k-yu=-1.25, sptu(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-61.25, yl= -62, k-yl=0.75, sptl(8:-1:1)=[ 0 -1  0  0  0  0  1  0 ], ndigits=2
k= -61, yu= -60, k-yu=-1, sptu(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k= -61, yl= -62, k-yl= 1, sptl(8:-1:1)=[ 0 -1  0  0  0  0  1  0 ], ndigits=2
k=-60.75, yu= -60, k-yu=-0.75, sptu(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-60.75, yl= -62, k-yl=1.25, sptl(8:-1:1)=[ 0 -1  0  0  0  0  1  0 ], ndigits=2
k=-60.5, yu= -60, k-yu=-0.5, sptu(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-60.5, yl= -62, k-yl=1.5, sptl(8:-1:1)=[ 0 -1  0  0  0  0  1  0 ], ndigits=2
k=-60.25, yu= -60, k-yu=-0.25, sptu(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-60.25, yl= -62, k-yl=1.75, sptl(8:-1:1)=[ 0 -1  0  0  0  0  1  0 ], ndigits=2
k= -60, yu= -60, k-yu= 0, sptu(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k= -60, yl= -60, k-yl= 0, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-59.75, yu= -56, k-yu=-3.75, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-59.75, yl= -60, k-yl=0.25, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-59.5, yu= -56, k-yu=-3.5, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-59.5, yl= -60, k-yl=0.5, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-59.25, yu= -56, k-yu=-3.25, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-59.25, yl= -60, k-yl=0.75, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k= -59, yu= -56, k-yu=-3, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -59, yl= -60, k-yl= 1, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-58.75, yu= -56, k-yu=-2.75, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-58.75, yl= -60, k-yl=1.25, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-58.5, yu= -56, k-yu=-2.5, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-58.5, yl= -60, k-yl=1.5, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-58.25, yu= -56, k-yu=-2.25, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-58.25, yl= -60, k-yl=1.75, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k= -58, yu= -56, k-yu=-2, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -58, yl= -60, k-yl= 2, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-57.75, yu= -56, k-yu=-1.75, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-57.75, yl= -60, k-yl=2.25, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-57.5, yu= -56, k-yu=-1.5, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-57.5, yl= -60, k-yl=2.5, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-57.25, yu= -56, k-yu=-1.25, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-57.25, yl= -60, k-yl=2.75, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k= -57, yu= -56, k-yu=-1, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -57, yl= -60, k-yl= 3, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-56.75, yu= -56, k-yu=-0.75, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-56.75, yl= -60, k-yl=3.25, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-56.5, yu= -56, k-yu=-0.5, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-56.5, yl= -60, k-yl=3.5, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k=-56.25, yu= -56, k-yu=-0.25, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-56.25, yl= -60, k-yl=3.75, sptl(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k= -56, yu= -56, k-yu= 0, sptu(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -56, yl= -56, k-yl= 0, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-55.75, yu= -48, k-yu=-7.75, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-55.75, yl= -56, k-yl=0.25, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-55.5, yu= -48, k-yu=-7.5, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-55.5, yl= -56, k-yl=0.5, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-55.25, yu= -48, k-yu=-7.25, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-55.25, yl= -56, k-yl=0.75, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -55, yu= -48, k-yu=-7, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -55, yl= -56, k-yl= 1, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-54.75, yu= -48, k-yu=-6.75, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-54.75, yl= -56, k-yl=1.25, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-54.5, yu= -48, k-yu=-6.5, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-54.5, yl= -56, k-yl=1.5, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-54.25, yu= -48, k-yu=-6.25, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-54.25, yl= -56, k-yl=1.75, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -54, yu= -48, k-yu=-6, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -54, yl= -56, k-yl= 2, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-53.75, yu= -48, k-yu=-5.75, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-53.75, yl= -56, k-yl=2.25, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-53.5, yu= -48, k-yu=-5.5, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-53.5, yl= -56, k-yl=2.5, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-53.25, yu= -48, k-yu=-5.25, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-53.25, yl= -56, k-yl=2.75, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -53, yu= -48, k-yu=-5, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -53, yl= -56, k-yl= 3, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-52.75, yu= -48, k-yu=-4.75, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-52.75, yl= -56, k-yl=3.25, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-52.5, yu= -48, k-yu=-4.5, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-52.5, yl= -56, k-yl=3.5, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-52.25, yu= -48, k-yu=-4.25, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-52.25, yl= -56, k-yl=3.75, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -52, yu= -48, k-yu=-4, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -52, yl= -56, k-yl= 4, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-51.75, yu= -48, k-yu=-3.75, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-51.75, yl= -56, k-yl=4.25, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-51.5, yu= -48, k-yu=-3.5, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-51.5, yl= -56, k-yl=4.5, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-51.25, yu= -48, k-yu=-3.25, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-51.25, yl= -56, k-yl=4.75, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -51, yu= -48, k-yu=-3, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -51, yl= -56, k-yl= 5, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-50.75, yu= -48, k-yu=-2.75, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-50.75, yl= -56, k-yl=5.25, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-50.5, yu= -48, k-yu=-2.5, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-50.5, yl= -56, k-yl=5.5, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-50.25, yu= -48, k-yu=-2.25, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-50.25, yl= -56, k-yl=5.75, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -50, yu= -48, k-yu=-2, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -50, yl= -56, k-yl= 6, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-49.75, yu= -48, k-yu=-1.75, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-49.75, yl= -56, k-yl=6.25, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-49.5, yu= -48, k-yu=-1.5, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-49.5, yl= -56, k-yl=6.5, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-49.25, yu= -48, k-yu=-1.25, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-49.25, yl= -56, k-yl=6.75, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -49, yu= -48, k-yu=-1, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -49, yl= -56, k-yl= 7, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-48.75, yu= -48, k-yu=-0.75, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-48.75, yl= -56, k-yl=7.25, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-48.5, yu= -48, k-yu=-0.5, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-48.5, yl= -56, k-yl=7.5, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k=-48.25, yu= -48, k-yu=-0.25, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-48.25, yl= -56, k-yl=7.75, sptl(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -48, yu= -48, k-yu= 0, sptu(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -48, yl= -48, k-yl= 0, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-47.75, yu= -40, k-yu=-7.75, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-47.75, yl= -48, k-yl=0.25, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-47.5, yu= -40, k-yu=-7.5, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-47.5, yl= -48, k-yl=0.5, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-47.25, yu= -40, k-yu=-7.25, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-47.25, yl= -48, k-yl=0.75, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -47, yu= -40, k-yu=-7, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -47, yl= -48, k-yl= 1, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-46.75, yu= -40, k-yu=-6.75, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-46.75, yl= -48, k-yl=1.25, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-46.5, yu= -40, k-yu=-6.5, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-46.5, yl= -48, k-yl=1.5, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-46.25, yu= -40, k-yu=-6.25, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-46.25, yl= -48, k-yl=1.75, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -46, yu= -40, k-yu=-6, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -46, yl= -48, k-yl= 2, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-45.75, yu= -40, k-yu=-5.75, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-45.75, yl= -48, k-yl=2.25, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-45.5, yu= -40, k-yu=-5.5, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-45.5, yl= -48, k-yl=2.5, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-45.25, yu= -40, k-yu=-5.25, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-45.25, yl= -48, k-yl=2.75, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -45, yu= -40, k-yu=-5, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -45, yl= -48, k-yl= 3, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-44.75, yu= -40, k-yu=-4.75, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-44.75, yl= -48, k-yl=3.25, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-44.5, yu= -40, k-yu=-4.5, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-44.5, yl= -48, k-yl=3.5, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-44.25, yu= -40, k-yu=-4.25, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-44.25, yl= -48, k-yl=3.75, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -44, yu= -40, k-yu=-4, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -44, yl= -48, k-yl= 4, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-43.75, yu= -40, k-yu=-3.75, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-43.75, yl= -48, k-yl=4.25, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-43.5, yu= -40, k-yu=-3.5, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-43.5, yl= -48, k-yl=4.5, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-43.25, yu= -40, k-yu=-3.25, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-43.25, yl= -48, k-yl=4.75, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -43, yu= -40, k-yu=-3, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -43, yl= -48, k-yl= 5, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-42.75, yu= -40, k-yu=-2.75, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-42.75, yl= -48, k-yl=5.25, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-42.5, yu= -40, k-yu=-2.5, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-42.5, yl= -48, k-yl=5.5, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-42.25, yu= -40, k-yu=-2.25, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-42.25, yl= -48, k-yl=5.75, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -42, yu= -40, k-yu=-2, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -42, yl= -48, k-yl= 6, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-41.75, yu= -40, k-yu=-1.75, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-41.75, yl= -48, k-yl=6.25, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-41.5, yu= -40, k-yu=-1.5, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-41.5, yl= -48, k-yl=6.5, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-41.25, yu= -40, k-yu=-1.25, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-41.25, yl= -48, k-yl=6.75, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -41, yu= -40, k-yu=-1, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -41, yl= -48, k-yl= 7, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-40.75, yu= -40, k-yu=-0.75, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-40.75, yl= -48, k-yl=7.25, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-40.5, yu= -40, k-yu=-0.5, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-40.5, yl= -48, k-yl=7.5, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k=-40.25, yu= -40, k-yu=-0.25, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-40.25, yl= -48, k-yl=7.75, sptl(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -40, yu= -40, k-yu= 0, sptu(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -40, yl= -40, k-yl= 0, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-39.75, yu= -36, k-yu=-3.75, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-39.75, yl= -40, k-yl=0.25, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-39.5, yu= -36, k-yu=-3.5, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-39.5, yl= -40, k-yl=0.5, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-39.25, yu= -36, k-yu=-3.25, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-39.25, yl= -40, k-yl=0.75, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -39, yu= -36, k-yu=-3, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k= -39, yl= -40, k-yl= 1, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-38.75, yu= -36, k-yu=-2.75, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-38.75, yl= -40, k-yl=1.25, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-38.5, yu= -36, k-yu=-2.5, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-38.5, yl= -40, k-yl=1.5, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-38.25, yu= -36, k-yu=-2.25, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-38.25, yl= -40, k-yl=1.75, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -38, yu= -36, k-yu=-2, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k= -38, yl= -40, k-yl= 2, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-37.75, yu= -36, k-yu=-1.75, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-37.75, yl= -40, k-yl=2.25, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-37.5, yu= -36, k-yu=-1.5, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-37.5, yl= -40, k-yl=2.5, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-37.25, yu= -36, k-yu=-1.25, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-37.25, yl= -40, k-yl=2.75, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -37, yu= -36, k-yu=-1, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k= -37, yl= -40, k-yl= 3, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-36.75, yu= -36, k-yu=-0.75, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-36.75, yl= -40, k-yl=3.25, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-36.5, yu= -36, k-yu=-0.5, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-36.5, yl= -40, k-yl=3.5, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k=-36.25, yu= -36, k-yu=-0.25, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-36.25, yl= -40, k-yl=3.75, sptl(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -36, yu= -36, k-yu= 0, sptu(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k= -36, yl= -36, k-yl= 0, sptl(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-35.75, yu= -34, k-yu=-1.75, sptu(8:-1:1)=[ 0  0 -1  0  0  0 -1  0 ], ndigits=2
k=-35.75, yl= -36, k-yl=0.25, sptl(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-35.5, yu= -34, k-yu=-1.5, sptu(8:-1:1)=[ 0  0 -1  0  0  0 -1  0 ], ndigits=2
k=-35.5, yl= -36, k-yl=0.5, sptl(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-35.25, yu= -34, k-yu=-1.25, sptu(8:-1:1)=[ 0  0 -1  0  0  0 -1  0 ], ndigits=2
k=-35.25, yl= -36, k-yl=0.75, sptl(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k= -35, yu= -34, k-yu=-1, sptu(8:-1:1)=[ 0  0 -1  0  0  0 -1  0 ], ndigits=2
k= -35, yl= -36, k-yl= 1, sptl(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-34.75, yu= -34, k-yu=-0.75, sptu(8:-1:1)=[ 0  0 -1  0  0  0 -1  0 ], ndigits=2
k=-34.75, yl= -36, k-yl=1.25, sptl(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-34.5, yu= -34, k-yu=-0.5, sptu(8:-1:1)=[ 0  0 -1  0  0  0 -1  0 ], ndigits=2
k=-34.5, yl= -36, k-yl=1.5, sptl(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k=-34.25, yu= -34, k-yu=-0.25, sptu(8:-1:1)=[ 0  0 -1  0  0  0 -1  0 ], ndigits=2
k=-34.25, yl= -36, k-yl=1.75, sptl(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k= -34, yu= -34, k-yu= 0, sptu(8:-1:1)=[ 0  0 -1  0  0  0 -1  0 ], ndigits=2
k= -34, yl= -34, k-yl= 0, sptl(8:-1:1)=[ 0  0 -1  0  0  0 -1  0 ], ndigits=2
k=-33.75, yu= -33, k-yu=-0.75, sptu(8:-1:1)=[ 0  0 -1  0  0  0  0 -1 ], ndigits=2
k=-33.75, yl= -34, k-yl=0.25, sptl(8:-1:1)=[ 0  0 -1  0  0  0 -1  0 ], ndigits=2
k=-33.5, yu= -33, k-yu=-0.5, sptu(8:-1:1)=[ 0  0 -1  0  0  0  0 -1 ], ndigits=2
k=-33.5, yl= -34, k-yl=0.5, sptl(8:-1:1)=[ 0  0 -1  0  0  0 -1  0 ], ndigits=2
k=-33.25, yu= -33, k-yu=-0.25, sptu(8:-1:1)=[ 0  0 -1  0  0  0  0 -1 ], ndigits=2
k=-33.25, yl= -34, k-yl=0.75, sptl(8:-1:1)=[ 0  0 -1  0  0  0 -1  0 ], ndigits=2
k= -33, yu= -33, k-yu= 0, sptu(8:-1:1)=[ 0  0 -1  0  0  0  0 -1 ], ndigits=2
k= -33, yl= -33, k-yl= 0, sptl(8:-1:1)=[ 0  0 -1  0  0  0  0 -1 ], ndigits=2
k=-32.75, yu= -32, k-yu=-0.75, sptu(8:-1:1)=[ 0  0 -1  0  0  0  0  0 ], ndigits=1
k=-32.75, yl= -33, k-yl=0.25, sptl(8:-1:1)=[ 0  0 -1  0  0  0  0 -1 ], ndigits=2
k=-32.5, yu= -32, k-yu=-0.5, sptu(8:-1:1)=[ 0  0 -1  0  0  0  0  0 ], ndigits=1
k=-32.5, yl= -33, k-yl=0.5, sptl(8:-1:1)=[ 0  0 -1  0  0  0  0 -1 ], ndigits=2
k=-32.25, yu= -32, k-yu=-0.25, sptu(8:-1:1)=[ 0  0 -1  0  0  0  0  0 ], ndigits=1
k=-32.25, yl= -33, k-yl=0.75, sptl(8:-1:1)=[ 0  0 -1  0  0  0  0 -1 ], ndigits=2
k= -32, yu= -32, k-yu= 0, sptu(8:-1:1)=[ 0  0 -1  0  0  0  0  0 ], ndigits=1
k= -32, yl= -32, k-yl= 0, sptl(8:-1:1)=[ 0  0 -1  0  0  0  0  0 ], ndigits=1
k=-31.75, yu= -31, k-yu=-0.75, sptu(8:-1:1)=[ 0  0 -1  0  0  0  0  1 ], ndigits=2
k=-31.75, yl= -32, k-yl=0.25, sptl(8:-1:1)=[ 0  0 -1  0  0  0  0  0 ], ndigits=1
k=-31.5, yu= -31, k-yu=-0.5, sptu(8:-1:1)=[ 0  0 -1  0  0  0  0  1 ], ndigits=2
k=-31.5, yl= -32, k-yl=0.5, sptl(8:-1:1)=[ 0  0 -1  0  0  0  0  0 ], ndigits=1
k=-31.25, yu= -31, k-yu=-0.25, sptu(8:-1:1)=[ 0  0 -1  0  0  0  0  1 ], ndigits=2
k=-31.25, yl= -32, k-yl=0.75, sptl(8:-1:1)=[ 0  0 -1  0  0  0  0  0 ], ndigits=1
k= -31, yu= -31, k-yu= 0, sptu(8:-1:1)=[ 0  0 -1  0  0  0  0  1 ], ndigits=2
k= -31, yl= -31, k-yl= 0, sptl(8:-1:1)=[ 0  0 -1  0  0  0  0  1 ], ndigits=2
k=-30.75, yu= -30, k-yu=-0.75, sptu(8:-1:1)=[ 0  0 -1  0  0  0  1  0 ], ndigits=2
k=-30.75, yl= -31, k-yl=0.25, sptl(8:-1:1)=[ 0  0 -1  0  0  0  0  1 ], ndigits=2
k=-30.5, yu= -30, k-yu=-0.5, sptu(8:-1:1)=[ 0  0 -1  0  0  0  1  0 ], ndigits=2
k=-30.5, yl= -31, k-yl=0.5, sptl(8:-1:1)=[ 0  0 -1  0  0  0  0  1 ], ndigits=2
k=-30.25, yu= -30, k-yu=-0.25, sptu(8:-1:1)=[ 0  0 -1  0  0  0  1  0 ], ndigits=2
k=-30.25, yl= -31, k-yl=0.75, sptl(8:-1:1)=[ 0  0 -1  0  0  0  0  1 ], ndigits=2
k= -30, yu= -30, k-yu= 0, sptu(8:-1:1)=[ 0  0 -1  0  0  0  1  0 ], ndigits=2
k= -30, yl= -30, k-yl= 0, sptl(8:-1:1)=[ 0  0 -1  0  0  0  1  0 ], ndigits=2
k=-29.75, yu= -28, k-yu=-1.75, sptu(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-29.75, yl= -30, k-yl=0.25, sptl(8:-1:1)=[ 0  0 -1  0  0  0  1  0 ], ndigits=2
k=-29.5, yu= -28, k-yu=-1.5, sptu(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-29.5, yl= -30, k-yl=0.5, sptl(8:-1:1)=[ 0  0 -1  0  0  0  1  0 ], ndigits=2
k=-29.25, yu= -28, k-yu=-1.25, sptu(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-29.25, yl= -30, k-yl=0.75, sptl(8:-1:1)=[ 0  0 -1  0  0  0  1  0 ], ndigits=2
k= -29, yu= -28, k-yu=-1, sptu(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k= -29, yl= -30, k-yl= 1, sptl(8:-1:1)=[ 0  0 -1  0  0  0  1  0 ], ndigits=2
k=-28.75, yu= -28, k-yu=-0.75, sptu(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-28.75, yl= -30, k-yl=1.25, sptl(8:-1:1)=[ 0  0 -1  0  0  0  1  0 ], ndigits=2
k=-28.5, yu= -28, k-yu=-0.5, sptu(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-28.5, yl= -30, k-yl=1.5, sptl(8:-1:1)=[ 0  0 -1  0  0  0  1  0 ], ndigits=2
k=-28.25, yu= -28, k-yu=-0.25, sptu(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-28.25, yl= -30, k-yl=1.75, sptl(8:-1:1)=[ 0  0 -1  0  0  0  1  0 ], ndigits=2
k= -28, yu= -28, k-yu= 0, sptu(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k= -28, yl= -28, k-yl= 0, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-27.75, yu= -24, k-yu=-3.75, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-27.75, yl= -28, k-yl=0.25, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-27.5, yu= -24, k-yu=-3.5, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-27.5, yl= -28, k-yl=0.5, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-27.25, yu= -24, k-yu=-3.25, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-27.25, yl= -28, k-yl=0.75, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k= -27, yu= -24, k-yu=-3, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k= -27, yl= -28, k-yl= 1, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-26.75, yu= -24, k-yu=-2.75, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-26.75, yl= -28, k-yl=1.25, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-26.5, yu= -24, k-yu=-2.5, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-26.5, yl= -28, k-yl=1.5, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-26.25, yu= -24, k-yu=-2.25, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-26.25, yl= -28, k-yl=1.75, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k= -26, yu= -24, k-yu=-2, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k= -26, yl= -28, k-yl= 2, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-25.75, yu= -24, k-yu=-1.75, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-25.75, yl= -28, k-yl=2.25, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-25.5, yu= -24, k-yu=-1.5, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-25.5, yl= -28, k-yl=2.5, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-25.25, yu= -24, k-yu=-1.25, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-25.25, yl= -28, k-yl=2.75, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k= -25, yu= -24, k-yu=-1, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k= -25, yl= -28, k-yl= 3, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-24.75, yu= -24, k-yu=-0.75, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-24.75, yl= -28, k-yl=3.25, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-24.5, yu= -24, k-yu=-0.5, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-24.5, yl= -28, k-yl=3.5, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k=-24.25, yu= -24, k-yu=-0.25, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-24.25, yl= -28, k-yl=3.75, sptl(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k= -24, yu= -24, k-yu= 0, sptu(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k= -24, yl= -24, k-yl= 0, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-23.75, yu= -20, k-yu=-3.75, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-23.75, yl= -24, k-yl=0.25, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-23.5, yu= -20, k-yu=-3.5, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-23.5, yl= -24, k-yl=0.5, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-23.25, yu= -20, k-yu=-3.25, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-23.25, yl= -24, k-yl=0.75, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k= -23, yu= -20, k-yu=-3, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k= -23, yl= -24, k-yl= 1, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-22.75, yu= -20, k-yu=-2.75, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-22.75, yl= -24, k-yl=1.25, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-22.5, yu= -20, k-yu=-2.5, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-22.5, yl= -24, k-yl=1.5, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-22.25, yu= -20, k-yu=-2.25, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-22.25, yl= -24, k-yl=1.75, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k= -22, yu= -20, k-yu=-2, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k= -22, yl= -24, k-yl= 2, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-21.75, yu= -20, k-yu=-1.75, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-21.75, yl= -24, k-yl=2.25, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-21.5, yu= -20, k-yu=-1.5, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-21.5, yl= -24, k-yl=2.5, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-21.25, yu= -20, k-yu=-1.25, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-21.25, yl= -24, k-yl=2.75, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k= -21, yu= -20, k-yu=-1, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k= -21, yl= -24, k-yl= 3, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-20.75, yu= -20, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-20.75, yl= -24, k-yl=3.25, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-20.5, yu= -20, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-20.5, yl= -24, k-yl=3.5, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k=-20.25, yu= -20, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-20.25, yl= -24, k-yl=3.75, sptl(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k= -20, yu= -20, k-yu= 0, sptu(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k= -20, yl= -20, k-yl= 0, sptl(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-19.75, yu= -18, k-yu=-1.75, sptu(8:-1:1)=[ 0  0  0 -1  0  0 -1  0 ], ndigits=2
k=-19.75, yl= -20, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-19.5, yu= -18, k-yu=-1.5, sptu(8:-1:1)=[ 0  0  0 -1  0  0 -1  0 ], ndigits=2
k=-19.5, yl= -20, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-19.25, yu= -18, k-yu=-1.25, sptu(8:-1:1)=[ 0  0  0 -1  0  0 -1  0 ], ndigits=2
k=-19.25, yl= -20, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k= -19, yu= -18, k-yu=-1, sptu(8:-1:1)=[ 0  0  0 -1  0  0 -1  0 ], ndigits=2
k= -19, yl= -20, k-yl= 1, sptl(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-18.75, yu= -18, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0 -1  0  0 -1  0 ], ndigits=2
k=-18.75, yl= -20, k-yl=1.25, sptl(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-18.5, yu= -18, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0 -1  0  0 -1  0 ], ndigits=2
k=-18.5, yl= -20, k-yl=1.5, sptl(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k=-18.25, yu= -18, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0 -1  0  0 -1  0 ], ndigits=2
k=-18.25, yl= -20, k-yl=1.75, sptl(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k= -18, yu= -18, k-yu= 0, sptu(8:-1:1)=[ 0  0  0 -1  0  0 -1  0 ], ndigits=2
k= -18, yl= -18, k-yl= 0, sptl(8:-1:1)=[ 0  0  0 -1  0  0 -1  0 ], ndigits=2
k=-17.75, yu= -17, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0 -1  0  0  0 -1 ], ndigits=2
k=-17.75, yl= -18, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0 -1  0  0 -1  0 ], ndigits=2
k=-17.5, yu= -17, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0 -1  0  0  0 -1 ], ndigits=2
k=-17.5, yl= -18, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0 -1  0  0 -1  0 ], ndigits=2
k=-17.25, yu= -17, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0 -1  0  0  0 -1 ], ndigits=2
k=-17.25, yl= -18, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0 -1  0  0 -1  0 ], ndigits=2
k= -17, yu= -17, k-yu= 0, sptu(8:-1:1)=[ 0  0  0 -1  0  0  0 -1 ], ndigits=2
k= -17, yl= -17, k-yl= 0, sptl(8:-1:1)=[ 0  0  0 -1  0  0  0 -1 ], ndigits=2
k=-16.75, yu= -16, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0 -1  0  0  0  0 ], ndigits=1
k=-16.75, yl= -17, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0 -1  0  0  0 -1 ], ndigits=2
k=-16.5, yu= -16, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0 -1  0  0  0  0 ], ndigits=1
k=-16.5, yl= -17, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0 -1  0  0  0 -1 ], ndigits=2
k=-16.25, yu= -16, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0 -1  0  0  0  0 ], ndigits=1
k=-16.25, yl= -17, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0 -1  0  0  0 -1 ], ndigits=2
k= -16, yu= -16, k-yu= 0, sptu(8:-1:1)=[ 0  0  0 -1  0  0  0  0 ], ndigits=1
k= -16, yl= -16, k-yl= 0, sptl(8:-1:1)=[ 0  0  0 -1  0  0  0  0 ], ndigits=1
k=-15.75, yu= -15, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0 -1  0  0  0  1 ], ndigits=2
k=-15.75, yl= -16, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0 -1  0  0  0  0 ], ndigits=1
k=-15.5, yu= -15, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0 -1  0  0  0  1 ], ndigits=2
k=-15.5, yl= -16, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0 -1  0  0  0  0 ], ndigits=1
k=-15.25, yu= -15, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0 -1  0  0  0  1 ], ndigits=2
k=-15.25, yl= -16, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0 -1  0  0  0  0 ], ndigits=1
k= -15, yu= -15, k-yu= 0, sptu(8:-1:1)=[ 0  0  0 -1  0  0  0  1 ], ndigits=2
k= -15, yl= -15, k-yl= 0, sptl(8:-1:1)=[ 0  0  0 -1  0  0  0  1 ], ndigits=2
k=-14.75, yu= -14, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0 -1  0  0  1  0 ], ndigits=2
k=-14.75, yl= -15, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0 -1  0  0  0  1 ], ndigits=2
k=-14.5, yu= -14, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0 -1  0  0  1  0 ], ndigits=2
k=-14.5, yl= -15, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0 -1  0  0  0  1 ], ndigits=2
k=-14.25, yu= -14, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0 -1  0  0  1  0 ], ndigits=2
k=-14.25, yl= -15, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0 -1  0  0  0  1 ], ndigits=2
k= -14, yu= -14, k-yu= 0, sptu(8:-1:1)=[ 0  0  0 -1  0  0  1  0 ], ndigits=2
k= -14, yl= -14, k-yl= 0, sptl(8:-1:1)=[ 0  0  0 -1  0  0  1  0 ], ndigits=2
k=-13.75, yu= -12, k-yu=-1.75, sptu(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k=-13.75, yl= -14, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0 -1  0  0  1  0 ], ndigits=2
k=-13.5, yu= -12, k-yu=-1.5, sptu(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k=-13.5, yl= -14, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0 -1  0  0  1  0 ], ndigits=2
k=-13.25, yu= -12, k-yu=-1.25, sptu(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k=-13.25, yl= -14, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0 -1  0  0  1  0 ], ndigits=2
k= -13, yu= -12, k-yu=-1, sptu(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k= -13, yl= -14, k-yl= 1, sptl(8:-1:1)=[ 0  0  0 -1  0  0  1  0 ], ndigits=2
k=-12.75, yu= -12, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k=-12.75, yl= -14, k-yl=1.25, sptl(8:-1:1)=[ 0  0  0 -1  0  0  1  0 ], ndigits=2
k=-12.5, yu= -12, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k=-12.5, yl= -14, k-yl=1.5, sptl(8:-1:1)=[ 0  0  0 -1  0  0  1  0 ], ndigits=2
k=-12.25, yu= -12, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k=-12.25, yl= -14, k-yl=1.75, sptl(8:-1:1)=[ 0  0  0 -1  0  0  1  0 ], ndigits=2
k= -12, yu= -12, k-yu= 0, sptu(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k= -12, yl= -12, k-yl= 0, sptl(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k=-11.75, yu= -10, k-yu=-1.75, sptu(8:-1:1)=[ 0  0  0  0 -1  0 -1  0 ], ndigits=2
k=-11.75, yl= -12, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k=-11.5, yu= -10, k-yu=-1.5, sptu(8:-1:1)=[ 0  0  0  0 -1  0 -1  0 ], ndigits=2
k=-11.5, yl= -12, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k=-11.25, yu= -10, k-yu=-1.25, sptu(8:-1:1)=[ 0  0  0  0 -1  0 -1  0 ], ndigits=2
k=-11.25, yl= -12, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k= -11, yu= -10, k-yu=-1, sptu(8:-1:1)=[ 0  0  0  0 -1  0 -1  0 ], ndigits=2
k= -11, yl= -12, k-yl= 1, sptl(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k=-10.75, yu= -10, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0 -1  0 -1  0 ], ndigits=2
k=-10.75, yl= -12, k-yl=1.25, sptl(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k=-10.5, yu= -10, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0 -1  0 -1  0 ], ndigits=2
k=-10.5, yl= -12, k-yl=1.5, sptl(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k=-10.25, yu= -10, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0 -1  0 -1  0 ], ndigits=2
k=-10.25, yl= -12, k-yl=1.75, sptl(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k= -10, yu= -10, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0 -1  0 -1  0 ], ndigits=2
k= -10, yl= -10, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0 -1  0 -1  0 ], ndigits=2
k=-9.75, yu=  -9, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0 -1  0  0 -1 ], ndigits=2
k=-9.75, yl= -10, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0 -1  0 -1  0 ], ndigits=2
k=-9.5, yu=  -9, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0 -1  0  0 -1 ], ndigits=2
k=-9.5, yl= -10, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0 -1  0 -1  0 ], ndigits=2
k=-9.25, yu=  -9, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0 -1  0  0 -1 ], ndigits=2
k=-9.25, yl= -10, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0 -1  0 -1  0 ], ndigits=2
k=  -9, yu=  -9, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0 -1  0  0 -1 ], ndigits=2
k=  -9, yl=  -9, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0 -1  0  0 -1 ], ndigits=2
k=-8.75, yu=  -8, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0 -1  0  0  0 ], ndigits=1
k=-8.75, yl=  -9, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0 -1  0  0 -1 ], ndigits=2
k=-8.5, yu=  -8, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0 -1  0  0  0 ], ndigits=1
k=-8.5, yl=  -9, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0 -1  0  0 -1 ], ndigits=2
k=-8.25, yu=  -8, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0 -1  0  0  0 ], ndigits=1
k=-8.25, yl=  -9, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0 -1  0  0 -1 ], ndigits=2
k=  -8, yu=  -8, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0 -1  0  0  0 ], ndigits=1
k=  -8, yl=  -8, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0 -1  0  0  0 ], ndigits=1
k=-7.75, yu=  -7, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0 -1  0  0  1 ], ndigits=2
k=-7.75, yl=  -8, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0 -1  0  0  0 ], ndigits=1
k=-7.5, yu=  -7, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0 -1  0  0  1 ], ndigits=2
k=-7.5, yl=  -8, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0 -1  0  0  0 ], ndigits=1
k=-7.25, yu=  -7, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0 -1  0  0  1 ], ndigits=2
k=-7.25, yl=  -8, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0 -1  0  0  0 ], ndigits=1
k=  -7, yu=  -7, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0 -1  0  0  1 ], ndigits=2
k=  -7, yl=  -7, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0 -1  0  0  1 ], ndigits=2
k=-6.75, yu=  -6, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0 -1  0  1  0 ], ndigits=2
k=-6.75, yl=  -7, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0 -1  0  0  1 ], ndigits=2
k=-6.5, yu=  -6, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0 -1  0  1  0 ], ndigits=2
k=-6.5, yl=  -7, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0 -1  0  0  1 ], ndigits=2
k=-6.25, yu=  -6, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0 -1  0  1  0 ], ndigits=2
k=-6.25, yl=  -7, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0 -1  0  0  1 ], ndigits=2
k=  -6, yu=  -6, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0 -1  0  1  0 ], ndigits=2
k=  -6, yl=  -6, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0 -1  0  1  0 ], ndigits=2
k=-5.75, yu=  -5, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  0 -1  0 -1 ], ndigits=2
k=-5.75, yl=  -6, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0 -1  0  1  0 ], ndigits=2
k=-5.5, yu=  -5, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  0 -1  0 -1 ], ndigits=2
k=-5.5, yl=  -6, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0 -1  0  1  0 ], ndigits=2
k=-5.25, yu=  -5, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  0 -1  0 -1 ], ndigits=2
k=-5.25, yl=  -6, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0 -1  0  1  0 ], ndigits=2
k=  -5, yu=  -5, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  0 -1  0 -1 ], ndigits=2
k=  -5, yl=  -5, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  0 -1  0 -1 ], ndigits=2
k=-4.75, yu=  -4, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  0 -1  0  0 ], ndigits=1
k=-4.75, yl=  -5, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  0 -1  0 -1 ], ndigits=2
k=-4.5, yu=  -4, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  0 -1  0  0 ], ndigits=1
k=-4.5, yl=  -5, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  0 -1  0 -1 ], ndigits=2
k=-4.25, yu=  -4, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  0 -1  0  0 ], ndigits=1
k=-4.25, yl=  -5, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  0 -1  0 -1 ], ndigits=2
k=  -4, yu=  -4, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  0 -1  0  0 ], ndigits=1
k=  -4, yl=  -4, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  0 -1  0  0 ], ndigits=1
k=-3.75, yu=  -3, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  0 -1  0  1 ], ndigits=2
k=-3.75, yl=  -4, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  0 -1  0  0 ], ndigits=1
k=-3.5, yu=  -3, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  0 -1  0  1 ], ndigits=2
k=-3.5, yl=  -4, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  0 -1  0  0 ], ndigits=1
k=-3.25, yu=  -3, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  0 -1  0  1 ], ndigits=2
k=-3.25, yl=  -4, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  0 -1  0  0 ], ndigits=1
k=  -3, yu=  -3, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  0 -1  0  1 ], ndigits=2
k=  -3, yl=  -3, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  0 -1  0  1 ], ndigits=2
k=-2.75, yu=  -2, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  0  0 -1  0 ], ndigits=1
k=-2.75, yl=  -3, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  0 -1  0  1 ], ndigits=2
k=-2.5, yu=  -2, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  0  0 -1  0 ], ndigits=1
k=-2.5, yl=  -3, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  0 -1  0  1 ], ndigits=2
k=-2.25, yu=  -2, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  0  0 -1  0 ], ndigits=1
k=-2.25, yl=  -3, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  0 -1  0  1 ], ndigits=2
k=  -2, yu=  -2, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  0  0 -1  0 ], ndigits=1
k=  -2, yl=  -2, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  0  0 -1  0 ], ndigits=1
k=-1.75, yu=  -1, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  0  0  0 -1 ], ndigits=1
k=-1.75, yl=  -2, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  0  0 -1  0 ], ndigits=1
k=-1.5, yu=  -1, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  0  0  0 -1 ], ndigits=1
k=-1.5, yl=  -2, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  0  0 -1  0 ], ndigits=1
k=-1.25, yu=  -1, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  0  0  0 -1 ], ndigits=1
k=-1.25, yl=  -2, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  0  0 -1  0 ], ndigits=1
k=  -1, yu=  -1, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  0  0  0 -1 ], ndigits=1
k=  -1, yl=  -1, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  0  0  0 -1 ], ndigits=1
k=-0.75, yu=   0, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  0  0  0  0 ], ndigits=0
k=-0.75, yl=  -1, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  0  0  0 -1 ], ndigits=1
k=-0.5, yu=   0, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  0  0  0  0 ], ndigits=0
k=-0.5, yl=  -1, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  0  0  0 -1 ], ndigits=1
k=-0.25, yu=   0, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  0  0  0  0 ], ndigits=0
k=-0.25, yl=  -1, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  0  0  0 -1 ], ndigits=1
k=   0, yu=   0, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  0  0  0  0 ], ndigits=0
k=   0, yl=   0, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  0  0  0  0 ], ndigits=0
k=0.25, yu=   1, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  0  0  0  1 ], ndigits=1
k=0.25, yl=   0, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  0  0  0  0 ], ndigits=0
k= 0.5, yu=   1, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  0  0  0  1 ], ndigits=1
k= 0.5, yl=   0, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  0  0  0  0 ], ndigits=0
k=0.75, yu=   1, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  0  0  0  1 ], ndigits=1
k=0.75, yl=   0, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  0  0  0  0 ], ndigits=0
k=   1, yu=   1, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  0  0  0  1 ], ndigits=1
k=   1, yl=   1, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  0  0  0  1 ], ndigits=1
k=1.25, yu=   2, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  0  0  1  0 ], ndigits=1
k=1.25, yl=   1, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  0  0  0  1 ], ndigits=1
k= 1.5, yu=   2, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  0  0  1  0 ], ndigits=1
k= 1.5, yl=   1, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  0  0  0  1 ], ndigits=1
k=1.75, yu=   2, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  0  0  1  0 ], ndigits=1
k=1.75, yl=   1, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  0  0  0  1 ], ndigits=1
k=   2, yu=   2, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  0  0  1  0 ], ndigits=1
k=   2, yl=   2, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  0  0  1  0 ], ndigits=1
k=2.25, yu=   3, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  0  1  0 -1 ], ndigits=2
k=2.25, yl=   2, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  0  0  1  0 ], ndigits=1
k= 2.5, yu=   3, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  0  1  0 -1 ], ndigits=2
k= 2.5, yl=   2, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  0  0  1  0 ], ndigits=1
k=2.75, yu=   3, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  0  1  0 -1 ], ndigits=2
k=2.75, yl=   2, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  0  0  1  0 ], ndigits=1
k=   3, yu=   3, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  0  1  0 -1 ], ndigits=2
k=   3, yl=   3, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  0  1  0 -1 ], ndigits=2
k=3.25, yu=   4, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  0  1  0  0 ], ndigits=1
k=3.25, yl=   3, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  0  1  0 -1 ], ndigits=2
k= 3.5, yu=   4, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  0  1  0  0 ], ndigits=1
k= 3.5, yl=   3, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  0  1  0 -1 ], ndigits=2
k=3.75, yu=   4, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  0  1  0  0 ], ndigits=1
k=3.75, yl=   3, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  0  1  0 -1 ], ndigits=2
k=   4, yu=   4, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  0  1  0  0 ], ndigits=1
k=   4, yl=   4, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  0  1  0  0 ], ndigits=1
k=4.25, yu=   5, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  0  1  0  1 ], ndigits=2
k=4.25, yl=   4, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  0  1  0  0 ], ndigits=1
k= 4.5, yu=   5, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  0  1  0  1 ], ndigits=2
k= 4.5, yl=   4, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  0  1  0  0 ], ndigits=1
k=4.75, yu=   5, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  0  1  0  1 ], ndigits=2
k=4.75, yl=   4, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  0  1  0  0 ], ndigits=1
k=   5, yu=   5, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  0  1  0  1 ], ndigits=2
k=   5, yl=   5, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  0  1  0  1 ], ndigits=2
k=5.25, yu=   6, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  1  0 -1  0 ], ndigits=2
k=5.25, yl=   5, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  0  1  0  1 ], ndigits=2
k= 5.5, yu=   6, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  1  0 -1  0 ], ndigits=2
k= 5.5, yl=   5, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  0  1  0  1 ], ndigits=2
k=5.75, yu=   6, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  1  0 -1  0 ], ndigits=2
k=5.75, yl=   5, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  0  1  0  1 ], ndigits=2
k=   6, yu=   6, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  1  0 -1  0 ], ndigits=2
k=   6, yl=   6, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  1  0 -1  0 ], ndigits=2
k=6.25, yu=   7, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  1  0  0 -1 ], ndigits=2
k=6.25, yl=   6, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  1  0 -1  0 ], ndigits=2
k= 6.5, yu=   7, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  1  0  0 -1 ], ndigits=2
k= 6.5, yl=   6, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  1  0 -1  0 ], ndigits=2
k=6.75, yu=   7, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  1  0  0 -1 ], ndigits=2
k=6.75, yl=   6, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  1  0 -1  0 ], ndigits=2
k=   7, yu=   7, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  1  0  0 -1 ], ndigits=2
k=   7, yl=   7, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  1  0  0 -1 ], ndigits=2
k=7.25, yu=   8, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  1  0  0  0 ], ndigits=1
k=7.25, yl=   7, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  1  0  0 -1 ], ndigits=2
k= 7.5, yu=   8, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  1  0  0  0 ], ndigits=1
k= 7.5, yl=   7, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  1  0  0 -1 ], ndigits=2
k=7.75, yu=   8, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  1  0  0  0 ], ndigits=1
k=7.75, yl=   7, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  1  0  0 -1 ], ndigits=2
k=   8, yu=   8, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  1  0  0  0 ], ndigits=1
k=   8, yl=   8, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  1  0  0  0 ], ndigits=1
k=8.25, yu=   9, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  1  0  0  1 ], ndigits=2
k=8.25, yl=   8, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  1  0  0  0 ], ndigits=1
k= 8.5, yu=   9, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  1  0  0  1 ], ndigits=2
k= 8.5, yl=   8, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  1  0  0  0 ], ndigits=1
k=8.75, yu=   9, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  1  0  0  1 ], ndigits=2
k=8.75, yl=   8, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  1  0  0  0 ], ndigits=1
k=   9, yu=   9, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  1  0  0  1 ], ndigits=2
k=   9, yl=   9, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  1  0  0  1 ], ndigits=2
k=9.25, yu=  10, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  0  1  0  1  0 ], ndigits=2
k=9.25, yl=   9, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  1  0  0  1 ], ndigits=2
k= 9.5, yu=  10, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  0  1  0  1  0 ], ndigits=2
k= 9.5, yl=   9, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  1  0  0  1 ], ndigits=2
k=9.75, yu=  10, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  0  1  0  1  0 ], ndigits=2
k=9.75, yl=   9, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  1  0  0  1 ], ndigits=2
k=  10, yu=  10, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  0  1  0  1  0 ], ndigits=2
k=  10, yl=  10, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  0  1  0  1  0 ], ndigits=2
k=10.25, yu=  12, k-yu=-1.75, sptu(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=10.25, yl=  10, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  0  1  0  1  0 ], ndigits=2
k=10.5, yu=  12, k-yu=-1.5, sptu(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=10.5, yl=  10, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  0  1  0  1  0 ], ndigits=2
k=10.75, yu=  12, k-yu=-1.25, sptu(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=10.75, yl=  10, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  0  1  0  1  0 ], ndigits=2
k=  11, yu=  12, k-yu=-1, sptu(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=  11, yl=  10, k-yl= 1, sptl(8:-1:1)=[ 0  0  0  0  1  0  1  0 ], ndigits=2
k=11.25, yu=  12, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=11.25, yl=  10, k-yl=1.25, sptl(8:-1:1)=[ 0  0  0  0  1  0  1  0 ], ndigits=2
k=11.5, yu=  12, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=11.5, yl=  10, k-yl=1.5, sptl(8:-1:1)=[ 0  0  0  0  1  0  1  0 ], ndigits=2
k=11.75, yu=  12, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=11.75, yl=  10, k-yl=1.75, sptl(8:-1:1)=[ 0  0  0  0  1  0  1  0 ], ndigits=2
k=  12, yu=  12, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=  12, yl=  12, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=12.25, yu=  14, k-yu=-1.75, sptu(8:-1:1)=[ 0  0  0  1  0  0 -1  0 ], ndigits=2
k=12.25, yl=  12, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=12.5, yu=  14, k-yu=-1.5, sptu(8:-1:1)=[ 0  0  0  1  0  0 -1  0 ], ndigits=2
k=12.5, yl=  12, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=12.75, yu=  14, k-yu=-1.25, sptu(8:-1:1)=[ 0  0  0  1  0  0 -1  0 ], ndigits=2
k=12.75, yl=  12, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=  13, yu=  14, k-yu=-1, sptu(8:-1:1)=[ 0  0  0  1  0  0 -1  0 ], ndigits=2
k=  13, yl=  12, k-yl= 1, sptl(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=13.25, yu=  14, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  1  0  0 -1  0 ], ndigits=2
k=13.25, yl=  12, k-yl=1.25, sptl(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=13.5, yu=  14, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  1  0  0 -1  0 ], ndigits=2
k=13.5, yl=  12, k-yl=1.5, sptl(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=13.75, yu=  14, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  1  0  0 -1  0 ], ndigits=2
k=13.75, yl=  12, k-yl=1.75, sptl(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=  14, yu=  14, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  1  0  0 -1  0 ], ndigits=2
k=  14, yl=  14, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  1  0  0 -1  0 ], ndigits=2
k=14.25, yu=  15, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  1  0  0  0 -1 ], ndigits=2
k=14.25, yl=  14, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  1  0  0 -1  0 ], ndigits=2
k=14.5, yu=  15, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  1  0  0  0 -1 ], ndigits=2
k=14.5, yl=  14, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  1  0  0 -1  0 ], ndigits=2
k=14.75, yu=  15, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  1  0  0  0 -1 ], ndigits=2
k=14.75, yl=  14, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  1  0  0 -1  0 ], ndigits=2
k=  15, yu=  15, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  1  0  0  0 -1 ], ndigits=2
k=  15, yl=  15, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  1  0  0  0 -1 ], ndigits=2
k=15.25, yu=  16, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  1  0  0  0  0 ], ndigits=1
k=15.25, yl=  15, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  1  0  0  0 -1 ], ndigits=2
k=15.5, yu=  16, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  1  0  0  0  0 ], ndigits=1
k=15.5, yl=  15, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  1  0  0  0 -1 ], ndigits=2
k=15.75, yu=  16, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  1  0  0  0  0 ], ndigits=1
k=15.75, yl=  15, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  1  0  0  0 -1 ], ndigits=2
k=  16, yu=  16, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  1  0  0  0  0 ], ndigits=1
k=  16, yl=  16, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  1  0  0  0  0 ], ndigits=1
k=16.25, yu=  17, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  1  0  0  0  1 ], ndigits=2
k=16.25, yl=  16, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  1  0  0  0  0 ], ndigits=1
k=16.5, yu=  17, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  1  0  0  0  1 ], ndigits=2
k=16.5, yl=  16, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  1  0  0  0  0 ], ndigits=1
k=16.75, yu=  17, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  1  0  0  0  1 ], ndigits=2
k=16.75, yl=  16, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  1  0  0  0  0 ], ndigits=1
k=  17, yu=  17, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  1  0  0  0  1 ], ndigits=2
k=  17, yl=  17, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  1  0  0  0  1 ], ndigits=2
k=17.25, yu=  18, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  1  0  0  1  0 ], ndigits=2
k=17.25, yl=  17, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  1  0  0  0  1 ], ndigits=2
k=17.5, yu=  18, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  1  0  0  1  0 ], ndigits=2
k=17.5, yl=  17, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  1  0  0  0  1 ], ndigits=2
k=17.75, yu=  18, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  1  0  0  1  0 ], ndigits=2
k=17.75, yl=  17, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  1  0  0  0  1 ], ndigits=2
k=  18, yu=  18, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  1  0  0  1  0 ], ndigits=2
k=  18, yl=  18, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  1  0  0  1  0 ], ndigits=2
k=18.25, yu=  20, k-yu=-1.75, sptu(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=18.25, yl=  18, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  1  0  0  1  0 ], ndigits=2
k=18.5, yu=  20, k-yu=-1.5, sptu(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=18.5, yl=  18, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  1  0  0  1  0 ], ndigits=2
k=18.75, yu=  20, k-yu=-1.25, sptu(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=18.75, yl=  18, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  1  0  0  1  0 ], ndigits=2
k=  19, yu=  20, k-yu=-1, sptu(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=  19, yl=  18, k-yl= 1, sptl(8:-1:1)=[ 0  0  0  1  0  0  1  0 ], ndigits=2
k=19.25, yu=  20, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=19.25, yl=  18, k-yl=1.25, sptl(8:-1:1)=[ 0  0  0  1  0  0  1  0 ], ndigits=2
k=19.5, yu=  20, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=19.5, yl=  18, k-yl=1.5, sptl(8:-1:1)=[ 0  0  0  1  0  0  1  0 ], ndigits=2
k=19.75, yu=  20, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=19.75, yl=  18, k-yl=1.75, sptl(8:-1:1)=[ 0  0  0  1  0  0  1  0 ], ndigits=2
k=  20, yu=  20, k-yu= 0, sptu(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=  20, yl=  20, k-yl= 0, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=20.25, yu=  24, k-yu=-3.75, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=20.25, yl=  20, k-yl=0.25, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=20.5, yu=  24, k-yu=-3.5, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=20.5, yl=  20, k-yl=0.5, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=20.75, yu=  24, k-yu=-3.25, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=20.75, yl=  20, k-yl=0.75, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=  21, yu=  24, k-yu=-3, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=  21, yl=  20, k-yl= 1, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=21.25, yu=  24, k-yu=-2.75, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=21.25, yl=  20, k-yl=1.25, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=21.5, yu=  24, k-yu=-2.5, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=21.5, yl=  20, k-yl=1.5, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=21.75, yu=  24, k-yu=-2.25, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=21.75, yl=  20, k-yl=1.75, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=  22, yu=  24, k-yu=-2, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=  22, yl=  20, k-yl= 2, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=22.25, yu=  24, k-yu=-1.75, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=22.25, yl=  20, k-yl=2.25, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=22.5, yu=  24, k-yu=-1.5, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=22.5, yl=  20, k-yl=2.5, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=22.75, yu=  24, k-yu=-1.25, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=22.75, yl=  20, k-yl=2.75, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=  23, yu=  24, k-yu=-1, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=  23, yl=  20, k-yl= 3, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=23.25, yu=  24, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=23.25, yl=  20, k-yl=3.25, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=23.5, yu=  24, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=23.5, yl=  20, k-yl=3.5, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=23.75, yu=  24, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=23.75, yl=  20, k-yl=3.75, sptl(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=  24, yu=  24, k-yu= 0, sptu(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=  24, yl=  24, k-yl= 0, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=24.25, yu=  28, k-yu=-3.75, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=24.25, yl=  24, k-yl=0.25, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=24.5, yu=  28, k-yu=-3.5, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=24.5, yl=  24, k-yl=0.5, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=24.75, yu=  28, k-yu=-3.25, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=24.75, yl=  24, k-yl=0.75, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=  25, yu=  28, k-yu=-3, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=  25, yl=  24, k-yl= 1, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=25.25, yu=  28, k-yu=-2.75, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=25.25, yl=  24, k-yl=1.25, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=25.5, yu=  28, k-yu=-2.5, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=25.5, yl=  24, k-yl=1.5, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=25.75, yu=  28, k-yu=-2.25, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=25.75, yl=  24, k-yl=1.75, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=  26, yu=  28, k-yu=-2, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=  26, yl=  24, k-yl= 2, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=26.25, yu=  28, k-yu=-1.75, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=26.25, yl=  24, k-yl=2.25, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=26.5, yu=  28, k-yu=-1.5, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=26.5, yl=  24, k-yl=2.5, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=26.75, yu=  28, k-yu=-1.25, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=26.75, yl=  24, k-yl=2.75, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=  27, yu=  28, k-yu=-1, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=  27, yl=  24, k-yl= 3, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=27.25, yu=  28, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=27.25, yl=  24, k-yl=3.25, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=27.5, yu=  28, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=27.5, yl=  24, k-yl=3.5, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=27.75, yu=  28, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=27.75, yl=  24, k-yl=3.75, sptl(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=  28, yu=  28, k-yu= 0, sptu(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=  28, yl=  28, k-yl= 0, sptl(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=28.25, yu=  30, k-yu=-1.75, sptu(8:-1:1)=[ 0  0  1  0  0  0 -1  0 ], ndigits=2
k=28.25, yl=  28, k-yl=0.25, sptl(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=28.5, yu=  30, k-yu=-1.5, sptu(8:-1:1)=[ 0  0  1  0  0  0 -1  0 ], ndigits=2
k=28.5, yl=  28, k-yl=0.5, sptl(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=28.75, yu=  30, k-yu=-1.25, sptu(8:-1:1)=[ 0  0  1  0  0  0 -1  0 ], ndigits=2
k=28.75, yl=  28, k-yl=0.75, sptl(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=  29, yu=  30, k-yu=-1, sptu(8:-1:1)=[ 0  0  1  0  0  0 -1  0 ], ndigits=2
k=  29, yl=  28, k-yl= 1, sptl(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=29.25, yu=  30, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  1  0  0  0 -1  0 ], ndigits=2
k=29.25, yl=  28, k-yl=1.25, sptl(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=29.5, yu=  30, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  1  0  0  0 -1  0 ], ndigits=2
k=29.5, yl=  28, k-yl=1.5, sptl(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=29.75, yu=  30, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  1  0  0  0 -1  0 ], ndigits=2
k=29.75, yl=  28, k-yl=1.75, sptl(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=  30, yu=  30, k-yu= 0, sptu(8:-1:1)=[ 0  0  1  0  0  0 -1  0 ], ndigits=2
k=  30, yl=  30, k-yl= 0, sptl(8:-1:1)=[ 0  0  1  0  0  0 -1  0 ], ndigits=2
k=30.25, yu=  31, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  1  0  0  0  0 -1 ], ndigits=2
k=30.25, yl=  30, k-yl=0.25, sptl(8:-1:1)=[ 0  0  1  0  0  0 -1  0 ], ndigits=2
k=30.5, yu=  31, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  1  0  0  0  0 -1 ], ndigits=2
k=30.5, yl=  30, k-yl=0.5, sptl(8:-1:1)=[ 0  0  1  0  0  0 -1  0 ], ndigits=2
k=30.75, yu=  31, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  1  0  0  0  0 -1 ], ndigits=2
k=30.75, yl=  30, k-yl=0.75, sptl(8:-1:1)=[ 0  0  1  0  0  0 -1  0 ], ndigits=2
k=  31, yu=  31, k-yu= 0, sptu(8:-1:1)=[ 0  0  1  0  0  0  0 -1 ], ndigits=2
k=  31, yl=  31, k-yl= 0, sptl(8:-1:1)=[ 0  0  1  0  0  0  0 -1 ], ndigits=2
k=31.25, yu=  32, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  1  0  0  0  0  0 ], ndigits=1
k=31.25, yl=  31, k-yl=0.25, sptl(8:-1:1)=[ 0  0  1  0  0  0  0 -1 ], ndigits=2
k=31.5, yu=  32, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  1  0  0  0  0  0 ], ndigits=1
k=31.5, yl=  31, k-yl=0.5, sptl(8:-1:1)=[ 0  0  1  0  0  0  0 -1 ], ndigits=2
k=31.75, yu=  32, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  1  0  0  0  0  0 ], ndigits=1
k=31.75, yl=  31, k-yl=0.75, sptl(8:-1:1)=[ 0  0  1  0  0  0  0 -1 ], ndigits=2
k=  32, yu=  32, k-yu= 0, sptu(8:-1:1)=[ 0  0  1  0  0  0  0  0 ], ndigits=1
k=  32, yl=  32, k-yl= 0, sptl(8:-1:1)=[ 0  0  1  0  0  0  0  0 ], ndigits=1
k=32.25, yu=  33, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  1  0  0  0  0  1 ], ndigits=2
k=32.25, yl=  32, k-yl=0.25, sptl(8:-1:1)=[ 0  0  1  0  0  0  0  0 ], ndigits=1
k=32.5, yu=  33, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  1  0  0  0  0  1 ], ndigits=2
k=32.5, yl=  32, k-yl=0.5, sptl(8:-1:1)=[ 0  0  1  0  0  0  0  0 ], ndigits=1
k=32.75, yu=  33, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  1  0  0  0  0  1 ], ndigits=2
k=32.75, yl=  32, k-yl=0.75, sptl(8:-1:1)=[ 0  0  1  0  0  0  0  0 ], ndigits=1
k=  33, yu=  33, k-yu= 0, sptu(8:-1:1)=[ 0  0  1  0  0  0  0  1 ], ndigits=2
k=  33, yl=  33, k-yl= 0, sptl(8:-1:1)=[ 0  0  1  0  0  0  0  1 ], ndigits=2
k=33.25, yu=  34, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  1  0  0  0  1  0 ], ndigits=2
k=33.25, yl=  33, k-yl=0.25, sptl(8:-1:1)=[ 0  0  1  0  0  0  0  1 ], ndigits=2
k=33.5, yu=  34, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  1  0  0  0  1  0 ], ndigits=2
k=33.5, yl=  33, k-yl=0.5, sptl(8:-1:1)=[ 0  0  1  0  0  0  0  1 ], ndigits=2
k=33.75, yu=  34, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  1  0  0  0  1  0 ], ndigits=2
k=33.75, yl=  33, k-yl=0.75, sptl(8:-1:1)=[ 0  0  1  0  0  0  0  1 ], ndigits=2
k=  34, yu=  34, k-yu= 0, sptu(8:-1:1)=[ 0  0  1  0  0  0  1  0 ], ndigits=2
k=  34, yl=  34, k-yl= 0, sptl(8:-1:1)=[ 0  0  1  0  0  0  1  0 ], ndigits=2
k=34.25, yu=  36, k-yu=-1.75, sptu(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=34.25, yl=  34, k-yl=0.25, sptl(8:-1:1)=[ 0  0  1  0  0  0  1  0 ], ndigits=2
k=34.5, yu=  36, k-yu=-1.5, sptu(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=34.5, yl=  34, k-yl=0.5, sptl(8:-1:1)=[ 0  0  1  0  0  0  1  0 ], ndigits=2
k=34.75, yu=  36, k-yu=-1.25, sptu(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=34.75, yl=  34, k-yl=0.75, sptl(8:-1:1)=[ 0  0  1  0  0  0  1  0 ], ndigits=2
k=  35, yu=  36, k-yu=-1, sptu(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=  35, yl=  34, k-yl= 1, sptl(8:-1:1)=[ 0  0  1  0  0  0  1  0 ], ndigits=2
k=35.25, yu=  36, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=35.25, yl=  34, k-yl=1.25, sptl(8:-1:1)=[ 0  0  1  0  0  0  1  0 ], ndigits=2
k=35.5, yu=  36, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=35.5, yl=  34, k-yl=1.5, sptl(8:-1:1)=[ 0  0  1  0  0  0  1  0 ], ndigits=2
k=35.75, yu=  36, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=35.75, yl=  34, k-yl=1.75, sptl(8:-1:1)=[ 0  0  1  0  0  0  1  0 ], ndigits=2
k=  36, yu=  36, k-yu= 0, sptu(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=  36, yl=  36, k-yl= 0, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=36.25, yu=  40, k-yu=-3.75, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=36.25, yl=  36, k-yl=0.25, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=36.5, yu=  40, k-yu=-3.5, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=36.5, yl=  36, k-yl=0.5, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=36.75, yu=  40, k-yu=-3.25, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=36.75, yl=  36, k-yl=0.75, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=  37, yu=  40, k-yu=-3, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  37, yl=  36, k-yl= 1, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=37.25, yu=  40, k-yu=-2.75, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=37.25, yl=  36, k-yl=1.25, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=37.5, yu=  40, k-yu=-2.5, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=37.5, yl=  36, k-yl=1.5, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=37.75, yu=  40, k-yu=-2.25, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=37.75, yl=  36, k-yl=1.75, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=  38, yu=  40, k-yu=-2, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  38, yl=  36, k-yl= 2, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=38.25, yu=  40, k-yu=-1.75, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=38.25, yl=  36, k-yl=2.25, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=38.5, yu=  40, k-yu=-1.5, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=38.5, yl=  36, k-yl=2.5, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=38.75, yu=  40, k-yu=-1.25, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=38.75, yl=  36, k-yl=2.75, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=  39, yu=  40, k-yu=-1, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  39, yl=  36, k-yl= 3, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=39.25, yu=  40, k-yu=-0.75, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=39.25, yl=  36, k-yl=3.25, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=39.5, yu=  40, k-yu=-0.5, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=39.5, yl=  36, k-yl=3.5, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=39.75, yu=  40, k-yu=-0.25, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=39.75, yl=  36, k-yl=3.75, sptl(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=  40, yu=  40, k-yu= 0, sptu(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  40, yl=  40, k-yl= 0, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=40.25, yu=  48, k-yu=-7.75, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=40.25, yl=  40, k-yl=0.25, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=40.5, yu=  48, k-yu=-7.5, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=40.5, yl=  40, k-yl=0.5, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=40.75, yu=  48, k-yu=-7.25, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=40.75, yl=  40, k-yl=0.75, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  41, yu=  48, k-yu=-7, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  41, yl=  40, k-yl= 1, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=41.25, yu=  48, k-yu=-6.75, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=41.25, yl=  40, k-yl=1.25, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=41.5, yu=  48, k-yu=-6.5, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=41.5, yl=  40, k-yl=1.5, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=41.75, yu=  48, k-yu=-6.25, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=41.75, yl=  40, k-yl=1.75, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  42, yu=  48, k-yu=-6, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  42, yl=  40, k-yl= 2, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=42.25, yu=  48, k-yu=-5.75, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=42.25, yl=  40, k-yl=2.25, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=42.5, yu=  48, k-yu=-5.5, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=42.5, yl=  40, k-yl=2.5, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=42.75, yu=  48, k-yu=-5.25, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=42.75, yl=  40, k-yl=2.75, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  43, yu=  48, k-yu=-5, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  43, yl=  40, k-yl= 3, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=43.25, yu=  48, k-yu=-4.75, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=43.25, yl=  40, k-yl=3.25, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=43.5, yu=  48, k-yu=-4.5, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=43.5, yl=  40, k-yl=3.5, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=43.75, yu=  48, k-yu=-4.25, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=43.75, yl=  40, k-yl=3.75, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  44, yu=  48, k-yu=-4, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  44, yl=  40, k-yl= 4, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=44.25, yu=  48, k-yu=-3.75, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=44.25, yl=  40, k-yl=4.25, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=44.5, yu=  48, k-yu=-3.5, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=44.5, yl=  40, k-yl=4.5, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=44.75, yu=  48, k-yu=-3.25, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=44.75, yl=  40, k-yl=4.75, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  45, yu=  48, k-yu=-3, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  45, yl=  40, k-yl= 5, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=45.25, yu=  48, k-yu=-2.75, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=45.25, yl=  40, k-yl=5.25, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=45.5, yu=  48, k-yu=-2.5, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=45.5, yl=  40, k-yl=5.5, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=45.75, yu=  48, k-yu=-2.25, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=45.75, yl=  40, k-yl=5.75, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  46, yu=  48, k-yu=-2, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  46, yl=  40, k-yl= 6, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=46.25, yu=  48, k-yu=-1.75, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=46.25, yl=  40, k-yl=6.25, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=46.5, yu=  48, k-yu=-1.5, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=46.5, yl=  40, k-yl=6.5, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=46.75, yu=  48, k-yu=-1.25, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=46.75, yl=  40, k-yl=6.75, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  47, yu=  48, k-yu=-1, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  47, yl=  40, k-yl= 7, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=47.25, yu=  48, k-yu=-0.75, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=47.25, yl=  40, k-yl=7.25, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=47.5, yu=  48, k-yu=-0.5, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=47.5, yl=  40, k-yl=7.5, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=47.75, yu=  48, k-yu=-0.25, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=47.75, yl=  40, k-yl=7.75, sptl(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  48, yu=  48, k-yu= 0, sptu(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  48, yl=  48, k-yl= 0, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=48.25, yu=  56, k-yu=-7.75, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=48.25, yl=  48, k-yl=0.25, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=48.5, yu=  56, k-yu=-7.5, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=48.5, yl=  48, k-yl=0.5, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=48.75, yu=  56, k-yu=-7.25, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=48.75, yl=  48, k-yl=0.75, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  49, yu=  56, k-yu=-7, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  49, yl=  48, k-yl= 1, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=49.25, yu=  56, k-yu=-6.75, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=49.25, yl=  48, k-yl=1.25, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=49.5, yu=  56, k-yu=-6.5, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=49.5, yl=  48, k-yl=1.5, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=49.75, yu=  56, k-yu=-6.25, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=49.75, yl=  48, k-yl=1.75, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  50, yu=  56, k-yu=-6, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  50, yl=  48, k-yl= 2, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=50.25, yu=  56, k-yu=-5.75, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=50.25, yl=  48, k-yl=2.25, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=50.5, yu=  56, k-yu=-5.5, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=50.5, yl=  48, k-yl=2.5, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=50.75, yu=  56, k-yu=-5.25, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=50.75, yl=  48, k-yl=2.75, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  51, yu=  56, k-yu=-5, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  51, yl=  48, k-yl= 3, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=51.25, yu=  56, k-yu=-4.75, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=51.25, yl=  48, k-yl=3.25, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=51.5, yu=  56, k-yu=-4.5, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=51.5, yl=  48, k-yl=3.5, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=51.75, yu=  56, k-yu=-4.25, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=51.75, yl=  48, k-yl=3.75, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  52, yu=  56, k-yu=-4, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  52, yl=  48, k-yl= 4, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=52.25, yu=  56, k-yu=-3.75, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=52.25, yl=  48, k-yl=4.25, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=52.5, yu=  56, k-yu=-3.5, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=52.5, yl=  48, k-yl=4.5, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=52.75, yu=  56, k-yu=-3.25, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=52.75, yl=  48, k-yl=4.75, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  53, yu=  56, k-yu=-3, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  53, yl=  48, k-yl= 5, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=53.25, yu=  56, k-yu=-2.75, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=53.25, yl=  48, k-yl=5.25, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=53.5, yu=  56, k-yu=-2.5, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=53.5, yl=  48, k-yl=5.5, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=53.75, yu=  56, k-yu=-2.25, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=53.75, yl=  48, k-yl=5.75, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  54, yu=  56, k-yu=-2, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  54, yl=  48, k-yl= 6, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=54.25, yu=  56, k-yu=-1.75, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=54.25, yl=  48, k-yl=6.25, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=54.5, yu=  56, k-yu=-1.5, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=54.5, yl=  48, k-yl=6.5, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=54.75, yu=  56, k-yu=-1.25, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=54.75, yl=  48, k-yl=6.75, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  55, yu=  56, k-yu=-1, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  55, yl=  48, k-yl= 7, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=55.25, yu=  56, k-yu=-0.75, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=55.25, yl=  48, k-yl=7.25, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=55.5, yu=  56, k-yu=-0.5, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=55.5, yl=  48, k-yl=7.5, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=55.75, yu=  56, k-yu=-0.25, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=55.75, yl=  48, k-yl=7.75, sptl(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  56, yu=  56, k-yu= 0, sptu(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  56, yl=  56, k-yl= 0, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=56.25, yu=  60, k-yu=-3.75, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=56.25, yl=  56, k-yl=0.25, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=56.5, yu=  60, k-yu=-3.5, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=56.5, yl=  56, k-yl=0.5, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=56.75, yu=  60, k-yu=-3.25, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=56.75, yl=  56, k-yl=0.75, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  57, yu=  60, k-yu=-3, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=  57, yl=  56, k-yl= 1, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=57.25, yu=  60, k-yu=-2.75, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=57.25, yl=  56, k-yl=1.25, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=57.5, yu=  60, k-yu=-2.5, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=57.5, yl=  56, k-yl=1.5, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=57.75, yu=  60, k-yu=-2.25, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=57.75, yl=  56, k-yl=1.75, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  58, yu=  60, k-yu=-2, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=  58, yl=  56, k-yl= 2, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=58.25, yu=  60, k-yu=-1.75, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=58.25, yl=  56, k-yl=2.25, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=58.5, yu=  60, k-yu=-1.5, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=58.5, yl=  56, k-yl=2.5, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=58.75, yu=  60, k-yu=-1.25, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=58.75, yl=  56, k-yl=2.75, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  59, yu=  60, k-yu=-1, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=  59, yl=  56, k-yl= 3, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=59.25, yu=  60, k-yu=-0.75, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=59.25, yl=  56, k-yl=3.25, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=59.5, yu=  60, k-yu=-0.5, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=59.5, yl=  56, k-yl=3.5, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=59.75, yu=  60, k-yu=-0.25, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=59.75, yl=  56, k-yl=3.75, sptl(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  60, yu=  60, k-yu= 0, sptu(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=  60, yl=  60, k-yl= 0, sptl(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=60.25, yu=  62, k-yu=-1.75, sptu(8:-1:1)=[ 0  1  0  0  0  0 -1  0 ], ndigits=2
k=60.25, yl=  60, k-yl=0.25, sptl(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=60.5, yu=  62, k-yu=-1.5, sptu(8:-1:1)=[ 0  1  0  0  0  0 -1  0 ], ndigits=2
k=60.5, yl=  60, k-yl=0.5, sptl(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=60.75, yu=  62, k-yu=-1.25, sptu(8:-1:1)=[ 0  1  0  0  0  0 -1  0 ], ndigits=2
k=60.75, yl=  60, k-yl=0.75, sptl(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=  61, yu=  62, k-yu=-1, sptu(8:-1:1)=[ 0  1  0  0  0  0 -1  0 ], ndigits=2
k=  61, yl=  60, k-yl= 1, sptl(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=61.25, yu=  62, k-yu=-0.75, sptu(8:-1:1)=[ 0  1  0  0  0  0 -1  0 ], ndigits=2
k=61.25, yl=  60, k-yl=1.25, sptl(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=61.5, yu=  62, k-yu=-0.5, sptu(8:-1:1)=[ 0  1  0  0  0  0 -1  0 ], ndigits=2
k=61.5, yl=  60, k-yl=1.5, sptl(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=61.75, yu=  62, k-yu=-0.25, sptu(8:-1:1)=[ 0  1  0  0  0  0 -1  0 ], ndigits=2
k=61.75, yl=  60, k-yl=1.75, sptl(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=  62, yu=  62, k-yu= 0, sptu(8:-1:1)=[ 0  1  0  0  0  0 -1  0 ], ndigits=2
k=  62, yl=  62, k-yl= 0, sptl(8:-1:1)=[ 0  1  0  0  0  0 -1  0 ], ndigits=2
k=62.25, yu=  63, k-yu=-0.75, sptu(8:-1:1)=[ 0  1  0  0  0  0  0 -1 ], ndigits=2
k=62.25, yl=  62, k-yl=0.25, sptl(8:-1:1)=[ 0  1  0  0  0  0 -1  0 ], ndigits=2
k=62.5, yu=  63, k-yu=-0.5, sptu(8:-1:1)=[ 0  1  0  0  0  0  0 -1 ], ndigits=2
k=62.5, yl=  62, k-yl=0.5, sptl(8:-1:1)=[ 0  1  0  0  0  0 -1  0 ], ndigits=2
k=62.75, yu=  63, k-yu=-0.25, sptu(8:-1:1)=[ 0  1  0  0  0  0  0 -1 ], ndigits=2
k=62.75, yl=  62, k-yl=0.75, sptl(8:-1:1)=[ 0  1  0  0  0  0 -1  0 ], ndigits=2
k=  63, yu=  63, k-yu= 0, sptu(8:-1:1)=[ 0  1  0  0  0  0  0 -1 ], ndigits=2
k=  63, yl=  63, k-yl= 0, sptl(8:-1:1)=[ 0  1  0  0  0  0  0 -1 ], ndigits=2
k=63.25, yu=  64, k-yu=-0.75, sptu(8:-1:1)=[ 0  1  0  0  0  0  0  0 ], ndigits=1
k=63.25, yl=  63, k-yl=0.25, sptl(8:-1:1)=[ 0  1  0  0  0  0  0 -1 ], ndigits=2
k=63.5, yu=  64, k-yu=-0.5, sptu(8:-1:1)=[ 0  1  0  0  0  0  0  0 ], ndigits=1
k=63.5, yl=  63, k-yl=0.5, sptl(8:-1:1)=[ 0  1  0  0  0  0  0 -1 ], ndigits=2
k=63.75, yu=  64, k-yu=-0.25, sptu(8:-1:1)=[ 0  1  0  0  0  0  0  0 ], ndigits=1
k=63.75, yl=  63, k-yl=0.75, sptl(8:-1:1)=[ 0  1  0  0  0  0  0 -1 ], ndigits=2
k=  64, yu=  64, k-yu= 0, sptu(8:-1:1)=[ 0  1  0  0  0  0  0  0 ], ndigits=1
k=  64, yl=  64, k-yl= 0, sptl(8:-1:1)=[ 0  1  0  0  0  0  0  0 ], ndigits=1
k=64.25, yu=  65, k-yu=-0.75, sptu(8:-1:1)=[ 0  1  0  0  0  0  0  1 ], ndigits=2
k=64.25, yl=  64, k-yl=0.25, sptl(8:-1:1)=[ 0  1  0  0  0  0  0  0 ], ndigits=1
k=64.5, yu=  65, k-yu=-0.5, sptu(8:-1:1)=[ 0  1  0  0  0  0  0  1 ], ndigits=2
k=64.5, yl=  64, k-yl=0.5, sptl(8:-1:1)=[ 0  1  0  0  0  0  0  0 ], ndigits=1
k=64.75, yu=  65, k-yu=-0.25, sptu(8:-1:1)=[ 0  1  0  0  0  0  0  1 ], ndigits=2
k=64.75, yl=  64, k-yl=0.75, sptl(8:-1:1)=[ 0  1  0  0  0  0  0  0 ], ndigits=1
k=  65, yu=  65, k-yu= 0, sptu(8:-1:1)=[ 0  1  0  0  0  0  0  1 ], ndigits=2
k=  65, yl=  65, k-yl= 0, sptl(8:-1:1)=[ 0  1  0  0  0  0  0  1 ], ndigits=2
k=65.25, yu=  66, k-yu=-0.75, sptu(8:-1:1)=[ 0  1  0  0  0  0  1  0 ], ndigits=2
k=65.25, yl=  65, k-yl=0.25, sptl(8:-1:1)=[ 0  1  0  0  0  0  0  1 ], ndigits=2
k=65.5, yu=  66, k-yu=-0.5, sptu(8:-1:1)=[ 0  1  0  0  0  0  1  0 ], ndigits=2
k=65.5, yl=  65, k-yl=0.5, sptl(8:-1:1)=[ 0  1  0  0  0  0  0  1 ], ndigits=2
k=65.75, yu=  66, k-yu=-0.25, sptu(8:-1:1)=[ 0  1  0  0  0  0  1  0 ], ndigits=2
k=65.75, yl=  65, k-yl=0.75, sptl(8:-1:1)=[ 0  1  0  0  0  0  0  1 ], ndigits=2
k=  66, yu=  66, k-yu= 0, sptu(8:-1:1)=[ 0  1  0  0  0  0  1  0 ], ndigits=2
k=  66, yl=  66, k-yl= 0, sptl(8:-1:1)=[ 0  1  0  0  0  0  1  0 ], ndigits=2
k=66.25, yu=  68, k-yu=-1.75, sptu(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=66.25, yl=  66, k-yl=0.25, sptl(8:-1:1)=[ 0  1  0  0  0  0  1  0 ], ndigits=2
k=66.5, yu=  68, k-yu=-1.5, sptu(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=66.5, yl=  66, k-yl=0.5, sptl(8:-1:1)=[ 0  1  0  0  0  0  1  0 ], ndigits=2
k=66.75, yu=  68, k-yu=-1.25, sptu(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=66.75, yl=  66, k-yl=0.75, sptl(8:-1:1)=[ 0  1  0  0  0  0  1  0 ], ndigits=2
k=  67, yu=  68, k-yu=-1, sptu(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=  67, yl=  66, k-yl= 1, sptl(8:-1:1)=[ 0  1  0  0  0  0  1  0 ], ndigits=2
k=67.25, yu=  68, k-yu=-0.75, sptu(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=67.25, yl=  66, k-yl=1.25, sptl(8:-1:1)=[ 0  1  0  0  0  0  1  0 ], ndigits=2
k=67.5, yu=  68, k-yu=-0.5, sptu(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=67.5, yl=  66, k-yl=1.5, sptl(8:-1:1)=[ 0  1  0  0  0  0  1  0 ], ndigits=2
k=67.75, yu=  68, k-yu=-0.25, sptu(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=67.75, yl=  66, k-yl=1.75, sptl(8:-1:1)=[ 0  1  0  0  0  0  1  0 ], ndigits=2
k=  68, yu=  68, k-yu= 0, sptu(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=  68, yl=  68, k-yl= 0, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=68.25, yu=  72, k-yu=-3.75, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=68.25, yl=  68, k-yl=0.25, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=68.5, yu=  72, k-yu=-3.5, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=68.5, yl=  68, k-yl=0.5, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=68.75, yu=  72, k-yu=-3.25, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=68.75, yl=  68, k-yl=0.75, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=  69, yu=  72, k-yu=-3, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  69, yl=  68, k-yl= 1, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=69.25, yu=  72, k-yu=-2.75, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=69.25, yl=  68, k-yl=1.25, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=69.5, yu=  72, k-yu=-2.5, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=69.5, yl=  68, k-yl=1.5, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=69.75, yu=  72, k-yu=-2.25, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=69.75, yl=  68, k-yl=1.75, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=  70, yu=  72, k-yu=-2, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  70, yl=  68, k-yl= 2, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=70.25, yu=  72, k-yu=-1.75, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=70.25, yl=  68, k-yl=2.25, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=70.5, yu=  72, k-yu=-1.5, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=70.5, yl=  68, k-yl=2.5, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=70.75, yu=  72, k-yu=-1.25, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=70.75, yl=  68, k-yl=2.75, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=  71, yu=  72, k-yu=-1, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  71, yl=  68, k-yl= 3, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=71.25, yu=  72, k-yu=-0.75, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=71.25, yl=  68, k-yl=3.25, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=71.5, yu=  72, k-yu=-0.5, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=71.5, yl=  68, k-yl=3.5, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=71.75, yu=  72, k-yu=-0.25, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=71.75, yl=  68, k-yl=3.75, sptl(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=  72, yu=  72, k-yu= 0, sptu(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  72, yl=  72, k-yl= 0, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=72.25, yu=  80, k-yu=-7.75, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=72.25, yl=  72, k-yl=0.25, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=72.5, yu=  80, k-yu=-7.5, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=72.5, yl=  72, k-yl=0.5, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=72.75, yu=  80, k-yu=-7.25, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=72.75, yl=  72, k-yl=0.75, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  73, yu=  80, k-yu=-7, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  73, yl=  72, k-yl= 1, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=73.25, yu=  80, k-yu=-6.75, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=73.25, yl=  72, k-yl=1.25, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=73.5, yu=  80, k-yu=-6.5, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=73.5, yl=  72, k-yl=1.5, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=73.75, yu=  80, k-yu=-6.25, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=73.75, yl=  72, k-yl=1.75, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  74, yu=  80, k-yu=-6, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  74, yl=  72, k-yl= 2, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=74.25, yu=  80, k-yu=-5.75, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=74.25, yl=  72, k-yl=2.25, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=74.5, yu=  80, k-yu=-5.5, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=74.5, yl=  72, k-yl=2.5, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=74.75, yu=  80, k-yu=-5.25, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=74.75, yl=  72, k-yl=2.75, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  75, yu=  80, k-yu=-5, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  75, yl=  72, k-yl= 3, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=75.25, yu=  80, k-yu=-4.75, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=75.25, yl=  72, k-yl=3.25, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=75.5, yu=  80, k-yu=-4.5, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=75.5, yl=  72, k-yl=3.5, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=75.75, yu=  80, k-yu=-4.25, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=75.75, yl=  72, k-yl=3.75, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  76, yu=  80, k-yu=-4, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  76, yl=  72, k-yl= 4, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=76.25, yu=  80, k-yu=-3.75, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=76.25, yl=  72, k-yl=4.25, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=76.5, yu=  80, k-yu=-3.5, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=76.5, yl=  72, k-yl=4.5, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=76.75, yu=  80, k-yu=-3.25, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=76.75, yl=  72, k-yl=4.75, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  77, yu=  80, k-yu=-3, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  77, yl=  72, k-yl= 5, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=77.25, yu=  80, k-yu=-2.75, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=77.25, yl=  72, k-yl=5.25, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=77.5, yu=  80, k-yu=-2.5, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=77.5, yl=  72, k-yl=5.5, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=77.75, yu=  80, k-yu=-2.25, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=77.75, yl=  72, k-yl=5.75, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  78, yu=  80, k-yu=-2, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  78, yl=  72, k-yl= 6, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=78.25, yu=  80, k-yu=-1.75, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=78.25, yl=  72, k-yl=6.25, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=78.5, yu=  80, k-yu=-1.5, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=78.5, yl=  72, k-yl=6.5, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=78.75, yu=  80, k-yu=-1.25, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=78.75, yl=  72, k-yl=6.75, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  79, yu=  80, k-yu=-1, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  79, yl=  72, k-yl= 7, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=79.25, yu=  80, k-yu=-0.75, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=79.25, yl=  72, k-yl=7.25, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=79.5, yu=  80, k-yu=-0.5, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=79.5, yl=  72, k-yl=7.5, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=79.75, yu=  80, k-yu=-0.25, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=79.75, yl=  72, k-yl=7.75, sptl(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  80, yu=  80, k-yu= 0, sptu(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  80, yl=  80, k-yl= 0, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=80.25, yu=  96, k-yu=-15.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=80.25, yl=  80, k-yl=0.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=80.5, yu=  96, k-yu=-15.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=80.5, yl=  80, k-yl=0.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=80.75, yu=  96, k-yu=-15.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=80.75, yl=  80, k-yl=0.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  81, yu=  96, k-yu=-15, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  81, yl=  80, k-yl= 1, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=81.25, yu=  96, k-yu=-14.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=81.25, yl=  80, k-yl=1.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=81.5, yu=  96, k-yu=-14.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=81.5, yl=  80, k-yl=1.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=81.75, yu=  96, k-yu=-14.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=81.75, yl=  80, k-yl=1.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  82, yu=  96, k-yu=-14, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  82, yl=  80, k-yl= 2, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=82.25, yu=  96, k-yu=-13.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=82.25, yl=  80, k-yl=2.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=82.5, yu=  96, k-yu=-13.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=82.5, yl=  80, k-yl=2.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=82.75, yu=  96, k-yu=-13.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=82.75, yl=  80, k-yl=2.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  83, yu=  96, k-yu=-13, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  83, yl=  80, k-yl= 3, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=83.25, yu=  96, k-yu=-12.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=83.25, yl=  80, k-yl=3.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=83.5, yu=  96, k-yu=-12.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=83.5, yl=  80, k-yl=3.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=83.75, yu=  96, k-yu=-12.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=83.75, yl=  80, k-yl=3.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  84, yu=  96, k-yu=-12, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  84, yl=  80, k-yl= 4, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=84.25, yu=  96, k-yu=-11.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=84.25, yl=  80, k-yl=4.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=84.5, yu=  96, k-yu=-11.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=84.5, yl=  80, k-yl=4.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=84.75, yu=  96, k-yu=-11.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=84.75, yl=  80, k-yl=4.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  85, yu=  96, k-yu=-11, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  85, yl=  80, k-yl= 5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=85.25, yu=  96, k-yu=-10.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=85.25, yl=  80, k-yl=5.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=85.5, yu=  96, k-yu=-10.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=85.5, yl=  80, k-yl=5.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=85.75, yu=  96, k-yu=-10.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=85.75, yl=  80, k-yl=5.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  86, yu=  96, k-yu=-10, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  86, yl=  80, k-yl= 6, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=86.25, yu=  96, k-yu=-9.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=86.25, yl=  80, k-yl=6.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=86.5, yu=  96, k-yu=-9.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=86.5, yl=  80, k-yl=6.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=86.75, yu=  96, k-yu=-9.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=86.75, yl=  80, k-yl=6.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  87, yu=  96, k-yu=-9, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  87, yl=  80, k-yl= 7, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=87.25, yu=  96, k-yu=-8.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=87.25, yl=  80, k-yl=7.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=87.5, yu=  96, k-yu=-8.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=87.5, yl=  80, k-yl=7.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=87.75, yu=  96, k-yu=-8.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=87.75, yl=  80, k-yl=7.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  88, yu=  96, k-yu=-8, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  88, yl=  80, k-yl= 8, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=88.25, yu=  96, k-yu=-7.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=88.25, yl=  80, k-yl=8.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=88.5, yu=  96, k-yu=-7.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=88.5, yl=  80, k-yl=8.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=88.75, yu=  96, k-yu=-7.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=88.75, yl=  80, k-yl=8.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  89, yu=  96, k-yu=-7, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  89, yl=  80, k-yl= 9, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=89.25, yu=  96, k-yu=-6.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=89.25, yl=  80, k-yl=9.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=89.5, yu=  96, k-yu=-6.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=89.5, yl=  80, k-yl=9.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=89.75, yu=  96, k-yu=-6.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=89.75, yl=  80, k-yl=9.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  90, yu=  96, k-yu=-6, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  90, yl=  80, k-yl=10, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=90.25, yu=  96, k-yu=-5.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=90.25, yl=  80, k-yl=10.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=90.5, yu=  96, k-yu=-5.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=90.5, yl=  80, k-yl=10.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=90.75, yu=  96, k-yu=-5.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=90.75, yl=  80, k-yl=10.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  91, yu=  96, k-yu=-5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  91, yl=  80, k-yl=11, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=91.25, yu=  96, k-yu=-4.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=91.25, yl=  80, k-yl=11.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=91.5, yu=  96, k-yu=-4.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=91.5, yl=  80, k-yl=11.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=91.75, yu=  96, k-yu=-4.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=91.75, yl=  80, k-yl=11.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  92, yu=  96, k-yu=-4, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  92, yl=  80, k-yl=12, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=92.25, yu=  96, k-yu=-3.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=92.25, yl=  80, k-yl=12.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=92.5, yu=  96, k-yu=-3.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=92.5, yl=  80, k-yl=12.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=92.75, yu=  96, k-yu=-3.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=92.75, yl=  80, k-yl=12.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  93, yu=  96, k-yu=-3, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  93, yl=  80, k-yl=13, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=93.25, yu=  96, k-yu=-2.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=93.25, yl=  80, k-yl=13.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=93.5, yu=  96, k-yu=-2.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=93.5, yl=  80, k-yl=13.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=93.75, yu=  96, k-yu=-2.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=93.75, yl=  80, k-yl=13.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  94, yu=  96, k-yu=-2, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  94, yl=  80, k-yl=14, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=94.25, yu=  96, k-yu=-1.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=94.25, yl=  80, k-yl=14.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=94.5, yu=  96, k-yu=-1.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=94.5, yl=  80, k-yl=14.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=94.75, yu=  96, k-yu=-1.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=94.75, yl=  80, k-yl=14.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  95, yu=  96, k-yu=-1, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  95, yl=  80, k-yl=15, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=95.25, yu=  96, k-yu=-0.75, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=95.25, yl=  80, k-yl=15.25, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=95.5, yu=  96, k-yu=-0.5, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=95.5, yl=  80, k-yl=15.5, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=95.75, yu=  96, k-yu=-0.25, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=95.75, yl=  80, k-yl=15.75, sptl(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  96, yu=  96, k-yu= 0, sptu(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  96, yl=  96, k-yl= 0, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=96.25, yu= 112, k-yu=-15.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=96.25, yl=  96, k-yl=0.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=96.5, yu= 112, k-yu=-15.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=96.5, yl=  96, k-yl=0.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=96.75, yu= 112, k-yu=-15.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=96.75, yl=  96, k-yl=0.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  97, yu= 112, k-yu=-15, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=  97, yl=  96, k-yl= 1, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=97.25, yu= 112, k-yu=-14.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=97.25, yl=  96, k-yl=1.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=97.5, yu= 112, k-yu=-14.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=97.5, yl=  96, k-yl=1.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=97.75, yu= 112, k-yu=-14.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=97.75, yl=  96, k-yl=1.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  98, yu= 112, k-yu=-14, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=  98, yl=  96, k-yl= 2, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=98.25, yu= 112, k-yu=-13.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=98.25, yl=  96, k-yl=2.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=98.5, yu= 112, k-yu=-13.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=98.5, yl=  96, k-yl=2.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=98.75, yu= 112, k-yu=-13.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=98.75, yl=  96, k-yl=2.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  99, yu= 112, k-yu=-13, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=  99, yl=  96, k-yl= 3, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=99.25, yu= 112, k-yu=-12.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=99.25, yl=  96, k-yl=3.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=99.5, yu= 112, k-yu=-12.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=99.5, yl=  96, k-yl=3.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=99.75, yu= 112, k-yu=-12.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=99.75, yl=  96, k-yl=3.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 100, yu= 112, k-yu=-12, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 100, yl=  96, k-yl= 4, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=100.25, yu= 112, k-yu=-11.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=100.25, yl=  96, k-yl=4.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=100.5, yu= 112, k-yu=-11.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=100.5, yl=  96, k-yl=4.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=100.75, yu= 112, k-yu=-11.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=100.75, yl=  96, k-yl=4.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 101, yu= 112, k-yu=-11, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 101, yl=  96, k-yl= 5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=101.25, yu= 112, k-yu=-10.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=101.25, yl=  96, k-yl=5.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=101.5, yu= 112, k-yu=-10.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=101.5, yl=  96, k-yl=5.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=101.75, yu= 112, k-yu=-10.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=101.75, yl=  96, k-yl=5.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 102, yu= 112, k-yu=-10, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 102, yl=  96, k-yl= 6, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=102.25, yu= 112, k-yu=-9.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=102.25, yl=  96, k-yl=6.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=102.5, yu= 112, k-yu=-9.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=102.5, yl=  96, k-yl=6.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=102.75, yu= 112, k-yu=-9.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=102.75, yl=  96, k-yl=6.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 103, yu= 112, k-yu=-9, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 103, yl=  96, k-yl= 7, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=103.25, yu= 112, k-yu=-8.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=103.25, yl=  96, k-yl=7.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=103.5, yu= 112, k-yu=-8.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=103.5, yl=  96, k-yl=7.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=103.75, yu= 112, k-yu=-8.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=103.75, yl=  96, k-yl=7.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 104, yu= 112, k-yu=-8, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 104, yl=  96, k-yl= 8, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=104.25, yu= 112, k-yu=-7.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=104.25, yl=  96, k-yl=8.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=104.5, yu= 112, k-yu=-7.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=104.5, yl=  96, k-yl=8.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=104.75, yu= 112, k-yu=-7.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=104.75, yl=  96, k-yl=8.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 105, yu= 112, k-yu=-7, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 105, yl=  96, k-yl= 9, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=105.25, yu= 112, k-yu=-6.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=105.25, yl=  96, k-yl=9.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=105.5, yu= 112, k-yu=-6.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=105.5, yl=  96, k-yl=9.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=105.75, yu= 112, k-yu=-6.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=105.75, yl=  96, k-yl=9.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 106, yu= 112, k-yu=-6, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 106, yl=  96, k-yl=10, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=106.25, yu= 112, k-yu=-5.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=106.25, yl=  96, k-yl=10.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=106.5, yu= 112, k-yu=-5.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=106.5, yl=  96, k-yl=10.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=106.75, yu= 112, k-yu=-5.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=106.75, yl=  96, k-yl=10.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 107, yu= 112, k-yu=-5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 107, yl=  96, k-yl=11, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=107.25, yu= 112, k-yu=-4.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=107.25, yl=  96, k-yl=11.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=107.5, yu= 112, k-yu=-4.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=107.5, yl=  96, k-yl=11.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=107.75, yu= 112, k-yu=-4.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=107.75, yl=  96, k-yl=11.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 108, yu= 112, k-yu=-4, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 108, yl=  96, k-yl=12, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=108.25, yu= 112, k-yu=-3.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=108.25, yl=  96, k-yl=12.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=108.5, yu= 112, k-yu=-3.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=108.5, yl=  96, k-yl=12.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=108.75, yu= 112, k-yu=-3.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=108.75, yl=  96, k-yl=12.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 109, yu= 112, k-yu=-3, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 109, yl=  96, k-yl=13, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=109.25, yu= 112, k-yu=-2.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=109.25, yl=  96, k-yl=13.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=109.5, yu= 112, k-yu=-2.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=109.5, yl=  96, k-yl=13.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=109.75, yu= 112, k-yu=-2.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=109.75, yl=  96, k-yl=13.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 110, yu= 112, k-yu=-2, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 110, yl=  96, k-yl=14, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=110.25, yu= 112, k-yu=-1.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=110.25, yl=  96, k-yl=14.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=110.5, yu= 112, k-yu=-1.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=110.5, yl=  96, k-yl=14.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=110.75, yu= 112, k-yu=-1.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=110.75, yl=  96, k-yl=14.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 111, yu= 112, k-yu=-1, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 111, yl=  96, k-yl=15, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=111.25, yu= 112, k-yu=-0.75, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=111.25, yl=  96, k-yl=15.25, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=111.5, yu= 112, k-yu=-0.5, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=111.5, yl=  96, k-yl=15.5, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=111.75, yu= 112, k-yu=-0.25, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=111.75, yl=  96, k-yl=15.75, sptl(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 112, yu= 112, k-yu= 0, sptu(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 112, yl= 112, k-yl= 0, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=112.25, yu= 120, k-yu=-7.75, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=112.25, yl= 112, k-yl=0.25, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=112.5, yu= 120, k-yu=-7.5, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=112.5, yl= 112, k-yl=0.5, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=112.75, yu= 120, k-yu=-7.25, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=112.75, yl= 112, k-yl=0.75, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 113, yu= 120, k-yu=-7, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 113, yl= 112, k-yl= 1, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=113.25, yu= 120, k-yu=-6.75, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=113.25, yl= 112, k-yl=1.25, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=113.5, yu= 120, k-yu=-6.5, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=113.5, yl= 112, k-yl=1.5, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=113.75, yu= 120, k-yu=-6.25, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=113.75, yl= 112, k-yl=1.75, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 114, yu= 120, k-yu=-6, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 114, yl= 112, k-yl= 2, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=114.25, yu= 120, k-yu=-5.75, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=114.25, yl= 112, k-yl=2.25, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=114.5, yu= 120, k-yu=-5.5, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=114.5, yl= 112, k-yl=2.5, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=114.75, yu= 120, k-yu=-5.25, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=114.75, yl= 112, k-yl=2.75, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 115, yu= 120, k-yu=-5, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 115, yl= 112, k-yl= 3, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=115.25, yu= 120, k-yu=-4.75, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=115.25, yl= 112, k-yl=3.25, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=115.5, yu= 120, k-yu=-4.5, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=115.5, yl= 112, k-yl=3.5, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=115.75, yu= 120, k-yu=-4.25, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=115.75, yl= 112, k-yl=3.75, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 116, yu= 120, k-yu=-4, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 116, yl= 112, k-yl= 4, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=116.25, yu= 120, k-yu=-3.75, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=116.25, yl= 112, k-yl=4.25, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=116.5, yu= 120, k-yu=-3.5, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=116.5, yl= 112, k-yl=4.5, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=116.75, yu= 120, k-yu=-3.25, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=116.75, yl= 112, k-yl=4.75, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 117, yu= 120, k-yu=-3, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 117, yl= 112, k-yl= 5, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=117.25, yu= 120, k-yu=-2.75, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=117.25, yl= 112, k-yl=5.25, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=117.5, yu= 120, k-yu=-2.5, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=117.5, yl= 112, k-yl=5.5, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=117.75, yu= 120, k-yu=-2.25, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=117.75, yl= 112, k-yl=5.75, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 118, yu= 120, k-yu=-2, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 118, yl= 112, k-yl= 6, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=118.25, yu= 120, k-yu=-1.75, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=118.25, yl= 112, k-yl=6.25, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=118.5, yu= 120, k-yu=-1.5, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=118.5, yl= 112, k-yl=6.5, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=118.75, yu= 120, k-yu=-1.25, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=118.75, yl= 112, k-yl=6.75, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 119, yu= 120, k-yu=-1, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 119, yl= 112, k-yl= 7, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=119.25, yu= 120, k-yu=-0.75, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=119.25, yl= 112, k-yl=7.25, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=119.5, yu= 120, k-yu=-0.5, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=119.5, yl= 112, k-yl=7.5, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k=119.75, yu= 120, k-yu=-0.25, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=119.75, yl= 112, k-yl=7.75, sptl(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 120, yu= 120, k-yu= 0, sptu(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 120, yl= 120, k-yl= 0, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=120.25, yu= 124, k-yu=-3.75, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=120.25, yl= 120, k-yl=0.25, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=120.5, yu= 124, k-yu=-3.5, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=120.5, yl= 120, k-yl=0.5, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=120.75, yu= 124, k-yu=-3.25, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=120.75, yl= 120, k-yl=0.75, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 121, yu= 124, k-yu=-3, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k= 121, yl= 120, k-yl= 1, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=121.25, yu= 124, k-yu=-2.75, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=121.25, yl= 120, k-yl=1.25, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=121.5, yu= 124, k-yu=-2.5, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=121.5, yl= 120, k-yl=1.5, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=121.75, yu= 124, k-yu=-2.25, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=121.75, yl= 120, k-yl=1.75, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 122, yu= 124, k-yu=-2, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k= 122, yl= 120, k-yl= 2, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=122.25, yu= 124, k-yu=-1.75, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=122.25, yl= 120, k-yl=2.25, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=122.5, yu= 124, k-yu=-1.5, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=122.5, yl= 120, k-yl=2.5, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=122.75, yu= 124, k-yu=-1.25, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=122.75, yl= 120, k-yl=2.75, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 123, yu= 124, k-yu=-1, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k= 123, yl= 120, k-yl= 3, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=123.25, yu= 124, k-yu=-0.75, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=123.25, yl= 120, k-yl=3.25, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=123.5, yu= 124, k-yu=-0.5, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=123.5, yl= 120, k-yl=3.5, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k=123.75, yu= 124, k-yu=-0.25, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=123.75, yl= 120, k-yl=3.75, sptl(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 124, yu= 124, k-yu= 0, sptu(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k= 124, yl= 124, k-yl= 0, sptl(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=124.25, yu= 126, k-yu=-1.75, sptu(8:-1:1)=[ 1  0  0  0  0  0 -1  0 ], ndigits=2
k=124.25, yl= 124, k-yl=0.25, sptl(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=124.5, yu= 126, k-yu=-1.5, sptu(8:-1:1)=[ 1  0  0  0  0  0 -1  0 ], ndigits=2
k=124.5, yl= 124, k-yl=0.5, sptl(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=124.75, yu= 126, k-yu=-1.25, sptu(8:-1:1)=[ 1  0  0  0  0  0 -1  0 ], ndigits=2
k=124.75, yl= 124, k-yl=0.75, sptl(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k= 125, yu= 126, k-yu=-1, sptu(8:-1:1)=[ 1  0  0  0  0  0 -1  0 ], ndigits=2
k= 125, yl= 124, k-yl= 1, sptl(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=125.25, yu= 126, k-yu=-0.75, sptu(8:-1:1)=[ 1  0  0  0  0  0 -1  0 ], ndigits=2
k=125.25, yl= 124, k-yl=1.25, sptl(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=125.5, yu= 126, k-yu=-0.5, sptu(8:-1:1)=[ 1  0  0  0  0  0 -1  0 ], ndigits=2
k=125.5, yl= 124, k-yl=1.5, sptl(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k=125.75, yu= 126, k-yu=-0.25, sptu(8:-1:1)=[ 1  0  0  0  0  0 -1  0 ], ndigits=2
k=125.75, yl= 124, k-yl=1.75, sptl(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k= 126, yu= 126, k-yu= 0, sptu(8:-1:1)=[ 1  0  0  0  0  0 -1  0 ], ndigits=2
k= 126, yl= 126, k-yl= 0, sptl(8:-1:1)=[ 1  0  0  0  0  0 -1  0 ], ndigits=2
k=126.25, yu= 127, k-yu=-0.75, sptu(8:-1:1)=[ 1  0  0  0  0  0  0 -1 ], ndigits=2
k=126.25, yl= 126, k-yl=0.25, sptl(8:-1:1)=[ 1  0  0  0  0  0 -1  0 ], ndigits=2
k=126.5, yu= 127, k-yu=-0.5, sptu(8:-1:1)=[ 1  0  0  0  0  0  0 -1 ], ndigits=2
k=126.5, yl= 126, k-yl=0.5, sptl(8:-1:1)=[ 1  0  0  0  0  0 -1  0 ], ndigits=2
k=126.75, yu= 127, k-yu=-0.25, sptu(8:-1:1)=[ 1  0  0  0  0  0  0 -1 ], ndigits=2
k=126.75, yl= 126, k-yl=0.75, sptl(8:-1:1)=[ 1  0  0  0  0  0 -1  0 ], ndigits=2
k= 127, yu= 127, k-yu= 0, sptu(8:-1:1)=[ 1  0  0  0  0  0  0 -1 ], ndigits=2
k= 127, yl= 127, k-yl= 0, sptl(8:-1:1)=[ 1  0  0  0  0  0  0 -1 ], ndigits=2
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

