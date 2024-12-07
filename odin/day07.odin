package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

Operator :: enum {
    ADD, MUL
}

incr :: proc(arr : ^[dynamic]Operator, ind : int) -> bool {
    if arr[ind] == .ADD do arr[ind] = .MUL 
    else if arr[ind] == .MUL {
        if ind == len(arr) - 1 do return false
        if incr(arr, ind + 1) do arr[ind] = .ADD; else do return false
    }

    return true
}

calc :: proc (vals: ^[dynamic]int, ops : ^[dynamic]Operator) -> int {
    res := 0
    for i in 0..<len(vals) {
        if i == 0 do res = vals[0]
        else {
            switch ops[i - 1] {
                case .ADD: res += vals[i]
                case .MUL: res *= vals[i]
            }
        }
    }
    return res
}

print_frml :: proc (vals: ^[dynamic]int, ops : ^[dynamic]Operator, res: int) {
    for i in 0..<len(vals) {
        if i == 0 do fmt.print(vals[0])
        else {
            switch ops[i - 1] {
                case .ADD: fmt.print("+ "); fmt.print(vals[i])
                case .MUL: fmt.print("* "); fmt.print(vals[i])
            }
        }
        fmt.print(" ")
    }
}

main :: proc() {
    // raw, ok := os.read_entire_file("../res/day07/test.data")
    raw, ok := os.read_entire_file("../res/day07/base.data")

    if !ok {
        fmt.println("Couldn't read data from file")
        return
    }

    defer delete(raw)

    data := string(raw)
    sum := 0
    added : bool
    for line in strings.split_lines_iterator(&data) {
        added = false
        argstr := strings.fields(line)
        trg, _ := strconv.parse_int(argstr[0][:len(argstr[0]) - 1])
        argstr = argstr[1:]

        argint := make([dynamic]int)
        defer delete(argint)
        for s in argstr {
            v, _ := strconv.parse_int(s)
            append(&argint, v)
        }

        sols := make([dynamic]Operator, len(argint) - 1)
        defer delete(sols)

        fmt.print(trg, argint)
        for {
            if !added {
                val := calc(&argint, &sols)
                if val == trg {
                    fmt.print("\t\t")
                    sum += val
                    print_frml(&argint, &sols, trg)
                    added = true
                }
            }
            v := incr(&sols, 0)
            if !v do break
        }
        fmt.println()
    }

    fmt.println("\n===\n")
    fmt.println("Sum", sum)
}