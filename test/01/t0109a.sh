#!/bin/sh

prog=schurexpand_test.m

descr="schurexpand_test.m (mfile)"

depends="schurexpand_test.m test_common.m check_octave_file.m \
schurdecomp.m schurexpand.m"

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
Using schurexpand mfile
warning: Using Octave m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 32 column 1
    schurexpand_test at line 16 column 6
k =
  -0.81674   0.99818  -0.88440   0.96513  -0.92990   0.88687  -0.56357

S =
 Columns 1 through 7:
    0.00060    0.00000    0.00000    0.00000    0.00000    0.00000    0.00000
   -0.00085    0.00104    0.00000    0.00000    0.00000    0.00000    0.00000
    0.01712   -0.02799    0.01715    0.00000    0.00000    0.00000    0.00000
   -0.03250    0.08972   -0.09241    0.03675    0.00000    0.00000    0.00000
    0.13548   -0.46485    0.67350   -0.47283    0.14038    0.00000    0.00000
   -0.35491    1.56379   -2.96665    3.00641   -1.62808    0.38166    0.00000
    0.73261   -3.89335    9.15564  -12.11566    9.50888   -4.20510    0.82607
   -0.56357    3.75572  -11.20037   19.34908  -20.91292   14.16718   -5.59032
 Column 8:
    0.00000
    0.00000
    0.00000
    0.00000
    0.00000
    0.00000
    0.00000
    1.00000

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 17 column 2
c =
 Columns 1 through 7:
  -0.055418   0.137744   0.200439   0.244231   0.218092   0.090615   0.039148
 Column 8:
   0.013694

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 18 column 3
dc =
 Columns 1 through 6:
   0.00059755  -0.00084580   0.01712032  -0.03250033   0.13548061  -0.35490685
 Columns 7 and 8:
   0.73261494  -0.56356990

warning: Using Octave m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 32 column 1
    schurexpand_test at line 19 column 9
km =
  -0.81674   0.99818  -0.88440   0.96513  -0.92990   0.88687  -0.56357

Sm =
 Columns 1 through 7:
   -0.00060    0.00000    0.00000    0.00000    0.00000    0.00000    0.00000
    0.00085   -0.00104    0.00000    0.00000    0.00000    0.00000    0.00000
   -0.01712    0.02799   -0.01715    0.00000    0.00000    0.00000    0.00000
    0.03250   -0.08972    0.09241   -0.03675    0.00000    0.00000    0.00000
   -0.13548    0.46485   -0.67350    0.47283   -0.14038    0.00000    0.00000
    0.35491   -1.56379    2.96665   -3.00641    1.62808   -0.38166    0.00000
   -0.73261    3.89335   -9.15564   12.11566   -9.50888    4.20510   -0.82607
    0.56357   -3.75572   11.20037  -19.34908   20.91292  -14.16718    5.59032
 Column 8:
    0.00000
    0.00000
    0.00000
    0.00000
    0.00000
    0.00000
    0.00000
   -1.00000

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 20 column 3
cm =
 Columns 1 through 7:
   0.055418  -0.137744  -0.200439  -0.244231  -0.218092  -0.090615  -0.039148
 Column 8:
  -0.013694

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 21 column 4
dcm =
 Columns 1 through 6:
  -0.00059755   0.00084580  -0.01712032   0.03250033  -0.13548061   0.35490685
 Columns 7 and 8:
  -0.73261494   0.56356990

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 22 column 5
dcmm =
 Columns 1 through 6:
   0.00059755  -0.00084580   0.01712032  -0.03250033   0.13548061  -0.35490685
 Columns 7 and 8:
   0.73261494  -0.56356990

ans = 0
ans = 0
ans = 0
ans = 0
warning: Using Octave m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 32 column 1
    schurexpand_test at line 30 column 6
k =
  -0.805776   0.999210  -0.785551   0.976849  -0.679467   0.609371  -0.028265

S =
 Columns 1 through 7:
    0.00181    0.00000    0.00000    0.00000    0.00000    0.00000    0.00000
   -0.00247    0.00306    0.00000    0.00000    0.00000    0.00000    0.00000
    0.07692   -0.12401    0.07698    0.00000    0.00000    0.00000    0.00000
   -0.09773    0.28173   -0.29805    0.12440    0.00000    0.00000    0.00000
    0.56805   -1.81777    2.60337   -1.83945    0.58151    0.00000    0.00000
   -0.53852    2.47769   -4.88844    5.23164   -3.03312    0.79257    0.00000
    0.60913   -3.01029    7.14567   -9.92237    8.50245   -4.23930    0.99960
   -0.02826    0.72924   -3.25191    7.42909  -10.12839    8.59097   -4.25822
 Column 8:
    0.00000
    0.00000
    0.00000
    0.00000
    0.00000
    0.00000
    0.00000
    1.00000

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 31 column 2
c =
 Columns 1 through 7:
   0.090791   0.087717  -0.186099  -0.095525   0.287667   0.161757  -0.660897
 Column 8:
   0.340938

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 32 column 3
dc =
 Columns 1 through 6:
   0.0018123  -0.0024658   0.0769199  -0.0977256   0.5680494  -0.5385246
 Columns 7 and 8:
   0.6091272  -0.0282647

warning: Using Octave m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 32 column 1
    schurexpand_test at line 33 column 8
km =
  -0.805776   0.999210  -0.785551   0.976849  -0.679467   0.609371  -0.028265

Sm =
 Columns 1 through 7:
   -0.00181    0.00000    0.00000    0.00000    0.00000    0.00000    0.00000
    0.00247   -0.00306    0.00000    0.00000    0.00000    0.00000    0.00000
   -0.07692    0.12401   -0.07698    0.00000    0.00000    0.00000    0.00000
    0.09773   -0.28173    0.29805   -0.12440    0.00000    0.00000    0.00000
   -0.56805    1.81777   -2.60337    1.83945   -0.58151    0.00000    0.00000
    0.53852   -2.47769    4.88844   -5.23164    3.03312   -0.79257    0.00000
   -0.60913    3.01029   -7.14567    9.92237   -8.50245    4.23930   -0.99960
    0.02826   -0.72924    3.25191   -7.42909   10.12839   -8.59097    4.25822
 Column 8:
    0.00000
    0.00000
    0.00000
    0.00000
    0.00000
    0.00000
    0.00000
   -1.00000

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 34 column 3
cm =
 Columns 1 through 7:
   0.090791   0.087717  -0.186099  -0.095525   0.287667   0.161757  -0.660897
 Column 8:
   0.340938

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 35 column 4
dcm =
 Columns 1 through 6:
  -0.0018123   0.0024658  -0.0769199   0.0977256  -0.5680494   0.5385246
 Columns 7 and 8:
  -0.6091272   0.0282647

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 36 column 5
dcmm =
 Columns 1 through 6:
   0.0018123  -0.0024658   0.0769199  -0.0977256   0.5680494  -0.5385246
 Columns 7 and 8:
   0.6091272  -0.0282647

ans = 0
ans = 0
ans = 0
ans = 0
warning: Using Octave m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 32 column 1
    schurexpand_test at line 46 column 6
k =
  -0.39699   0.93499  -0.65887   0.62581  -0.31213

S =
   0.18146   0.00000   0.00000   0.00000   0.00000   0.00000
  -0.07849   0.19771   0.00000   0.00000   0.00000   0.00000
   0.52119  -0.42820   0.55743   0.00000   0.00000   0.00000
  -0.48823   1.06788  -1.02571   0.74101   0.00000   0.00000
   0.59455  -1.44893   2.22593  -1.70679   0.95004   0.00000
  -0.31213   1.18656  -2.25644   2.81902  -1.99188   1.00000

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 47 column 2
c =
  -0.225839   0.158736   0.362673   0.353330   0.171004   0.049343

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 48 column 3
dc =
   0.181460  -0.078488   0.521186  -0.488228   0.594547  -0.312129

warning: Using Octave m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 32 column 1
    schurexpand_test at line 49 column 8
km =
  -0.39699   0.93499  -0.65887   0.62581  -0.31213

Sm =
  -0.18146   0.00000   0.00000   0.00000   0.00000   0.00000
   0.07849  -0.19771   0.00000   0.00000   0.00000   0.00000
  -0.52119   0.42820  -0.55743   0.00000   0.00000   0.00000
   0.48823  -1.06788   1.02571  -0.74101   0.00000   0.00000
  -0.59455   1.44893  -2.22593   1.70679  -0.95004   0.00000
   0.31213  -1.18656   2.25644  -2.81902   1.99188  -1.00000

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 50 column 3
cm =
  -0.225839   0.158736   0.362673   0.353330   0.171004   0.049343

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 51 column 4
dcm =
  -0.181460   0.078488  -0.521186   0.488228  -0.594547   0.312129

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 52 column 5
dcmm =
   0.181460  -0.078488   0.521186  -0.488228   0.594547  -0.312129

ans = 0
ans = 0
ans = 0
ans = 0
warning: Using Octave m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 32 column 1
    schurexpand_test at line 60 column 6
k =
  -0.269728   0.952677   0.055805   0.450264   0.155925

S =
   0.25777   0.00000   0.00000   0.00000   0.00000   0.00000
  -0.07220   0.26769   0.00000   0.00000   0.00000   0.00000
   0.83893  -0.46380   0.88060   0.00000   0.00000   0.00000
   0.04922   0.81431  -0.41764   0.88197   0.00000   0.00000
   0.44476  -0.15548   1.32263  -0.44292   0.98777   0.00000
   0.15592   0.38035   0.05138   1.31446  -0.37819   1.00000

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 61 column 2
c =
   0.108554  -0.272622  -0.050916   0.499813  -0.430072   0.139910

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 62 column 3
dc =
   0.257767  -0.072203   0.838927   0.049219   0.444757   0.155925

warning: Using Octave m-file version of function schurdecomp()!
warning: called from
    schurdecomp at line 32 column 1
    schurexpand_test at line 63 column 8
km =
  -0.269728   0.952677   0.055805   0.450264   0.155925

Sm =
  -0.25777   0.00000   0.00000   0.00000   0.00000   0.00000
   0.07220  -0.26769   0.00000   0.00000   0.00000   0.00000
  -0.83893   0.46380  -0.88060   0.00000   0.00000   0.00000
  -0.04922  -0.81431   0.41764  -0.88197   0.00000   0.00000
  -0.44476   0.15548  -1.32263   0.44292  -0.98777   0.00000
  -0.15592  -0.38035  -0.05138  -1.31446   0.37819  -1.00000

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 64 column 3
cm =
   0.108554  -0.272622  -0.050916   0.499813  -0.430072   0.139910

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 65 column 4
dcm =
  -0.257767   0.072203  -0.838927  -0.049219  -0.444757  -0.155925

warning: Using Octave m-file version of function schurexpand()!
warning: called from
    schurexpand at line 32 column 1
    schurexpand_test at line 66 column 5
dcmm =
   0.257767  -0.072203   0.838927   0.049219   0.444757   0.155925

ans = 0
ans = 0
ans = 0
ans = 0
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $descr"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $descr"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

