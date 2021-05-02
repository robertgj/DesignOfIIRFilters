#!/bin/sh

prog=bin2SD_test.m

descr="bin2SD_test.m (octfile)"

depends="bin2SD_test.m test_common.m check_octave_file.m bin2SD.oct bin2SPT.oct"

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
Using bin2SD octfile
Caught sd=bin2SD([6:7],4,1): x is not a scalar
Caught y=bin2SD(1,51,52): Expected 0<=ndigits(52)<=nbits(51)
Caught y=bin2SD(1,52,51): Expected 0<nbits(52)<=51
Caught y=bin2SD(1,8,9): Expected 0<=ndigits(9)<=nbits(8)
x=     1, y=0, spt(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
Caught y=bin2SD(1,8,-1): Expected 0<=ndigits(-1)<=nbits(8)
Caught y=bin2SD(1,0,8): Expected 0<nbits(0)<=51
Caught y=bin2SD(1,0,0): Expected 0<nbits(0)<=51
x=     0, y=0, spt(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=     0, y=0, spt(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=     0, y=0, spt(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=     0, y=0, spt(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
x=     0, y=0, spt(1:-1:1)=[  0 ], ndigits=0
Caught y=bin2SD(1,1,1): x=1,round(x)=1 is out of range for a 1 bits 2s complement number!
Caught y=bin2SD(2,1,1): x=2,round(x)=2 is out of range for a 1 bits 2s complement number!
x=    -1, y=-1, spt(1:-1:1)=[ -1 ], ndigits=1
x=     0, y=0, spt(2:-1:1)=[  0  0 ], ndigits=0
x=     1, y=1, spt(2:-1:1)=[  0  1 ], ndigits=1
x=    -1, y=-1, spt(2:-1:1)=[  0 -1 ], ndigits=1
x=    -2, y=-2, spt(2:-1:1)=[ -1  0 ], ndigits=1
x=     1, y=1, spt(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=     1, y=1, spt(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=     1, y=1, spt(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=     1, y=1, spt(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
x=    -1, y=-1, spt(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=    -1, y=-1, spt(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=    -1, y=-1, spt(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=    -1, y=-1, spt(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
x=   1.5, y=2, spt(8:-1:1)=[  0  0  0  0  0  0  1  0 ], ndigits=1
x=  -1.5, y=-2, spt(8:-1:1)=[  0  0  0  0  0  0 -1  0 ], ndigits=1
x=   1.5, y=2, spt(8:-1:1)=[  0  0  0  0  0  0  1  0 ], ndigits=1
x=  -1.5, y=-2, spt(8:-1:1)=[  0  0  0  0  0  0 -1  0 ], ndigits=1
x=   1.5, y=2, spt(8:-1:1)=[  0  0  0  0  0  0  1  0 ], ndigits=1
x=  -1.5, y=-2, spt(8:-1:1)=[  0  0  0  0  0  0 -1  0 ], ndigits=1
x=   -43, y=-32, spt(7:-1:1)=[  0 -1  0  0  0  0  0 ], ndigits=1
x=   -43, y=-40, spt(7:-1:1)=[  0 -1  0 -1  0  0  0 ], ndigits=2
x=   -43, y=-44, spt(7:-1:1)=[ -1  0  1  0  1  0  0 ], ndigits=3
x=   -43, y=-43, spt(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x=   -43, y=-43, spt(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x=    43, y=32, spt(7:-1:1)=[  0  1  0  0  0  0  0 ], ndigits=1
x=    43, y=40, spt(7:-1:1)=[  0  1  0  1  0  0  0 ], ndigits=2
x=    43, y=44, spt(7:-1:1)=[  1  0 -1  0 -1  0  0 ], ndigits=3
x=    43, y=43, spt(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x=    43, y=43, spt(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x= -43.4, y=-32, spt(7:-1:1)=[  0 -1  0  0  0  0  0 ], ndigits=1
x= -43.4, y=-40, spt(7:-1:1)=[  0 -1  0 -1  0  0  0 ], ndigits=2
x= -43.4, y=-44, spt(7:-1:1)=[ -1  0  1  0  1  0  0 ], ndigits=3
x= -43.4, y=-43, spt(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x= -43.4, y=-43, spt(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x=  43.4, y=32, spt(7:-1:1)=[  0  1  0  0  0  0  0 ], ndigits=1
x=  43.4, y=40, spt(7:-1:1)=[  0  1  0  1  0  0  0 ], ndigits=2
x=  43.4, y=44, spt(7:-1:1)=[  1  0 -1  0 -1  0  0 ], ndigits=3
x=  43.4, y=43, spt(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x=  43.4, y=43, spt(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x= -43.6, y=-32, spt(7:-1:1)=[  0 -1  0  0  0  0  0 ], ndigits=1
x= -43.6, y=-48, spt(7:-1:1)=[ -1  0  1  0  0  0  0 ], ndigits=2
x= -43.6, y=-44, spt(7:-1:1)=[ -1  0  1  0  1  0  0 ], ndigits=3
x= -43.6, y=-44, spt(7:-1:1)=[ -1  0  1  0  1  0  0 ], ndigits=3
x= -43.6, y=-44, spt(7:-1:1)=[ -1  0  1  0  1  0  0 ], ndigits=3
x=  43.6, y=32, spt(7:-1:1)=[  0  1  0  0  0  0  0 ], ndigits=1
x=  43.6, y=48, spt(7:-1:1)=[  1  0 -1  0  0  0  0 ], ndigits=2
x=  43.6, y=44, spt(7:-1:1)=[  1  0 -1  0 -1  0  0 ], ndigits=3
x=  43.6, y=44, spt(7:-1:1)=[  1  0 -1  0 -1  0  0 ], ndigits=3
x=  43.6, y=44, spt(7:-1:1)=[  1  0 -1  0 -1  0  0 ], ndigits=3
x= -42.9, y=-32, spt(7:-1:1)=[  0 -1  0  0  0  0  0 ], ndigits=1
x= -42.9, y=-40, spt(7:-1:1)=[  0 -1  0 -1  0  0  0 ], ndigits=2
x= -42.9, y=-44, spt(7:-1:1)=[ -1  0  1  0  1  0  0 ], ndigits=3
x= -42.9, y=-43, spt(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x= -42.9, y=-43, spt(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
x=  42.9, y=32, spt(7:-1:1)=[  0  1  0  0  0  0  0 ], ndigits=1
x=  42.9, y=40, spt(7:-1:1)=[  0  1  0  1  0  0  0 ], ndigits=2
x=  42.9, y=44, spt(7:-1:1)=[  1  0 -1  0 -1  0  0 ], ndigits=3
x=  42.9, y=43, spt(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x=  42.9, y=43, spt(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
x=   141, y=141, spt(9:-1:1)=[  0  1  0  0  1  0 -1  0  1 ], ndigits=4
x=  -141, y=-141, spt(9:-1:1)=[  0 -1  0  0 -1  0  1  0 -1 ], ndigits=4
x=   170, y=128, spt(9:-1:1)=[  0  1  0  0  0  0  0  0  0 ], ndigits=1
x=   170, y=160, spt(9:-1:1)=[  0  1  0  1  0  0  0  0  0 ], ndigits=2
x=   170, y=168, spt(9:-1:1)=[  0  1  0  1  0  1  0  0  0 ], ndigits=3
x=   170, y=170, spt(9:-1:1)=[  0  1  0  1  0  1  0  1  0 ], ndigits=4
x=   170, y=170, spt(9:-1:1)=[  0  1  0  1  0  1  0  1  0 ], ndigits=4
x=  -170, y=-128, spt(9:-1:1)=[  0 -1  0  0  0  0  0  0  0 ], ndigits=1
x=  -170, y=-160, spt(9:-1:1)=[  0 -1  0 -1  0  0  0  0  0 ], ndigits=2
x=  -170, y=-168, spt(9:-1:1)=[  0 -1  0 -1  0 -1  0  0  0 ], ndigits=3
x=  -170, y=-170, spt(9:-1:1)=[  0 -1  0 -1  0 -1  0 -1  0 ], ndigits=4
x=  -170, y=-170, spt(9:-1:1)=[  0 -1  0 -1  0 -1  0 -1  0 ], ndigits=4
Caught y=bin2SD(128,8,1): x=128,round(x)=128 is out of range for a 8 bits 2s complement number!
x=   128, y=128, spt(9:-1:1)=[  0  1  0  0  0  0  0  0  0 ], ndigits=1
x=  -128, y=-128, spt(8:-1:1)=[ -1  0  0  0  0  0  0  0 ], ndigits=1
x=   127, y=128, spt(8:-1:1)=[  1  0  0  0  0  0  0  0 ], ndigits=1
x=   127, y=127, spt(8:-1:1)=[  1  0  0  0  0  0  0 -1 ], ndigits=2
x=   127, y=127, spt(8:-1:1)=[  1  0  0  0  0  0  0 -1 ], ndigits=2
x=   127, y=127, spt(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0 -1 ], ndigits=2
x=   127, y=127, spt(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0 -1 ], ndigits=2
x=  -128, y=-128, spt(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0 ], ndigits=1
x=  -128, y=-128, spt(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0 ], ndigits=1
Caught y=bin2SD(128,8,2): x=128,round(x)=128 is out of range for a 8 bits 2s complement number!
Caught y=bin2SD(-129,8,2): x=-129,round(x)=-129 is out of range for a 8 bits 2s complement number!
x= 63.49, y=63, spt(7:-1:1)=[  1  0  0  0  0  0 -1 ], ndigits=2
Caught y=bin2SD(63.51,7,2): x=63.51,round(x)=64 is out of range for a 7 bits 2s complement number!
k=-128, y=-128, k-y= 0, spt(8:-1:1)=[-1  0  0  0  0  0  0  0 ], ndigits=1
k=-127, y=-127, k-y= 0, spt(8:-1:1)=[-1  0  0  0  0  0  0  1 ], ndigits=2
k=-126, y=-126, k-y= 0, spt(8:-1:1)=[-1  0  0  0  0  0  1  0 ], ndigits=2
k=-125, y=-124, k-y=-1, spt(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-124, y=-124, k-y= 0, spt(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-123, y=-124, k-y= 1, spt(8:-1:1)=[-1  0  0  0  0  1  0  0 ], ndigits=2
k=-122, y=-120, k-y=-2, spt(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-121, y=-120, k-y=-1, spt(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-120, y=-120, k-y= 0, spt(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-119, y=-120, k-y= 1, spt(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-118, y=-120, k-y= 2, spt(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-117, y=-120, k-y= 3, spt(8:-1:1)=[-1  0  0  0  1  0  0  0 ], ndigits=2
k=-116, y=-112, k-y=-4, spt(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-115, y=-112, k-y=-3, spt(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-114, y=-112, k-y=-2, spt(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-113, y=-112, k-y=-1, spt(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-112, y=-112, k-y= 0, spt(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-111, y=-112, k-y= 1, spt(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-110, y=-112, k-y= 2, spt(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-109, y=-112, k-y= 3, spt(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-108, y=-112, k-y= 4, spt(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-107, y=-112, k-y= 5, spt(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-106, y=-112, k-y= 6, spt(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-105, y=-112, k-y= 7, spt(8:-1:1)=[-1  0  0  1  0  0  0  0 ], ndigits=2
k=-104, y= -96, k-y=-8, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-103, y= -96, k-y=-7, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-102, y= -96, k-y=-6, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-101, y= -96, k-y=-5, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k=-100, y= -96, k-y=-4, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -99, y= -96, k-y=-3, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -98, y= -96, k-y=-2, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -97, y= -96, k-y=-1, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -96, y= -96, k-y= 0, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -95, y= -96, k-y= 1, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -94, y= -96, k-y= 2, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -93, y= -96, k-y= 3, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -92, y= -96, k-y= 4, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -91, y= -96, k-y= 5, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -90, y= -96, k-y= 6, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -89, y= -96, k-y= 7, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -88, y= -96, k-y= 8, spt(8:-1:1)=[-1  0  1  0  0  0  0  0 ], ndigits=2
k= -87, y= -80, k-y=-7, spt(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -86, y= -80, k-y=-6, spt(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -85, y= -80, k-y=-5, spt(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -84, y= -80, k-y=-4, spt(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -83, y= -80, k-y=-3, spt(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -82, y= -80, k-y=-2, spt(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -81, y= -80, k-y=-1, spt(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -80, y= -80, k-y= 0, spt(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -79, y= -80, k-y= 1, spt(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -78, y= -80, k-y= 2, spt(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -77, y= -80, k-y= 3, spt(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -76, y= -80, k-y= 4, spt(8:-1:1)=[ 0 -1  0 -1  0  0  0  0 ], ndigits=2
k= -75, y= -72, k-y=-3, spt(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -74, y= -72, k-y=-2, spt(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -73, y= -72, k-y=-1, spt(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -72, y= -72, k-y= 0, spt(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -71, y= -72, k-y= 1, spt(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -70, y= -72, k-y= 2, spt(8:-1:1)=[ 0 -1  0  0 -1  0  0  0 ], ndigits=2
k= -69, y= -68, k-y=-1, spt(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k= -68, y= -68, k-y= 0, spt(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k= -67, y= -68, k-y= 1, spt(8:-1:1)=[ 0 -1  0  0  0 -1  0  0 ], ndigits=2
k= -66, y= -66, k-y= 0, spt(8:-1:1)=[ 0 -1  0  0  0  0 -1  0 ], ndigits=2
k= -65, y= -65, k-y= 0, spt(8:-1:1)=[ 0 -1  0  0  0  0  0 -1 ], ndigits=2
k= -64, y= -64, k-y= 0, spt(8:-1:1)=[ 0 -1  0  0  0  0  0  0 ], ndigits=1
k= -63, y= -63, k-y= 0, spt(8:-1:1)=[ 0 -1  0  0  0  0  0  1 ], ndigits=2
k= -62, y= -62, k-y= 0, spt(8:-1:1)=[ 0 -1  0  0  0  0  1  0 ], ndigits=2
k= -61, y= -60, k-y=-1, spt(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k= -60, y= -60, k-y= 0, spt(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k= -59, y= -60, k-y= 1, spt(8:-1:1)=[ 0 -1  0  0  0  1  0  0 ], ndigits=2
k= -58, y= -56, k-y=-2, spt(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -57, y= -56, k-y=-1, spt(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -56, y= -56, k-y= 0, spt(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -55, y= -56, k-y= 1, spt(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -54, y= -56, k-y= 2, spt(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -53, y= -56, k-y= 3, spt(8:-1:1)=[ 0 -1  0  0  1  0  0  0 ], ndigits=2
k= -52, y= -48, k-y=-4, spt(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -51, y= -48, k-y=-3, spt(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -50, y= -48, k-y=-2, spt(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -49, y= -48, k-y=-1, spt(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -48, y= -48, k-y= 0, spt(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -47, y= -48, k-y= 1, spt(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -46, y= -48, k-y= 2, spt(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -45, y= -48, k-y= 3, spt(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -44, y= -48, k-y= 4, spt(8:-1:1)=[ 0 -1  0  1  0  0  0  0 ], ndigits=2
k= -43, y= -40, k-y=-3, spt(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -42, y= -40, k-y=-2, spt(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -41, y= -40, k-y=-1, spt(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -40, y= -40, k-y= 0, spt(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -39, y= -40, k-y= 1, spt(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -38, y= -40, k-y= 2, spt(8:-1:1)=[ 0  0 -1  0 -1  0  0  0 ], ndigits=2
k= -37, y= -36, k-y=-1, spt(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k= -36, y= -36, k-y= 0, spt(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k= -35, y= -36, k-y= 1, spt(8:-1:1)=[ 0  0 -1  0  0 -1  0  0 ], ndigits=2
k= -34, y= -34, k-y= 0, spt(8:-1:1)=[ 0  0 -1  0  0  0 -1  0 ], ndigits=2
k= -33, y= -33, k-y= 0, spt(8:-1:1)=[ 0  0 -1  0  0  0  0 -1 ], ndigits=2
k= -32, y= -32, k-y= 0, spt(8:-1:1)=[ 0  0 -1  0  0  0  0  0 ], ndigits=1
k= -31, y= -31, k-y= 0, spt(8:-1:1)=[ 0  0 -1  0  0  0  0  1 ], ndigits=2
k= -30, y= -30, k-y= 0, spt(8:-1:1)=[ 0  0 -1  0  0  0  1  0 ], ndigits=2
k= -29, y= -28, k-y=-1, spt(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k= -28, y= -28, k-y= 0, spt(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k= -27, y= -28, k-y= 1, spt(8:-1:1)=[ 0  0 -1  0  0  1  0  0 ], ndigits=2
k= -26, y= -24, k-y=-2, spt(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k= -25, y= -24, k-y=-1, spt(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k= -24, y= -24, k-y= 0, spt(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k= -23, y= -24, k-y= 1, spt(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k= -22, y= -24, k-y= 2, spt(8:-1:1)=[ 0  0 -1  0  1  0  0  0 ], ndigits=2
k= -21, y= -20, k-y=-1, spt(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k= -20, y= -20, k-y= 0, spt(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k= -19, y= -20, k-y= 1, spt(8:-1:1)=[ 0  0  0 -1  0 -1  0  0 ], ndigits=2
k= -18, y= -18, k-y= 0, spt(8:-1:1)=[ 0  0  0 -1  0  0 -1  0 ], ndigits=2
k= -17, y= -17, k-y= 0, spt(8:-1:1)=[ 0  0  0 -1  0  0  0 -1 ], ndigits=2
k= -16, y= -16, k-y= 0, spt(8:-1:1)=[ 0  0  0 -1  0  0  0  0 ], ndigits=1
k= -15, y= -15, k-y= 0, spt(8:-1:1)=[ 0  0  0 -1  0  0  0  1 ], ndigits=2
k= -14, y= -14, k-y= 0, spt(8:-1:1)=[ 0  0  0 -1  0  0  1  0 ], ndigits=2
k= -13, y= -12, k-y=-1, spt(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k= -12, y= -12, k-y= 0, spt(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k= -11, y= -12, k-y= 1, spt(8:-1:1)=[ 0  0  0 -1  0  1  0  0 ], ndigits=2
k= -10, y= -10, k-y= 0, spt(8:-1:1)=[ 0  0  0  0 -1  0 -1  0 ], ndigits=2
k=  -9, y=  -9, k-y= 0, spt(8:-1:1)=[ 0  0  0  0 -1  0  0 -1 ], ndigits=2
k=  -8, y=  -8, k-y= 0, spt(8:-1:1)=[ 0  0  0  0 -1  0  0  0 ], ndigits=1
k=  -7, y=  -7, k-y= 0, spt(8:-1:1)=[ 0  0  0  0 -1  0  0  1 ], ndigits=2
k=  -6, y=  -6, k-y= 0, spt(8:-1:1)=[ 0  0  0  0 -1  0  1  0 ], ndigits=2
k=  -5, y=  -5, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  0 -1  0 -1 ], ndigits=2
k=  -4, y=  -4, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  0 -1  0  0 ], ndigits=1
k=  -3, y=  -3, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  0 -1  0  1 ], ndigits=2
k=  -2, y=  -2, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  0  0 -1  0 ], ndigits=1
k=  -1, y=  -1, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  0  0  0 -1 ], ndigits=1
k=   0, y=   0, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  0  0  0  0 ], ndigits=0
k=   1, y=   1, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  0  0  0  1 ], ndigits=1
k=   2, y=   2, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  0  0  1  0 ], ndigits=1
k=   3, y=   3, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  0  1  0 -1 ], ndigits=2
k=   4, y=   4, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  0  1  0  0 ], ndigits=1
k=   5, y=   5, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  0  1  0  1 ], ndigits=2
k=   6, y=   6, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  1  0 -1  0 ], ndigits=2
k=   7, y=   7, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  1  0  0 -1 ], ndigits=2
k=   8, y=   8, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  1  0  0  0 ], ndigits=1
k=   9, y=   9, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  1  0  0  1 ], ndigits=2
k=  10, y=  10, k-y= 0, spt(8:-1:1)=[ 0  0  0  0  1  0  1  0 ], ndigits=2
k=  11, y=  12, k-y=-1, spt(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=  12, y=  12, k-y= 0, spt(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=  13, y=  12, k-y= 1, spt(8:-1:1)=[ 0  0  0  1  0 -1  0  0 ], ndigits=2
k=  14, y=  14, k-y= 0, spt(8:-1:1)=[ 0  0  0  1  0  0 -1  0 ], ndigits=2
k=  15, y=  15, k-y= 0, spt(8:-1:1)=[ 0  0  0  1  0  0  0 -1 ], ndigits=2
k=  16, y=  16, k-y= 0, spt(8:-1:1)=[ 0  0  0  1  0  0  0  0 ], ndigits=1
k=  17, y=  17, k-y= 0, spt(8:-1:1)=[ 0  0  0  1  0  0  0  1 ], ndigits=2
k=  18, y=  18, k-y= 0, spt(8:-1:1)=[ 0  0  0  1  0  0  1  0 ], ndigits=2
k=  19, y=  20, k-y=-1, spt(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=  20, y=  20, k-y= 0, spt(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=  21, y=  20, k-y= 1, spt(8:-1:1)=[ 0  0  0  1  0  1  0  0 ], ndigits=2
k=  22, y=  24, k-y=-2, spt(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=  23, y=  24, k-y=-1, spt(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=  24, y=  24, k-y= 0, spt(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=  25, y=  24, k-y= 1, spt(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=  26, y=  24, k-y= 2, spt(8:-1:1)=[ 0  0  1  0 -1  0  0  0 ], ndigits=2
k=  27, y=  28, k-y=-1, spt(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=  28, y=  28, k-y= 0, spt(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=  29, y=  28, k-y= 1, spt(8:-1:1)=[ 0  0  1  0  0 -1  0  0 ], ndigits=2
k=  30, y=  30, k-y= 0, spt(8:-1:1)=[ 0  0  1  0  0  0 -1  0 ], ndigits=2
k=  31, y=  31, k-y= 0, spt(8:-1:1)=[ 0  0  1  0  0  0  0 -1 ], ndigits=2
k=  32, y=  32, k-y= 0, spt(8:-1:1)=[ 0  0  1  0  0  0  0  0 ], ndigits=1
k=  33, y=  33, k-y= 0, spt(8:-1:1)=[ 0  0  1  0  0  0  0  1 ], ndigits=2
k=  34, y=  34, k-y= 0, spt(8:-1:1)=[ 0  0  1  0  0  0  1  0 ], ndigits=2
k=  35, y=  36, k-y=-1, spt(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=  36, y=  36, k-y= 0, spt(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=  37, y=  36, k-y= 1, spt(8:-1:1)=[ 0  0  1  0  0  1  0  0 ], ndigits=2
k=  38, y=  40, k-y=-2, spt(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  39, y=  40, k-y=-1, spt(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  40, y=  40, k-y= 0, spt(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  41, y=  40, k-y= 1, spt(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  42, y=  40, k-y= 2, spt(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  43, y=  40, k-y= 3, spt(8:-1:1)=[ 0  0  1  0  1  0  0  0 ], ndigits=2
k=  44, y=  48, k-y=-4, spt(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  45, y=  48, k-y=-3, spt(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  46, y=  48, k-y=-2, spt(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  47, y=  48, k-y=-1, spt(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  48, y=  48, k-y= 0, spt(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  49, y=  48, k-y= 1, spt(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  50, y=  48, k-y= 2, spt(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  51, y=  48, k-y= 3, spt(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  52, y=  48, k-y= 4, spt(8:-1:1)=[ 0  1  0 -1  0  0  0  0 ], ndigits=2
k=  53, y=  56, k-y=-3, spt(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  54, y=  56, k-y=-2, spt(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  55, y=  56, k-y=-1, spt(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  56, y=  56, k-y= 0, spt(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  57, y=  56, k-y= 1, spt(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  58, y=  56, k-y= 2, spt(8:-1:1)=[ 0  1  0  0 -1  0  0  0 ], ndigits=2
k=  59, y=  60, k-y=-1, spt(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=  60, y=  60, k-y= 0, spt(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=  61, y=  60, k-y= 1, spt(8:-1:1)=[ 0  1  0  0  0 -1  0  0 ], ndigits=2
k=  62, y=  62, k-y= 0, spt(8:-1:1)=[ 0  1  0  0  0  0 -1  0 ], ndigits=2
k=  63, y=  63, k-y= 0, spt(8:-1:1)=[ 0  1  0  0  0  0  0 -1 ], ndigits=2
k=  64, y=  64, k-y= 0, spt(8:-1:1)=[ 0  1  0  0  0  0  0  0 ], ndigits=1
k=  65, y=  65, k-y= 0, spt(8:-1:1)=[ 0  1  0  0  0  0  0  1 ], ndigits=2
k=  66, y=  66, k-y= 0, spt(8:-1:1)=[ 0  1  0  0  0  0  1  0 ], ndigits=2
k=  67, y=  68, k-y=-1, spt(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=  68, y=  68, k-y= 0, spt(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=  69, y=  68, k-y= 1, spt(8:-1:1)=[ 0  1  0  0  0  1  0  0 ], ndigits=2
k=  70, y=  72, k-y=-2, spt(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  71, y=  72, k-y=-1, spt(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  72, y=  72, k-y= 0, spt(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  73, y=  72, k-y= 1, spt(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  74, y=  72, k-y= 2, spt(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  75, y=  72, k-y= 3, spt(8:-1:1)=[ 0  1  0  0  1  0  0  0 ], ndigits=2
k=  76, y=  80, k-y=-4, spt(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  77, y=  80, k-y=-3, spt(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  78, y=  80, k-y=-2, spt(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  79, y=  80, k-y=-1, spt(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  80, y=  80, k-y= 0, spt(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  81, y=  80, k-y= 1, spt(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  82, y=  80, k-y= 2, spt(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  83, y=  80, k-y= 3, spt(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  84, y=  80, k-y= 4, spt(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  85, y=  80, k-y= 5, spt(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  86, y=  80, k-y= 6, spt(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  87, y=  80, k-y= 7, spt(8:-1:1)=[ 0  1  0  1  0  0  0  0 ], ndigits=2
k=  88, y=  96, k-y=-8, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  89, y=  96, k-y=-7, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  90, y=  96, k-y=-6, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  91, y=  96, k-y=-5, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  92, y=  96, k-y=-4, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  93, y=  96, k-y=-3, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  94, y=  96, k-y=-2, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  95, y=  96, k-y=-1, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  96, y=  96, k-y= 0, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  97, y=  96, k-y= 1, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  98, y=  96, k-y= 2, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k=  99, y=  96, k-y= 3, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 100, y=  96, k-y= 4, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 101, y=  96, k-y= 5, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 102, y=  96, k-y= 6, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 103, y=  96, k-y= 7, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 104, y=  96, k-y= 8, spt(8:-1:1)=[ 1  0 -1  0  0  0  0  0 ], ndigits=2
k= 105, y= 112, k-y=-7, spt(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 106, y= 112, k-y=-6, spt(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 107, y= 112, k-y=-5, spt(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 108, y= 112, k-y=-4, spt(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 109, y= 112, k-y=-3, spt(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 110, y= 112, k-y=-2, spt(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 111, y= 112, k-y=-1, spt(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 112, y= 112, k-y= 0, spt(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 113, y= 112, k-y= 1, spt(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 114, y= 112, k-y= 2, spt(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 115, y= 112, k-y= 3, spt(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 116, y= 112, k-y= 4, spt(8:-1:1)=[ 1  0  0 -1  0  0  0  0 ], ndigits=2
k= 117, y= 120, k-y=-3, spt(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 118, y= 120, k-y=-2, spt(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 119, y= 120, k-y=-1, spt(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 120, y= 120, k-y= 0, spt(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 121, y= 120, k-y= 1, spt(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 122, y= 120, k-y= 2, spt(8:-1:1)=[ 1  0  0  0 -1  0  0  0 ], ndigits=2
k= 123, y= 124, k-y=-1, spt(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k= 124, y= 124, k-y= 0, spt(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k= 125, y= 124, k-y= 1, spt(8:-1:1)=[ 1  0  0  0  0 -1  0  0 ], ndigits=2
k= 126, y= 126, k-y= 0, spt(8:-1:1)=[ 1  0  0  0  0  0 -1  0 ], ndigits=2
k= 127, y= 127, k-y= 0, spt(8:-1:1)=[ 1  0  0  0  0  0  0 -1 ], ndigits=2
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $descr"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $descr"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
