#!/bin/sh
for i in 1 2 3 4 5
do
	if [ "$i" -gt 3 ]
	then
		break
	fi
	echo "Number: $i"
done
exit 0
