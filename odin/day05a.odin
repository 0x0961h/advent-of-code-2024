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

is_valid :: proc(arr: []string, bad_rules: map[string][dynamic]string) -> bool {
    loop: #reverse for n, i in arr {
        for j := i - 1; j >= 0; j -= 1 {
            if contains(bad_rules[n], arr[j]) do return false
        }
    }

    return true
}

cmp :: proc(gt_rules: ^map[string][dynamic]string, lt_rules: ^map[string][dynamic]string, a, b: string) -> int {
    if contains(gt_rules^[a], b) do return +1
    else if contains(lt_rules^[a], b) do return -1
    else do return 0
}

do_sort :: proc(gt_rules: ^map[string][dynamic]string, lt_rules: ^map[string][dynamic]string, spl: ^[]string) {
    was_swapped := true
    for was_swapped {
        was_swapped = false
        for i := 0; i < len(spl) - 1; i += 1 {
            cmpv := cmp(gt_rules, lt_rules, spl[i], spl[i + 1])
            if cmpv == -1 {
                spl[i], spl[i + 1] = spl[i + 1], spl[i]
                was_swapped = true
            } else if cmpv == 0 {
                panic("cmpv == 0")
            }
        }
    }
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
    lt_rules : map[string][dynamic]string
    gt_rules : map[string][dynamic]string

    res_sum := 0
    reading_rules := true
    for line in strings.split_lines_iterator(&data) {
        if reading_rules {
            if line == "" {
                reading_rules = false
            } else {
                spl := strings.split(line, "|")
                
                if !has_key(lt_rules, spl[1]) do lt_rules[spl[1]] = make([dynamic]string)
                if !has_key(gt_rules, spl[0]) do gt_rules[spl[0]] = make([dynamic]string)
                
                append(&lt_rules[spl[1]], spl[0])
                append(&gt_rules[spl[0]], spl[1])
            }
        } else {
            spl := strings.split(line, ",")
            if !is_valid(spl, gt_rules) {
                do_sort(&gt_rules, &lt_rules, &spl)
                v, vok := strconv.parse_int(spl[len(spl) / 2])
                res_sum += v
            }
        }
    }

    fmt.println(res_sum)
}