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

calc_diffs :: proc(levels: []int) -> []int {
    diffs := make([]int, len(levels) - 1)
    for i := 1; i < len(levels); i += 1 {
        diffs[i - 1] = levels[i] - levels[i - 1]
    }
    return diffs
}

SafetyResult :: enum{SAFE, SAFE_PROBE, UNSAFE_DIFF, UNSAFE_GRAD}

are_lvls_safe :: proc(levels: []int) -> SafetyResult {
    diffs := calc_diffs(levels)
    defer delete(diffs)

    loop: for diff, i in diffs {
        if diff == 0 || math.abs(diff) > 3 {
            return SafetyResult.UNSAFE_DIFF
        } else if i > 0 && sign(diff) != sign(diffs[0]) {
            return SafetyResult.UNSAFE_GRAD
        }
    }

    return SafetyResult.SAFE
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
        baselevels := make([]int, len(d))
        defer delete(baselevels)
        for r, i in d {
            l, lok := strconv.parse_int(r)
            if !ok {
                fmt.println("Couldn't convert one of the input strings to number")
                return
            }

            baselevels[i] = l
        }

        res := are_lvls_safe(baselevels)
        fmt.print(pad_right(fmt.tprint(baselevels), 32), " .. ", res)
        if res != SafetyResult.SAFE {
            fmt.println()
            probing_loop: for i := 0; i < len(baselevels); i += 1 {
                blt : [dynamic]int
                defer delete(blt)
                append(&blt, ..baselevels[:])
                ordered_remove(&blt, i)
                tres := are_lvls_safe(blt[:])
                fmt.println("    Trying to remove index ", pad_right(fmt.tprint(i), 6), pad_right(fmt.tprint(blt), 32), " .. ", tres)
                if tres == SafetyResult.SAFE {
                    res = SafetyResult.SAFE_PROBE
                    break probing_loop
                }
            }
        }

        if res == SafetyResult.SAFE || res == SafetyResult.SAFE_PROBE {
            safecounter += 1
        }

        fmt.println()
    }

    fmt.println()
    fmt.println("Safe Counter: ", safecounter)
    fmt.println()
}