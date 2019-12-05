// --- Day 4: Secure Container ---
//
// You arrive at the Venus fuel depot only to discover it's protected by a password. The Elves had
// written the password on a sticky note, but someone threw it out.
//
// However, they do remember a few key facts about the password:
//
//     It is a six-digit number.
//     The value is within the range given in your puzzle input.
//     Two adjacent digits are the same (like 22 in 122345).
//     Going from left to right, the digits never decrease; they only ever increase or stay the
//      same (like 111123 or 135679).
//
// Other than the range rule, the following are true:
//
//     111111 meets these criteria (double 11, never decreases).
//     223450 does not meet these criteria (decreasing pair of digits 50).
//     123789 does not meet these criteria (no double).
//
// How many different passwords within the range given in your puzzle input meet these criteria?

const std = @import("std");

fn valid(n: usize) bool {
    var digits: [6]usize = undefined;

    comptime var i: usize = 0;
    inline while (i < 6) : (i += 1) {
        digits[5 - i] = (n / std.math.pow(usize, 10, i)) % 10;
    }

    var same = false;
    var c: usize = digits[0];
    for (digits[1..]) |d| {
        // not ascending
        if (d < c) {
            return false;
        }

        // same adjacent digits
        if (d == c) {
            same = true;
        }

        c = d;
    }

    return same;
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
