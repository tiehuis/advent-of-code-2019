// --- Part Two ---
//
// An Elf just remembered one more important detail: the two adjacent matching digits are not part
// of a larger group of matching digits.
//
// Given this additional criterion, but still ignoring the range rule, the following are now true:
//
//     112233 meets these criteria because the digits never decrease and all repeated digits are
//      exactly two digits long.
//     123444 no longer meets the criteria (the repeated 44 is part of a larger group of 444).
//     111122 meets the criteria (even though 1 is repeated more than twice, it still contains a
//      double 22).
//
// How many different passwords within the range given in your puzzle input meet all of the criteria?

const std = @import("std");

fn valid(n: usize) bool {
    var digits: [6]usize = undefined;

    comptime var i: usize = 0;
    inline while (i < 6) : (i += 1) {
        digits[5 - i] = (n / std.math.pow(usize, 10, i)) % 10;
    }

    var match: usize = 1;
    var found_pair = false;
    var c: usize = digits[0];
    for (digits[1..]) |d| {
        // not ascending
        if (d < c) {
            return false;
        }

        // adjacent pair, but not more
        if (d == c) {
            match += 1;
        } else {
            if (match == 2) {
                found_pair = true;
            }
            match = 1;
        }

        c = d;
    }

    if (match == 2) {
        found_pair = true;
    }

    return found_pair;
}

pub fn main() void {
    var total: usize = 0;

    var n: usize = 245318;
    while (n <= 765747) : (n += 1) {
        if (valid(n)) {
            total += 1;
        }
    }

    std.debug.warn("{}\n", total);
}
