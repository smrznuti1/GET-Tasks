#! /bin/bash

regex="k[0-9a-f]{8}\.kod"

while IFS= read -r line; do
	touch "$line"

	if ! [[ $line =~ $regex ]]; then
		echo "$line"
	else
		num=${line:7:1}
		echo "$num in $line"
	fi
	

done < ../prilog.txt
