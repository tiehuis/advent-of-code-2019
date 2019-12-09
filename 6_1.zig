// --- Day 6: Universal Orbit Map ---
//
// You've landed at the Universal Orbit Map facility on Mercury. Because navigation in space often
// involves transferring between orbits, the orbit maps here are useful for finding efficient
// routes between, for example, you and Santa. You download a map of the local orbits (your puzzle
// input).
//
// Except for the universal Center of Mass (COM), every object in space is in orbit around exactly
// one other object. An orbit looks roughly like this:
//
//                   \
//                    \
//                     |
//                     |
// AAA--> o            o <--BBB
//                     |
//                     |
//                    /
//                   /
//
// In this diagram, the object BBB is in orbit around AAA. The path that BBB takes around AAA (drawn
// with lines) is only partly shown. In the map data, this orbital relationship is written AAA)BBB,
// which means "BBB is in orbit around AAA".
//
// Before you use your map data to plot a course, you need to make sure it wasn't corrupted during
// the download. To verify maps, the Universal Orbit Map facility uses orbit count checksums - the
// total number of direct orbits (like the one shown above) and indirect orbits.
//
// Whenever A orbits B and B orbits C, then A indirectly orbits C. This chain can be any number of
// objects long: if A orbits B, B orbits C, and C orbits D, then A indirectly orbits D.
//
// For example, suppose you have the following map:
//
// COM)B
// B)C
// C)D
// D)E
// E)F
// B)G
// G)H
// D)I
// E)J
// J)K
// K)L
//
// Visually, the above map of orbits looks like this:
//
//         G - H       J - K - L
//        /           /
// COM - B - C - D - E - F
//                \
//                 I
//
// In this visual representation, when two objects are connected by a line, the one on the right
// directly orbits the one on the left.
//
// Here, we can count the total number of orbits as follows:
//
//     D directly orbits C and indirectly orbits B and COM, a total of 3 orbits.
//     L directly orbits K and indirectly orbits J, E, D, C, B, and COM, a total of 7 orbits.
//     COM orbits nothing.
//
// The total number of direct and indirect orbits in this example is 42.
//
// What is the total number of direct and indirect orbits in your map data?

const std = @import("std");

const Node = struct {
    id: []const u8,
    // Every object in space is in orbit around exactly one other object
    parent: ?*Node,
    orbiters: std.ArrayList(*Node),

    pub fn init(allocator: *std.mem.Allocator, id: []const u8) !*Node {
        var node = try allocator.create(Node);
        node.id = id;
        node.parent = null;
        node.orbiters = std.ArrayList(*Node).init(allocator);
        return node;
    }
};

fn traverse(link: *Node, steps: usize) usize {
    var sum = steps;
    for (link.orbiters.toSliceConst()) |orbiter| {
        sum += traverse(orbiter, steps + 1);
    }
    return sum;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = &arena.allocator;
    defer arena.deinit();

    var space = std.StringHashMap(*Node).init(allocator);
    defer space.deinit();

    // Input data will not have COM as an orbiter of any other object
    try space.putNoClobber("COM", try Node.init(allocator, "COM"));

    for (input) |orbit| {
        // Get or create existing orbitee
        var target = try space.getOrPut(orbit.target);
        if (!target.found_existing) {
            target.kv.value = try Node.init(allocator, orbit.target);
        }

        // Point orbiter at the target
        var orbiter = try space.getOrPut(orbit.id);
        if (!orbiter.found_existing) {
            orbiter.kv.value = try Node.init(allocator, orbit.id);
        }
        orbiter.kv.value.parent = target.kv.value;

        // Fill backlinks for reverse traversal
        try target.kv.value.orbiters.append(orbiter.kv.value);
    }

    var origin = space.getValue("COM").?;
    std.debug.warn("{}\n", traverse(origin, 0));
}

const Orbit = struct {
    id: []const u8,
    target: []const u8,
};

fn O(target: *const [3]u8, id: *const [3]u8) Orbit {
    return Orbit{
        .id = id[0..],
        .target = target[0..],
    };
}

const input = blk: {
    @setEvalBranchQuota(20000);

    break :blk [_]Orbit{
        O("36S", "VWN"), O("6FM", "RNW"), O("S2M", "329"), O("DQ3", "5CD"), O("XYW", "X2Y"),
        O("LFS", "LXR"), O("SMP", "C57"), O("2YY", "MSP"), O("4TM", "DPK"), O("PZQ", "77L"),
        O("SNX", "Y6Q"), O("JSS", "T26"), O("KDF", "PR8"), O("SNM", "XBG"), O("46X", "P5S"),
        O("CPN", "C93"), O("VXL", "ZHS"), O("B9V", "XZN"), O("B6X", "H3Y"), O("234", "FHY"),
        O("BZY", "L3T"), O("6YT", "Q53"), O("JK6", "RC4"), O("TW9", "64K"), O("3VT", "2GJ"),
        O("XKG", "7L4"), O("ZM3", "36S"), O("C2S", "5T2"), O("RYH", "8Z1"), O("YK6", "G7K"),
        O("7YB", "WQ7"), O("X7D", "SNW"), O("8QS", "ZRP"), O("HNX", "812"), O("TN4", "K68"),
        O("H6L", "PFY"), O("69Y", "1DT"), O("JKH", "41K"), O("RDZ", "S52"), O("DH8", "4HT"),
        O("MH8", "HB3"), O("NCR", "PY1"), O("3L1", "8Z9"), O("HRQ", "BBC"), O("SNW", "99L"),
        O("5VY", "L15"), O("D69", "9FP"), O("DRC", "S4T"), O("NJV", "MTR"), O("6ND", "49Z"),
        O("RF1", "82H"), O("329", "Y37"), O("HCL", "ZBZ"), O("Q47", "ZVJ"), O("QDM", "6QM"),
        O("DR8", "KWZ"), O("M2N", "PWL"), O("RLF", "N2D"), O("41G", "XTK"), O("5CF", "CFW"),
        O("BBC", "KYF"), O("SX1", "G9C"), O("791", "HQD"), O("9KV", "MZC"), O("B6C", "RBX"),
        O("Q5H", "R7X"), O("488", "4C5"), O("5D5", "ZTC"), O("5ZK", "G2C"), O("2HC", "SMP"),
        O("CB2", "91H"), O("F4T", "J17"), O("VCJ", "HZV"), O("G3D", "LMX"), O("KMD", "98B"),
        O("8Q2", "MKP"), O("4BK", "152"), O("M3H", "57J"), O("SS3", "BC7"), O("VP8", "6MV"),
        O("ZDZ", "W55"), O("997", "5S5"), O("67Q", "N7M"), O("PWL", "BMZ"), O("D8V", "PBJ"),
        O("KT4", "RPQ"), O("D9G", "69Y"), O("BWS", "9SV"), O("3HV", "K1J"), O("HZR", "959"),
        O("WDT", "15T"), O("SLW", "C1P"), O("4VV", "1Q4"), O("D6G", "KBZ"), O("B7W", "5QP"),
        O("6YL", "TFD"), O("NHZ", "XNK"), O("93V", "K1N"), O("9PS", "KTX"), O("LYZ", "P92"),
        O("LTJ", "JMP"), O("CJL", "MW2"), O("L15", "LF5"), O("MRL", "PTW"), O("WNB", "NK3"),
        O("TF2", "KVF"), O("MF9", "VFF"), O("J2G", "V88"), O("GBR", "NJJ"), O("CLZ", "PRR"),
        O("ZLL", "ZFB"), O("9JW", "8G1"), O("SXK", "ZQ8"), O("2VP", "4XG"), O("ZQ8", "288"),
        O("NQ3", "61J"), O("79G", "4ZM"), O("NL3", "SD6"), O("R38", "LCH"), O("SBX", "4S2"),
        O("2VB", "8C2"), O("ND1", "3VP"), O("C93", "NHM"), O("M8L", "FL6"), O("FFV", "M61"),
        O("5V5", "FDH"), O("29D", "ZYC"), O("32S", "YL6"), O("YMY", "DSJ"), O("3KS", "3GK"),
        O("JZ5", "X9Q"), O("F1P", "3YV"), O("D6L", "Q94"), O("Y77", "8M4"), O("MZN", "XD7"),
        O("Q7H", "C78"), O("RCD", "8KB"), O("QVD", "NP7"), O("9NM", "LRT"), O("4S6", "67F"),
        O("H1W", "9MH"), O("Z68", "7LV"), O("75K", "693"), O("38K", "9ZG"), O("RZX", "M3K"),
        O("XQW", "WPK"), O("6L8", "7LR"), O("RL8", "NJH"), O("W9Q", "7V7"), O("S4S", "KR5"),
        O("R2F", "4MX"), O("QCY", "TY3"), O("8C2", "Z68"), O("CFW", "B7B"), O("6GV", "CST"),
        O("3HG", "N6V"), O("BNW", "YQP"), O("WZZ", "6YL"), O("6QT", "39G"), O("8M4", "ML1"),
        O("XW7", "6XH"), O("YY6", "3HZ"), O("KYF", "6KB"), O("NMS", "BVR"), O("V7M", "ZZB"),
        O("152", "2ZP"), O("7LD", "CLM"), O("6K8", "YCB"), O("8VS", "96S"), O("7R5", "8QJ"),
        O("YBS", "BVQ"), O("H82", "7SR"), O("JCL", "CMP"), O("7XX", "4BV"), O("WGM", "WCS"),
        O("LDY", "H1F"), O("KS3", "2BT"), O("HKQ", "JVY"), O("7RG", "BWZ"), O("248", "629"),
        O("HMJ", "QN6"), O("L1J", "BCJ"), O("JLV", "G7P"), O("M61", "S45"), O("Q8L", "9B4"),
        O("HBX", "K9Z"), O("TCV", "NM4"), O("TBX", "BQC"), O("JDG", "3HS"), O("PLQ", "DXW"),
        O("4WS", "CR1"), O("PSK", "CNM"), O("4HT", "37C"), O("9L1", "QL2"), O("LL4", "LGQ"),
        O("W1V", "91R"), O("JTF", "W3M"), O("QVV", "4TM"), O("K6C", "4RM"), O("7F5", "PDF"),
        O("QYV", "MW8"), O("KBZ", "WMV"), O("Q7H", "NMS"), O("DZ9", "7TV"), O("K82", "D4Y"),
        O("YQP", "ZDZ"), O("R8S", "L8Y"), O("DTS", "X8T"), O("CLG", "5X3"), O("11F", "GMT"),
        O("VMG", "787"), O("63B", "NVC"), O("S5Y", "X5N"), O("5FV", "MPK"), O("J6B", "34Z"),
        O("25Y", "DV9"), O("Q4R", "D7F"), O("1R6", "K1Q"), O("5T2", "3PD"), O("YHR", "C7V"),
        O("1B3", "TGT"), O("F53", "8JX"), O("6MV", "4S6"), O("DQ3", "QSG"), O("ZSF", "Y5C"),
        O("SK9", "FKR"), O("XD7", "6H9"), O("8TY", "3Z1"), O("WPK", "F1X"), O("JD2", "QBH"),
        O("HF3", "5HX"), O("SJC", "Q6T"), O("2WS", "G4T"), O("MDJ", "D84"), O("5ZN", "JVT"),
        O("NV7", "D8G"), O("Q8C", "RYH"), O("XGB", "M11"), O("Z4H", "LXD"), O("G4T", "NPV"),
        O("FZS", "Q51"), O("VL3", "17R"), O("9W2", "THD"), O("6GP", "H65"), O("8YK", "WV7"),
        O("F8Y", "2FF"), O("PR8", "GDT"), O("N3J", "FLX"), O("4TY", "318"), O("7NV", "213"),
        O("773", "DGG"), O("HY6", "W1J"), O("WJG", "X1V"), O("279", "8V3"), O("M1Z", "FB4"),
        O("GHV", "YF7"), O("WMW", "2GY"), O("L9F", "TS1"), O("PQ2", "HZ2"), O("WQD", "MG6"),
        O("8HR", "27Z"), O("5V6", "5V5"), O("BT1", "RQ5"), O("2T9", "3V9"), O("FDD", "Q27"),
        O("FGP", "9LY"), O("6QM", "X38"), O("ZT2", "QWP"), O("MZC", "PVN"), O("R8G", "2JS"),
        O("VRS", "W3C"), O("6TQ", "24L"), O("W1X", "JJ3"), O("QVZ", "HBN"), O("5JK", "X57"),
        O("49Z", "2CV"), O("XZN", "ZN1"), O("G5Y", "6K4"), O("KYW", "255"), O("ZW2", "3KB"),
        O("WRG", "FN4"), O("QJ2", "9CW"), O("RH2", "V3K"), O("2HP", "G7L"), O("3MS", "3P9"),
        O("JD9", "11F"), O("FLX", "2ZY"), O("N4C", "GJD"), O("VZV", "8T9"), O("JRT", "764"),
        O("KCK", "SNP"), O("V8K", "SK9"), O("46T", "JCM"), O("H3N", "FK2"), O("ZW4", "1BP"),
        O("CLQ", "7BR"), O("QSS", "723"), O("VZY", "K9J"), O("32W", "Z6L"), O("PKC", "XMM"),
        O("MGW", "46X"), O("FT1", "WPC"), O("6B4", "C4W"), O("Z99", "1Z6"), O("QB4", "BT1"),
        O("9LQ", "V4K"), O("1C2", "4DN"), O("GHM", "VS1"), O("YRQ", "6QT"), O("XGV", "DQW"),
        O("7WD", "FG3"), O("ZV5", "P84"), O("XR8", "Y89"), O("WQP", "5P9"), O("R4P", "TTV"),
        O("5RP", "5MJ"), O("DZR", "QVZ"), O("D9R", "DWV"), O("Y44", "YSZ"), O("R23", "6DK"),
        O("ZRP", "GTP"), O("M7C", "9FL"), O("HN9", "NZX"), O("HWY", "HSC"), O("7L4", "YH3"),
        O("VJ5", "YR2"), O("85G", "65K"), O("KRN", "T3J"), O("9JV", "FVR"), O("3FV", "QSW"),
        O("GMZ", "K1R"), O("HSZ", "HWY"), O("9DT", "W14"), O("5KH", "PLQ"), O("MXX", "4YT"),
        O("T9P", "8VW"), O("7V7", "2N1"), O("733", "C6C"), O("G5Y", "7V3"), O("NGT", "NZC"),
        O("2H6", "FGY"), O("6TT", "CSW"), O("K1Q", "D6L"), O("9BN", "HHH"), O("PDZ", "4NK"),
        O("QZY", "BZH"), O("JY9", "NG4"), O("HX7", "7TB"), O("F1X", "NT5"), O("DKR", "HN9"),
        O("HYQ", "QV1"), O("T3X", "HPW"), O("WR8", "18C"), O("1XF", "GT3"), O("NR3", "D69"),
        O("ZN6", "YFM"), O("NVX", "2VP"), O("7CV", "YHJ"), O("LLZ", "BTM"), O("8LL", "38K"),
        O("Y3X", "Q1N"), O("GJD", "VQ3"), O("MFR", "V6R"), O("6RS", "DXL"), O("1GH", "L45"),
        O("62B", "7FX"), O("HRJ", "Z9Z"), O("3YQ", "X8J"), O("CMP", "TZP"), O("749", "FWW"),
        O("D6P", "KNG"), O("8D3", "Y9B"), O("CLZ", "GKN"), O("34Z", "LLZ"), O("7W9", "86N"),
        O("9PC", "Y3X"), O("JHX", "56F"), O("91P", "2MZ"), O("LRQ", "CLQ"), O("N2Z", "R6N"),
        O("M64", "NWV"), O("T1M", "TPD"), O("Y9L", "6DY"), O("JT5", "V4Y"), O("DHH", "C8V"),
        O("RNH", "JB4"), O("Y5C", "VK7"), O("36H", "6L8"), O("T26", "S7Q"), O("HHY", "PPD"),
        O("4YT", "8RK"), O("QZY", "WSJ"), O("764", "XMK"), O("7NT", "W71"), O("7F5", "9QN"),
        O("K96", "V2L"), O("CCY", "DYM"), O("3HG", "YC9"), O("46X", "YMC"), O("HW3", "YKQ"),
        O("FGQ", "B27"), O("CFZ", "PY7"), O("ZN1", "VHW"), O("Z68", "Q83"), O("4WS", "7F1"),
        O("TF3", "HKC"), O("D4Y", "TD2"), O("Z9Z", "2HP"), O("Y8F", "91P"), O("3ML", "9NM"),
        O("6DK", "HQM"), O("FDH", "V5J"), O("N4Z", "GD9"), O("86Y", "597"), O("D4G", "G7R"),
        O("16M", "X2D"), O("72W", "5QS"), O("WGT", "DYT"), O("MTR", "7QG"), O("GDF", "VN5"),
        O("39G", "8LL"), O("RBY", "KQK"), O("P9G", "WK3"), O("LTH", "NV5"), O("SVY", "LW1"),
        O("723", "5N1"), O("NJH", "8MQ"), O("1HF", "KPV"), O("YCH", "XGB"), O("8R2", "JV3"),
        O("NPV", "8Q2"), O("4YP", "9BN"), O("YN6", "DZR"), O("QJS", "DHH"), O("77L", "DXN"),
        O("JNN", "FTQ"), O("YV5", "JPS"), O("KKD", "JRT"), O("6XH", "CG8"), O("MJY", "LNJ"),
        O("9T5", "HJ3"), O("MZC", "9S1"), O("JGN", "TXD"), O("3VP", "FN6"), O("RC4", "75K"),
        O("Y37", "69L"), O("5CW", "T4L"), O("R4W", "VWK"), O("FVL", "ZW2"), O("LL2", "2H6"),
        O("CMY", "GRL"), O("1DT", "YW6"), O("TV5", "S5P"), O("8WR", "717"), O("3V9", "KN6"),
        O("RTL", "3BZ"), O("LN4", "54L"), O("TXF", "MKH"), O("1WM", "J65"), O("YFM", "5NT"),
        O("JS6", "7F8"), O("WNN", "W6Z"), O("KVF", "FFX"), O("CRJ", "STR"), O("N1D", "BZ2"),
        O("1KB", "R4P"), O("C1S", "626"), O("VS1", "67Q"), O("JMP", "7X5"), O("17K", "GYC"),
        O("WPK", "72W"), O("4DN", "641"), O("WC5", "YRQ"), O("S6B", "GXJ"), O("5N7", "3VT"),
        O("3GK", "SXK"), O("41G", "K96"), O("WHJ", "LRZ"), O("3PD", "TXF"), O("7J9", "PKC"),
        O("GS6", "JX4"), O("736", "2ZB"), O("FW5", "2T9"), O("V88", "YQX"), O("KVB", "VX3"),
        O("4ZD", "GYB"), O("JTK", "MHK"), O("CCC", "XXQ"), O("PXG", "JCL"), O("PP2", "Y7J"),
        O("SHY", "XYX"), O("QBZ", "MQW"), O("BCJ", "F53"), O("7LR", "HZQ"), O("SZX", "41J"),
        O("RNW", "K6N"), O("S2W", "78F"), O("JLF", "ZM3"), O("JV1", "SXG"), O("WWR", "WZS"),
        O("MXG", "RFT"), O("HQD", "GBR"), O("C8C", "7NV"), O("F59", "758"), O("T26", "LX3"),
        O("62P", "CLG"), O("HJ3", "4KT"), O("33Q", "DSD"), O("ZHS", "DXK"), O("6RY", "QK8"),
        O("3H7", "414"), O("GYC", "ZQH"), O("65K", "YHV"), O("L8L", "D6P"), O("MJS", "H5K"),
        O("7ML", "834"), O("VW4", "Q6W"), O("PVM", "6Q3"), O("5Z2", "2LS"), O("1B5", "RNH"),
        O("318", "JHH"), O("T3J", "5FV"), O("CXK", "MRW"), O("7GK", "KT4"), O("YX8", "26Z"),
        O("8J9", "3T2"), O("DWV", "N88"), O("9T9", "BSS"), O("HN6", "L9F"), O("9TH", "7J9"),
        O("RR2", "MSS"), O("V5F", "QSS"), O("J2R", "1W8"), O("PLT", "DX7"), O("GFL", "N73"),
        O("PVN", "KN2"), O("96L", "NGT"), O("8M7", "JGW"), O("YW6", "92B"), O("9V7", "4W7"),
        O("SKL", "GHM"), O("94K", "6H2"), O("XBH", "1WD"), O("8DS", "QKH"), O("HJP", "BKD"),
        O("27Z", "X36"), O("9CR", "5ZN"), O("XYD", "SXC"), O("NYH", "VMB"), O("TCC", "3ML"),
        O("4BV", "2JY"), O("5QP", "7NT"), O("WMX", "B7W"), O("SLQ", "7RR"), O("7SC", "R5N"),
        O("ZNY", "W5C"), O("656", "T84"), O("VM1", "JZ8"), O("H2X", "NHD"), O("3RQ", "MPG"),
        O("7WF", "T44"), O("268", "C2S"), O("W7D", "9YD"), O("DWF", "8BB"), O("TZ2", "BK3"),
        O("R17", "DQT"), O("MRW", "K9L"), O("8MQ", "W1K"), O("L4V", "6FM"), O("SWR", "FNL"),
        O("PMB", "J2G"), O("N4X", "3YT"), O("NP7", "KS3"), O("DXN", "WFH"), O("3BZ", "JD9"),
        O("QCD", "W5J"), O("P22", "B9V"), O("NR1", "WX7"), O("G42", "CMW"), O("SS6", "KY6"),
        O("D84", "X97"), O("QV1", "8DS"), O("TQM", "VJX"), O("4VB", "JHX"), O("4WM", "9TT"),
        O("T8H", "K2G"), O("Q72", "H6L"), O("QN6", "Y7K"), O("C4M", "YY6"), O("W8P", "WYP"),
        O("NCC", "31C"), O("HVZ", "93C"), O("Y13", "XXZ"), O("93V", "QXS"), O("NRL", "9J8"),
        O("JZW", "FW3"), O("BVR", "16M"), O("W5C", "XC5"), O("XC5", "HJF"), O("4PG", "FFW"),
        O("TWM", "C9R"), O("MNG", "GHV"), O("V5F", "FC2"), O("RBJ", "JXR"), O("94W", "1KD"),
        O("SYP", "TQR"), O("T84", "MTZ"), O("T1F", "7XK"), O("ZFX", "F7Q"), O("GT3", "X4X"),
        O("YHB", "V16"), O("SQZ", "8QS"), O("FGY", "5FJ"), O("N2D", "N4C"), O("P84", "72Z"),
        O("MYP", "6LP"), O("717", "J1Q"), O("3V8", "8D9"), O("7ZP", "RM7"), O("PK9", "HTS"),
        O("6J1", "RWN"), O("CCC", "V2X"), O("L14", "92M"), O("91H", "VTN"), O("MCF", "G5Y"),
        O("9R5", "LCZ"), O("CR1", "P9M"), O("15T", "2WS"), O("7XK", "V8S"), O("J8T", "D3P"),
        O("TVD", "4YP"), O("PTC", "K7P"), O("L82", "6RD"), O("N6V", "FSX"), O("5TH", "C9H"),
        O("HY9", "52F"), O("249", "VXL"), O("LRQ", "SCP"), O("FHK", "RQQ"), O("Y3J", "F5Q"),
        O("4LH", "9Q9"), O("MW2", "BHT"), O("JBS", "1B3"), O("D3P", "BK8"), O("G7R", "FW5"),
        O("HPW", "Z3T"), O("TT6", "L8L"), O("2FY", "CLZ"), O("V8T", "T97"), O("P2G", "W9Q"),
        O("144", "SRL"), O("MHK", "H3P"), O("Q35", "FQ5"), O("V3K", "BZY"), O("TQP", "V7V"),
        O("HF6", "LWB"), O("BZ9", "L4V"), O("GRS", "BDM"), O("45R", "YBS"), O("5SF", "4BG"),
        O("FPF", "CG7"), O("R4R", "K6C"), O("D5P", "9BC"), O("9XJ", "GBV"), O("B5L", "T59"),
        O("D82", "K93"), O("R6D", "KKW"), O("XXQ", "F9N"), O("SNP", "M74"), O("BXC", "TQM"),
        O("81T", "CHD"), O("213", "8M7"), O("RQQ", "H4G"), O("NZT", "7QP"), O("6KB", "85G"),
        O("93C", "DVQ"), O("P7F", "2FY"), O("N3Z", "QS4"), O("PVT", "FGQ"), O("JB4", "VCJ"),
        O("QFS", "1B5"), O("NH3", "1KF"), O("DPH", "FL2"), O("GTP", "FR4"), O("G8M", "WWD"),
        O("FB6", "ZNS"), O("842", "PMB"), O("GBV", "46N"), O("YC9", "1Y8"), O("FL2", "HLY"),
        O("DPK", "3TJ"), O("8QJ", "6BY"), O("C1P", "ZRH"), O("9Q9", "TVB"), O("W14", "WLW"),
        O("XWR", "972"), O("7V7", "NVX"), O("H9X", "ZZ8"), O("BYG", "YSK"), O("FDD", "3H1"),
        O("5WQ", "NZ5"), O("ZLD", "7CV"), O("4RZ", "1GV"), O("V8C", "N2G"), O("N2J", "VX8"),
        O("TBK", "TWM"), O("M3K", "W1V"), O("G85", "T14"), O("N5L", "RTT"), O("6ZZ", "54W"),
        O("8N1", "7W3"), O("42N", "R73"), O("54W", "9FV"), O("7TS", "HD6"), O("S45", "HZG"),
        O("KQK", "BMQ"), O("8V5", "F91"), O("M3J", "HM9"), O("W54", "268"), O("DV9", "JDT"),
        O("63D", "GMZ"), O("6B3", "8V5"), O("KNV", "RFX"), O("JH5", "MK3"), O("YQQ", "Q7Y"),
        O("V9W", "5LX"), O("KZK", "4VB"), O("RXX", "YNY"), O("NM4", "XZR"), O("ZBZ", "33Q"),
        O("ZW7", "279"), O("QKH", "DP7"), O("6KQ", "WL9"), O("3Q3", "9TH"), O("9QN", "7X9"),
        O("9YD", "RLF"), O("FB4", "Q5H"), O("8S3", "XTC"), O("CLV", "P4L"), O("FP1", "N1D"),
        O("GKN", "CNT"), O("X8J", "8KK"), O("V5H", "T8M"), O("Y4L", "H4W"), O("BXZ", "DRZ"),
        O("6VP", "6HP"), O("1BP", "BDJ"), O("GLB", "71J"), O("Q4P", "VD7"), O("YKQ", "XWZ"),
        O("YRY", "V5S"), O("T5L", "V15"), O("2LS", "4R8"), O("2Z3", "7FZ"), O("JVY", "7LD"),
        O("C4W", "QFS"), O("T94", "P9G"), O("S2Q", "FTC"), O("K36", "9XL"), O("RR5", "43C"),
        O("7TB", "NLQ"), O("8BN", "56N"), O("M7Y", "H6V"), O("PFY", "96L"), O("NB3", "51P"),
        O("TTR", "BKW"), O("PLT", "HZR"), O("PZQ", "563"), O("HTW", "Q6J"), O("CB9", "J7C"),
        O("3YV", "4PG"), O("LCZ", "7YB"), O("HW4", "YHB"), O("95K", "J8K"), O("Q3F", "YGH"),
        O("R82", "Q35"), O("4LQ", "54X"), O("1FB", "22B"), O("W5J", "JSJ"), O("GY8", "JKH"),
        O("N7Z", "TTS"), O("B7B", "VLB"), O("LX3", "8XL"), O("T5L", "KKG"), O("G2C", "NWH"),
        O("T8M", "W24"), O("KJ5", "LFS"), O("SQP", "RNF"), O("Y6Q", "PSL"), O("SR9", "XBH"),
        O("YDF", "HL4"), O("22B", "XKP"), O("V5H", "81T"), O("1CN", "L5B"), O("JPX", "T62"),
        O("RPQ", "H82"), O("ZBG", "462"), O("TKG", "WMW"), O("KRQ", "R6S"), O("1KD", "NN4"),
        O("XTW", "L14"), O("FN6", "D67"), O("JD5", "RL8"), O("GD9", "GQ8"), O("67F", "RJX"),
        O("Y4J", "23M"), O("YHV", "WKJ"), O("5XR", "VJ5"), O("NZ5", "3TH"), O("2ZP", "313"),
        O("78F", "K98"), O("N1L", "RR5"), O("5X4", "814"), O("MKR", "C8C"), O("NYY", "1R4"),
        O("J7J", "JZW"), O("P9Y", "Q47"), O("VNS", "XDG"), O("4VB", "YMY"), O("LZR", "LTH"),
        O("J2N", "Z5P"), O("56N", "VNJ"), O("QC6", "XVY"), O("8J4", "KWP"), O("JLP", "5V3"),
        O("4PP", "Q5M"), O("CR1", "R17"), O("VQC", "CPN"), O("K6N", "CTX"), O("75G", "G1T"),
        O("3V1", "QDM"), O("3V4", "XHD"), O("BVQ", "9CR"), O("5NT", "MXV"), O("1R4", "G98"),
        O("XZN", "5C5"), O("M7Y", "Y1D"), O("Q5M", "HVK"), O("R31", "LLL"), O("T62", "7R5"),
        O("6PY", "X6G"), O("4RM", "RH2"), O("BRS", "DCV"), O("3L5", "YDF"), O("F55", "GR2"),
        O("HVN", "9RJ"), O("K7P", "CRD"), O("9V7", "3MQ"), O("284", "736"), O("CRD", "BWF"),
        O("N5J", "C75"), O("L21", "BGB"), O("91R", "C1S"), O("9B4", "777"), O("HL9", "Y13"),
        O("4RY", "NR1"), O("N73", "937"), O("DV9", "3H7"), O("8NZ", "CRJ"), O("YR2", "Y4J"),
        O("ZN6", "HSZ"), O("S52", "L1J"), O("XKP", "72F"), O("7M7", "MXG"), O("YQX", "KCK"),
        O("Q6S", "2MT"), O("VK7", "1V3"), O("M8R", "JY9"), O("KKG", "WC5"), O("T97", "L47"),
        O("KP2", "HGF"), O("NJJ", "R4R"), O("W55", "QCD"), O("RHJ", "P7F"), O("XTC", "TC1"),
        O("QSG", "WZZ"), O("GWZ", "YX8"), O("9J8", "JG8"), O("LGQ", "KVJ"), O("T6B", "XZ7"),
        O("PRR", "XTW"), O("MC4", "8YL"), O("42Y", "V1M"), O("43X", "8NZ"), O("NYS", "1KB"),
        O("Q1N", "B5L"), O("61J", "SQZ"), O("QL7", "6S8"), O("9X9", "YZH"), O("BMC", "WMX"),
        O("HZV", "3MS"), O("MSP", "FGP"), O("MCN", "VDT"), O("SJL", "XDV"), O("KQ1", "GNT"),
        O("YX7", "BN4"), O("MKP", "SX9"), O("1W8", "1DF"), O("VNJ", "N3Z"), O("YT8", "8QV"),
        O("JPS", "VF2"), O("G7P", "KGY"), O("4ZD", "MDX"), O("HHS", "THP"), O("WCS", "5SD"),
        O("N63", "RTL"), O("4ZG", "YQQ"), O("ZRH", "HRQ"), O("5P6", "MMY"), O("MMY", "V4N"),
        O("Q27", "M3F"), O("J65", "VH7"), O("JHH", "NHZ"), O("X4V", "W5L"), O("2H6", "NP4"),
        O("XH5", "48R"), O("X61", "656"), O("WQ5", "BV7"), O("4FH", "TQP"), O("DMF", "WZ3"),
        O("CHD", "PP2"), O("7FX", "TJT"), O("92B", "2GG"), O("37C", "ZV5"), O("H3P", "N4Z"),
        O("MJF", "842"), O("F8H", "ZGB"), O("XRS", "MPT"), O("7BR", "BYF"), O("FCT", "SB9"),
        O("NV3", "Z4H"), O("SQM", "WHJ"), O("4NB", "FJ7"), O("HMD", "R38"), O("VC7", "HFT"),
        O("31C", "57K"), O("RX2", "SWR"), O("H65", "GXT"), O("23M", "8ZQ"), O("PWL", "VFB"),
        O("FW3", "79G"), O("57K", "TZ2"), O("7TV", "1MS"), O("FV1", "VF7"), O("W55", "RCJ"),
        O("TS1", "P22"), O("W5X", "XZX"), O("Z9H", "9ZV"), O("8XQ", "9KP"), O("L8Y", "6KL"),
        O("5LX", "FD3"), O("DZV", "ZQ4"), O("8MK", "46T"), O("3FV", "V6G"), O("RFT", "MG8"),
        O("41K", "2HC"), O("YC4", "M7B"), O("QWP", "HYK"), O("DYF", "WP2"), O("VXJ", "D7Y"),
        O("BYG", "VQ2"), O("V6G", "SQ3"), O("17K", "248"), O("9XL", "DVV"), O("WWD", "QM4"),
        O("HG1", "Q4R"), O("C2H", "Q3F"), O("2MT", "YOU"), O("V16", "17K"), O("PTW", "XQW"),
        O("46N", "D3L"), O("VM1", "ZW4"), O("SKY", "SF8"), O("LLL", "H48"), O("SX9", "784"),
        O("17R", "HGT"), O("S27", "GY8"), O("G7V", "7WD"), O("24C", "RBY"), O("HHV", "4NB"),
        O("WVX", "TCC"), O("FC2", "36H"), O("NHT", "63D"), O("XXW", "7ML"), O("FG3", "BMC"),
        O("FVD", "FN1"), O("GFG", "1JY"), O("X6G", "CMY"), O("BGB", "DR8"), O("ZTC", "2G7"),
        O("9HF", "T9P"), O("MWN", "W54"), O("JSJ", "SX1"), O("XWZ", "SLW"), O("H2N", "RX2"),
        O("C7S", "YNS"), O("6K7", "X4Y"), O("V83", "N68"), O("V9T", "R4W"), O("YMC", "HRJ"),
        O("T94", "NR3"), O("6H1", "YT8"), O("GW8", "T94"), O("FQ5", "62P"), O("CNM", "N8R"),
        O("TJ4", "G3D"), O("X34", "N2J"), O("JHJ", "G3C"), O("NSG", "1CN"), O("QKZ", "873"),
        O("RC4", "1HF"), O("BL4", "TKG"), O("JH2", "D6C"), O("716", "N5B"), O("CD6", "YV5"),
        O("NZC", "4LH"), O("5X3", "5W3"), O("BY2", "TKD"), O("3H7", "SMW"), O("K1J", "J6B"),
        O("Q51", "BZW"), O("N6J", "6Q5"), O("MPG", "6XK"), O("VBG", "R7V"), O("MLP", "L82"),
        O("STK", "WNN"), O("WSJ", "JW1"), O("QDD", "LWS"), O("DG3", "JRQ"), O("TVV", "8G8"),
        O("LL2", "NSZ"), O("5V4", "YP4"), O("WDH", "GZG"), O("937", "JK6"), O("H6V", "B95"),
        O("VFB", "DPN"), O("CQW", "V7M"), O("W5X", "RCD"), O("ZNS", "WWR"), O("6DY", "CV6"),
        O("NWV", "7F5"), O("8TV", "445"), O("92M", "HVN"), O("XW7", "VXJ"), O("V2L", "135"),
        O("KPV", "836"), O("H3H", "SMB"), O("WKJ", "WDH"), O("678", "TF2"), O("D12", "8YK"),
        O("7X9", "MXX"), O("NYH", "VTH"), O("5GM", "JS2"), O("KLY", "HYQ"), O("G7L", "DZ9"),
        O("WRG", "D47"), O("8YL", "K7F"), O("7RG", "YGR"), O("641", "G85"), O("Z1M", "R8T"),
        O("XDG", "SHY"), O("V5Y", "Z76"), O("BN4", "JZ5"), O("QLD", "XPW"), O("3SS", "GD6"),
        O("X2Y", "HY6"), O("QTM", "FHK"), O("FPW", "HG1"), O("SQ3", "WR8"), O("VF7", "1NN"),
        O("CQD", "V8W"), O("HJF", "GTM"), O("MF1", "7BP"), O("C7V", "2C2"), O("FHY", "QTM"),
        O("RL8", "PZQ"), O("ML1", "HY9"), O("VVK", "8QH"), O("7LN", "QYQ"), O("WDG", "855"),
        O("9ZV", "KMV"), O("597", "87V"), O("R5B", "3L1"), O("RM6", "6B3"), O("VN5", "WSR"),
        O("CLM", "MF1"), O("MG8", "YK6"), O("TQP", "PVM"), O("3S1", "5GR"), O("Q5D", "GWZ"),
        O("ZW4", "3V1"), O("4JF", "D12"), O("JBY", "MD5"), O("C75", "R6R"), O("RWN", "5P6"),
        O("5P9", "MNG"), O("2TK", "G68"), O("C6C", "CB2"), O("6K4", "MP2"), O("K7F", "DZ4"),
        O("959", "NRL"), O("3H1", "FQQ"), O("MRL", "YFX"), O("W3M", "9X9"), O("TM6", "VNS"),
        O("TY3", "QYV"), O("TXJ", "WVJ"), O("YCB", "65X"), O("H4G", "Z9H"), O("2ZY", "SZR"),
        O("P31", "X61"), O("9QN", "K2W"), O("S71", "GN7"), O("6GV", "3HG"), O("418", "2YY"),
        O("VNV", "9T5"), O("T4L", "N6J"), O("3YT", "4VG"), O("1X3", "6ND"), O("DCV", "5WQ"),
        O("XXZ", "75G"), O("H7C", "4G2"), O("CB2", "32S"), O("8HN", "7FP"), O("HVP", "MF9"),
        O("D47", "V24"), O("HZY", "G1S"), O("2GJ", "WGT"), O("FFX", "R4T"), O("R6N", "444"),
        O("XWY", "G42"), O("TJT", "13B"), O("THD", "Y5P"), O("L47", "KTF"), O("PKS", "7XX"),
        O("GC9", "BKL"), O("D6C", "2W3"), O("J9G", "395"), O("XNR", "T7S"), O("YQ7", "VL3"),
        O("FBJ", "R31"), O("5FJ", "JBS"), O("XX7", "LRQ"), O("LF5", "MJY"), O("GR3", "8S3"),
        O("S4T", "X7D"), O("HQX", "MC4"), O("KVJ", "3NK"), O("L14", "W2B"), O("Z2S", "XMG"),
        O("24L", "4SK"), O("VJX", "K5W"), O("SXC", "4VV"), O("FTQ", "R5S"), O("YDB", "Y3J"),
        O("C9N", "YBP"), O("L36", "9PC"), O("FKR", "QQ1"), O("8T9", "LCM"), O("S7Q", "C3T"),
        O("2N1", "9JW"), O("YSZ", "XXW"), O("LWS", "DQ3"), O("H1F", "24C"), O("LNJ", "YFD"),
        O("7V3", "5V6"), O("XDW", "RPJ"), O("814", "M64"), O("9SV", "GJ4"), O("NHD", "M2R"),
        O("HB3", "KR8"), O("4BG", "SYP"), O("W71", "T7N"), O("CG7", "T1M"), O("VFF", "21F"),
        O("L8Y", "H2N"), O("N68", "3NV"), O("L63", "MKR"), O("9RJ", "81G"), O("F5Q", "LJJ"),
        O("25B", "SJL"), O("TJ4", "LZR"), O("KZD", "N7Q"), O("5V3", "7W9"), O("MD5", "X4C"),
        O("D6P", "NV7"), O("6H9", "CLV"), O("3NK", "3L6"), O("5S5", "XW1"), O("J2R", "RXX"),
        O("2KN", "298"), O("7FZ", "8N1"), O("VTC", "5RG"), O("SJ8", "571"), O("VQ2", "GPR"),
        O("PY7", "DKV"), O("MPC", "54J"), O("2BT", "H2X"), O("CSC", "KDF"), O("LJ4", "X3V"),
        O("V22", "NHT"), O("ZVJ", "8DW"), O("2FC", "FCT"), O("PLR", "5JB"), O("51J", "KNV"),
        O("BYF", "HW4"), O("JXR", "KX7"), O("NV9", "R23"), O("K8R", "BSP"), O("96P", "J52"),
        O("NB3", "SQM"), O("JDT", "KZD"), O("LWB", "6TT"), O("5N1", "QC6"), O("BGN", "9V7"),
        O("QBH", "P5T"), O("T14", "4JF"), O("HM9", "Y6K"), O("KR2", "6ZZ"), O("K87", "JPX"),
        O("69N", "5GV"), O("629", "GYP"), O("BZW", "YC4"), O("7PG", "9R5"), O("PPD", "RQ8"),
        O("NSZ", "TW9"), O("G2H", "WJG"), O("NP4", "W5X"), O("FZ4", "TCR"), O("X8T", "XQY"),
        O("3L6", "QZP"), O("N7M", "ZR8"), O("V15", "2GW"), O("6BY", "4XL"), O("YCH", "BNW"),
        O("DHQ", "5SF"), O("5SZ", "846"), O("F1V", "ZT2"), O("82H", "LTJ"), O("ZYC", "H3H"),
        O("HHY", "Q6S"), O("BKL", "4XY"), O("XKY", "RSY"), O("VTN", "HVZ"), O("9TH", "XNR"),
        O("6KL", "S8G"), O("C78", "J9G"), O("7QP", "LN4"), O("VQH", "W1C"), O("FN6", "CSC"),
        O("BSP", "NZT"), O("6RD", "ZFX"), O("5VY", "DZV"), O("HHH", "95J"), O("B7K", "JNN"),
        O("2MZ", "DY1"), O("4SK", "P5H"), O("HZG", "TZD"), O("F9N", "5Z2"), O("Q5H", "8D3"),
        O("HVK", "WQ5"), O("F7Q", "2YV"), O("L5K", "R2W"), O("Z6L", "7GK"), O("P9M", "H1V"),
        O("W5G", "HL8"), O("5WQ", "R8G"), O("CG8", "QKZ"), O("6S8", "SS3"), O("YML", "2BC"),
        O("ZQH", "B4Z"), O("84W", "R2S"), O("YSY", "6VP"), O("W3T", "XLJ"), O("94W", "G8P"),
        O("HGF", "JH5"), O("XHD", "HX7"), O("F6Q", "R82"), O("4NW", "J7J"), O("CV6", "J8T"),
        O("TRG", "XX5"), O("LW1", "5GM"), O("956", "5JK"), O("FVR", "VW4"), O("4YT", "716"),
        O("5NG", "2FC"), O("GDT", "S7D"), O("RPJ", "YCH"), O("5ZZ", "5KH"), O("54L", "SWD"),
        O("KZ5", "J3M"), O("3MQ", "6X2"), O("HFT", "F3Z"), O("455", "F4T"), O("RWN", "JHN"),
        O("TFD", "N5L"), O("XW1", "WS1"), O("2DH", "KHP"), O("N2G", "8WR"), O("V2V", "WNQ"),
        O("Z4V", "ZX3"), O("N59", "FB6"), O("R7X", "KZK"), O("TQC", "59M"), O("CQ5", "25B"),
        O("8KZ", "N4S"), O("T1F", "VP8"), O("C9H", "6H1"), O("86N", "DH8"), O("96S", "23D"),
        O("ZB7", "NCR"), O("7ZP", "6L2"), O("PFG", "9L1"), O("G98", "6KQ"), O("846", "GBD"),
        O("3NV", "JLP"), O("LYM", "LL2"), O("GPR", "TL5"), O("7NR", "GWR"), O("1Q4", "583"),
        O("1DT", "YRY"), O("WBW", "JLF"), O("Z43", "KHR"), O("72Z", "Y44"), O("WQP", "NC5"),
        O("26Z", "PQ2"), O("11Y", "4ZG"), O("KTX", "DHZ"), O("98B", "3SF"), O("H48", "YSY"),
        O("V8N", "SZX"), O("T3G", "MG1"), O("FDJ", "HHV"), O("56F", "FQ9"), O("P7W", "WNB"),
        O("WV7", "SLZ"), O("53L", "YXT"), O("LVR", "M7C"), O("8V3", "QCY"), O("JR1", "HW3"),
        O("33Q", "NGJ"), O("H3Y", "6J1"), O("XLJ", "PSK"), O("VHW", "NBZ"), O("7LV", "7NR"),
        O("27X", "V9T"), O("213", "CQD"), O("SD6", "Z43"), O("PBJ", "17Q"), O("R73", "V5H"),
        O("MGX", "9XV"), O("GTM", "JHF"), O("KR5", "W1H"), O("MJF", "MFR"), O("R5N", "GC9"),
        O("CJK", "VNV"), O("FHK", "XVL"), O("LF8", "1L4"), O("RM7", "HHY"), O("M6H", "PXG"),
        O("XMM", "BXZ"), O("7BP", "T6Y"), O("LXD", "7PG"), O("48R", "XRS"), O("6Q3", "51J"),
        O("TZD", "SQP"), O("7ZL", "F55"), O("M64", "NYY"), O("FBJ", "F72"), O("2GW", "F1P"),
        O("444", "HBX"), O("V1M", "84W"), O("D8V", "VRS"), O("QLX", "8HR"), O("NZ7", "LJD"),
        O("HT8", "B6X"), O("F91", "S27"), O("9MH", "XT4"), O("FGB", "JLV"), O("6XH", "1XF"),
        O("23K", "ZDP"), O("834", "RM6"), O("GJ4", "818"), O("XJD", "7SC"), O("13N", "D4G"),
        O("HGS", "P2G"), O("TWB", "DWF"), O("KT9", "GH6"), O("YHB", "36R"), O("FWW", "7DR"),
        O("H9N", "HTG"), O("C1V", "QX5"), O("J3M", "KT9"), O("SLZ", "1GH"), O("ZYD", "K55"),
        O("BDJ", "C4L"), O("395", "TBX"), O("J8K", "4C2"), O("8G1", "WDG"), O("TZD", "3XG"),
        O("MXV", "HF6"), O("P5T", "NV9"), O("MHG", "4D2"), O("V2X", "DTS"), O("1Z6", "1WM"),
        O("BC7", "GW8"), O("NV5", "4ZD"), O("26Z", "PLT"), O("FR4", "GS6"), O("1DF", "TNP"),
        O("NLQ", "MPC"), O("ZFL", "45R"), O("Z3T", "7WF"), O("3P9", "P9Y"), O("V7V", "2QT"),
        O("X3M", "ZBG"), O("XMG", "HT8"), O("ZSJ", "HS1"), O("TCR", "V9W"), O("VTH", "TBK"),
        O("BTM", "WBW"), O("27X", "BS6"), O("WNQ", "HTW"), O("BQC", "SJ8"), O("GCM", "WVX"),
        O("SB7", "MJF"), O("X9Q", "YQ7"), O("D6K", "MRL"), O("HSZ", "F8F"), O("BWS", "PKS"),
        O("9KP", "9W2"), O("43C", "DWN"), O("KN2", "GZQ"), O("G1L", "NXL"), O("TCL", "8TY"),
        O("BKW", "B21"), O("M82", "9DT"), O("B27", "GLB"), O("JDG", "F26"), O("99X", "Y9L"),
        O("566", "CQW"), O("MPK", "SLQ"), O("WL9", "956"), O("N13", "653"), O("SWS", "JR1"),
        O("N35", "29D"), O("QVK", "J2R"), O("4C2", "P8F"), O("C1S", "4TY"), O("YF7", "6RS"),
        O("BDM", "YX7"), O("9TY", "ZYD"), O("TPD", "8XQ"), O("DYM", "JPR"), O("TKD", "TWB"),
        O("WVJ", "N4X"), O("41J", "KSY"), O("HTG", "Q8C"), O("N8R", "H9X"), O("XVR", "RQM"),
        O("WSR", "KMD"), O("S99", "V83"), O("BS3", "8VP"), O("QPH", "23K"), O("3VF", "S6B"),
        O("23D", "76X"), O("827", "9VC"), O("5GV", "SDR"), O("635", "FDJ"), O("RQM", "8TV"),
        O("51Z", "9VM"), O("NT5", "95K"), O("F72", "9FR"), O("YP4", "7Y4"), O("G42", "3N2"),
        O("PY1", "CC3"), O("S4P", "JRR"), O("7X5", "566"), O("KR8", "VS8"), O("13B", "NZ7"),
        O("X4C", "VQH"), O("VLB", "BZM"), O("LCM", "V3V"), O("K1R", "9TY"), O("7K5", "N13"),
        O("W1H", "S2M"), O("V8S", "635"), O("J1L", "TRG"), O("ZR8", "Q8L"), O("XPW", "QRY"),
        O("XDV", "997"), O("M74", "VWG"), O("395", "T7W"), O("QYV", "RDZ"), O("8JX", "4NW"),
        O("4C5", "FZ4"), O("XVL", "1C2"), O("WDT", "FV1"), O("R2W", "VQ8"), O("C4L", "TV5"),
        O("N57", "GQS"), O("9FR", "QLX"), O("6C4", "L5K"), O("F3Z", "62B"), O("W9M", "S3G"),
        O("JHH", "7LN"), O("HBN", "GYK"), O("DY9", "CJK"), O("787", "2Z3"), O("44V", "LF8"),
        O("C3T", "13N"), O("XTK", "5ZK"), O("571", "HL9"), O("TTQ", "R9R"), O("VWK", "MWN"),
        O("DYT", "8ZN"), O("CCH", "YCF"), O("JPJ", "JHJ"), O("JHF", "DKR"), O("SPP", "FPW"),
        O("MKR", "78L"), O("X8Q", "C9N"), O("J1Q", "SPP"), O("Y7J", "YML"), O("2JS", "F6Q"),
        O("56T", "DHL"), O("3N2", "6YT"), O("DF4", "K82"), O("Y89", "VR6"), O("59M", "SZ2"),
        O("1MV", "CTP"), O("626", "Z2S"), O("7D7", "L36"), O("V6V", "H1W"), O("T7W", "D3D"),
        O("WPJ", "71N"), O("75G", "XFP"), O("71J", "HGL"), O("WK3", "S3T"), O("SMW", "QVK"),
        O("T3L", "Y8F"), O("P84", "NL3"), O("TF4", "6GD"), O("KMK", "FQC"), O("2QT", "CXK"),
        O("8LL", "PDZ"), O("4C2", "32W"), O("5JB", "Q4P"), O("4W7", "5N7"), O("QZP", "TQ2"),
        O("7QG", "Q72"), O("SDR", "LZH"), O("C9R", "7ZP"), O("QXS", "X2K"), O("D7Y", "YYG"),
        O("9BC", "4RY"), O("976", "6TQ"), O("QL2", "BXC"), O("ZXK", "HQX"), O("D3D", "6C4"),
        O("NK3", "S2Q"), O("B95", "SKL"), O("NN4", "2VB"), O("NHT", "1X3"), O("RHG", "F8Y"),
        O("GRL", "RS8"), O("2GY", "41G"), O("D48", "F4D"), O("2YV", "3V8"), O("JC5", "V8C"),
        O("T7S", "TYM"), O("KRN", "7K5"), O("K1N", "RTD"), O("X97", "MCF"), O("3TH", "5XR"),
        O("MNG", "MHG"), O("QX5", "STK"), O("D82", "D9R"), O("KNG", "K36"), O("288", "4FF"),
        O("W1G", "LZN"), O("FJ7", "TVV"), O("YXT", "BVH"), O("RQ8", "QB4"), O("5QS", "7DY"),
        O("FZX", "T5L"), O("BZ2", "WRG"), O("GYP", "X8Q"), O("NY3", "N3J"), O("298", "JS9"),
        O("KHR", "JTK"), O("T7N", "JC5"), O("2J7", "KKD"), O("HL9", "PDT"), O("XZX", "WQP"),
        O("GXJ", "T6B"), O("NHM", "PCD"), O("R4T", "JBY"), O("3SF", "J2N"), O("MW8", "9T9"),
        O("3YQ", "D5P"), O("6J1", "NC9"), O("VDT", "4RZ"), O("9VM", "FZQ"), O("G77", "2TK"),
        O("YL6", "H3N"), O("QSW", "V4V"), O("GR2", "KYS"), O("MPT", "PTC"), O("N1L", "D6K"),
        O("F8N", "T1F"), O("K2W", "R5B"), O("RC1", "D9J"), O("PP2", "WJ4"), O("JRR", "V8N"),
        O("GZW", "4LQ"), O("21F", "2VL"), O("HQM", "4XJ"), O("CNT", "HH7"), O("7DY", "ZGV"),
        O("FQC", "L63"), O("972", "JS6"), O("BK3", "SWS"), O("9CW", "4WS"), O("V5S", "Q7H"),
        O("2WP", "QX6"), O("C57", "6GF"), O("BZH", "GFL"), O("FK2", "SJF"), O("NBZ", "RBV"),
        O("4NK", "CCY"), O("JRQ", "QVV"), O("3HS", "M7Y"), O("6HP", "G77"), O("TNP", "9LQ"),
        O("8G8", "NH3"), O("DVQ", "3V4"), O("K98", "G2J"), O("BSS", "JSS"), O("KGY", "G8M"),
        O("SZR", "2KN"), O("KWZ", "NJV"), O("WJG", "FPF"), O("F26", "ZFL"), O("TVB", "2M8"),
        O("445", "KJ5"), O("RQ8", "2P3"), O("SDR", "XJD"), O("HL8", "M82"), O("TLY", "3YQ"),
        O("R16", "249"), O("2CV", "144"), O("L45", "W7D"), O("P5S", "R8S"), O("V3V", "HNX"),
        O("G7K", "X34"), O("W1V", "DXZ"), O("HXJ", "BVV"), O("TLY", "7ZL"), O("BVH", "CQ5"),
        O("QSG", "GRS"), O("Q53", "96P"), O("RCJ", "TVD"), O("YGR", "VC7"), O("P92", "C2H"),
        O("D3D", "N7Z"), O("NWH", "XYW"), O("8XL", "T3G"), O("824", "3L5"), O("M3K", "KLY"),
        O("QQ1", "QJ2"), O("NXL", "L21"), O("N88", "KYB"), O("DWN", "JT5"), O("TPW", "NY3"),
        O("HGT", "SVY"), O("LZH", "SC2"), O("CP6", "S1B"), O("51P", "6RY"), O("GZ9", "DHQ"),
        O("FSX", "FGB"), O("NZX", "KMK"), O("RMT", "8BN"), O("71N", "TQC"), O("BHT", "NYS"),
        O("W1G", "8J9"), O("LMG", "K87"), O("SF8", "CCC"), O("7DH", "JD5"), O("59M", "M6H"),
        O("V8N", "JH2"), O("8KK", "HVP"), O("R6S", "42Y"), O("8Z1", "5V4"), O("ZX3", "69N"),
        O("VWN", "GZW"), O("JCM", "HKQ"), O("G61", "M1Z"), O("6Q5", "N91"), O("89H", "CFK"),
        O("MW2", "W5H"), O("M11", "5F4"), O("YXV", "HVW"), O("563", "KQ1"), O("GBN", "7TS"),
        O("LJD", "TF3"), O("1TM", "C1V"), O("RS8", "5CF"), O("96S", "XR8"), O("GZQ", "NB3"),
        O("W5L", "976"), O("BZM", "TPW"), O("D67", "488"), O("1JY", "PLR"), O("DXK", "B9Y"),
        O("7W3", "3KS"), O("COM", "N59"), O("2JY", "M2N"), O("Y1D", "DG3"), O("K1Q", "H9L"),
        O("Y4J", "7M7"), O("YMC", "M8R"), O("S5P", "GBM"), O("KN6", "TXJ"), O("T44", "L7C"),
        O("HK4", "HGS"), O("P9R", "3FV"), O("CTX", "8J4"), O("N5D", "H7C"), O("WZ1", "1BF"),
        O("7Y4", "6VZ"), O("LLZ", "827"), O("JS9", "S4P"), O("HLY", "773"), O("8KB", "RR2"),
        O("4VG", "5NG"), O("87V", "NL7"), O("1BF", "HJP"), O("X4Y", "MYW"), O("9LQ", "VTC"),
        O("RNH", "XWR"), O("ZFB", "RC1"), O("KSY", "MGL"), O("9PY", "Z1M"), O("15Y", "MYP"),
        O("LV3", "614"), O("2C2", "R6D"), O("8Z9", "XH5"), O("HH7", "FZX"), O("HGL", "JGN"),
        O("HTS", "XGV"), O("17Q", "45Q"), O("J17", "99X"), O("LMX", "BY2"), O("GZG", "YXV"),
        O("8D9", "BRS"), O("18C", "MZN"), O("DP7", "VVK"), O("MXX", "PFG"), O("P1K", "9XJ"),
        O("99L", "ZN6"), O("2G7", "C4M"), O("GXT", "W1G"), O("72F", "4CC"), O("YFD", "HZY"),
        O("65X", "56T"), O("YR2", "5SZ"), O("D3L", "7NQ"), O("K9J", "SJC"), O("Q83", "9PS"),
        O("Z91", "4T7"), O("W1K", "KVB"), O("SJF", "FVD"), O("ZG1", "63B"), O("NV5", "R16"),
        O("DHZ", "FP1"), O("LZN", "ND1"), O("Z2S", "93V"), O("J8T", "GZ9"), O("W3T", "94W"),
        O("JG8", "6QV"), O("MG1", "W8P"), O("FNL", "DYF"), O("255", "RF1"), O("X38", "BWS"),
        O("KX7", "5ZZ"), O("9Y2", "V22"), O("QBX", "DXQ"), O("K93", "N1L"), O("653", "P31"),
        O("LR9", "7FH"), O("9ZG", "3PN"), O("V5J", "CP6"), O("PDF", "15Y"), O("ZQP", "N35"),
        O("ZZ8", "TCV"), O("NK3", "FDD"), O("23K", "N5J"), O("BK8", "TLY"), O("S3G", "HCL"),
        O("BS6", "HK4"), O("W1J", "3Q3"), O("D7F", "X3M"), O("YWL", "ZW7"), O("DVV", "YHR"),
        O("K9Z", "T8H"), O("5D5", "HLB"), O("MYW", "8R2"), O("J5M", "ZLD"), O("1GQ", "6T9"),
        O("L21", "KRQ"), O("6GD", "Y77"), O("MDX", "R2N"), O("NC5", "DR9"), O("K55", "TFC"),
        O("YH3", "P7W"), O("4FF", "6S4"), O("BMZ", "9PY"), O("P5H", "XKG"), O("BV7", "QBX"),
        O("135", "PK9"), O("LZR", "DPH"), O("N57", "TM6"), O("VH7", "XX7"), O("MPC", "LYZ"),
        O("L5B", "V6V"), O("JS2", "BS3"), O("784", "ZT7"), O("95J", "D8V"), O("F91", "4BK"),
        O("3TJ", "43X"), O("6B4", "LDY"), O("DR9", "J5M"), O("3T2", "CFZ"), O("5XK", "5TH"),
        O("XKG", "1SC"), O("M7B", "D48"), O("DX7", "G9P"), O("CST", "DMF"), O("7ML", "7D7"),
        O("TVM", "YWL"), O("L47", "G61"), O("XBC", "W9M"), O("F4D", "3SS"), O("JV1", "T1T"),
        O("G1T", "86Y"), O("3YP", "JPJ"), O("DHL", "G1L"), O("QYQ", "9PL"), O("Z76", "GFG"),
        O("NGV", "TTR"), O("Q7Y", "QL7"), O("BWF", "M6M"), O("KN2", "3RQ"), O("WYP", "NZZ"),
        O("KY6", "SB7"), O("JHN", "19T"), O("836", "NYV"), O("LXQ", "KG6"), O("SKJ", "XV2"),
        O("XVY", "Y4L"), O("W3C", "J1L"), O("Z5P", "6B4"), O("78L", "LMG"), O("X1V", "S99"),
        O("JVT", "5X4"), O("GD6", "42N"), O("RDZ", "S5Y"), O("4S2", "CJM"), O("G1L", "455"),
        O("HSC", "733"), O("WZS", "N6W"), O("W5H", "ZQP"), O("QBZ", "D82"), O("V24", "K8R"),
        O("CSW", "VMG"), O("X4X", "VBG"), O("C8V", "SAN"), O("YSK", "LL4"), O("FLX", "RKC"),
        O("GH1", "234"), O("H5K", "T3L"), O("JZ8", "ZG1"), O("VD7", "GR3"), O("WQ7", "8KZ"),
        O("Y5P", "RZX"), O("P4L", "ZSJ"), O("VMB", "32K"), O("Y7K", "JD2"), O("LYZ", "XW7"),
        O("JV3", "CCH"), O("VX3", "XWY"), O("XMK", "P9R"), O("TYM", "1TM"), O("J7C", "DV8"),
        O("1KF", "WQV"), O("TD2", "G4H"), O("WJ4", "XVR"), O("JW1", "VM1"), O("DRZ", "9KV"),
        O("ZWJ", "TCL"), O("4D2", "8VS"), O("5RG", "W3T"), O("T6Y", "NB5"), O("GYB", "NSG"),
        O("414", "1FB"), O("YRQ", "M8L"), O("YYF", "LJ4"), O("SB9", "QJS"), O("V4K", "B7K"),
        O("YZH", "WGM"), O("YGH", "1MV"), O("RTD", "VZY"), O("HVK", "VZV"), O("DXW", "QDD"),
        O("4G2", "MDJ"), O("R8T", "VQC"), O("1KD", "ZB7"), O("XFP", "H9N"), O("Q72", "XBC"),
        O("HDD", "SS6"), O("JZ8", "N2Z"), O("X3V", "XYD"), O("FQQ", "Z4V"), O("H9L", "5CW"),
        O("R2N", "LVR"), O("RKC", "MJS"), O("NYV", "3S1"), O("TRG", "G5T"), O("XZ7", "1R6"),
        O("6QV", "P17"), O("WS1", "6GV"), O("W2M", "P1K"), O("1WD", "5VY"), O("RBV", "HF3"),
        O("GPR", "4FH"), O("855", "BP6"), O("W2B", "LR9"), O("GN7", "9JV"), O("BP6", "4WM"),
        O("JGW", "94K"), O("VWG", "Q5D"), O("LXR", "PJ7"), O("LZ1", "HXJ"), O("WLW", "NCC"),
        O("MCN", "V5F"), O("5CD", "RMT"), O("57L", "LYM"), O("J52", "QLD"), O("GBD", "FBJ"),
        O("HZ2", "51Z"), O("3Z1", "DF4"), O("LRZ", "8MK"), O("M2R", "G7V"), O("G98", "3VF"),
        O("NB5", "JV1"), O("LL4", "25Y"), O("6T9", "6PY"), O("V4V", "R8C"), O("F7J", "BZ9"),
        O("HVW", "V8K"), O("R6R", "SNM"), O("53L", "F1V"), O("R7V", "WQD"), O("3VP", "BFP"),
        O("SD6", "SBX"), O("CQW", "CJL"), O("ZGV", "7RG"), O("STR", "WPJ"), O("HZQ", "R2F"),
        O("M6M", "N57"), O("SCP", "D6G"), O("G3C", "DBX"), O("3XG", "V8T"), O("MSS", "F8H"),
        O("VT8", "57L"), O("2W3", "MGW"), O("QK8", "HHS"), O("5HX", "TN4"), O("FLZ", "791"),
        O("9XV", "3CB"), O("N6W", "KZ5"), O("NJW", "284"), O("4T7", "SKJ"), O("36R", "GBN"),
        O("FTC", "V2V"), O("MQW", "X4V"), O("FPW", "G2H"), O("Q4R", "8HN"), O("2FF", "27X"),
        O("818", "WDT"), O("81G", "KR2"), O("H4W", "MLP"), O("1R4", "F7J"), O("V6R", "WZ1"),
        O("3PN", "N63"), O("DXL", "W1X"), O("5KH", "469"), O("V8W", "NJW"), O("6H2", "TF4"),
        O("TC1", "GCM"), O("GZG", "ZXK"), O("WMV", "76P"), O("RQ5", "FT1"), O("583", "V5Y"),
        O("LRT", "XDW"), O("S3T", "824"), O("GQS", "Z91"), O("YYG", "KYW"), O("GH6", "T3X"),
        O("4KT", "SNX"), O("X5N", "KP2"), O("HD6", "NGV"), O("5W3", "TVM"), O("SXG", "JTF"),
        O("7NQ", "2NX"), O("VQ3", "NYH"), O("7FP", "LZ1"), O("FL6", "MH8"), O("MQW", "51M"),
        O("GMT", "FZS"), O("N13", "BGN"), O("STR", "MBF"), O("2P3", "MGX"), O("NGJ", "YN6"),
        O("B4Z", "YYF"), O("127", "PVT"), O("SMB", "9Y2"), O("6LP", "YDB"), O("V4N", "S2W"),
        O("LMX", "5RJ"), O("W1C", "FLZ"), O("BFP", "QXB"), O("BCJ", "9HF"), O("9PL", "FFV"),
        O("777", "TTQ"), O("52F", "11Y"), O("7F1", "S71"), O("R4W", "Y5R"), O("9FP", "6JH"),
        O("S7D", "6K7"), O("F3Z", "LV3"), O("2GG", "B6C"), O("6S4", "MYX"), O("TTS", "3YP"),
        O("KMV", "MTG"), O("R8C", "ZSF"), O("8RK", "ZLL"), O("5F4", "RHJ"), O("KYS", "BL4"),
        O("19T", "44V"), O("XWZ", "VT8"), O("L7C", "Z99"), O("BVV", "QPH"), O("7DR", "W5G"),
        O("1B5", "RBJ"), O("1Y8", "KRN"), O("57J", "QVD"), O("S8G", "FVL"), O("F8F", "RHG"),
        O("RBX", "GH1"), O("JX4", "HDD"), O("G9P", "D9G"), O("H1V", "TT6"), O("51M", "2DH"),
        O("7M7", "TJ4"), O("XYX", "678"), O("G5T", "3HV"), O("758", "BYG"), O("6GF", "QZY"),
        O("MYX", "JDG"), O("9S1", "ZNY"), O("T59", "NQ3"), O("CTP", "NV3"), O("DBX", "XKY"),
        O("8N1", "4PP"), O("D6C", "7DH"), O("2BC", "QBZ"), O("CC3", "C7S"), O("DQT", "127"),
        O("RNF", "53L"), O("ZQ4", "2J7"), O("873", "M3J"), O("XMK", "MCN"), O("BC7", "DRC"),
        O("4XY", "89H"), O("8VW", "5XK"), O("8BB", "HMJ"), O("PJ7", "GDF"), O("G9C", "HMD"),
        O("6VZ", "CB9"), O("32K", "S4S"), O("CMW", "ZWJ"), O("7SR", "5RP"), O("W24", "418"),
        O("6L2", "F8N"), O("8QV", "W2M"), O("TXD", "M3H"), O("RBJ", "749"), O("DSJ", "SKY"),
        O("DY1", "SR9"), O("VR6", "6GP"), O("1GV", "CD6"), O("S7D", "DY9"), O("8QH", "HPX"),
        O("GNT", "5D5"), O("KG6", "6K8"), O("DSD", "HN6"), O("NG4", "2WP"), O("N5D", "1GQ"),
        O("X2K", "F59"), O("45Q", "LXQ"), O("L3T", "N5D"),
    };
};
