package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:math"

sign :: proc(x: int) -> int {
	return cast(int)(x > 0) - cast(int)(x < 0);
}

pad_right :: proc(s: string, w: int) -> string {
	topad := w - len(s);
	if topad <= 0 { return s; }
	return strings.concatenate({s, strings.repeat(" ", topad)});
}

main :: proc() {
	// raw, ok := os.read_entire_file("../res/day02/test.data")
	raw, ok := os.read_entire_file("../res/day02/base.data")

	if !ok {
		fmt.println("Couldn't read data from file")
		return
	}

	defer delete(raw)

	data := string(raw)

	safecounter := 0
	for report in strings.split_lines_iterator(&data) {
		d := strings.fields(report)
		levels := make([]int, len(d))
		diffs := make([]int, len(d) - 1)
		for r, i in d {
			l, lok := strconv.parse_int(r)
			if !ok {
				fmt.println("Couldn't convert one of the input strings to number")
				return
			}

			levels[i] = l
			if i > 0 {
				diffs[i - 1] = levels[i] - levels[i - 1]
			}
		}

		fmt.print(pad_right(fmt.tprint(levels), 32), " .. ")
		fmt.print(pad_right(fmt.tprint(diffs), 32), " .. ")

		isSafe := true
		loop: for diff, i in diffs {
			if diff == 0 || math.abs(diff) > 3 {
				fmt.printf("✗ Unsafe (difference: %v)", math.abs(diff))
				isSafe = false
				break loop
			} else if i > 0 && sign(diff) != sign(diffs[0]) {
				fmt.print("✗ Unsafe (not gradual)")
				isSafe = false
				break loop
			}
		}

		if isSafe {
			safecounter += 1
			fmt.print("✓ Safe")
		}

		fmt.println()
	}

	fmt.println()
	fmt.println("Safe Counter: ", safecounter)
	fmt.println()
}