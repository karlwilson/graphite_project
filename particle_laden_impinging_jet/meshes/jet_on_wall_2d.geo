// SPDX-FileCopyrightText: Copyright (c) 2025 The Lethe Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception OR LGPL-2.1-or-later

// 2D midplane cross-section of a particle-laden jet impinging on a wall.
// x-axis: lateral (horizontal), y-axis: flow direction (positive toward wall).
// Domain: nozzle (wc wide, dc tall) connected to chamber (hp wide, dp tall).
// Nozzle-chamber junction is at y=0; impingement wall is at y=dp.

// Projection zone (main chamber)
hp = 0.18;   // width of chamber
dp = 0.02;   // height of chamber (jet-to-wall distance)
zp = 20;     // cells in flow direction (chamber)
nhp = 31;    // points across each chamber half-width (graded toward jet)
exp = 1.05;  // grading progression toward jet axis

// Jet nozzle (charging zone)
wc = 0.007;  // nozzle width
dc = 0.036;  // nozzle length
zc = 40;     // cells in flow direction (nozzle)
nhc = 10;    // points across nozzle half-width

// Points — nozzle-chamber junction level (y = 0)
Point(1) = {-hp/2, 0, 0};   // chamber: outer left
Point(2) = {-wc/2, 0, 0};   // junction: inner left
Point(3) = { wc/2, 0, 0};   // junction: inner right
Point(4) = { hp/2, 0, 0};   // chamber: outer right

// Points — impingement wall (y = dp)
Point(5) = {-hp/2, dp, 0};
Point(6) = {-wc/2, dp, 0};
Point(7) = { wc/2, dp, 0};
Point(8) = { hp/2, dp, 0};

// Points — nozzle inlet (y = -dc)
Point(9)  = {-wc/2, -dc, 0};
Point(10) = { wc/2, -dc, 0};

// Lines — junction level (y = 0)
Line(1) = {1, 2};    // left anterior wall
Line(2) = {2, 3};    // jet entry opening
Line(3) = {3, 4};    // right anterior wall

// Lines — impingement wall (y = dp)
Line(4) = {5, 6};    // left section
Line(5) = {6, 7};    // center section
Line(6) = {7, 8};    // right section

// Lines — vertical (chamber)
Line(7)  = {1, 5};   // left side wall
Line(8)  = {2, 6};   // left divider
Line(9)  = {3, 7};   // right divider
Line(10) = {4, 8};   // right side wall

// Lines — nozzle
Line(11) = {9, 10};  // inlet
Line(12) = {9, 2};   // left nozzle wall
Line(13) = {10, 3};  // right nozzle wall

// Surfaces (counter-clockwise line loops)
Line Loop(1) = {1, 8, -4, -7};     // left chamber patch
Line Loop(2) = {2, 9, -5, -8};     // center chamber patch
Line Loop(3) = {3, 10, -6, -9};    // right chamber patch
Line Loop(4) = {11, 13, -2, -12};  // nozzle patch

Plane Surface(1) = {1};
Plane Surface(2) = {2};
Plane Surface(3) = {3};
Plane Surface(4) = {4};

// Transfinite meshing
// Nozzle width and center chamber — uniform
Transfinite Line {2, 5, 11} = nhc Using Progression 1;

// Chamber half-widths — graded fine toward jet axis
// Lines 1 and 4 go outer→inner, so reversed (-) gives fine end at inner node
Transfinite Line {-1, -4} = nhp Using Progression exp;
// Lines 3 and 6 go inner→outer, so forward gives fine end at inner node
Transfinite Line {3, 6} = nhp Using Progression exp;

// Flow direction — chamber (uniform, zp cells → zp+1 points)
Transfinite Line {7, 8, 9, 10} = zp + 1 Using Progression 1;

// Flow direction — nozzle (uniform, zc cells → zc+1 points)
Transfinite Line {12, 13} = zc + 1 Using Progression 1;

Transfinite Surface {1, 2, 3, 4};
Recombine Surface {1, 2, 3, 4};

// Physical groups (boundary IDs match 3D convention)
Physical Surface(0) = {1, 2, 3, 4};  // fluid domain

Physical Line(0) = {11};             // Inlet
Physical Line(1) = {1, 3};           // Anterior wall (solid face at junction level)
Physical Line(2) = {4, 5, 6};        // Impingement wall (back wall)
Physical Line(3) = {12, 13};         // Nozzle walls (pipe wall)
Physical Line(4) = {7, 10};          // Side walls (contour)
