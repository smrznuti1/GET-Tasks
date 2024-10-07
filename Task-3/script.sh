#! /bin/bash

regex="k[0-9a-f]{8}\.kod"

while IFS= read -r line; do
	if [[ $line =~ $regex ]]; then
		echo "$line"
	fi
done < ../prilog.txt

