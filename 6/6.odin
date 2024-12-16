package main

import "core:fmt"
import "core:slice"
import "core:strings"
import "core:testing"
import "core:unicode/utf8"

main :: proc() {
	input: string = #load("./input.txt")

	world := strings.split_lines(input)
	defer delete(world)

	visited_cells := walk(world)
	defer delete(visited_cells)

	distinct_cells_number := count_distinct_cells(visited_cells[:])

	fmt.println("Distinct cells number:", distinct_cells_number)

}

Coords :: [2]int

Cell :: enum rune {
	Guard         = '^',
	Empty         = '.',
	Obstruction   = '#',
	Out_Of_Bounds = 'f',
}

Direction :: enum {
	North,
	East,
	South,
	West,
}

walk :: proc(world: []string) -> [dynamic]Coords {
	visited_cells := make([dynamic]Coords)

	direction_vectors := [Direction]Coords {
		.North = {0, -1},
		.East  = {+1, 0},
		.South = {0, +1},
		.West  = {-1, 0},
	}

	guard_pos := find_starting_position(world)
	append(&visited_cells, guard_pos)
	turns_count := 0
	direction := direction_vectors[cast(Direction)(turns_count % 4)]

	step: for {
		next_pos := guard_pos + direction

		switch get_cell_type(world, next_pos) {
		case .Guard: // we might encounter our starting position
		case .Empty:
			guard_pos = next_pos
			append(&visited_cells, guard_pos)
		case .Obstruction:
			turns_count += 1
			direction = direction_vectors[cast(Direction)(turns_count % 4)]
		case .Out_Of_Bounds:
			break step
		}
	}

	return visited_cells
}

get_cell_type :: proc(world: []string, p: Coords) -> Cell {
	min_y := 0
	max_y := len(world) - 1
	min_x := 0
	max_x := len(world[0]) - 1 // assuming the world has uniform X across all Y

	if p.y < min_y || p.y > max_y || p.x < min_x || p.x > max_x {
		return .Out_Of_Bounds
	}

	cell := utf8.rune_at(world[p.y], p.x)

	switch cell {
	case cast(rune)Cell.Guard:
	case cast(rune)Cell.Empty:
		return .Empty
	case cast(rune)Cell.Obstruction:
		return .Obstruction
	case:
		fmt.println("Unknown rune!", cell)
		panic("Panicking")
	}

	return .Empty
}

find_starting_position :: proc(world: []string) -> Coords {
	coords := Coords{0, 0}
	for line, y in world {
		for cell, x in line {
			switch cell {
			case cast(rune)Cell.Guard:
				return {x, y}
			}
		}
	}
	return coords
}

count_distinct_cells :: proc(cells: []Coords) -> int {
	unique_cells := slice.clone(cells)
	slice.sort_by(unique_cells, proc(a: Coords, b: Coords) -> bool {
		if a.x - b.x != 0 do return a.x < b.x
		return a.y < b.y
	})
	unique_cells = slice.unique(unique_cells)
	defer delete(unique_cells)

	return len(unique_cells)
}


@(test)
sample_test :: proc(t: ^testing.T) {
	input: string = #load("./sample.txt")

	world := strings.split_lines(input)
	defer delete(world)

	testing.expect_value(t, find_starting_position(world), Coords{4, 6})

	visited_cells := walk(world)
	defer delete(visited_cells)

	testing.expect_value(t, count_distinct_cells(visited_cells[:]), 41)
}
