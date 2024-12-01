package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:math"

main :: proc() {
	raw, ok := os.read_entire_file("../res/day01/base.data")
	if !ok {
		fmt.println("Couldn't read data from file")
		return
	}
	defer delete(raw)

	data := string(raw)
	
	left: [dynamic]int
	right: [dynamic]int
	for line in strings.split_lines_iterator(&data) {
		d := strings.fields(line)
		ls, rs := d[0], d[1]

		l, lok := strconv.parse_int(ls)
		r, rok := strconv.parse_int(rs)

		if !(lok && rok) {
			fmt.println("Couldn't convert one of the input strings to number")
			return
		}

		append(&left, l)
		append(&right, r)
	}

	slice.sort(left[:])
	slice.sort(right[:])

	// fmt.println(left)
	// fmt.println(right)

	counter := make(map[int]int)
	defer delete(counter)

	for num in right {
		if !(num in counter) { counter[num] = 0 }
		counter[num] += 1
	}

	sum := 0
	for num in left {
		if num in counter {
			sum += num * counter[num]
		}
	}

	// fmt.println(counter)
	fmt.println(sum)
}