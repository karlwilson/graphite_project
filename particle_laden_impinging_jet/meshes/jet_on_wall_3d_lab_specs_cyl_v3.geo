// SPDX-FileCopyrightText: Copyright (c) 2025 The Lethe Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception OR LGPL-2.1-or-later

// Cylindrical jet in a cylindrical chamber. v3: the central nozzle bore is
// re-meshed with the "balanced ball" layout of deal.II's 2D
// GridGenerator::hyper_ball_balanced() instead of the single-inner-square
// O-grid of v1/v2. The full ball is 4 quadrants x 3 cells = 12 quads: four
// inner quads pinwheeled around the centre plus eight boundary "cap" cells,
// one per 45deg arc (deal.II quarter_hyper_ball vertices: inner-axis at
// 0.55647 R, interior-diagonal at 0.42883 R, boundary points every 45deg).
//
// Because the balanced bore places 8 nodes on the bore circle (every 45deg,
// vs the 4 of v1/v2), the surrounding O-grid is now 8-fold: the nozzle-wall,
// chamber and extended annuli are each split into 8 sectors so every ring
// stays conformal with the bore. Geometry (radii, depths) is unchanged from
// v2; only the cross-sectional topology and the angular count differ.

// ---------------------------------------------------------------- parameters
wc  = 0.0072 / Sqrt(2);   // nozzle square half-diagonal (sets the bore radius)
rb  = wc / Sqrt(2);       // bore radius (unchanged: circle through +/-wc/2)
rbd = rb / Sqrt(2);       // diagonal boundary coordinate ( = wc/2 )
ri  = 0.55647 * rb;       // deal.II inner-axis radius
rq  = 0.42883 * rb;       // deal.II interior-diagonal coordinate
tc  = 0.00125;            // nozzle tube wall thickness
wo  = wc/2 + tc/Sqrt(2);  // nozzle outer-wall half-diagonal
Rw  = wo * Sqrt(2);       // nozzle outer-wall radius
dc  = 0.075;              // depth (z) of charging zone / nozzle interior
dp  = 0.05;               // depth (z) of projection zone
Rc  = 0.1;                // chamber radius
Rd  = Rc / Sqrt(2);       // chamber diagonal coordinate
Rc2 = Rc + 0.1;           // extended chamber radius (0.2)
Rd2 = Rc2 / Sqrt(2);      // extended diagonal coordinate

nb   = 3;      // points per 45deg arc  (circumferential; also inner-quad edges)
nbr  = 3;      // points across a bore cap (radial): 2 cell layers to nozzle wall
ntc  = 1;      // points across the nozzle wall thickness
nhp  = 8;      // points across the chamber annulus (radial)
exp  = 1.35;   // chamber annulus radial grading (finer near the jet)
nhp2 = 5;      // points across the extended annulus (radial, coarser)
exp2 = 1.0;    // extended annulus radial grading (uniform)
zp   = 7;      // z cells in the projection zone (forward, +dp)
zc   = 10;     // z cells in the charging zone   (backward, -dc)

// ---------------------------------------------------------------- points (z = 0)
Point(1) = {0, 0, 0};  // centre
// bore circle, 8 points every 45deg (k = 0..7: E,NE,N,NW,W,SW,S,SE)
Point(10) = {rb, 0, 0};  // E
Point(11) = {rbd, rbd, 0};  // NE
Point(12) = {0, rb, 0};  // N
Point(13) = {-rbd, rbd, 0};  // NW
Point(14) = {-rb, 0, 0};  // W
Point(15) = {-rbd, -rbd, 0};  // SW
Point(16) = {0, -rb, 0};  // S
Point(17) = {rbd, -rbd, 0};  // SE
// bore inner-axis ring (radius ri): ea, na, wa, sa
Point(20) = {ri, 0, 0};  // ea
Point(21) = {0, ri, 0};  // na
Point(22) = {-ri, 0, 0};  // wa
Point(23) = {0, -ri, 0};  // sa
// bore interior-diagonal ring (coordinate rq): ine, inw, isw, ise
Point(30) = {rq, rq, 0};  // ine
Point(31) = {-rq, rq, 0};  // inw
Point(32) = {-rq, -rq, 0};  // isw
Point(33) = {rq, -rq, 0};  // ise
// nozzle outer-wall circle (radius Rw), 8 points
Point(40) = {Rw, 0, 0};  // E
Point(41) = {wo, wo, 0};  // NE
Point(42) = {0, Rw, 0};  // N
Point(43) = {-wo, wo, 0};  // NW
Point(44) = {-Rw, 0, 0};  // W
Point(45) = {-wo, -wo, 0};  // SW
Point(46) = {0, -Rw, 0};  // S
Point(47) = {wo, -wo, 0};  // SE
// chamber circle (radius Rc), 8 points
Point(50) = {Rc, 0, 0};  // E
Point(51) = {Rd, Rd, 0};  // NE
Point(52) = {0, Rc, 0};  // N
Point(53) = {-Rd, Rd, 0};  // NW
Point(54) = {-Rc, 0, 0};  // W
Point(55) = {-Rd, -Rd, 0};  // SW
Point(56) = {0, -Rc, 0};  // S
Point(57) = {Rd, -Rd, 0};  // SE
// extended chamber circle (radius Rc2), 8 points
Point(60) = {Rc2, 0, 0};  // E
Point(61) = {Rd2, Rd2, 0};  // NE
Point(62) = {0, Rc2, 0};  // N
Point(63) = {-Rd2, Rd2, 0};  // NW
Point(64) = {-Rc2, 0, 0};  // W
Point(65) = {-Rd2, -Rd2, 0};  // SW
Point(66) = {0, -Rc2, 0};  // S
Point(67) = {Rd2, -Rd2, 0};  // SE

// bore points duplicated at z = -dc for the nozzle interior (+100 offset)
Point(101) = {0, 0, -dc};  // centre (back)
Point(110) = {rb, 0, -dc};  // E
Point(111) = {rbd, rbd, -dc};  // NE
Point(112) = {0, rb, -dc};  // N
Point(113) = {-rbd, rbd, -dc};  // NW
Point(114) = {-rb, 0, -dc};  // W
Point(115) = {-rbd, -rbd, -dc};  // SW
Point(116) = {0, -rb, -dc};  // S
Point(117) = {rbd, -rbd, -dc};  // SE
Point(120) = {ri, 0, -dc};  // ea
Point(121) = {0, ri, -dc};  // na
Point(122) = {-ri, 0, -dc};  // wa
Point(123) = {0, -ri, -dc};  // sa
Point(130) = {rq, rq, -dc};  // ine
Point(131) = {-rq, rq, -dc};  // inw
Point(132) = {-rq, -rq, -dc};  // isw
Point(133) = {rq, -rq, -dc};  // ise

// --- front (z = 0) bore: arcs / radials / octagon / spokes ---
Circle(200) = {10, 1, 11};
Circle(201) = {11, 1, 12};
Circle(202) = {12, 1, 13};
Circle(203) = {13, 1, 14};
Circle(204) = {14, 1, 15};
Circle(205) = {15, 1, 16};
Circle(206) = {16, 1, 17};
Circle(207) = {17, 1, 10};
Line(210) = {10, 20};
Line(211) = {11, 30};
Line(212) = {12, 21};
Line(213) = {13, 31};
Line(214) = {14, 22};
Line(215) = {15, 32};
Line(216) = {16, 23};
Line(217) = {17, 33};
Line(220) = {20, 30};
Line(221) = {30, 21};
Line(222) = {21, 31};
Line(223) = {31, 22};
Line(224) = {22, 32};
Line(225) = {32, 23};
Line(226) = {23, 33};
Line(227) = {33, 20};
Line(230) = {1, 20};
Line(231) = {1, 21};
Line(232) = {1, 22};
Line(233) = {1, 23};

Line Loop(1) = {230, 220, 221, -231};
Plane Surface(1) = {1};
Line Loop(2) = {231, 222, 223, -232};
Plane Surface(2) = {2};
Line Loop(3) = {232, 224, 225, -233};
Plane Surface(3) = {3};
Line Loop(4) = {233, 226, 227, -230};
Plane Surface(4) = {4};
Line Loop(5) = {200, 211, -220, -210};
Plane Surface(5) = {5};
Line Loop(6) = {201, 212, -221, -211};
Plane Surface(6) = {6};
Line Loop(7) = {202, 213, -222, -212};
Plane Surface(7) = {7};
Line Loop(8) = {203, 214, -223, -213};
Plane Surface(8) = {8};
Line Loop(9) = {204, 215, -224, -214};
Plane Surface(9) = {9};
Line Loop(10) = {205, 216, -225, -215};
Plane Surface(10) = {10};
Line Loop(11) = {206, 217, -226, -216};
Plane Surface(11) = {11};
Line Loop(12) = {207, 210, -227, -217};
Plane Surface(12) = {12};

// --- nozzle-wall annulus: outer arcs + radial connectors + 8 sectors ---
Circle(240) = {40, 1, 41};
Circle(241) = {41, 1, 42};
Circle(242) = {42, 1, 43};
Circle(243) = {43, 1, 44};
Circle(244) = {44, 1, 45};
Circle(245) = {45, 1, 46};
Circle(246) = {46, 1, 47};
Circle(247) = {47, 1, 40};
Line(250) = {10, 40};
Line(251) = {11, 41};
Line(252) = {12, 42};
Line(253) = {13, 43};
Line(254) = {14, 44};
Line(255) = {15, 45};
Line(256) = {16, 46};
Line(257) = {17, 47};
Line Loop(13) = {200, 251, -240, -250};
Plane Surface(13) = {13};
Line Loop(14) = {201, 252, -241, -251};
Plane Surface(14) = {14};
Line Loop(15) = {202, 253, -242, -252};
Plane Surface(15) = {15};
Line Loop(16) = {203, 254, -243, -253};
Plane Surface(16) = {16};
Line Loop(17) = {204, 255, -244, -254};
Plane Surface(17) = {17};
Line Loop(18) = {205, 256, -245, -255};
Plane Surface(18) = {18};
Line Loop(19) = {206, 257, -246, -256};
Plane Surface(19) = {19};
Line Loop(20) = {207, 250, -247, -257};
Plane Surface(20) = {20};

// --- chamber annulus: outer arcs + radial connectors + 8 sectors ---
Circle(260) = {50, 1, 51};
Circle(261) = {51, 1, 52};
Circle(262) = {52, 1, 53};
Circle(263) = {53, 1, 54};
Circle(264) = {54, 1, 55};
Circle(265) = {55, 1, 56};
Circle(266) = {56, 1, 57};
Circle(267) = {57, 1, 50};
Line(270) = {40, 50};
Line(271) = {41, 51};
Line(272) = {42, 52};
Line(273) = {43, 53};
Line(274) = {44, 54};
Line(275) = {45, 55};
Line(276) = {46, 56};
Line(277) = {47, 57};
Line Loop(21) = {240, 271, -260, -270};
Plane Surface(21) = {21};
Line Loop(22) = {241, 272, -261, -271};
Plane Surface(22) = {22};
Line Loop(23) = {242, 273, -262, -272};
Plane Surface(23) = {23};
Line Loop(24) = {243, 274, -263, -273};
Plane Surface(24) = {24};
Line Loop(25) = {244, 275, -264, -274};
Plane Surface(25) = {25};
Line Loop(26) = {245, 276, -265, -275};
Plane Surface(26) = {26};
Line Loop(27) = {246, 277, -266, -276};
Plane Surface(27) = {27};
Line Loop(28) = {247, 270, -267, -277};
Plane Surface(28) = {28};

// --- extended annulus: outer arcs + radial connectors + 8 sectors ---
Circle(280) = {60, 1, 61};
Circle(281) = {61, 1, 62};
Circle(282) = {62, 1, 63};
Circle(283) = {63, 1, 64};
Circle(284) = {64, 1, 65};
Circle(285) = {65, 1, 66};
Circle(286) = {66, 1, 67};
Circle(287) = {67, 1, 60};
Line(290) = {50, 60};
Line(291) = {51, 61};
Line(292) = {52, 62};
Line(293) = {53, 63};
Line(294) = {54, 64};
Line(295) = {55, 65};
Line(296) = {56, 66};
Line(297) = {57, 67};
Line Loop(29) = {260, 291, -280, -290};
Plane Surface(29) = {29};
Line Loop(30) = {261, 292, -281, -291};
Plane Surface(30) = {30};
Line Loop(31) = {262, 293, -282, -292};
Plane Surface(31) = {31};
Line Loop(32) = {263, 294, -283, -293};
Plane Surface(32) = {32};
Line Loop(33) = {264, 295, -284, -294};
Plane Surface(33) = {33};
Line Loop(34) = {265, 296, -285, -295};
Plane Surface(34) = {34};
Line Loop(35) = {266, 297, -286, -296};
Plane Surface(35) = {35};
Line Loop(36) = {267, 290, -287, -297};
Plane Surface(36) = {36};

// --- back (z = -dc) bore: arcs / radials / octagon / spokes ---
Circle(300) = {110, 101, 111};
Circle(301) = {111, 101, 112};
Circle(302) = {112, 101, 113};
Circle(303) = {113, 101, 114};
Circle(304) = {114, 101, 115};
Circle(305) = {115, 101, 116};
Circle(306) = {116, 101, 117};
Circle(307) = {117, 101, 110};
Line(310) = {110, 120};
Line(311) = {111, 130};
Line(312) = {112, 121};
Line(313) = {113, 131};
Line(314) = {114, 122};
Line(315) = {115, 132};
Line(316) = {116, 123};
Line(317) = {117, 133};
Line(320) = {120, 130};
Line(321) = {130, 121};
Line(322) = {121, 131};
Line(323) = {131, 122};
Line(324) = {122, 132};
Line(325) = {132, 123};
Line(326) = {123, 133};
Line(327) = {133, 120};
Line(330) = {101, 120};
Line(331) = {101, 121};
Line(332) = {101, 122};
Line(333) = {101, 123};

Line Loop(41) = {330, 320, 321, -331};
Plane Surface(41) = {41};
Line Loop(42) = {331, 322, 323, -332};
Plane Surface(42) = {42};
Line Loop(43) = {332, 324, 325, -333};
Plane Surface(43) = {43};
Line Loop(44) = {333, 326, 327, -330};
Plane Surface(44) = {44};
Line Loop(45) = {300, 311, -320, -310};
Plane Surface(45) = {45};
Line Loop(46) = {301, 312, -321, -311};
Plane Surface(46) = {46};
Line Loop(47) = {302, 313, -322, -312};
Plane Surface(47) = {47};
Line Loop(48) = {303, 314, -323, -313};
Plane Surface(48) = {48};
Line Loop(49) = {304, 315, -324, -314};
Plane Surface(49) = {49};
Line Loop(50) = {305, 316, -325, -315};
Plane Surface(50) = {50};
Line Loop(51) = {306, 317, -326, -316};
Plane Surface(51) = {51};
Line Loop(52) = {307, 310, -327, -317};
Plane Surface(52) = {52};

// ---------------------------------------------------------------- transfinite
Transfinite Surface {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52};
Recombine Surface {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52};

// circumferential + inner-quad edges (nb points per 45deg)
Transfinite Line {200, 201, 202, 203, 204, 205, 206, 207, 240, 241, 242, 243, 244, 245, 246, 247, 260, 261, 262, 263, 264, 265, 266, 267, 280, 281, 282, 283, 284, 285, 286, 287, 300, 301, 302, 303, 304, 305, 306, 307, 220, 221, 222, 223, 224, 225, 226, 227, 320, 321, 322, 323, 324, 325, 326, 327, 230, 231, 232, 233, 330, 331, 332, 333} = Ceil(nb) Using Progression 1;
// bore cap radial (bore circle -> inner ring)
Transfinite Line {210, 211, 212, 213, 214, 215, 216, 217, 310, 311, 312, 313, 314, 315, 316, 317} = Ceil(nbr) Using Progression 1;
// nozzle wall thickness
Transfinite Line {250, 251, 252, 253, 254, 255, 256, 257} = Ceil(ntc) Using Progression 1;
// chamber annulus radial (graded outward, finer near the jet)
Transfinite Line {270, 271, 272, 273, 274, 275, 276, 277} = Ceil(nhp) Using Progression exp;
// extended annulus radial (coarser)
Transfinite Line {290, 291, 292, 293, 294, 295, 296, 297} = Ceil(nhp2) Using Progression exp2;

// ---------------------------------------------------------------- extrusions
// Each base surface is a quad, so its 6-entry Extrude block is
// [top, volume, lat0, lat1, lat2, lat3]; lat_k is the swept k-th Line Loop
// curve. Block i starts at index 6*i in the captured list.

// Projection zone (forward, +dp): bore (12) + wall annulus (8)
// + chamber annulus (8) + extended annulus (8) = 36 surfaces, all fluid.
pA[] = Extrude {0, 0, dp} {
  Surface{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36};
  Layers{zp}; Recombine;
};

// Nozzle interior (forward, +dc from z = -dc): balanced bore only (12).
pB[] = Extrude {0, 0, dc} {
  Surface{41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52};
  Layers{zc}; Recombine;
};

// Surrounding fluid (backward, -dc): chamber annulus (8) + extended annulus
// (8). The wall annulus and bore are NOT sweep here, leaving the solid
// nozzle wall as an un-meshed void.
pC[] = Extrude {0, 0, -dc} {
  Surface{21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36};
  Layers{zc}; Recombine;
};

// ---------------------------------------------------------------- physical groups
// 36 + 12 + 16 = 64 fluid volumes.
Physical Volume(0) = {1:64};

// (0) Inlet: nozzle interior back face (z = -dc), stable base surfaces.
Physical Surface(0) = {41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52};

// (1) Anterior chamber face (z = -dc): top faces of pC (all 16 sectors).
Physical Surface(1) = {pC[0], pC[6], pC[12], pC[18], pC[24], pC[30], pC[36], pC[42], pC[48], pC[54], pC[60], pC[66], pC[72], pC[78], pC[84], pC[90]};

// (2) Downstream wall (z = +dp): every top face of pA.
Physical Surface(2) = {pA[0], pA[6], pA[12], pA[18], pA[24], pA[30], pA[36], pA[42], pA[48], pA[54], pA[60], pA[66], pA[72], pA[78], pA[84], pA[90], pA[96], pA[102], pA[108], pA[114], pA[120], pA[126], pA[132], pA[138], pA[144], pA[150], pA[156], pA[162], pA[168], pA[174], pA[180], pA[186], pA[192], pA[198], pA[204], pA[210]};

// (3) Nozzle wall (no-slip): inner cylinder (swept bore-cap arcs of pB),
//     outer cylinder (swept wall arcs of pC chamber annulus), and the rim
//     (wall-annulus base surfaces at z = 0).
Physical Surface(3) = {pB[26], pB[32], pB[38], pB[44], pB[50], pB[56], pB[62], pB[68],
                       pC[2], pC[8], pC[14], pC[20], pC[26], pC[32], pC[38], pC[44],
                       13, 14, 15, 16, 17, 18, 19, 20};

// (4) Lateral chamber wall: swept extended-circle arcs (loop index 2) from
//     pA (forward, extended annulus at positions 28..35) and pC (backward,
//     extended annulus at positions 8..15).
Physical Surface(4) = {pA[172], pA[178], pA[184], pA[190], pA[196], pA[202], pA[208], pA[214],
                       pC[52], pC[58], pC[64], pC[70], pC[76], pC[82], pC[88], pC[94]};

