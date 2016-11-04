#!/bin/bash
sum=0
num=0
for x in novo* 
do
  num=$(wc -w "$x" | awk '{print $1}')
  sum=$[$num+$sum]
done
echo $sum
rm novo*
