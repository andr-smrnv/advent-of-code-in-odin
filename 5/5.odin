package main

import "core:fmt"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"
import "core:unicode/utf8"

Rule :: [2]int

main :: proc() {
	input: string = #load("./input.txt")


	rules, updates := parse_input(input)
	defer {
		delete(rules)
		for update in updates {
			delete(update)
		}
		delete(updates)
	}

	before_map, after_map := make_precedence_maps(rules[:])
	defer {
		delete_precedence_map(before_map)
		delete_precedence_map(after_map)
	}

	sum := 0
	total_ordered := 0
	total_unordered := 0
	for update, i in updates {
		if is_in_order(update[:], &before_map, &after_map) {
			total_ordered += 1
			sum += update[(len(update) - 1) / 2]
		} else {
			slice := update[:]
			total_unordered += 1
			break
		}
	}

	fmt.println("Sum:", sum)
	fmt.println("Total Ordered:", total_ordered)
	fmt.println("Total Unordered:", total_unordered)
}

make_precedence_maps :: proc(rules: []Rule) -> (map[int][dynamic]int, map[int][dynamic]int) {
	before := make(map[int][dynamic]int)
	after := make(map[int][dynamic]int)

	for rule in rules {
		if !(rule.x in before) {
			before[rule.x] = make([dynamic]int)
		}
		append(&before[rule.x], rule.y)

		if !(rule.y in after) {
			after[rule.y] = make([dynamic]int)
		}
		append(&after[rule.y], rule.x)
	}

	return before, after
}

delete_precedence_map :: proc(precedence: map[int][dynamic]int) {
	defer {
		for key, value in precedence {
			delete(value)
		}
		delete(precedence)
	}
}

is_in_order :: proc(
	list: []int,
	before_map: ^map[int][dynamic]int,
	after_map: ^map[int][dynamic]int,
) -> bool {
	for curr, i in list {
		before, should_come_before := before_map[curr]
		if should_come_before {
			#reverse for prev, j in list[:i] {
				_, found := slice.linear_search(before[:], prev)
				if found {
					return false
				}
			}
		}

		after, should_come_after := after_map[curr]
		if should_come_after {
			for next, j in list[i:] {
				_, found := slice.linear_search(after[:], next)
				if found {
					return false
				}
			}
		}

	}
	return true
}

// sort_with_rules :: proc(list: []int, before: ^map[int][dynamic]int, after: ^map[int][dynamic]int) {
// 	context.user_ptr = &[2]^map[int][dynamic]int{before, after}
// 	slice.sort_by_cmp(list, proc(a: int, b: int) -> slice.Ordering {
// 		rules_matrix := cast(^[2]^map[int][dynamic]int)context.user_ptr
// 		before, has_numbers_after := rules_matrix[0][a]

// 		if has_numbers_after {
// 			_, found := slice.linear_search(before[:], b)
// 			return .Less
// 		}

// 		after, has_numbers_before := rules_matrix[1][a]
// 		if has_numbers_before {
// 			_, found := slice.linear_search(after[:], b)
// 			return .Greater
// 		}
// 		return .Equal
// 	})
// }


parse_input :: proc(input: string) -> (rules: [dynamic]Rule, updates: [dynamic][dynamic]int) {
	lines := strings.split_lines(input)
	defer delete(lines)

	rules = make([dynamic]Rule)
	updates = make([dynamic][dynamic]int)

	rules_done := false
	for line in lines {
		if len(line) == 0 {
			rules_done = true
			continue
		}

		if !rules_done {
			left, _ := strconv.parse_int(line[0:2])
			right, _ := strconv.parse_int(line[3:])
			append(&rules, Rule{left, right})
		} else {
			update := make([dynamic]int)
			res, err := strings.split(line, ",")
			defer delete(res)

			for numeric in res {
				number, _ := strconv.parse_int(numeric)
				append(&update, number)
			}
			append(&updates, update)
		}
	}

	return rules, updates
}

@(test)
first_sample :: proc(t: ^testing.T) {
	input: string = #load("./sample.txt")

	rules, updates := parse_input(input)
	defer {
		delete(rules)
		for update in updates {
			delete(update)
		}
		delete(updates)
	}

	before_map, after_map := make_precedence_maps(rules[:])
	defer {
		delete_precedence_map(before_map)
		delete_precedence_map(after_map)
	}

	testing.expect_value(t, is_in_order(updates[0][:], &before_map, &after_map), true)
	testing.expect_value(t, is_in_order(updates[1][:], &before_map, &after_map), true)
	testing.expect_value(t, is_in_order(updates[2][:], &before_map, &after_map), true)
	testing.expect_value(t, is_in_order(updates[3][:], &before_map, &after_map), false)
	testing.expect_value(t, is_in_order(updates[4][:], &before_map, &after_map), false)
	testing.expect_value(t, is_in_order(updates[5][:], &before_map, &after_map), false)

	to_order := slice.clone(updates[5][:])
	testing.expect_value(t, is_in_order(to_order, &before_map, &after_map), true)
}
