#!/bin/sh

prog=bmisolver_test.m
depends="test/bmisolver_test.m test_common.m"

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

# If BMIsolver does not exist then return the aet code for "pass"
if ! test -f src/BMIsolver/BMI_config.m; then 
    echo SKIPPED $prog BMI_config not found! ; exit 0; 
fi
# If COMPlib does not exist then return the aet code for "pass"
if ! test -f src/COMPlib/COMPleib.m; then 
    echo SKIPPED $prog COMPleib.m not found! ; exit 0; 
fi

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
# Created by Octave
# name: result
# type: cell
# rows: 1
# columns: 2
# name: <cell-element>
# type: scalar struct
# ndims: 2
 1 1
# length: 3
# name: F
# type: matrix
# rows: 2
# columns: 2
 -1.0774372772621585 1.3907094546894341
 -1.6206658102324172 -0.89243385520813778


# name: P
# type: matrix
# rows: 4
# columns: 4
 0.13977025019161268 -0.34028094204369402 0.21129909913481715 0.24910229021695704
 -0.34028094204369402 2.031383824772325 -0.45045141181559489 -1.0214975277570437
 0.21129909913481715 -0.45045141181559489 1.0761425275903032 0.5546320513501618
 0.24910229021695704 -1.0214975277570437 0.5546320513501618 0.64191867759620869


# name: b
# type: scalar
-0.40803988348530829





# name: <cell-element>
# type: scalar struct
# ndims: 2
 1 1
# length: 5
# name: F
# type: matrix
# rows: 3
# columns: 3
 0.28753153352796218 -0.1040305341541567 0.19786675227860023
 -0.0015788716792141432 -0.26290038691372414 -0.35390015816972903
 0.74904024613876896 -0.088666893100288205 1.0647176058881875


# name: P1
# type: matrix
# rows: 5
# columns: 5
 115.13351963652509 52.682441761457909 35.472632723477098 22.484845086978304 -61.869516403133531
 52.682441761457909 358.20386536375878 -8.7001265254718732 -84.488255897095016 -16.543948373613446
 35.472632723477098 -8.7001265254718732 354.36805522288824 101.51856428202974 -132.90503077352179
 22.484845086978304 -84.488255897095016 101.51856428202974 223.21676069244347 -30.841646187496728
 -61.869516403133531 -16.543948373613446 -132.90503077352179 -30.841646187496728 294.65752559355906


# name: P2
# type: matrix
# rows: 5
# columns: 5
 102.30291251616879 163.69861555044676 -2.3140001753792623 23.151832206196417 -23.650526050900663
 163.69861555044676 912.16725663568207 30.120199476189839 -462.92364219537387 115.0369223983119
 -2.3140001753792623 30.120199476189839 129.30161285533623 41.272678832838409 16.689173643049287
 23.151832206196417 -462.92364219537387 41.272678832838409 627.08188763915734 -51.715541726043305
 -23.650526050900663 115.0369223983119 16.689173643049287 -51.715541726043305 217.03972895211459


# name: Z
# type: matrix
# rows: 2
# columns: 2
 0.0007915707357659678 7.4090351097025873e-05
 7.4090351097025873e-05 0.0026445816446548473


# name: f
# type: scalar
0.0034346281352422041
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -bB -I '^[#\ Created\ by\ Octave]' test.ok bmisolver_test.mat
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

