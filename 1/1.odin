package main

import sa "core:container/small_array"
import "core:fmt"
import "core:math"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	input: string = #load("./input.txt")
	delimiters := [?]string{"   ", "\r\n"}

	first: sa.Small_Array(1000, int)
	second: sa.Small_Array(1000, int)

	i := 0
	for chunk in strings.split_multi_iterate(&input, delimiters[:]) {
		number, ok := strconv.parse_int(chunk)

		if !ok {
			panic("Couldn't parse number from a chunk")
		}

		if i % 2 == 0 {
			sa.append(&first, number)
		} else {
			sa.append(&second, number)
		}
		i += 1
	}

	if sa.len(first) != sa.len(second) {
		panic("Lists aren't equal")
	}

	first_sorted := sa.slice(&first)
	second_sorted := sa.slice(&second)
	slice.sort(first_sorted)
	slice.sort(second_sorted)

	sum := 0
	for i in 0 ..< 1000 {
		diff := math.abs(first_sorted[i] - second_sorted[i])
		sum += diff
	}


	fmt.printfln("The result is: %d", sum)
}
