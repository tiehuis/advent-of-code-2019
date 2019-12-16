// --- Day 10: Monitoring Station ---
//
// You fly into the asteroid belt and reach the Ceres monitoring station. The Elves here have an
// emergency: they're having trouble tracking all of the asteroids and can't be sure they're safe.
//
// The Elves would like to build a new monitoring station in a nearby area of space; they hand you
// a map of all of the asteroids in that region (your puzzle input).
//
// The map indicates whether each position is empty (.) or contains an asteroid (#). The asteroids
// are much smaller than they appear on the map, and every asteroid is exactly in the center of its
// marked position. The asteroids can be described with X,Y coordinates where X is the distance from
// the left edge and Y is the distance from the top edge (so the top-left corner is 0,0 and the
// position immediately to its right is 1,0).
//
// Your job is to figure out which asteroid would be the best place to build a new monitoring
// station. A monitoring station can detect any asteroid to which it has direct line of sight - that
// is, there cannot be another asteroid exactly between them. This line of sight can be at any
// angle, not just lines aligned to the grid or diagonally. The best location is the asteroid that
// can detect the largest number of other asteroids.
//
// For example, consider the following map:
//
// .#..#
// .....
// #####
// ....#
// ...##
//
// The best location for a new monitoring station on this map is the highlighted asteroid at 3,4
// because it can detect 8 asteroids, more than any other location. (The only asteroid it cannot
// detect is the one at 1,0; its view of this asteroid is blocked by the asteroid at 2,2.) All other
// asteroids are worse locations; they can detect 7 or fewer other asteroids. Here is the number of
// other asteroids a monitoring station on each asteroid could detect:
//
// .7..7
// .....
// 67775
// ....7
// ...87
//
// Here is an asteroid (#) and some examples of the ways its line of sight might be blocked. If
// there were another asteroid at the location of a capital letter, the locations marked with the
// corresponding lowercase letter would be blocked and could not be detected:
//
// #.........
// ...A......
// ...B..a...
// .EDCG....a
// ..F.c.b...
// .....c....
// ..efd.c.gb
// .......c..
// ....f...c.
// ...e..d..c
//
// Here are some larger examples:
//
//     Best is 5,8 with 33 other asteroids detected:
//
//     ......#.#.
//     #..#.#....
//     ..#######.
//     .#.#.###..
//     .#..#.....
//     ..#....#.#
//     #..#....#.
//     .##.#..###
//     ##...#..#.
//     .#....####
//
//     Best is 1,2 with 35 other asteroids detected:
//
//     #.#...#.#.
//     .###....#.
//     .#....#...
//     ##.#.#.#.#
//     ....#.#.#.
//     .##..###.#
//     ..#...##..
//     ..##....##
//     ......#...
//     .####.###.
//
//     Best is 6,3 with 41 other asteroids detected:
//
//     .#..#..###
//     ####.###.#
//     ....###.#.
//     ..###.##.#
//     ##.##.#.#.
//     ....###..#
//     ..#.#..#.#
//     #..#.#.###
//     .##...##.#
//     .....#.#..
//
//     Best is 11,13 with 210 other asteroids detected:
//
//     .#..##.###...#######
//     ##.############..##.
//     .#.######.########.#
//     .###.#######.####.#.
//     #####.##.#.##.###.##
//     ..#####..#.#########
//     ####################
//     #.####....###.#.#.##
//     ##.#################
//     #####.##.###..####..
//     ..######..##.#######
//     ####.##.####...##..#
//     .#####..#.######.###
//     ##...#.##########...
//     #.##########.#######
//     .####.#.###.###.#.##
//     ....##.##.###..#####
//     .#.#.###########.###
//     #.#.#.#####.####.###
//     ###.##.####.##.#..##
//
// Find the best location for a new monitoring station. How many other asteroids can be detected
// from that location?

const std = @import("std");

const Space = struct {
    const max_width = 128;
    const max_height = 128;

    grid: [max_width * max_height]u8,
    w: usize,
    h: usize,

    fn copy(self: *Space, other: Space) void {
        std.mem.copy(u8, &self.grid, &other.grid);
        self.w = other.w;
        self.h = other.h;
    }

    fn load(self: *Space, input_: []const u8) void {
        var max_x: ?usize = null;
        var max_y: usize = 0;

        var i: usize = 0;
        for (input_) |c| {
            switch (c) {
                '.' => {
                    self.grid[i] = 0;
                    i += 1;
                },
                '#' => {
                    self.grid[i] = 1;
                    i += 1;
                },
                '\n' => {
                    if (max_x == null) max_x = i;
                    max_y += 1;
                },
                else => unreachable,
            }
        }

        self.w = max_x.?;
        self.h = max_y + 1; // No newline at end
    }
};

pub fn main() void {
    var cached: Space = undefined;
    cached.load(input);

    var max_count: usize = std.math.minInt(usize);
    var max_x: usize = 0;
    var max_y: usize = 0;

    var y: usize = 0;
    while (y < cached.h) : (y += 1) {
        var x: usize = 0;
        while (x < cached.h) : (x += 1) {
            if (cached.grid[y * cached.w + x] == 1) {
                var space: Space = undefined;
                space.copy(cached);

                space.grid[y * cached.w + x] = 0;
                const count = scan(&space, x, y);
                if (count >= max_count) {
                    max_count = count;
                    max_x = x;
                    max_y = y;
                }
            }
        }
    }

    std.debug.warn("{} ({},{})\n", max_count, max_x, max_y);
}

fn gcd(a: isize, b: isize) isize {
    if (b == 0) return a;
    return gcd(b, @mod(a, b));
}

fn reduce(x: *isize, y: *isize) void {
    const f = gcd(
        std.math.absInt(x.*) catch unreachable,
        std.math.absInt(y.*) catch unreachable,
    );

    x.* = @divFloor(x.*, f);
    y.* = @divFloor(y.*, f);
}

fn scan(space: *Space, cx: usize, cy: usize) usize {
    // For each asteroid, compute the angle between it and the origin. Trace from the origin
    // outwards and mark the first asteroid seen as being in a non-intersecting path.
    var sum: usize = 0;
    {
        var y: usize = 0;
        while (y < space.h) : (y += 1) {
            var x: usize = 0;
            while (x < space.w) : (x += 1) {
                if (space.grid[y * space.w + x] == 0) continue;

                const ix = @intCast(isize, x);
                const iy = @intCast(isize, y);
                const icx = @intCast(isize, cx);
                const icy = @intCast(isize, cy);

                var sx = ix - icx;
                var sy = iy - icy;
                reduce(&sx, &sy);

                var rx = icx + sx;
                var ry = icy + sy;

                var first_asteroid = true;
                while (rx >= 0 and rx < @intCast(isize, space.w) and ry >= 0 and ry < @intCast(isize, space.h)) : ({
                    rx += sx;
                    ry += sy;
                }) {
                    const index = @intCast(usize, ry) * space.w + @intCast(usize, rx);

                    switch (space.grid[index]) {
                        2 => break,
                        1 => {
                            sum += 1;
                            space.grid[index] = 2;
                            break;
                        },
                        0 => {},
                        else => unreachable,
                    }
                }
            }
        }
    }

    return sum;
}

const input =
    \\....#.....#.#...##..........#.......#......
    \\.....#...####..##...#......#.........#.....
    \\.#.#...#..........#.....#.##.......#...#..#
    \\.#..#...........#..#..#.#.......####.....#.
    \\##..#.................#...#..........##.##.
    \\#..##.#...#.....##.#..#...#..#..#....#....#
    \\##...#.............#.#..........#...#.....#
    \\#.#..##.#.#..#.#...#.....#.#.............#.
    \\...#..##....#........#.....................
    \\##....###..#.#.......#...#..........#..#..#
    \\....#.#....##...###......#......#...#......
    \\.........#.#.....#..#........#..#..##..#...
    \\....##...#..##...#.....##.#..#....#........
    \\............#....######......##......#...#.
    \\#...........##...#.#......#....#....#......
    \\......#.....#.#....#...##.###.....#...#.#..
    \\..#.....##..........#..........#...........
    \\..#.#..#......#......#.....#...##.......##.
    \\.#..#....##......#.............#...........
    \\..##.#.....#.........#....###.........#..#.
    \\...#....#...#.#.......#...#.#.....#........
    \\...####........#...#....#....#........##..#
    \\.#...........#.................#...#...#..#
    \\#................#......#..#...........#..#
    \\..#.#.......#...........#.#......#.........
    \\....#............#.............#.####.#.#..
    \\.....##....#..#...........###........#...#.
    \\.#.....#...#.#...#..#..........#..#.#......
    \\.#.##...#........#..#...##...#...#...#.#.#.
    \\#.......#...#...###..#....#..#...#.........
    \\.....#...##...#.###.#...##..........##.###.
    \\..#.....#.##..#.....#..#.....#....#....#..#
    \\.....#.....#..............####.#.........#.
    \\..#..#.#..#.....#..........#..#....#....#..
    \\#.....#.#......##.....#...#...#.......#.#..
    \\..##.##...........#..........#.............
    \\...#..##....#...##..##......#........#....#
    \\.....#..........##.#.##..#....##..#........
    \\.#...#...#......#..#.##.....#...#.....##...
    \\...##.#....#...........####.#....#.#....#..
    \\...#....#.#..#.........#.......#..#...##...
    \\...##..............#......#................
    \\........................#....##..#........#
;
