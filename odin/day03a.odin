package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

main :: proc() {
    // raw, ok := os.read_entire_file("../res/day03/test_a.data")
    raw, ok := os.read_entire_file("../res/day03/base.data")

    if !ok {
        fmt.println("Couldn't read data from file")
        return
    }

    defer delete(raw)

    buf := strings.builder_make()

    read_number :: proc(i: ^int, raw: ^[]byte) -> (num: int, ok: bool) {
        buf := strings.builder_make()
        for j := i^; j < len(raw); {
            rb := raw^[j]
            if rb - '0' > 9 {
                i^ = j
                v, vok := strconv.parse_int(strings.to_string(buf))
                ok = vok
                num = vok ? v : 0
                return
            } else {
                strings.write_byte(&buf, rb)
            }
            j += 1
        }

        return -1, false
    }

    expect :: proc(expected_rune: rune, i: ^int, raw: ^[]byte) -> (ok: bool) {
        v := cast(rune)raw^[i^] == expected_rune
        i^ += 1
        return v
    }

    mul_enabled := true
    res := 0
    for i := 0; i < len(raw); {
        rb := raw[i]
        strings.write_byte(&buf, rb)

        bufs := strings.to_string(buf)
        if strings.ends_with(bufs, "mul(") {
            strings.builder_reset(&buf)
            i += 1
            num1, ok1 := read_number(&i, &raw)
            if ok1 && expect(',', &i, &raw) {
                num2, ok2 := read_number(&i, &raw)
                if ok2 && expect(')', &i, &raw) {
                    // Full hit
                    if mul_enabled do res += num1 * num2
                }
            }
        } else if strings.ends_with(bufs, "don't()") {
            strings.builder_reset(&buf)
            i += 1
            mul_enabled = false
        } else if strings.ends_with(bufs, "do()") {
            strings.builder_reset(&buf)
            i += 1
            mul_enabled = true
        } else {
            i += 1
        }
    }

    fmt.println("Result", res)
}