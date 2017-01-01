#!/bin/sh

randomVal=$[$[$RANDOM%10]+1]

echo 随机${randomVal}次

for ((I=1;i<=$randomVal;i++))
do 
{
echo $i
echo 'i am jumbo.' >> readme.md
git add .
git commit -m'@itzhangbao'
}
done
