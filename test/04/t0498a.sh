#!/bin/sh

prog=yalmip_test.m
depends="yalmip_test.m test_common.m"

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
For sdpt3 : solution = [ -0.000000  0.500000  0.083333  0.416667  0.166667  0.333333  0.250000  0.250000  0.333333  0.166667 ]
For sedumi : solution = [ -0.000000  0.500000  0.083333  0.416667  0.166666  0.333334  0.250000  0.250000  0.333333  0.166667 ]
For sparsepop : solution = [  0.000000  0.500000  0.083333  0.416667  0.166666  0.333334  0.249999  0.250001  0.333331  0.166669 ]
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

cat > yalmiptest.ok << 'EOF'
|      Searching for installed solvers       |
|       Solver|   Version/module|      Status|
|                   Test|    Solution|                       Solver message|
|   Core functionalities|         N/A|         Successfully solved (YALMIP)|
|                     LP|     Correct|   Successfully solved (GLPK-GLPKMEX)|
|                     LP|     Correct|   Successfully solved (GLPK-GLPKMEX)|
|                     QP|     Correct|     Successfully solved (SeDuMi-1.3)|
|                     QP|     Correct|     Successfully solved (SeDuMi-1.3)|
|                   SOCP|     Correct|     Successfully solved (SeDuMi-1.3)|
|                   SOCP|     Correct|     Successfully solved (SeDuMi-1.3)|
|                   SOCP|     Correct|     Successfully solved (SeDuMi-1.3)|
|                    SDP|     Correct|     Successfully solved (SeDuMi-1.3)|
|                    SDP|     Correct|     Successfully solved (SeDuMi-1.3)|
|                    SDP|     Correct|     Successfully solved (SeDuMi-1.3)|
|                    SDP|     Correct|     Successfully solved (SeDuMi-1.3)|
|                 MAXDET|     Correct|     Successfully solved (SeDuMi-1.3)|
|                 MAXDET|     Correct|     Successfully solved (SeDuMi-1.3)|
|          Infeasible LP|         N/A|    Infeasible problem (GLPK-GLPKMEX)|
|          Infeasible QP|         N/A|      Infeasible problem (SeDuMi-1.3)|
|         Infeasible SDP|         N/A|      Infeasible problem (SeDuMi-1.3)|
|      Moment relaxation|     Correct|     Successfully solved (SeDuMi-1.3)|
|         Sum-of-squares|     Correct|     Successfully solved (SeDuMi-1.3)|
|           Bilinear SDP|   Incorrect|         Successfully solved (BMIBNB)|
|      Searching for installed solvers       |
|       Solver|   Version/module|      Status|
|                   Test|   Solution|                                                                       Solver message|
|   Core functionalities|        N/A|                                                         Successfully solved (YALMIP)|
|                     LP|    Correct|                                                     Successfully solved (SeDuMi-1.3)|
|                     LP|    Correct|                                                     Successfully solved (SeDuMi-1.3)|
|                     QP|    Correct|                                                     Successfully solved (SeDuMi-1.3)|
|                     QP|    Correct|                                                     Successfully solved (SeDuMi-1.3)|
|                   SOCP|    Correct|                                                     Successfully solved (SeDuMi-1.3)|
|                   SOCP|    Correct|                                                     Successfully solved (SeDuMi-1.3)|
|                   SOCP|    Correct|                                                     Successfully solved (SeDuMi-1.3)|
|                    SDP|    Correct|                                                     Successfully solved (SeDuMi-1.3)|
|                    SDP|    Correct|                                                     Successfully solved (SeDuMi-1.3)|
|                    SDP|    Correct|                                                     Successfully solved (SeDuMi-1.3)|
|                    SDP|    Correct|                                                     Successfully solved (SeDuMi-1.3)|
|                 MAXDET|    Correct|                                                     Successfully solved (SeDuMi-1.3)|
|                 MAXDET|    Correct|                                                     Successfully solved (SeDuMi-1.3)|
|          Infeasible LP|        N/A|                                                      Infeasible problem (SeDuMi-1.3)|
|          Infeasible QP|        N/A|                                                      Infeasible problem (SeDuMi-1.3)|
|         Infeasible SDP|        N/A|                                                      Infeasible problem (SeDuMi-1.3)|
|      Moment relaxation|    Correct|                                                     Successfully solved (SeDuMi-1.3)|
|         Sum-of-squares|    Correct|                                                     Successfully solved (SeDuMi-1.3)|
|           Bilinear SDP|        N/A|   Solver not applicable (sedumi does not support quadratic semidefinite constraints)|
|      Searching for installed solvers       |
|       Solver|   Version/module|      Status|
|                   Test|   Solution|                                                                      Solver message|
|   Core functionalities|        N/A|                                                        Successfully solved (YALMIP)|
|                     LP|    Correct|                                                       Successfully solved (SDPT3-4)|
|                     LP|    Correct|                                                       Successfully solved (SDPT3-4)|
|                     QP|    Correct|                                                       Successfully solved (SDPT3-4)|
|                     QP|    Correct|                                                       Successfully solved (SDPT3-4)|
|                   SOCP|    Correct|                                                       Successfully solved (SDPT3-4)|
|                   SOCP|    Correct|                                                       Successfully solved (SDPT3-4)|
|                   SOCP|    Correct|                                                       Successfully solved (SDPT3-4)|
|                    SDP|    Correct|                                                       Successfully solved (SDPT3-4)|
|                    SDP|    Correct|                                                       Successfully solved (SDPT3-4)|
|                    SDP|    Correct|                                                       Successfully solved (SDPT3-4)|
|                    SDP|    Correct|                                                       Successfully solved (SDPT3-4)|
|                 MAXDET|    Correct|                                                       Successfully solved (SDPT3-4)|
|                 MAXDET|    Correct|                                                       Successfully solved (SDPT3-4)|
|          Infeasible LP|        N/A|                                                        Numerical problems (SDPT3-4)|
|          Infeasible QP|        N/A|                                                        Infeasible problem (SDPT3-4)|
|         Infeasible SDP|        N/A|                                                        Infeasible problem (SDPT3-4)|
|      Moment relaxation|    Correct|                                                       Successfully solved (SDPT3-4)|
|         Sum-of-squares|    Correct|                                                       Successfully solved (SDPT3-4)|
|           Bilinear SDP|        N/A|   Solver not applicable (sdpt3 does not support quadratic semidefinite constraints)|
EOF
if [ $? -ne 0 ]; then echo "Failed output cat yalmiptest.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.results
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

grep -e "^|" yalmip_test.diary | egrep -v found | egrep -v Ax > yalmiptest.out
diff -Bb yalmiptest.ok yalmiptest.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb yalmiptest.ok"; fail; fi

#
# this much worked
#
pass

