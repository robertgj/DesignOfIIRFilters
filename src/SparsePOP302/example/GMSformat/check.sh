#!/bin/sh

for name in `ls *.gms`
do
	echo ${name}
	num=`grep -n "* set non default bounds" ${name} | cut -d":" -f1`
	if [ -n "${num}" ]; then
			num2=`expr ${num} + 1`
			head -n${num2} ${name} | tail -n2
	else
		echo "${name} does not have this line."
	fi
done
