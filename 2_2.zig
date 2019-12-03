// --- Part Two ---
//
// "Good, the new computer seems to be working correctly! Keep it nearby during this mission -
// you'll probably use it again. Real Intcode computers support many more features than your new
// one, but we'll let you know what they are as you need them."
//
// "However, your current priority should be to complete your gravity assist around the Moon. For
// this mission to succeed, we should settle on some terminology for the parts you've already built."
//
// Intcode programs are given as a list of integers; these values are used as the initial state for
// the computer's memory. When you run an Intcode program, make sure to start by initializing
// memory to the program's values. A position in memory is called an address (for example, the
// first value in memory is at "address 0").
//
// Opcodes (like 1, 2, or 99) mark the beginning of an instruction. The values used immediately
// after an opcode, if any, are called the instruction's parameters. For example, in the
// instruction 1,2,3,4, 1 is the opcode; 2, 3, and 4 are the parameters. The instruction 99 contains
// only an opcode and has no parameters.
// The address of the current instruction is called the instruction pointer; it starts at 0. After
// an instruction finishes, the instruction pointer increases by the number of values in the
// instruction; until you add more instructions to the computer, this is always 4 (1 opcode +
// 3 parameters) for the add and multiply instructions. (The halt instruction would increase the
// instruction pointer by 1, but it halts the program instead.)
//
// "With terminology out of the way, we're ready to proceed. To complete the gravity assist, you
// need to determine what pair of inputs produces the output 19690720."
//
// The inputs should still be provided to the program by replacing the values at addresses 1 and 2,
// just like before. In this program, the value placed in address 1 is called the noun, and the
// value placed in address 2 is called the verb. Each of the two input values will be between 0 and
// 99, inclusive.
//
// Once the program has halted, its output is available at address 0, also just like before. Each
// time you try a pair of inputs, make sure you first reset the computer's memory to the values in
// the program (your puzzle input) - in other words, don't reuse memory from a previous attempt.
//
// Find the input noun and verb that cause the program to produce the output 19690720. What is
// 100 * noun + verb? (For example, if noun=12 and verb=2, the answer would be 1202.)

const std = @import("std");

pub fn main() void {
    var noun: usize = 0;
    while (noun < 100) : (noun += 1) {
        var verb: usize = 0;
        while (verb < 100) : (verb += 1) {
            var ip: usize = 0;
            var mem: [input.len]usize = undefined;
            std.mem.copy(usize, mem[0..], input[0..]);

            mem[1] = noun;
            mem[2] = verb;

            program: while (true) : (ip += 4) {
                if (ip > mem.len) @panic("invalid memory access");

                switch (mem[ip]) {
                    1 => mem[mem[ip + 3]] = mem[mem[ip + 1]] + mem[mem[ip + 2]],
                    2 => mem[mem[ip + 3]] = mem[mem[ip + 1]] * mem[mem[ip + 2]],
                    99 => break :program,
                    else => @panic("unhandled opcode"),
                }
            }

            if (mem[0] == 19690720) {
                std.debug.warn("{}\n", 100 * noun + verb);
                return;
            }
        }
    }

    @panic("no solution found");
}

var input = [_]usize{
    1,   0,   0,   3,  1,   1,   2,   3,   1,   3,   4,   3,   1,   5,   0,  3,   2,   6,   1,
    19,  1,   5,   19, 23,  1,   13,  23,  27,  1,   6,   27,  31,  2,   31, 13,  35,  1,   9,
    35,  39,  2,   39, 13,  43,  1,   43,  10,  47,  1,   47,  13,  51,  2,  13,  51,  55,  1,
    55,  9,   59,  1,  59,  5,   63,  1,   6,   63,  67,  1,   13,  67,  71, 2,   71,  10,  75,
    1,   6,   75,  79, 1,   79,  10,  83,  1,   5,   83,  87,  2,   10,  87, 91,  1,   6,   91,
    95,  1,   9,   95, 99,  1,   99,  9,   103, 2,   103, 10,  107, 1,   5,  107, 111, 1,   9,
    111, 115, 2,   13, 115, 119, 1,   119, 10,  123, 1,   123, 10,  127, 2,  127, 10,  131, 1,
    5,   131, 135, 1,  10,  135, 139, 1,   139, 2,   143, 1,   6,   143, 0,  99,  2,   14,  0,
    0,
};
