#!/bin/sh
for i in 1 2 3 4 5
do
	if [ $i -eq 3 ]
	then
		continue
	fi
	echo "Number: $i"
done
exit 0
