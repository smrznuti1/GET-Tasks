#! /bin/bash



regex="k[0-9a-f]{8}\.kod"

while IFS= read -r line; do
	touch "$line"

	if ! [[ $line =~ $regex ]]; then
		echo "$line"
	else
		letterG="${line:7:1}"
		letterE="${line:8:1}"
		numG=$(printf "%d\n" "0x$letterG")

		if (( numG % 2 == 0 )); then
			mkdir -p "${letterG}0/${letterE}0"
			mv "$line" "${letterG}0/${letterE}0"
		else
			numG=$((numG - 1))
			hexG=$(printf "%x\n" $numG)
			mkdir -p "${hexG}0/${letterE}0"
			mv "$line" "${hexG}0/${letterE}0"
		fi
	fi
	

done < ../prilog.txt
