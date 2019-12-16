// --- Part Two ---
//
// Once you give them the coordinates, the Elves quickly deploy an Instant Monitoring Station to the
// location and discover the worst: there are simply too many asteroids.
//
// The only solution is complete vaporization by giant laser.
//
// Fortunately, in addition to an asteroid scanner, the new monitoring station also comes equipped
// with a giant rotating laser perfect for vaporizing asteroids. The laser starts by pointing up and
// always rotates clockwise, vaporizing any asteroid it hits.
//
// If multiple asteroids are exactly in line with the station, the laser only has enough power to
// vaporize one of them before continuing its rotation. In other words, the same asteroids that can
// be detected can be vaporized, but if vaporizing one asteroid makes another one detectable, the
// newly-detected asteroid won't be vaporized until the laser has returned to the same position by
// rotating a full 360 degrees.
//
// For example, consider the following map, where the asteroid with the new monitoring station
// (and laser) is marked X:
//
// .#....#####...#..
// ##...##.#####..##
// ##...#...#.#####.
// ..#.....X...###..
// ..#.#.....#....##
//
// The first nine asteroids to get vaporized, in order, would be:
//
// .#....###24...#..
// ##...##.13#67..9#
// ##...#...5.8####.
// ..#.....X...###..
// ..#.#.....#....##
//
// Note that some asteroids (the ones behind the asteroids marked 1, 5, and 7) won't have a chance
// to be vaporized until the next full rotation. The laser continues rotating; the next nine to be
// vaporized are:
//
// .#....###.....#..
// ##...##...#.....#
// ##...#......1234.
// ..#.....X...5##..
// ..#.9.....8....76
//
// The next nine to be vaporized are then:
//
// .8....###.....#..
// 56...9#...#.....#
// 34...7...........
// ..2.....X....##..
// ..1..............
//
// Finally, the laser completes its first full rotation (1 through 3), a second rotation
// (4 through 8), and vaporizes the last asteroid (9) partway through its third rotation:
//
// ......234.....6..
// ......1...5.....7
// .................
// ........X....89..
// .................
//
// In the large example above (the one with the best monitoring station location at 11,13):
//
//     The 1st asteroid to be vaporized is at 11,12.
//     The 2nd asteroid to be vaporized is at 12,1.
//     The 3rd asteroid to be vaporized is at 12,2.
//     The 10th asteroid to be vaporized is at 12,8.
//     The 20th asteroid to be vaporized is at 16,0.
//     The 50th asteroid to be vaporized is at 16,9.
//     The 100th asteroid to be vaporized is at 10,16.
//     The 199th asteroid to be vaporized is at 9,6.
//     The 200th asteroid to be vaporized is at 8,2.
//     The 201st asteroid to be vaporized is at 10,9.
//     The 299th and final asteroid to be vaporized is at 11,1.
//
// The Elves are placing bets on which will be the 200th asteroid to be vaporized. Win the bet by
// determining which asteroid that will be; what do you get if you multiply its X coordinate by 100
// and then add its Y coordinate? (For example, 8,2 becomes 802.)

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

const Asteroid = struct {
    angle: f64,
    distance: f64,
    x: usize,
    y: usize,
    pass: usize,
};

var allocator = std.heap.page_allocator;

pub fn main() !void {
    // From 10_1.zig output
    const ox = 30;
    const oy = 34;

    var space: Space = undefined;
    space.load(input);
    space.grid[oy * space.w + ox] = 0;

    var asteroids = std.ArrayList(Asteroid).init(allocator);
    defer asteroids.deinit();

    // Compute angle between monitoring station and each asteroid. Then, sort by angle and then
    // distance so we can iterate through and simulate destruction.
    var y: usize = 0;
    while (y < space.h) : (y += 1) {
        var x: usize = 0;
        while (x < space.w) : (x += 1) {
            if (space.grid[y * space.w + x] == 1) {
                var ix = @intCast(isize, x);
                var iy = @intCast(isize, y);

                var dx = @intToFloat(f64, ix - ox);
                var dy = @intToFloat(f64, iy - oy);

                // tan(theta) = dx/dy
                var angle = std.math.atan(std.math.fabs(dx) / std.math.fabs(dy));
                angle = 180 * angle / std.math.pi;

                // Adjust angle for correct quadrant
                if (dx >= 0 and dy < 0) angle = angle;
                if (dx >= 0 and dy >= 0) angle = 90 + angle;
                if (dx < 0 and dy >= 0) angle = 180 + angle;
                if (dx < 0 and dy < 0) angle = 360 - angle;

                try asteroids.append(Asteroid{
                    .angle = angle,
                    .distance = std.math.sqrt(dx * dx + dy * dy),
                    .x = x,
                    .y = y,
                    .pass = undefined, // Filled in later
                });
            }
        }
    }

    std.sort.sort(Asteroid, asteroids.toSlice(), struct {
        fn lessThan(a: Asteroid, b: Asteroid) bool {
            if (a.angle != b.angle) {
                return a.angle <= b.angle;
            }

            return a.distance <= b.distance;
        }
    }.lessThan);

    // Mark the pass in which each asteroid will be destroyed. Then, simulate destruction.
    {
        var as = asteroids.toSlice();
        var i: usize = 0;
        var same: usize = 0;
        while (i < as.len) : (i += 1) {
            if (i > 0 and as[i - 1].angle == as[i].angle) {
                same += 1;
            } else {
                same = 0;
            }

            as[i].pass = same;
        }

        var count: usize = 1;
        var pass: usize = 0;
        while (true) : (pass += 1) {
            for (asteroids.toSlice()) |a| {
                if (a.pass != pass) continue;

                if (count == 200) {
                    std.debug.warn("{}\n", a.x * 100 + a.y);
                    return;
                }

                count += 1;
            }
        }
    }
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
