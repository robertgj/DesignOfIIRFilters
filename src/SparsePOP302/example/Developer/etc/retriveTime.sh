#!/bin/sh 

#file=`date +"%Y%m%d"`
#file=$file.csv
#if [ -e $file ]; then
#        rm $file
#fi
#touch $file

idx1=`grep "total" $1 | awk '{print $3}'`
#echo $idx1
idx2=`grep "  elpsed time" $1 | awk '{print $3}'` 
#echo $idx2
idx3=`grep "computing error" $1 | awk '{print $9}'` 
#echo $idx3


s=0;
for i in `echo $idx1`
do
	#echo $i
	#echo $s
	s=`echo "$s+$i" | bc`
done
for i in `echo $idx2`
do
	#echo $i
	#echo $s
	s=`echo "$s+$i" | bc`
done
for i in `echo $idx3`
do
	#echo $i
	#echo $s
	s=`echo "$s+$i" | bc`
done
echo "total cpu time = $s [sec]"
m=`echo "$s/60" | bc`
echo "total cpu time = $m [min]"
