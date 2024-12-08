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

	left_list: sa.Small_Array(1000, int)
	right_list: sa.Small_Array(1000, int)

	i := 0
	for chunk in strings.split_multi_iterate(&input, delimiters[:]) {
		number, ok := strconv.parse_int(chunk)

		if !ok {
			panic("Couldn't parse number from a chunk")
		}

		if i % 2 == 0 {
			sa.append(&left_list, number)
		} else {
			sa.append(&right_list, number)
		}
		i += 1
	}


	if sa.len(left_list) != sa.len(right_list) {
		panic("Lists aren't equal")
	}

	left_slice := sa.slice(&left_list)
	right_slice := sa.slice(&right_list)
	slice.sort(left_slice)
	slice.sort(right_slice)

	total_diff_distance := calculate_total_diff_distance(left_slice, right_slice)
	fmt.printfln("Total distance between the lists is: %d", total_diff_distance)

	similarity_score := calculate_similarity_score(left_slice, right_slice)
	fmt.printfln("Similarity score between the lists is: %d", similarity_score)
}

calculate_total_diff_distance :: proc(sorted_left: []int, sorted_right: []int) -> int {
	total_distance := 0
	for i in 0 ..< 1000 {
		diff := math.abs(sorted_left[i] - sorted_right[i])
		total_distance += diff
	}
	return total_distance
}

calculate_similarity_score :: proc(left: []int, right: []int) -> int {
	right_list_histogram := make(map[int]int)
	defer delete(right_list_histogram)

	for number in right {
		ok := number in right_list_histogram
		if !ok {
			right_list_histogram[number] = 1
		} else {
			right_list_histogram[number] += 1
		}
	}

	total_score := 0
	for number in left {
		frequency := right_list_histogram[number]
		total_score += number * frequency
	}

	return total_score
}
