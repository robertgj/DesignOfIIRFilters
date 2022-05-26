#!/bin/sh

prog=bin2SPT_test.m

descr="bin2SPT_test.m (mfile)"

depends="test/bin2SPT_test.m test_common.m check_octave_file.m bin2SPT.m"

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
Using bin2SPT mfile
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=     1, nbits=51, spt(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

Caught spt=bin2SPT(1,52): Expected 0<nbits(52)<=51
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=     1, nbits=8, spt(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=    -1, nbits=8, spt(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

Caught spt=bin2SPT(1,0): nbits<=0
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

Caught spt=bin2SPT(-1,0): nbits<=0
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=     0, nbits=8, spt(8:-1:1)=[  0  0  0  0  0  0  0  0 ], ndigits=0
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=     0, nbits=1, spt(1:-1:1)=[  0 ], ndigits=0
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=     1, nbits=1, spt(1:-1:1)=[  1 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

Caught spt=bin2SPT(2,1): round(x)=2 is out of range for a 1 bits signed-digit number
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=    -1, nbits=1, spt(1:-1:1)=[ -1 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=     0, nbits=2, spt(2:-1:1)=[  0  0 ], ndigits=0
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=     1, nbits=2, spt(2:-1:1)=[  0  1 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=    -1, nbits=2, spt(2:-1:1)=[  0 -1 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=    -2, nbits=2, spt(2:-1:1)=[ -1  0 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=     1, nbits=8, spt(8:-1:1)=[  0  0  0  0  0  0  0  1 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=    -1, nbits=8, spt(8:-1:1)=[  0  0  0  0  0  0  0 -1 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=   1.5, nbits=8, spt(8:-1:1)=[  0  0  0  0  0  0  1  0 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=  -1.5, nbits=8, spt(8:-1:1)=[  0  0  0  0  0  0 -1  0 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=   -43, nbits=7, spt(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=    43, nbits=7, spt(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x= -43.4, nbits=7, spt(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=  43.4, nbits=7, spt(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x= -43.6, nbits=7, spt(7:-1:1)=[ -1  0  1  0  1  0  0 ], ndigits=3
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=  43.6, nbits=7, spt(7:-1:1)=[  1  0 -1  0 -1  0  0 ], ndigits=3
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x= -42.9, nbits=7, spt(7:-1:1)=[ -1  0  1  0  1  0  1 ], ndigits=4
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=  42.9, nbits=7, spt(7:-1:1)=[  1  0 -1  0 -1  0 -1 ], ndigits=4
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=   141, nbits=9, spt(9:-1:1)=[  0  1  0  0  1  0 -1  0  1 ], ndigits=4
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=  -141, nbits=9, spt(9:-1:1)=[  0 -1  0  0 -1  0  1  0 -1 ], ndigits=4
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=   170, nbits=9, spt(9:-1:1)=[  0  1  0  1  0  1  0  1  0 ], ndigits=4
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=  -170, nbits=9, spt(9:-1:1)=[  0 -1  0 -1  0 -1  0 -1  0 ], ndigits=4
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

Caught spt=bin2SPT(129,8): round(x)=129 is out of range for a 8 bits signed-digit number
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=   129, nbits=9, spt(9:-1:1)=[  0  1  0  0  0  0  0  0  1 ], ndigits=2
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

Caught spt=bin2SPT(-129,8): round(x)=-129 is out of range for a 8 bits signed-digit number
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=  -129, nbits=9, spt(9:-1:1)=[  0 -1  0  0  0  0  0  0 -1 ], ndigits=2
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=   128, nbits=8, spt(8:-1:1)=[  1  0  0  0  0  0  0  0 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=   128, nbits=9, spt(9:-1:1)=[  0  1  0  0  0  0  0  0  0 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=  -128, nbits=8, spt(8:-1:1)=[ -1  0  0  0  0  0  0  0 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=   127, nbits=8, spt(8:-1:1)=[  1  0  0  0  0  0  0 -1 ], ndigits=2
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=   127, nbits=8, spt(8:-1:1)=[  1  0  0  0  0  0  0 -1 ], ndigits=2
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=  -127, nbits=8, spt(8:-1:1)=[ -1  0  0  0  0  0  0  1 ], ndigits=2
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=   127, nbits=51, spt(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0 -1 ], ndigits=2
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=  -127, nbits=51, spt(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  1 ], ndigits=2
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=   128, nbits=51, spt(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x=  -128, nbits=51, spt(51:-1:1)=[  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

Caught spt=bin2SPT(129,8): round(x)=129 is out of range for a 8 bits signed-digit number
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

Caught spt=bin2SPT(-129,8): round(x)=-129 is out of range for a 8 bits signed-digit number
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x= 63.49, nbits=7, spt(7:-1:1)=[  1  0  0  0  0  0 -1 ], ndigits=2
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 89 column 10
    bin2SPT_test at line 109 column 1

x= 63.51, nbits=7, spt(7:-1:1)=[  1  0  0  0  0  0  0 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 98 column 10
    bin2SPT_test at line 109 column 1

x=     0, spt(1:-1:1)=[  0 ], ndigits=0
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 98 column 10
    bin2SPT_test at line 109 column 1

x=   0.1, spt(1:-1:1)=[  0 ], ndigits=0
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 98 column 10
    bin2SPT_test at line 109 column 1

x=  -0.1, spt(1:-1:1)=[  0 ], ndigits=0
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 98 column 10
    bin2SPT_test at line 109 column 1

x=   0.5, spt(1:-1:1)=[  1 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 98 column 10
    bin2SPT_test at line 109 column 1

x=  -0.5, spt(1:-1:1)=[ -1 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 98 column 10
    bin2SPT_test at line 109 column 1

x=     1, spt(1:-1:1)=[  1 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 98 column 10
    bin2SPT_test at line 109 column 1

x=    -1, spt(1:-1:1)=[ -1 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 98 column 10
    bin2SPT_test at line 109 column 1

x=   1.1, spt(1:-1:1)=[  1 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 98 column 10
    bin2SPT_test at line 109 column 1

x=  -1.1, spt(1:-1:1)=[ -1 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 98 column 10
    bin2SPT_test at line 109 column 1

x=  1023, spt(11:-1:1)=[  1  0  0  0  0  0  0  0  0  0 -1 ], ndigits=2
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 98 column 10
    bin2SPT_test at line 109 column 1

x= -1023, spt(11:-1:1)=[ -1  0  0  0  0  0  0  0  0  0  1 ], ndigits=2
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 98 column 10
    bin2SPT_test at line 109 column 1

x=  1024, spt(11:-1:1)=[  1  0  0  0  0  0  0  0  0  0  0 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 98 column 10
    bin2SPT_test at line 109 column 1

x= -1024, spt(11:-1:1)=[ -1  0  0  0  0  0  0  0  0  0  0 ], ndigits=1
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 98 column 10
    bin2SPT_test at line 109 column 1

x=  1025, spt(12:-1:1)=[  0  1  0  0  0  0  0  0  0  0  0  1 ], ndigits=2
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    testfun at line 98 column 10
    bin2SPT_test at line 109 column 1

x= -1025, spt(12:-1:1)=[  0 -1  0  0  0  0  0  0  0  0  0 -1 ], ndigits=2
warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 115 column 6

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 126 column 2

X =
{
  [1,1] =
     0   0   0   0   0   0   0  -1
  [1,2] =
     1   0   0   0   0   0   0  -1
  [1,3] =
     0   1   0   0   0   0   0  -1
  [1,4] =
    -1   0   1   0   0   0   0  -1
  [1,5] =
     0   0   1   0   0   0   0  -1
  [1,6] =
     1   0   1   0   0   0   0  -1
  [1,7] =
     0  -1   0   1   0   0   0  -1
  [1,8] =
    -1   0   0   1   0   0   0  -1
  [1,9] =
     0   0   0   1   0   0   0  -1
  [1,10] =
     1   0   0   1   0   0   0  -1
  [1,11] =
     0   1   0   1   0   0   0  -1
  [1,12] =
    -1   0  -1   0   1   0   0  -1
  [1,13] =
     0   0  -1   0   1   0   0  -1
  [1,14] =
     1   0  -1   0   1   0   0  -1
  [1,15] =
     0  -1   0   0   1   0   0  -1
  [1,16] =
    -1   0   0   0   1   0   0  -1
  [1,17] =
     0   0   0   0   1   0   0  -1
  [1,18] =
     1   0   0   0   1   0   0  -1
  [1,19] =
     0   1   0   0   1   0   0  -1
  [1,20] =
    -1   0   1   0   1   0   0  -1
  [1,21] =
     0   0   1   0   1   0   0  -1
  [1,22] =
     1   0   1   0   1   0   0  -1
  [1,23] =
     0  -1   0  -1   0   1   0  -1
  [1,24] =
    -1   0   0  -1   0   1   0  -1
  [1,25] =
     0   0   0  -1   0   1   0  -1
  [1,26] =
     1   0   0  -1   0   1   0  -1
  [1,27] =
     0   1   0  -1   0   1   0  -1
  [1,28] =
    -1   0  -1   0   0   1   0  -1
  [1,29] =
     0   0  -1   0   0   1   0  -1
  [1,30] =
     1   0  -1   0   0   1   0  -1
  [1,31] =
     0  -1   0   0   0   1   0  -1
  [1,32] =
    -1   0   0   0   0   1   0  -1
  [1,33] =
     0   0   0   0   0   1   0  -1
  [1,34] =
     1   0   0   0   0   1   0  -1
  [1,35] =
     0   1   0   0   0   1   0  -1
  [1,36] =
    -1   0   1   0   0   1   0  -1
  [1,37] =
     0   0   1   0   0   1   0  -1
  [1,38] =
     1   0   1   0   0   1   0  -1
  [1,39] =
     0  -1   0   1   0   1   0  -1
  [1,40] =
    -1   0   0   1   0   1   0  -1
  [1,41] =
     0   0   0   1   0   1   0  -1
  [1,42] =
     1   0   0   1   0   1   0  -1
  [1,43] =
     0   1   0   1   0   1   0  -1
  [1,44] =
    -1   0  -1   0  -1   0  -1   0
  [1,45] =
     0   0  -1   0  -1   0  -1   0
  [1,46] =
     1   0  -1   0  -1   0  -1   0
  [1,47] =
     0  -1   0   0  -1   0  -1   0
  [1,48] =
    -1   0   0   0  -1   0  -1   0
  [1,49] =
     0   0   0   0  -1   0  -1   0
  [1,50] =
     1   0   0   0  -1   0  -1   0
  [1,51] =
     0   1   0   0  -1   0  -1   0
  [1,52] =
    -1   0   1   0  -1   0  -1   0
  [1,53] =
     0   0   1   0  -1   0  -1   0
  [1,54] =
     1   0   1   0  -1   0  -1   0
  [1,55] =
     0  -1   0  -1   0   0  -1   0
  [1,56] =
    -1   0   0  -1   0   0  -1   0
  [1,57] =
     0   0   0  -1   0   0  -1   0
  [1,58] =
     1   0   0  -1   0   0  -1   0
  [1,59] =
     0   1   0  -1   0   0  -1   0
  [1,60] =
    -1   0  -1   0   0   0  -1   0
  [1,61] =
     0   0  -1   0   0   0  -1   0
  [1,62] =
     1   0  -1   0   0   0  -1   0
  [1,63] =
     0  -1   0   0   0   0  -1   0
  [1,64] =
    -1   0   0   0   0   0  -1   0
  [1,65] =
     0   0   0   0   0   0  -1
  [1,66] =
     1   0   0   0   0   0  -1
  [1,67] =
     0   1   0   0   0   0  -1
  [1,68] =
    -1   0   1   0   0   0  -1
  [1,69] =
     0   0   1   0   0   0  -1
  [1,70] =
     1   0   1   0   0   0  -1
  [1,71] =
     0  -1   0   1   0   0  -1
  [1,72] =
    -1   0   0   1   0   0  -1
  [1,73] =
     0   0   0   1   0   0  -1
  [1,74] =
     1   0   0   1   0   0  -1
  [1,75] =
     0   1   0   1   0   0  -1
  [1,76] =
    -1   0  -1   0   1   0  -1
  [1,77] =
     0   0  -1   0   1   0  -1
  [1,78] =
     1   0  -1   0   1   0  -1
  [1,79] =
     0  -1   0   0   1   0  -1
  [1,80] =
    -1   0   0   0   1   0  -1
  [1,81] =
     0   0   0   0   1   0  -1
  [1,82] =
     1   0   0   0   1   0  -1
  [1,83] =
     0   1   0   0   1   0  -1
  [1,84] =
    -1   0   1   0   1   0  -1
  [1,85] =
     0   0   1   0   1   0  -1
  [1,86] =
     1   0   1   0   1   0  -1
  [1,87] =
     0  -1   0  -1   0  -1   0
  [1,88] =
    -1   0   0  -1   0  -1   0
  [1,89] =
     0   0   0  -1   0  -1   0
  [1,90] =
     1   0   0  -1   0  -1   0
  [1,91] =
     0   1   0  -1   0  -1   0
  [1,92] =
    -1   0  -1   0   0  -1   0
  [1,93] =
     0   0  -1   0   0  -1   0
  [1,94] =
     1   0  -1   0   0  -1   0
  [1,95] =
     0  -1   0   0   0  -1   0
  [1,96] =
    -1   0   0   0   0  -1   0
  [1,97] =
     0   0   0   0   0  -1
  [1,98] =
     1   0   0   0   0  -1
  [1,99] =
     0   1   0   0   0  -1
  [1,100] =
    -1   0   1   0   0  -1
  [1,101] =
     0   0   1   0   0  -1
  [1,102] =
     1   0   1   0   0  -1
  [1,103] =
     0  -1   0   1   0  -1
  [1,104] =
    -1   0   0   1   0  -1
  [1,105] =
     0   0   0   1   0  -1
  [1,106] =
     1   0   0   1   0  -1
  [1,107] =
     0   1   0   1   0  -1
  [1,108] =
    -1   0  -1   0  -1   0
  [1,109] =
     0   0  -1   0  -1   0
  [1,110] =
     1   0  -1   0  -1   0
  [1,111] =
     0  -1   0   0  -1   0
  [1,112] =
    -1   0   0   0  -1   0
  [1,113] =
     0   0   0   0  -1
  [1,114] =
     1   0   0   0  -1
  [1,115] =
     0   1   0   0  -1
  [1,116] =
    -1   0   1   0  -1
  [1,117] =
     0   0   1   0  -1
  [1,118] =
     1   0   1   0  -1
  [1,119] =
     0  -1   0  -1   0
  [1,120] =
    -1   0   0  -1   0
  [1,121] =
     0   0   0  -1
  [1,122] =
     1   0   0  -1
  [1,123] =
     0   1   0  -1
  [1,124] =
    -1   0  -1   0
  [1,125] =
     0   0  -1
  [1,126] =
     1   0  -1
  [1,127] =
     0  -1
  [1,128] = -1
  [1,129] = 0
  [1,130] = 1
  [1,131] =
     0   1
  [1,132] =
    -1   0   1
  [1,133] =
     0   0   1
  [1,134] =
     1   0   1   0
  [1,135] =
     0  -1   0   1
  [1,136] =
    -1   0   0   1
  [1,137] =
     0   0   0   1
  [1,138] =
     1   0   0   1   0
  [1,139] =
     0   1   0   1   0
  [1,140] =
    -1   0  -1   0   1
  [1,141] =
     0   0  -1   0   1
  [1,142] =
     1   0  -1   0   1
  [1,143] =
     0  -1   0   0   1
  [1,144] =
    -1   0   0   0   1
  [1,145] =
     0   0   0   0   1
  [1,146] =
     1   0   0   0   1   0
  [1,147] =
     0   1   0   0   1   0
  [1,148] =
    -1   0   1   0   1   0
  [1,149] =
     0   0   1   0   1   0
  [1,150] =
     1   0   1   0   1   0
  [1,151] =
     0  -1   0  -1   0   1
  [1,152] =
    -1   0   0  -1   0   1
  [1,153] =
     0   0   0  -1   0   1
  [1,154] =
     1   0   0  -1   0   1
  [1,155] =
     0   1   0  -1   0   1
  [1,156] =
    -1   0  -1   0   0   1
  [1,157] =
     0   0  -1   0   0   1
  [1,158] =
     1   0  -1   0   0   1
  [1,159] =
     0  -1   0   0   0   1
  [1,160] =
    -1   0   0   0   0   1
  [1,161] =
     0   0   0   0   0   1
  [1,162] =
     1   0   0   0   0   1   0
  [1,163] =
     0   1   0   0   0   1   0
  [1,164] =
    -1   0   1   0   0   1   0
  [1,165] =
     0   0   1   0   0   1   0
  [1,166] =
     1   0   1   0   0   1   0
  [1,167] =
     0  -1   0   1   0   1   0
  [1,168] =
    -1   0   0   1   0   1   0
  [1,169] =
     0   0   0   1   0   1   0
  [1,170] =
     1   0   0   1   0   1   0
  [1,171] =
     0   1   0   1   0   1   0
  [1,172] =
    -1   0  -1   0  -1   0   1
  [1,173] =
     0   0  -1   0  -1   0   1
  [1,174] =
     1   0  -1   0  -1   0   1
  [1,175] =
     0  -1   0   0  -1   0   1
  [1,176] =
    -1   0   0   0  -1   0   1
  [1,177] =
     0   0   0   0  -1   0   1
  [1,178] =
     1   0   0   0  -1   0   1
  [1,179] =
     0   1   0   0  -1   0   1
  [1,180] =
    -1   0   1   0  -1   0   1
  [1,181] =
     0   0   1   0  -1   0   1
  [1,182] =
     1   0   1   0  -1   0   1
  [1,183] =
     0  -1   0  -1   0   0   1
  [1,184] =
    -1   0   0  -1   0   0   1
  [1,185] =
     0   0   0  -1   0   0   1
  [1,186] =
     1   0   0  -1   0   0   1
  [1,187] =
     0   1   0  -1   0   0   1
  [1,188] =
    -1   0  -1   0   0   0   1
  [1,189] =
     0   0  -1   0   0   0   1
  [1,190] =
     1   0  -1   0   0   0   1
  [1,191] =
     0  -1   0   0   0   0   1
  [1,192] =
    -1   0   0   0   0   0   1
  [1,193] =
     0   0   0   0   0   0   1
  [1,194] =
     1   0   0   0   0   0   1   0
  [1,195] =
     0   1   0   0   0   0   1   0
  [1,196] =
    -1   0   1   0   0   0   1   0
  [1,197] =
     0   0   1   0   0   0   1   0
  [1,198] =
     1   0   1   0   0   0   1   0
  [1,199] =
     0  -1   0   1   0   0   1   0
  [1,200] =
    -1   0   0   1   0   0   1   0
  [1,201] =
     0   0   0   1   0   0   1   0
  [1,202] =
     1   0   0   1   0   0   1   0
  [1,203] =
     0   1   0   1   0   0   1   0
  [1,204] =
    -1   0  -1   0   1   0   1   0
  [1,205] =
     0   0  -1   0   1   0   1   0
  [1,206] =
     1   0  -1   0   1   0   1   0
  [1,207] =
     0  -1   0   0   1   0   1   0
  [1,208] =
    -1   0   0   0   1   0   1   0
  [1,209] =
     0   0   0   0   1   0   1   0
  [1,210] =
     1   0   0   0   1   0   1   0
  [1,211] =
     0   1   0   0   1   0   1   0
  [1,212] =
    -1   0   1   0   1   0   1   0
  [1,213] =
     0   0   1   0   1   0   1   0
  [1,214] =
     1   0   1   0   1   0   1   0
  [1,215] =
     0  -1   0  -1   0  -1   0   1
  [1,216] =
    -1   0   0  -1   0  -1   0   1
  [1,217] =
     0   0   0  -1   0  -1   0   1
  [1,218] =
     1   0   0  -1   0  -1   0   1
  [1,219] =
     0   1   0  -1   0  -1   0   1
  [1,220] =
    -1   0  -1   0   0  -1   0   1
  [1,221] =
     0   0  -1   0   0  -1   0   1
  [1,222] =
     1   0  -1   0   0  -1   0   1
  [1,223] =
     0  -1   0   0   0  -1   0   1
  [1,224] =
    -1   0   0   0   0  -1   0   1
  [1,225] =
     0   0   0   0   0  -1   0   1
  [1,226] =
     1   0   0   0   0  -1   0   1
  [1,227] =
     0   1   0   0   0  -1   0   1
  [1,228] =
    -1   0   1   0   0  -1   0   1
  [1,229] =
     0   0   1   0   0  -1   0   1
  [1,230] =
     1   0   1   0   0  -1   0   1
  [1,231] =
     0  -1   0   1   0  -1   0   1
  [1,232] =
    -1   0   0   1   0  -1   0   1
  [1,233] =
     0   0   0   1   0  -1   0   1
  [1,234] =
     1   0   0   1   0  -1   0   1
  [1,235] =
     0   1   0   1   0  -1   0   1
  [1,236] =
    -1   0  -1   0  -1   0   0   1
  [1,237] =
     0   0  -1   0  -1   0   0   1
  [1,238] =
     1   0  -1   0  -1   0   0   1
  [1,239] =
     0  -1   0   0  -1   0   0   1
  [1,240] =
    -1   0   0   0  -1   0   0   1
  [1,241] =
     0   0   0   0  -1   0   0   1
  [1,242] =
     1   0   0   0  -1   0   0   1
  [1,243] =
     0   1   0   0  -1   0   0   1
  [1,244] =
    -1   0   1   0  -1   0   0   1
  [1,245] =
     0   0   1   0  -1   0   0   1
  [1,246] =
     1   0   1   0  -1   0   0   1
  [1,247] =
     0  -1   0  -1   0   0   0   1
  [1,248] =
    -1   0   0  -1   0   0   0   1
  [1,249] =
     0   0   0  -1   0   0   0   1
  [1,250] =
     1   0   0  -1   0   0   0   1
  [1,251] =
     0   1   0  -1   0   0   0   1
  [1,252] =
    -1   0  -1   0   0   0   0   1
  [1,253] =
     0   0  -1   0   0   0   0   1
  [1,254] =
     1   0  -1   0   0   0   0   1
  [1,255] =
     0  -1   0   0   0   0   0   1
  [1,256] =
    -1   0   0   0   0   0   0   1
  [1,257] =
     0   0   0   0   0   0   0   1
}

y =
    92  -119   -27    75   213
   123   128   150    28  -202
   -23   146    -4   102   206
   231    41   158   121    62
  -187   197   168  -119   114

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

warning: Using Octave m-file version of function bin2SPT()!
warning: called from
    bin2SPT at line 64 column 3
    bin2SPT_test at line 135 column 2

Y =
{
  [1,1] =
     0   0  -1   0   0  -1   0   1
  [2,1] =
    -1   0  -1   0   0   0   0   1
  [3,1] =
     1   0   0   1   0  -1
  [4,1] =
    -1   0   0   1   0  -1   0   0   1
  [5,1] =
     1   0   1   0   0   0   1   0  -1
  [1,2] =
     1   0   0   1   0   0   0  -1
  [2,2] =
     0   0   0   0   0   0   0   1
  [3,2] =
     0   1   0   0   1   0   0   1   0
  [4,2] =
     1   0   0   1   0   1   0
  [5,2] =
     1   0   1   0   0   0  -1   0   1
  [1,3] =
     1   0   1   0   0  -1
  [2,3] =
     0  -1   0  -1   0   1   0   1   0
  [3,3] =
     0   0  -1
  [4,3] =
     0  -1   0   0   0   1   0   1   0
  [5,3] =
     0   0   0   1   0   1   0   1   0
  [1,4] =
    -1   0  -1   0   1   0   1   0
  [2,4] =
     0   0  -1   0   0   1
  [3,4] =
     0  -1   0   1   0  -1   0   1
  [4,4] =
     1   0   0  -1   0   0   0   1
  [5,4] =
     1   0   0   1   0   0   0  -1
  [1,5] =
     1   0   1   0   1   0  -1   0   1
  [2,5] =
     0  -1   0  -1   0   0   1   0  -1
  [3,5] =
     0  -1   0   0   1   0  -1   0   1
  [4,5] =
     0  -1   0   0   0   0   1
  [5,5] =
     0   1   0   0  -1   0   0   1
}

z =
   3   3   3   4   5
   3   1   4   2   4
   3   3   1   4   4
   4   3   3   3   2
   4   4   3   3   3

zz =
  1  1  1  1  1
  1  0  1  1  1
  1  1  0  1  1
  1  1  1  1  1
  1  1  1  1  1

ans = 54
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

