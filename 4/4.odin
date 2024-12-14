package main

import "core:fmt"
import "core:strings"
import "core:testing"
import "core:unicode/utf8"

main :: proc() {
	input: string = #load("./input.txt")

	grid := strings.split_lines(input)

	n := count_words(grid, "XMAS")
	fmt.printfln("XMAS appears %d times", n)
}

count_words :: proc(haystack: []string, needle: string) -> int {
	count := 0
	for line, y in haystack {
		for column, x in line {
			find(haystack, {x, y}, needle, &count)
		}
	}
	return count
}

find :: proc(haystack: []string, coords: [2]int, needle: string, count: ^int) {
	directions := [8][2]int {
		{1, 0}, //right
		{-1, 0}, //left
		{0, 1}, //bottom
		{0, -1}, //top
		{1, 1}, //bottom-right
		{-1, -1}, //top-left
		{1, -1}, //top-right
		{-1, 1}, //bottom-left
	}

	min_y := 0
	max_y := len(haystack) - 1
	min_x := 0
	max_x := len(haystack[coords.y]) - 1

	direction: for transform in directions {
		dt := (transform * (len(needle) - 1)) + coords
		if dt.y < min_y || dt.y > max_y || dt.x < min_x || dt.x > max_x {
			continue direction
		}
		depth: for char, i in needle {
			p := (transform * i) + coords
			if utf8.rune_at(haystack[p.y], p.x) != char {
				continue direction
			}
		}
		count^ += 1
	}
}

@(test)
sample_test :: proc(t: ^testing.T) {
	sample := [?]string {
		"MMMSXXMASM",
		"MSAMXMSMSA",
		"AMXSXMAAMM",
		"MSAMASMSMX",
		"XMASAMXAMM",
		"XXAMMXXAMA",
		"SMSMSASXSS",
		"SAXAMASAAA",
		"MAMMMXMMMM",
		"MXMXAXMASX",
	}

	counted := count_words(sample[:], "XMAS")

	testing.expect_value(t, counted, 18)
}
