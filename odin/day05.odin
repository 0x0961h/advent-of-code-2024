package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

has_key :: proc(m: map[$K]$V, key: K) -> bool {
    v, ok := m[key]
    return ok
}

contains :: proc(arr: [dynamic]$T, val: T) -> bool {
    for varr in arr {
        if varr == val do return true
    }

    return false
}

main :: proc() {
    // raw, ok := os.read_entire_file("../res/day05/test.data")
    raw, ok := os.read_entire_file("../res/day05/base.data")

    if !ok {
        fmt.println("Couldn't read data from file")
        return
    }

    defer delete(raw)

    data := string(raw)
    rules : map[string][dynamic]string

    res_sum := 0
    reading_rules := true
    for line in strings.split_lines_iterator(&data) {
        if reading_rules {
            if line == "" {
                reading_rules = false
            } else {
                spl := strings.split(line, "|")
                if !has_key(rules, spl[0]) {
                    rules[spl[0]] = make([dynamic]string)
                }
                append(&rules[spl[0]], spl[1])
            }
        } else {
            spl := strings.split(line, ",")
            valid := true
            loop: #reverse for n, i in spl {
                for j := i - 1; j >= 0; j -= 1 {
                    if contains(rules[n], spl[j]) {
                        valid = false
                        break loop
                    }
                }
            }

            if valid {
                v, ok := strconv.parse_int(spl[len(spl) / 2])
                res_sum += v
            }
        }
    }

    fmt.println(res_sum)
}