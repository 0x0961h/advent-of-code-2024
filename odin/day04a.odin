package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

CharStat :: struct {
    r : rune,
    used : bool,
    processed : map[int]bool
}

extract_word :: proc(arr: [dynamic][dynamic]CharStat, arrlen: int, x0: int, y0: int, dx: int, dy: int) -> (string, bool) {
    buf := strings.builder_make()
    for i := 0; i < arrlen; i += 1 {
        x, y := x0 + dx * i, y0 + dy * i
        if y < 0 || x < 0 ||y >= len(arr) || x >= len(arr[y]) do return "", false
        strings.write_rune(&buf, arr[y][x].r)
    }
    return strings.to_string(buf), true;
}

main :: proc() {
    // raw, ok := os.read_entire_file("../res/day04/test.data")
    raw, ok := os.read_entire_file("../res/day04/base.data")

    if !ok {
        fmt.println("Couldn't read data from file")
        return
    }

    defer delete(raw)

    data := string(raw)
    lines := strings.split_lines(data)
    arr := make([dynamic][dynamic]CharStat, len(lines))

    for line, y in lines {
        arr[y] = make([dynamic]CharStat, len(line))
        for char, x in line {
            arr[y][x] = CharStat{char, false, make(map[int]bool)}
        }
    }

    h := len(arr)
    w := len(arr[0])
    count := 0
    for line, y in arr {
        if y == 0 || y == h - 1 do continue
        for char, x in line {
            if x == 0 || x == w - 1 do continue

            w1, ok1 := extract_word(arr, 3, x + 1, y + 1, -1, -1)
            w2, ok2 := extract_word(arr, 3, x - 1, y + 1, +1, -1)

            if (w1 == "MAS" || w1 == "SAM") && (w2 == "MAS" || w2 == "SAM") {
                count += 1
                arr[y - 1][x - 1].used = true
                arr[y - 1][x + 1].used = true
                arr[y][x].used = true
                arr[y + 1][x - 1].used = true
                arr[y + 1][x + 1].used = true
            }

            // for dx in -1..=1 do for dy in -1..=1 do if !(dx == 0 && dy == 0) {
            //     word, ok := extract_word(arr, 4, x, y, dx, dy)
            //     if ok && (word == "XMAS") {
            //         count += 1
            //         for i in 0..=3 do arr[y + dy * i][x + dx * i].used = true
            //     }
            // }
        }
    }

    for line in arr {
        for c in line {
            if c.used {
                fmt.print(c.r)
            } else {
                fmt.print('.')
            }
        }
        fmt.println()
    }

    // fmt.println()
    fmt.println("Count", count)
}