package main

import "core:fmt"
import "core:math"
import "core:strings"
import "core:testing"
import "core:unicode/utf8"

main :: proc() {
	input: string = #load("./input.txt")

	grid := strings.split_lines(input)

	n := count_xmas(grid)
	fmt.printfln("XMAS appears %d times", n)

	n2 := count_x_mas(grid)
	fmt.printfln("X-MAS appears %d times", n2)
}

count_xmas :: proc(haystack: []string) -> int {
	count := 0
	for line, y in haystack {
		for column, x in line {
			find_xmas(haystack, {x, y}, "XMAS", &count)
		}
	}
	return count
}

find_xmas :: proc(haystack: []string, coords: [2]int, needle: string, count: ^int) {
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

count_x_mas :: proc(haystack: []string) -> int {
	count := 0
	for line, y in haystack {
		if y == 0 do continue
		for column, x in line {
			if x == 0 do continue
			if column == 'A' {
				find_x_mas(haystack, {x, y}, "MAS", &count)
			}
		}
	}
	return count
}

find_x_mas :: proc(haystack: []string, coords: [2]int, needle: string, count: ^int) {
	directions := [4][2]int {
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
		p := coords + transform
		opposite := coords - transform
		if math.max(p.x, opposite.x) > max_x ||
		   math.min(p.x, opposite.x) < min_x ||
		   math.max(p.y, opposite.y) > max_y ||
		   math.min(p.y, opposite.y) < min_y {
			return
		}

		found := utf8.rune_at(haystack[p.y], p.x)
		opposite_found := utf8.rune_at(haystack[opposite.y], opposite.x)

		if found == 'M' && opposite_found == 'S' {
			continue
		}

		if found == 'S' && opposite_found == 'M' {
			continue
		}

		return
	}

	count^ += 1
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

	counted := count_xmas(sample[:])

	testing.expect_value(t, counted, 18)
}

@(test)
sample_test_2 :: proc(t: ^testing.T) {
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

	counted := count_x_mas(sample[:])

	testing.expect_value(t, counted, 9)
}
