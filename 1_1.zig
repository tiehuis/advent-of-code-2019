// --- Day 1: The Tyranny of the Rocket Equation ---
//
// Santa has become stranded at the edge of the Solar System while delivering presents to other
// planets! To accurately calculate his position in space, safely align his warp drive, and return
// to Earth in time to save Christmas, he needs you to bring him measurements from fifty stars.
//
// Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent
// calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star.
// Good luck!
//
// The Elves quickly load you into a spacecraft and prepare to launch.
//
// At the first Go / No Go poll, every Elf is Go until the Fuel Counter-Upper. They haven't
// determined the amount of fuel required yet.
//
// Fuel required to launch a given module is based on its mass. Specifically, to find the fuel
// required for a module, take its mass, divide by three, round down, and subtract 2.
//
// For example:
//
//     For a mass of 12, divide by 3 and round down to get 4, then subtract 2 to get 2.
//     For a mass of 14, dividing by 3 and rounding down still yields 4, so the fuel required is also 2.
//     For a mass of 1969, the fuel required is 654.
//     For a mass of 100756, the fuel required is 33583.
//
// The Fuel Counter-Upper needs to know the total fuel requirement. To find it, individually
// calculate the fuel needed for the mass of each module (your puzzle input), then add together
// all the fuel values.
//
// What is the sum of the fuel requirements for all of the modules on your spacecraft?

const std = @import("std");

pub fn main() void {
    var total: isize = 0;

    for (input) |e| {
        total += @divTrunc(e, 3) - 2;
    }

    std.debug.warn("{}\n", total);
}

const input = [_]isize{
    123265, 68442,  94896,  94670,  145483, 93807,  88703,  139755, 53652,  52754,  128052, 81533,
    56602,  96476,  87674,  102510, 95735,  69174,  136331, 51266,  148009, 72417,  52577,  86813,
    60803,  149232, 115843, 138175, 94723,  85623,  97925,  141772, 63662,  107293, 130779, 147027,
    88003,  77238,  53184,  149255, 71921,  139799, 84851,  104899, 92290,  74438,  55631,  58655,
    140496, 110176, 138718, 104768, 93177,  53212,  129572, 69877,  139944, 116062, 51362,  135245,
    59682,  128705, 98105,  69172,  89244,  109048, 88690,  62124,  53981,  71885,  59216,  107718,
    146343, 138788, 73588,  51648,  122227, 54507,  59283,  101230, 93080,  123120, 148248, 102909,
    91199,  105704, 113956, 120368, 75020,  103734, 81791,  87323,  77278,  123013, 58901,  136351,
    121295, 132994, 84039,  76813,
};
