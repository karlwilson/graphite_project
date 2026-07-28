// SPDX-FileCopyrightText: Copyright (c) 2025 The Lethe Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception OR LGPL-2.1-or-later

// Cylindrical jet in a *cylindrical* chamber (axisymmetric variant of
// jet_on_wall_3d_lab_specs_v1.geo). The nozzle bore and wall are unchanged;
// only the outer chamber cross-section is swapped from a rectangular ring to a
// circular annular ring, concentric with and aligned to the jet axis (z). This
// gives the chamber cells 4-fold angular symmetry about the jet.
//
// v2: the cylindrical chamber radius is extended outward by another 0.1 (from
// Rc = 0.1 to Rc2 = 0.2). The extension is added as a second, concentric
// annular ring outside the original chamber circle. It shares the chamber-circle
// arcs (so it is conformal with the v1 mesh), keeps the same circumferential and
// axial (z) resolution, but uses a coarser radial resolution across the added
// annulus (nhp2 < nhp) so the far field is meshed more cheaply.

// Define variables

// Charging zone (nozzle)

wc = 0.0072 / Sqrt(2); // width/height of charging zone
sq = 0.75 * wc; // width/height of square inside circle
dc = 0.075; // depth in z of charging zone
tc = 0.00125; // thickness of nozzle tube
nhc = 5; // number of points in height/width of charging zone
nwc = 3; // number of points in the width/height of the square
ntc = 2; // number of points across the nozzle wall thickness (annulus)
wo = wc/2 + tc/Sqrt(2); // half-width of the nozzle outer wall (outer O-grid ring)
zc = 8; // number of cells in the z direction (depth) of charging zone
R = Sqrt(2) * wc; // radius of big circle
h = (R - wc) / 2; // height of arcs


// Projection zone (main chamber) -- now a cylinder aligned with the jet

Rc = 0.1;          // radius of cylindrical chamber (was wp/2 = hp/2 = 0.1)
Rd = Rc / Sqrt(2); // diagonal coordinate of the chamber-circle O-grid corners
dp = 0.05; // depth in z of projection zone
dt = dc + dp; // total depth of chamber
zp = 6; // number of cells in the z direction (depth) of projection zone
nhp = 15; // number of points across the chamber annulus (radial)
exp = 1.05; // radial grading of the chamber annulus (finer near the jet)

// Extended (v2) far-field ring: outer radius grown by another 0.1, coarser mesh
Rc2 = Rc + 0.1;      // extended chamber radius (0.2)
Rd2 = Rc2 / Sqrt(2); // diagonal coordinate of the extended-circle O-grid corners
nhp2 = 6;            // (coarser) number of points across the extended annulus (radial)
exp2 = 1.0;          // radial grading of the extended annulus (uniform)


// --- Nozzle bore + wall points (unchanged from the rectangular version) ---
Point(6)  = {-wc/2,  wc/2, 0};
Point(7)  = {-wc/2, -wc/2, 0};
Point(10) = { wc/2,  wc/2, 0};
Point(11) = { wc/2, -wc/2, 0};
Point(17) = {-wc/2,  wc/2, -dc};
Point(18) = {-wc/2, -wc/2, -dc};
Point(19) = { wc/2,  wc/2, -dc};
Point(20) = { wc/2, -wc/2, -dc};
Point(21) = {0, 0, -dc};
Point(22) = {0, 0, 0};
Point(23) = {-sq/2,  sq/2, 0};
Point(24) = {-sq/2, -sq/2, 0};
Point(25) = { sq/2, -sq/2, 0};
Point(26) = { sq/2,  sq/2, 0};
Point(27) = {-sq/2,  sq/2, -dc};
Point(28) = {-sq/2, -sq/2, -dc};
Point(29) = { sq/2, -sq/2, -dc};
Point(30) = { sq/2,  sq/2, -dc};

// Outer-wall O-grid corner points (z = 0), radially outside the inner-circle
// corners 6, 7, 11, 10. These define the outer circle of the nozzle wall.
Point(31) = {-wo,  wo, 0};   // outer of 6 (top-left)
Point(32) = {-wo, -wo, 0};   // outer of 7 (bottom-left)
Point(33) = { wo, -wo, 0};   // outer of 11 (bottom-right)
Point(34) = { wo,  wo, 0};   // outer of 10 (top-right)

// Chamber O-grid corner points (z = 0): the outer circle of the whole chamber,
// concentric with the nozzle, one point per 45deg diagonal so the radial
// connectors below run straight out from the nozzle-wall corners.
Point(35) = {-Rd,  Rd, 0};   // outer of 31 (top-left)
Point(36) = {-Rd, -Rd, 0};   // outer of 32 (bottom-left)
Point(37) = { Rd, -Rd, 0};   // outer of 33 (bottom-right)
Point(38) = { Rd,  Rd, 0};   // outer of 34 (top-right)

// Extended-chamber O-grid corner points (z = 0): the outer circle of the added
// far-field ring, concentric with the nozzle, radially outside corners 35-38.
Point(39) = {-Rd2,  Rd2, 0}; // outer of 35 (top-left)
Point(40) = {-Rd2, -Rd2, 0}; // outer of 36 (bottom-left)
Point(41) = { Rd2, -Rd2, 0}; // outer of 37 (bottom-right)
Point(42) = { Rd2,  Rd2, 0}; // outer of 38 (top-right)

// --- Nozzle bore arcs / squares / connectors (unchanged) ---
Circle(6)  = {6, 22, 7};
Circle(13) = {10, 22, 6};
Circle(14) = {7, 22, 11};
Circle(15) = {11, 22, 10};
Circle(25) = {17, 21, 18};
Circle(26) = {18, 21, 20};
Circle(27) = {20, 21, 19};
Circle(28) = {19, 21, 17};
Line(29) = {23, 24};
Line(30) = {24, 25};
Line(31) = {25, 26};
Line(32) = {26, 23};
Line(33) = {23, 6};
Line(34) = {10, 26};
Line(35) = {25, 11};
Line(36) = {7, 24};
Line(37) = {27, 28};
Line(38) = {28, 29};
Line(39) = {29, 30};
Line(40) = {30, 27};
Line(41) = {27, 17};
Line(42) = {19, 30};
Line(43) = {29, 20};
Line(44) = {18, 28};

// Outer circle of the nozzle wall (z = 0), concentric with the inner circle
Circle(100) = {31, 22, 32}; // left
Circle(101) = {32, 22, 33}; // bottom
Circle(102) = {33, 22, 34}; // right
Circle(103) = {34, 22, 31}; // top

// Radial connectors across the wall thickness (inner corner -> outer corner)
Line(104) = {6, 31};
Line(105) = {7, 32};
Line(106) = {11, 33};
Line(107) = {10, 34};

// Outer circle of the chamber (z = 0), concentric with the nozzle
Circle(108) = {35, 22, 36}; // left
Circle(109) = {36, 22, 37}; // bottom
Circle(110) = {37, 22, 38}; // right
Circle(111) = {38, 22, 35}; // top

// Radial connectors across the chamber annulus (wall corner -> chamber corner)
Line(112) = {31, 35}; // top-left
Line(113) = {32, 36}; // bottom-left
Line(114) = {33, 37}; // bottom-right
Line(115) = {34, 38}; // top-right

// Outer circle of the extended chamber (z = 0), concentric with the nozzle
Circle(116) = {39, 22, 40}; // left
Circle(117) = {40, 22, 41}; // bottom
Circle(118) = {41, 22, 42}; // right
Circle(119) = {42, 22, 39}; // top

// Radial connectors across the extended annulus (chamber corner -> extended corner)
Line(120) = {35, 39}; // top-left
Line(121) = {36, 40}; // bottom-left
Line(122) = {37, 41}; // bottom-right
Line(123) = {38, 42}; // top-right

// --- Nozzle bore cross-section (unchanged) ---
Line Loop(9)  = {29, 30, 31, 32};    // central square (z = 0)
Line Loop(10) = {33, -13, 34, 32};
Line Loop(11) = {34, -31, 35, 15};
Line Loop(12) = {35, -14, 36, 30};
Line Loop(13) = {36, -29, 33, 6};

Line Loop(14) = {37, 38, 39, 40};    // central square (z = -dc)
Line Loop(15) = {41, -28, 42, 40};
Line Loop(16) = {42, -39, 43, 27};
Line Loop(17) = {43, -26, 44, 38};
Line Loop(18) = {44, -37, 41, 25};

// Nozzle-wall annulus segments (between bore circle and outer wall circle,
// z = 0). Extruded forward (fluid in the chamber) but NOT backward, so their
// backward sweep is the un-meshed solid nozzle wall.
Line Loop(19) = {6, 105, -100, -104};   // left
Line Loop(20) = {14, 106, -101, -105};  // bottom
Line Loop(21) = {15, 107, -102, -106};  // right
Line Loop(22) = {13, 104, -103, -107};  // top

// Chamber annulus segments (between outer wall circle and chamber circle,
// z = 0). This is the new circular replacement for the old rectangular outer
// ring: four 90deg sectors giving the chamber 4-fold angular symmetry.
Line Loop(1) = {100, 113, -108, -112};  // left
Line Loop(2) = {101, 114, -109, -113};  // bottom
Line Loop(3) = {102, 115, -110, -114};  // right
Line Loop(4) = {103, 112, -111, -115};  // top

// Extended (v2) annulus segments (between chamber circle and extended circle,
// z = 0). Four 90deg sectors, concentric with and conformal to the chamber
// annulus above; meshed with the coarser radial resolution nhp2.
Line Loop(5) = {108, 121, -116, -120};  // left
Line Loop(6) = {109, 122, -117, -121};  // bottom
Line Loop(7) = {110, 123, -118, -122};  // right
Line Loop(8) = {111, 120, -119, -123};  // top

Plane Surface(1)  = {1};
Plane Surface(2)  = {2};
Plane Surface(3)  = {3};
Plane Surface(4)  = {4};
Plane Surface(5)  = {5};
Plane Surface(6)  = {6};
Plane Surface(7)  = {7};
Plane Surface(8)  = {8};
Plane Surface(9)  = {9};
Plane Surface(10) = {10};
Plane Surface(11) = {11};
Plane Surface(12) = {12};
Plane Surface(13) = {13};
Plane Surface(14) = {14};
Plane Surface(15) = {15};
Plane Surface(16) = {16};
Plane Surface(17) = {17};
Plane Surface(18) = {18};
Plane Surface(19) = {19};
Plane Surface(20) = {20};
Plane Surface(21) = {21};
Plane Surface(22) = {22};

Transfinite Surface {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22};
Recombine Surface  {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22};


// Each Extrude below groups all of its base surfaces into a single command so
// shared edges stay conformal. The returned list is captured: every base
// surface is a quad, so it occupies a 6-entry block [top, volume, lat0, lat1,
// lat2, lat3], where lat_k is the swept k-th curve of that surface's Line Loop.
// Block i therefore starts at index 6*i (in the order the surfaces are listed).

// Projection zone (forward, +dp): full cross-section = chamber annulus (1-4)
// + bore O-grid (9-13) + nozzle-wall annulus (19-22) + extended annulus (5-8).
// Here the wall has ended, so the annulus region is open fluid. The extended
// ring is appended LAST so the earlier block indices are unchanged from v1.
// Order: 1..4, 9..13, 19..22, 5..8  (i = 0..16)
pA[] = Extrude {0, 0, dp} {
  Surface{1, 2, 3, 4, 9, 10, 11, 12, 13, 19, 20, 21, 22, 5, 6, 7, 8};
  Layers{zp}; Recombine;
};

// Charging zone / nozzle interior (backward, -dc): bore only.
// Order: 14..18  (i = 0..4)
pB[] = Extrude {0, 0, dc} {
  Surface{14, 15, 16, 17, 18};
  Layers{zc}; Recombine;
};

// Surrounding fluid drafted around the nozzle (backward, -dc): chamber annulus
// (1-4) + extended annulus (5-8). The nozzle-wall annulus is deliberately NOT
// extruded here, leaving the solid nozzle wall as a void between this volume and
// the nozzle interior. The cross-section at z = 0 matches surfaces 1-4 and 5-8
// exactly, so this is conformal with the projection zone. The extended ring is
// appended LAST so the earlier block indices are unchanged from v1.
// Order: 1..4, 5..8  (i = 0..7)
pC[] = Extrude {0, 0, -dc} {
  Surface{1, 2, 3, 4, 5, 6, 7, 8};
  Layers{zc}; Recombine;
};

// Circumferential (bore arcs, squares, wall circle, chamber circle,
// extended circle)
Transfinite Line {6, 13, 14, 15, 25, 26, 27, 28, 29, 30, 31, 32, 37, 38, 39, 40,
                  100, 101, 102, 103, 108, 109, 110, 111,
                  116, 117, 118, 119} = Ceil(nhc) Using Progression 1;
// Bore O-grid radial connectors (square corner -> bore circle)
Transfinite Line {33, 34, 35, 36, 41, 42, 43, 44} = Ceil(nwc) Using Progression 1;
// Nozzle wall thickness
Transfinite Line {104, 105, 106, 107} = Ceil(ntc) Using Progression 1;
// Chamber annulus radial (wall circle -> chamber circle), graded outward
Transfinite Line {112, 113, 114, 115} = Ceil(nhp) Using Progression exp;
// Extended annulus radial (chamber circle -> extended circle), coarser
Transfinite Line {120, 121, 122, 123} = Ceil(nhp2) Using Progression exp2;


// Fluid volumes: 17 (projection) + 5 (nozzle interior) + 8 (surrounding) = 30,
// created sequentially by the three Extrudes. The nozzle wall is never
// extruded, so it is absent from every volume (un-meshed solid).
Physical Volume(0) = {1:30};

// --- Boundary groups, addressed through the captured Extrude lists so the IDs
//     survive any geometry renumbering. Index = 6*block + slot, where slot 0 is
//     the top face and slots 2-5 are the swept Line Loop curves (in order).

// (0) Inlet: nozzle interior back face (z = -dc), stable base surfaces.
Physical Surface(0) = {14, 15, 16, 17, 18};

// (1) Anterior face of the chamber (z = -dc, the face the nozzle exits through):
//     top faces of the backward chamber-annulus + extended-annulus extrusion pC.
//     chamber annulus = pC cells 0..3; extended annulus = pC cells 4..7.
Physical Surface(1) = {pC[0], pC[6], pC[12], pC[18],
                       pC[24], pC[30], pC[36], pC[42]};

// (2) Downstream wall (z = +dp): every top face of the forward extrusion pA,
//     including the four extended-annulus cells appended last (i = 13..16).
Physical Surface(2) = {pA[0], pA[6], pA[12], pA[18], pA[24], pA[30], pA[36],
                       pA[42], pA[48], pA[54], pA[60], pA[66], pA[72],
                       pA[78], pA[84], pA[90], pA[96]};

// (3) Nozzle wall (no-slip): inner cylinder + outer cylinder + rim.
//   inner cylinder = swept bore arcs 28,27,26,25  (pB cells 15,16,17,18)
//   outer cylinder = swept outer-wall arcs 100,101,102,103  (pC cells 1,2,3,4)
//   rim            = annulus end caps at z = 0  (stable base surfaces 19-22)
Physical Surface(3) = {pB[9], pB[17], pB[21], pB[29],
                       pC[2], pC[8], pC[14], pC[20],
                       19, 20, 21, 22};

// (4) Lateral chamber wall: the cylindrical outer wall of the extended chamber,
//     i.e. the swept extended-circle arcs 116,117,118,119 from BOTH extrusions
//     pA (forward, cells 13..16) and pC (backward, cells 4..7), spanning
//     z = -dc to z = +dp. In each extended-annulus block the outer arc is the
//     3rd swept curve (slot 4). The old chamber arcs 108-111 are now interior
//     (shared between the chamber and extended annulus) and are omitted here.
Physical Surface(4) = {pA[82], pA[88], pA[94], pA[100],
                       pC[28], pC[34], pC[40], pC[46]};
