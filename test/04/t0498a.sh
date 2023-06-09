#!/bin/sh

prog=yalmip_test.m
depends="test/yalmip_test.m test_common.m"

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
|   Searching for installed solvers   |
|       Solver|   Version|      Status|
|    BISECTION|          |    internal|
|       BMIBNB|          |    internal|
|          BNB|          |    internal|
|       CUTSDP|          |    internal|
|        KKTQP|          |    internal|
|                                     Test|    Status|   Solver|
|                     Core functionalities|   Success|         |
|                  Linear programming (LP)|   Success|     GLPK|
|               Quadratic programming (QP)|   Success|   SeDuMi|
|     Second-order cone programming (SOCP)|   Success|   SeDuMi|
|           Semidefinite programming (SDP)|   Success|   SeDuMi|
|               Geometric programming (GP)|    Failed|         |
|              Nonlinear programming (NLP)|    Failed|         |
|                    Nonlinear SDP (NLSDP)|   Success|   BMIBNB|
|       Exponential cone programming (ECP)|    Failed|         |
|                  Mixed-integer LP (MIQP)|   Success|     GLPK|
|                  Mixed-integer QP (MIQP)|   Success|      BNB|
|              Mixed-integer SOCP (MISOCP)|   Success|      BNB|
|   Global nonconvex quadratic programming|   Success|   BMIBNB|
|             Global nonconvex programming|   Success|   BMIBNB|
|   Searching for installed solvers   |
|       Solver|   Version|      Status|
|    BISECTION|          |    internal|
|       BMIBNB|          |    internal|
|          BNB|          |    internal|
|       CUTSDP|          |    internal|
|        KKTQP|          |    internal|
|                                     Test|    Status|   Solver|
|                     Core functionalities|   Success|         |
|                  Linear programming (LP)|   Success|   SeDuMi|
|               Quadratic programming (QP)|   Success|   SeDuMi|
|     Second-order cone programming (SOCP)|   Success|   SeDuMi|
|           Semidefinite programming (SDP)|   Success|   SeDuMi|
|               Geometric programming (GP)|    Failed|         |
|              Nonlinear programming (NLP)|    Failed|         |
|                    Nonlinear SDP (NLSDP)|    Failed|         |
|       Exponential cone programming (ECP)|    Failed|         |
|                  Mixed-integer LP (MIQP)|    Failed|         |
|                  Mixed-integer QP (MIQP)|    Failed|         |
|              Mixed-integer SOCP (MISOCP)|    Failed|         |
|   Global nonconvex quadratic programming|    Failed|         |
|             Global nonconvex programming|    Failed|         |
|   Searching for installed solvers   |
|       Solver|   Version|      Status|
|    BISECTION|          |    internal|
|       BMIBNB|          |    internal|
|          BNB|          |    internal|
|       CUTSDP|          |    internal|
|        KKTQP|          |    internal|
|                                     Test|    Status|   Solver|
|                     Core functionalities|   Success|         |
|                  Linear programming (LP)|   Success|    SDPT3|
|               Quadratic programming (QP)|   Success|    SDPT3|
|     Second-order cone programming (SOCP)|   Success|    SDPT3|
|           Semidefinite programming (SDP)|   Success|    SDPT3|
|               Geometric programming (GP)|    Failed|         |
|              Nonlinear programming (NLP)|    Failed|         |
|                    Nonlinear SDP (NLSDP)|    Failed|         |
|       Exponential cone programming (ECP)|    Failed|         |
|                  Mixed-integer LP (MIQP)|    Failed|         |
|                  Mixed-integer QP (MIQP)|    Failed|         |
|              Mixed-integer SOCP (MISOCP)|    Failed|         |
|   Global nonconvex quadratic programming|    Failed|         |
|             Global nonconvex programming|    Failed|         |
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

grep -e "^|" yalmip_test.diary | grep -v found | grep -v Ax > yalmiptest.out
diff -Bb yalmiptest.ok yalmiptest.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb yalmiptest.ok"; fail; fi

#
# this much worked
#
pass

