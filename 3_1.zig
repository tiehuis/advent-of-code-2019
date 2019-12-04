// --- Day 3: Crossed Wires ---
//
// The gravity assist was successful, and you're well on your way to the Venus refuelling station.
// During the rush back on Earth, the fuel management system wasn't completely installed, so that's
// next on the priority list.
//
// Opening the front panel reveals a jumble of wires. Specifically, two wires are connected to a
// central port and extend outward on a grid. You trace the path each wire takes as it leaves the
// central port, one wire per line of text (your puzzle input).
//
// The wires twist and turn, but the two wires occasionally cross paths. To fix the circuit, you
// need to find the intersection point closest to the central port. Because the wires are on a
// grid, use the Manhattan distance for this measurement. While the wires do technically cross
// right at the central port where they both start, this point does not count, nor does a wire
// count as crossing with itself.
//
// For example, if the first wire's path is R8,U5,L5,D3, then starting from the central port (o),
// it goes right 8, up 5, left 5, and finally down 3:
//
// ...........
// ...........
// ...........
// ....+----+.
// ....|....|.
// ....|....|.
// ....|....|.
// .........|.
// .o-------+.
// ...........
//
// Then, if the second wire's path is U7,R6,D4,L4, it goes up 7, right 6, down 4, and left 4:
//
// ...........
// .+-----+...
// .|.....|...
// .|..+--X-+.
// .|..|..|.|.
// .|.-X--+.|.
// .|..|....|.
// .|.......|.
// .o-------+.
// ...........
//
// These wires cross at two locations (marked X), but the lower-left one is closer to the central
// port: its distance is 3 + 3 = 6.
//
// Here are a few more examples:
//
//     R75,D30,R83,U83,L12,D49,R71,U7,L72
//     U62,R66,U55,R34,D71,R55,D58,R83 = distance 159
//     R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
//     U98,R91,D20,R16,D67,R40,U7,R15,U6,R7 = distance 135
//
// What is the Manhattan distance from the central port to the closest intersection?

const std = @import("std");

const Marker = enum(u2) {
    Empty = 0,
    Wire1 = 0b01,
    Wire2 = 0b10,
    Both = 0b11,
};

var allocator = std.heap.page_allocator;

pub fn main() !void {
    const origin_x = 15000;
    const origin_y = 15000;

    const w = 2 * origin_x;
    const h = 2 * origin_y;

    var grid = try allocator.alloc(u8, h * w);
    defer allocator.free(grid);
    std.mem.set(u8, grid, 0);

    // Trace wire1 path onto grid
    {
        var x: usize = origin_x;
        var y: usize = origin_y;

        for (wire1_path[0..]) |p| {
            var i: usize = 0;
            while (i < p.len) : (i += 1) {
                // Don't want to mark central port
                if (x != origin_x and y != origin_y) {
                    grid[y + w * x] |= @enumToInt(Marker.Wire1);
                }

                switch (p.dir) {
                    .Left => x -= 1,
                    .Right => x += 1,
                    .Up => y += 1,
                    .Down => y -= 1,
                }
            }
        }
    }

    // Trace wire2 path onto grid and check intersections
    {
        var x: usize = origin_x;
        var y: usize = origin_y;
        var min_distance: usize = std.math.maxInt(usize);

        for (wire2_path[0..]) |p| {
            var i: usize = 0;
            while (i < p.len) : (i += 1) {
                if (x != origin_x and y != origin_y) {
                    grid[y + w * x] |= @enumToInt(Marker.Wire2);
                }

                if (grid[y + w * x] == @enumToInt(Marker.Both)) {
                    var dx = @intCast(isize, x) - origin_x;
                    if (dx < 0) dx = -dx;

                    var dy = @intCast(isize, y) - origin_y;
                    if (dy < 0) dy = -dy;

                    const dist = @intCast(usize, dx + dy);
                    if (dist < min_distance) {
                        min_distance = dist;
                    }
                }

                switch (p.dir) {
                    .Left => x -= 1,
                    .Right => x += 1,
                    .Up => y += 1,
                    .Down => y -= 1,
                }
            }
        }

        std.debug.warn("{}\n", min_distance);
    }
}

const Path = struct {
    const Direction = enum {
        Left,
        Right,
        Up,
        Down,
    };

    dir: Direction,
    len: usize,
};

fn R(n: usize) Path {
    return Path{ .dir = .Right, .len = n };
}

fn L(n: usize) Path {
    return Path{ .dir = .Left, .len = n };
}

fn U(n: usize) Path {
    return Path{ .dir = .Up, .len = n };
}

fn D(n: usize) Path {
    return Path{ .dir = .Down, .len = n };
}

const wire1_path = [_]Path{
    R(1009), D(117), L(888), D(799), L(611), U(766), L(832), U(859), L(892), D(79),  R(645), U(191),
    L(681),  D(787), R(447), D(429), L(988), U(536), L(486), D(832), R(221), D(619), R(268), D(545),
    L(706),  U(234), L(528), D(453), R(493), D(24),  L(688), U(658), L(74),  D(281), R(910), D(849),
    L(5),    U(16),  R(935), D(399), L(417), U(609), R(22),  D(782), L(432), D(83),  L(357), D(982),
    L(902),  U(294), L(338), U(102), R(342), D(621), R(106), U(979), L(238), U(158), R(930), D(948),
    L(700),  D(808), R(445), U(897), R(980), U(227), L(466), D(416), R(244), U(396), R(576), U(157),
    R(548),  U(795), R(709), U(550), R(137), U(212), L(977), U(786), L(423), D(792), R(391), D(974),
    R(390),  U(771), R(270), D(409), L(917), D(9),   R(412), D(699), L(170), D(276), L(912), U(710),
    R(814),  U(656), R(4),   D(800), R(596), U(970), L(194), U(315), L(845), D(490), L(303), U(514),
    L(675),  D(737), L(880), D(86),  L(253), D(525), R(861), D(5),   R(424), D(113), L(764), D(900),
    R(485),  D(421), R(125), U(684), R(53),  U(96),  L(871), U(260), R(456), U(378), L(448), D(450),
    L(903),  D(482), R(750), U(961), R(264), D(501), R(605), D(367), R(550), U(642), R(228), U(164),
    L(343),  U(868), R(595), D(318), R(452), U(845), L(571), D(281), R(49),  D(889), L(481), U(963),
    R(182),  U(358), R(454), U(267), L(790), D(252), R(455), D(188), L(73),  U(256), L(835), D(816),
    R(503),  U(895), L(259), U(418), R(642), U(818), L(187), U(355), R(772), U(466), R(21),  U(91),
    R(707),  D(349), L(200), U(305), R(931), D(982), L(334), D(416), L(247), D(935), L(326), U(449),
    L(398),  D(914), R(602), U(10),  R(762), D(944), L(639), D(141), L(457), U(579), L(198), U(527),
    R(750),  U(167), R(816), D(753), R(850), D(281), L(712), D(583), L(172), D(254), L(544), D(456),
    R(966),  U(839), R(673), D(479), R(730), D(912), R(992), D(969), R(766), U(205), R(477), D(719),
    R(172),  D(735), R(998), D(687), R(698), D(407), R(172), U(945), R(199), U(348), L(256), D(876),
    R(580),  U(770), L(483), D(437), R(353), D(214), R(619), U(541), R(234), D(962), R(842), U(639),
    R(520),  D(354), L(279), D(15),  R(42),  U(138), L(321), D(376), L(628), D(893), L(670), D(574),
    L(339),  U(298), L(321), D(120), L(370), U(408), L(333), D(353), L(263), D(79),  R(535), D(487),
    R(113),  D(638), R(623), D(59),  L(508), D(866), R(315), U(166), L(534), U(927), L(401), D(626),
    L(19),   D(994), L(778), D(317), L(936), U(207), L(768), U(948), R(452), U(165), R(864), D(283),
    L(874),
};

const wire2_path = [_]Path{
    L(995), D(93),  L(293), U(447), L(793), D(605), R(497), D(155), L(542), D(570), R(113), D(779),
    L(510), U(367), L(71),  D(980), R(237), U(290), L(983), U(49),  R(745), U(182), L(922), D(174),
    L(189), D(629), R(315), D(203), R(533), U(72),  L(981), D(848), L(616), U(654), R(445), D(864),
    R(526), D(668), L(678), U(378), L(740), D(840), L(202), D(429), R(136), D(998), L(116), D(554),
    L(893), U(759), R(617), U(942), R(999), U(582), L(220), U(447), R(895), D(13),  R(217), U(743),
    L(865), U(950), R(91),  D(381), R(662), D(518), L(798), D(637), L(213), D(93),  L(231), D(185),
    R(704), U(581), L(268), U(773), R(405), U(862), R(796), U(73),  L(891), U(553), L(952), U(450),
    R(778), D(868), R(329), D(669), L(182), U(378), L(933), D(83),  R(574), U(807), R(785), D(278),
    R(139), D(362), R(8),   U(546), R(651), U(241), L(462), D(309), L(261), D(307), L(85),  U(701),
    L(913), U(271), R(814), U(723), L(777), D(256), R(417), U(814), L(461), U(652), R(198), D(747),
    R(914), U(520), R(806), U(956), L(771), D(229), R(984), U(685), R(663), D(812), R(650), U(214),
    R(839), U(574), L(10),  U(66),  R(644), D(371), L(917), D(819), L(73),  D(236), R(277), U(611),
    R(390), U(723), L(129), D(496), L(552), D(451), R(584), U(105), L(805), U(165), R(179), D(372),
    L(405), D(702), R(14),  U(332), L(893), D(419), R(342), D(146), R(907), D(672), L(316), U(257),
    L(903), U(919), L(942), U(771), R(879), U(624), L(280), U(150), L(320), U(220), R(590), D(242),
    R(744), U(291), R(562), U(418), L(898), U(66),  L(564), U(495), R(837), D(555), L(739), D(780),
    R(409), D(122), L(426), D(857), R(937), D(600), R(428), D(592), R(727), U(917), R(256), D(680),
    L(422), U(630), L(14),  U(240), R(617), D(664), L(961), D(554), L(302), U(925), L(376), D(187),
    L(700), D(31),  L(762), U(397), L(554), D(217), R(679), D(683), R(680), D(572), R(54),  D(164),
    L(940), D(523), R(140), U(52),  L(506), D(638), R(331), D(415), R(389), D(884), R(410), D(62),
    R(691), U(665), R(889), U(864), L(663), D(690), R(487), U(811), L(190), U(780), L(758), U(267),
    R(155), D(344), L(133), D(137), R(93),  D(229), L(729), U(878), L(889), D(603), R(288), U(890),
    R(251), U(531), L(249), D(995), R(863), D(257), R(655), D(311), R(874), U(356), L(833), U(151),
    L(741), U(246), R(694), D(899), L(48),  U(915), L(900), U(757), L(861), U(402), R(971), U(537),
    R(460), D(844), R(54),  U(956), L(151), U(74),  R(892), U(248), R(677), D(881), R(99),  D(931),
    R(427),
};
