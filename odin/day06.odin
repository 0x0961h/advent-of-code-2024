package main

import "core:fmt"
import "core:os"
import "core:strings"

Vec2i :: struct {
    x : int,
    y : int,
}

MapCell :: struct {
    is_wall : bool,
    was_passed : bool,
}

GuardData :: struct {
    pos : Vec2i,
    dir : Vec2i,
    out : bool
}

print_map :: proc(level: ^[dynamic][dynamic]MapCell, guard: ^GuardData) {
    fmt.println()
    for row, y in level {
        for cell, x in row {
            if !guard.out && guard.pos.x == x && guard.pos.y == y {
                if guard.dir.x == -1 && guard.dir.y == 0 {
                    fmt.print("<")
                } else if guard.dir.x == +1 && guard.dir.y == 0 {
                    fmt.print(">")
                } else if guard.dir.x == 0 && guard.dir.y == -1 {
                    fmt.print("^")
                } else if guard.dir.x == 0 && guard.dir.y == +1 {
                    fmt.print("v")
                } else {
                    fmt.print("?")
                }
            } else if cell.is_wall {
                fmt.print("#")
            } else if cell.was_passed {
                fmt.print("x")
            } else {
                fmt.print(".")                
            }
        }
        fmt.println()
    }
    fmt.println()
}

count_cover :: proc(level: ^[dynamic][dynamic]MapCell) -> (res: int) {
    res = 0
    for row, y in level {
        for cell, x in row {
            if cell.was_passed {
                res += 1
            }
        }
    }
    return
}

guard_rot :: proc(guard: ^GuardData) {
    if guard.dir.x == -1 && guard.dir.y == 0 do guard.dir.x, guard.dir.y = 0, -1
    else if guard.dir.x == +1 && guard.dir.y == 0 do guard.dir.x, guard.dir.y = 0, +1
    else if guard.dir.x == 0 && guard.dir.y == -1 do guard.dir.x, guard.dir.y = +1, 0
    else if guard.dir.x == 0 && guard.dir.y == +1 do guard.dir.x, guard.dir.y = -1, 0
}

guard_move :: proc(level: ^[dynamic][dynamic]MapCell, guard: ^GuardData) {
    if guard.out do return

    h, w := len(level), len(level[0])
    x, y := guard.pos.x, guard.pos.y
    dx, dy := guard.dir.x, guard.dir.y

    in_bound :: proc(x, y, dx, dy, w, h: int) -> bool {
        return x + dx >= 0 && x + dx < w && y + dy >= 0 && y + dy < h
    }

    for in_bound(x, y, dx, dy, w, h) && !level[y + dy][x + dx].is_wall {
        level[y][x].was_passed = true
        x += dx
        y += dy
    }

    guard.pos.x, guard.pos.y = x, y
    if in_bound(x, y, dx, dy, w, h) {
        guard_rot(guard)
    } else {
        level[guard.pos.y][guard.pos.x].was_passed = true
        guard.out = true
    }
}

main :: proc() {
    // raw, ok := os.read_entire_file("../res/day06/test.data")
    raw, ok := os.read_entire_file("../res/day06/base.data")

    if !ok {
        fmt.println("Couldn't read data from file")
        return
    }

    defer delete(raw)

    data := string(raw)
    lines := strings.split_lines(data)
    level := make([dynamic][dynamic]MapCell, len(lines))
    defer delete(level)

    guard : GuardData

    for line, y in lines {
        level[y] = make([dynamic]MapCell, len(line))

        for char, x in line {
            if char == '.' do level[y][x] = MapCell{ false, false }
            else if char == '#' do level[y][x] = MapCell{ true, false }
            else if char == '^' {
                level[y][x] = MapCell{ false, false }
                guard = GuardData { Vec2i { x, y }, Vec2i { 0, -1 }, false }
            }
        }
    }

    print_map(&level, &guard)
    for !guard.out do guard_move(&level, &guard)
    print_map(&level, &guard)

    fmt.println("Count", count_cover(&level), 5444)
}