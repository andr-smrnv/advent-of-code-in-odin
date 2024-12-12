package main

import "core:fmt"
import "core:strconv"

Op :: struct {
	type:     enum {
		Multiplication,
		Do,
		Dont,
	},
	operands: [2]int,
}

main :: proc() {
	input: string = #load("./input.txt")

	ops := make([dynamic]Op)
	defer delete(ops)

	for char, index in input {
		switch char {

		case 'm':
			if input[index:index + 4] == "mul(" {
				operands_count := 0
				operands := [2]int{}
				numbers_in_progress := false

				begin := index + 4
				curr_pos := begin
				collect_operands: for {
					switch input[curr_pos] {
					case '1', '2', '3', '4', '5', '6', '7', '8', '9', '0':
						curr_pos += 1
						numbers_in_progress = true
					case ',':
						if numbers_in_progress == false {
							break collect_operands
						}
						if operands_count >= 2 {
							break collect_operands
						}
						if parsed, ok := strconv.parse_int(input[begin:curr_pos]); ok {
							operands[operands_count] = parsed
						} else {
							break collect_operands
						}

						operands_count += 1
						begin = curr_pos + 1
						curr_pos = begin
					case ')':
						if numbers_in_progress == false {
							break collect_operands
						}
						if operands_count != 1 {
							break collect_operands
						}

						if parsed, ok := strconv.parse_int(input[begin:curr_pos]); ok {
							operands[operands_count] = parsed
						} else {
							break collect_operands
						}

						append(&ops, Op{type = .Multiplication, operands = operands})
						break collect_operands
					case:
						break collect_operands
					}
				}
			}
		case 'd':
			if input[index:index + 7] == "don't()" {
				append(&ops, Op{type = .Dont})
			} else if input[index:index + 4] == "do()" {
				append(&ops, Op{type = .Do})
			}
		}
	}

	sum := 0
	enabled := true
	for op in ops {
		switch op.type {
		case .Do:
			enabled = true
		case .Dont:
			enabled = false
		case .Multiplication:
			if enabled {
				sum += op.operands[0] * op.operands[1]
			}
		}
	}

	fmt.println(sum)
}
