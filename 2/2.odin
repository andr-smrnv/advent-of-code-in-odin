package main

import "core:fmt"
import "core:log"
import "core:math"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"

main :: proc() {
	input: string = #load("./input.txt")

	reports := make([dynamic][dynamic]int)
	defer {
		for report in reports do delete(report)
		delete(reports)
	}

	raw_reports := strings.split_lines(input)
	for &raw_report in raw_reports {
		report := make([dynamic]int)
		for raw_level in strings.fields_iterator(&raw_report) {
			level, ok := strconv.parse_int(raw_level)
			if !ok do panic("Couldn't parse number from a report")
			append(&report, level)
		}
		append(&reports, report)
	}
	assert(len(raw_reports) == len(reports))

	safe_reports_amount: int
	safe_reports_with_dampener: int
	for report in reports {
		if is_report_safe(report[:]) {
			safe_reports_amount += 1
		} else if is_report_safe_with_problem_dampener(report[:]) {
			safe_reports_with_dampener += 1
		}
	}

	fmt.printfln("Total number of reports is: %d", len(reports))
	fmt.printfln("The number of safe reports is: %d", safe_reports_amount)
	fmt.printfln("The number of safe reports with dampener is: %d", safe_reports_with_dampener)
	fmt.printfln(
		"Total number of safe reports: %d",
		safe_reports_amount + safe_reports_with_dampener,
	)
}

is_report_safe :: proc(report: []int) -> bool {
	prev_diff: int
	first_run := true
	length := len(report)
	for curr, i in report {
		if i + 1 == length do break

		next := report[i + 1]
		diff := next - curr
		magnitude := math.abs(diff)

		if magnitude < 1 || magnitude > 3 {
			return false
		}
		if !first_run && ((diff < 0) != (prev_diff < 0)) {
			return false
		}

		prev_diff = diff
		if first_run do first_run = false
	}
	return true
}

is_report_safe_with_problem_dampener :: proc(report: []int) -> bool {
	for i in 0 ..< len(report) {
		if i == 0 {
			if is_report_safe(report[1:]) {
				return true
			}
		}
		if i == len(report) - 1 {
			if is_report_safe(report[:len(report) - 1]) {
				return true
			}
		}

		skipped := slice.concatenate([][]int{report[:i], report[i + 1:]})
		defer delete(skipped)
		if is_report_safe(skipped) {
			return true
		}
	}
	return false
}

@(test)
test_examples :: proc(t: ^testing.T) {
	safe_reports := [2][5]int{{7, 6, 4, 2, 1}, {1, 3, 6, 7, 9}}
	for &report in safe_reports {
		testing.expectf(t, is_report_safe(report[:]), "Values were", report[:])
	}

	unsafe_reports := [4][5]int{{1, 2, 7, 8, 9}, {9, 7, 6, 2, 1}, {1, 3, 2, 4, 5}, {8, 6, 4, 4, 1}}
	for &report in unsafe_reports {
		fmt.println("Testing", report)
		testing.expectf(t, !is_report_safe(report[:]), "Values were", report[:])
	}
}

@(test)
test_safe_report :: proc(t: ^testing.T) {
	safe_report := [?]int{-11, -9, -7, -4, -1, 0, 1}

	testing.expect_value(t, is_report_safe(safe_report[:]), true)
}
