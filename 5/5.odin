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

	successor_map, predecessor_map := make_precedence_maps(rules[:])
	defer {
		delete_precedence_map(successor_map)
		delete_precedence_map(predecessor_map)
	}

	sum := 0
	total_ordered := 0
	total_unordered := 0
	sum_of_newly_ordered := 0
	for update, i in updates {
		if is_in_order(update[:], &successor_map, &predecessor_map) {
			total_ordered += 1
			sum += update[(len(update) - 1) / 2]
		} else {
			slice := update[:]
			sort_with_rules(slice, &successor_map, &predecessor_map)
			sum_of_newly_ordered += update[(len(slice) - 1) / 2]
			total_unordered += 1
		}
	}

	fmt.println("Sum:", sum)
	fmt.println("Total Ordered:", total_ordered)
	fmt.println("Total Unordered:", total_unordered)
	fmt.println("Sum of newly ordered:", sum_of_newly_ordered)
}


PrecedenceMap :: map[int][dynamic]int
make_precedence_maps :: proc(rules: []Rule) -> (PrecedenceMap, PrecedenceMap) {
	before := make(PrecedenceMap)
	after := make(PrecedenceMap)

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

delete_precedence_map :: proc(precedence: PrecedenceMap) {
	defer {
		for key, value in precedence {
			delete(value)
		}
		delete(precedence)
	}
}

is_in_order :: proc(
	list: []int,
	successor_map: ^PrecedenceMap,
	predecessor_map: ^PrecedenceMap,
) -> bool {
	for curr, i in list {
		before, should_come_before := successor_map[curr]
		if should_come_before {
			#reverse for prev, j in list[:i] {
				_, found := slice.linear_search(before[:], prev)
				if found {
					return false
				}
			}
		}

		after, should_come_after := predecessor_map[curr]
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

sort_with_rules :: proc(list: []int, before: ^PrecedenceMap, after: ^PrecedenceMap) {
	context.user_ptr = &[2]^PrecedenceMap{before, after}
	slice.sort_by_cmp(list, proc(a: int, b: int) -> slice.Ordering {
		rules_matrix := cast(^[2]^PrecedenceMap)context.user_ptr

		return compare(a, b, rules_matrix[0], rules_matrix[1])
	})
}

compare :: proc(x: int, y: int, before: ^PrecedenceMap, after: ^PrecedenceMap) -> slice.Ordering {
	if _, ok := slice.linear_search(before[x][:], y); ok {
		return .Less
	}

	if _, ok := slice.linear_search(after[x][:], y); ok {
		return .Greater
	}

	return .Equal
}


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

	successor_map, predecessor_map := make_precedence_maps(rules[:])
	defer {
		delete_precedence_map(successor_map)
		delete_precedence_map(predecessor_map)
	}

	testing.expect_value(t, is_in_order(updates[0][:], &successor_map, &predecessor_map), true)
	testing.expect_value(t, is_in_order(updates[1][:], &successor_map, &predecessor_map), true)
	testing.expect_value(t, is_in_order(updates[2][:], &successor_map, &predecessor_map), true)
	testing.expect_value(t, is_in_order(updates[3][:], &successor_map, &predecessor_map), false)
	testing.expect_value(t, is_in_order(updates[4][:], &successor_map, &predecessor_map), false)
	testing.expect_value(t, is_in_order(updates[5][:], &successor_map, &predecessor_map), false)

	to_order := slice.clone(updates[5][:])
	defer delete(to_order)
	fmt.println("Before order", to_order)
	sort_with_rules(to_order, &successor_map, &predecessor_map)
	fmt.println("After order", to_order)
	testing.expect_value(t, is_in_order(to_order, &successor_map, &predecessor_map), true)
}
