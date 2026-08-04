// SPDX-FileCopyrightText: Copyright (c) 2025 The Lethe Authors
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception OR LGPL-2.1-or-later

// Cylindrical jet in a cylindrical chamber. v4 keeps the geometry of v3
// (all radii and depths identical) and the balanced-ball bore, but breaks the
// aspect-ratio invariant that limits v3.
//
// In v3 one axial count is shared by the whole cross-section, so
//     AR(r) / AR(bore) = r / r_bore = 114
// is fixed by geometry: an isotropic bore (zc=84/zp=56) forces AR 43.7 at Rc
// and 87.4 at Rc2, and no choice of nhp/exp/nb can change it (the binding edge
// out there is the circumferential chord over dz, and dz ~ 1/(nb-1) cancels
// the chord's own 1/(nb-1)).
//
// v4 lets dz vary with radius. Three 2:1 transition rings coarsen the axial
// spacing outward, each ring being a conforming 3-quad template (a hanging
// node made conforming - deal.II cannot read a level-0 hanging node, see
// GridIn's documentation, and would silently treat it as an internal crack).
// Result: bore AR ~1.1 AND max AR ~11, with 11% fewer cells than v3.
//
// Construction: the bore and the nozzle-wall annulus are an xy cross-section
// extruded in z (as in v3). The annulus bands are xy sectors extruded in z
// with their own layer count. The transition rings are (x,z) faces revolved
// 8 x 45deg.
//
// !! BUILD STEP !! Meshing this file with the gmsh CLI alone leaves duplicate
// nodes on the band-to-ring interfaces and on the 360deg seam of each revolved
// ring: gmsh merges only entity-identical geometry, and a band's lateral
// surface (one patch per zone) is not the same entity as the ring's (one patch
// per coarse cell), even though every node coincides. "Coherence" and
// "Coherence Mesh" both leave those nodes unmerged. Build with build_v4.py,
// which runs the gmsh API and calls removeDuplicateNodes() after meshing. A
// mesh built without that step is NOT conforming and deal.II will silently
// read it as a cracked domain. Always verify afterwards that every internal
// face is used by exactly two hexes.

// Entity-by-entity duplicate checking is O(n^2) here (about 3000 revolved
// volumes); switching it off takes the geometry stage from minutes to seconds.
// It is safe because the weld above is what actually makes the mesh conforming.
Geometry.AutoCoherence = 0;

// ---------------------------------------------------------------- parameters
wc  = 0.0072 / Sqrt(2);   // nozzle square half-diagonal (sets the bore radius)
rb  = wc / Sqrt(2);       // bore radius
rbd = rb / Sqrt(2);       // diagonal boundary coordinate ( = wc/2 )
ri  = 0.55647 * rb;       // deal.II inner-axis radius
rq  = 0.42883 * rb;       // deal.II interior-diagonal coordinate
tc  = 0.00125;            // nozzle tube wall thickness
wo  = wc/2 + tc/Sqrt(2);  // nozzle outer-wall half-diagonal
Rw  = wo * Sqrt(2);       // nozzle outer-wall radius
dc  = 0.075;              // depth (z) of charging zone / nozzle interior
dp  = 0.05;               // depth (z) of projection zone
Rc2 = 0.2;                // chamber radius (v3's intermediate ring at Rc=0.1
                          // is dropped: it carried no boundary condition and
                          // the graded bands now span Rw->Rc2 in one system)

nb   = 3;      // points per 45deg arc  (circumferential; also inner-quad edges)
nbr  = 3;      // points across a bore cap (radial)
ntc  = 1;      // points across the nozzle wall thickness

// Axial counts. Both MUST be divisible by 2^(number of transition rings) = 8.
// dz is then ~0.87 mm, inside the central pinwheel's in-plane edge range
// (0.850-0.948 mm), so the bore cells stay isotropic as in v3.
zp   = 56;     // z cells in the projection zone at factor 1 (forward, +dp)
zc   = 88;     // z cells in the charging zone   at factor 1 (backward, -dc)

// THE knob: coarsen dz one step whenever a cell's circumferential chord
// reaches arT * dz. Lower arT = lower aspect ratio but the fine-dz region
// shrinks toward the nozzle; higher arT pushes the transitions outward.
arT  = 8.0;

// ------------------------------------------------------- derived radial plan
dzp = dp / zp;             // reference dz (projection zone)
CH  = 2 * Sin(Pi/16);      // circumferential chord per cell, divided by r

// transition radii and ring thicknesses (thickness = coarse cell height,
// which is where the 3-quad template is least skewed)
tR0 = arT * dzp / CH;      tW0 = 2 * dzp;
tR1 = arT * 2*dzp / CH;    tW1 = 4 * dzp;
tR2 = arT * 4*dzp / CH;    tW2 = 8 * dzp;

// uniform bands: inner radius, outer radius, radial cells, axial coarsening
bA0[] = {Rw,          tR0 + tW0,   tR1 + tW1,   tR2 + tW2};
bA1[] = {tR0,         tR1,         tR2,         Rc2};
bNr[] = {3,           2,           2,           2};
bF [] = {1,           2,           4,           8};

tRi[] = {tR0, tR1, tR2};   // transition ring inner radii
tWi[] = {tW0, tW1, tW2};   // transition ring thicknesses
tFc[] = {2,   4,   8};     // coarse-side factor of each ring

// ------------------------------------------------------- bore points (z = 0)
Point(1) = {0, 0, 0};
Point(10) = {rb, 0, 0};      Point(11) = {rbd, rbd, 0};
Point(12) = {0, rb, 0};      Point(13) = {-rbd, rbd, 0};
Point(14) = {-rb, 0, 0};     Point(15) = {-rbd, -rbd, 0};
Point(16) = {0, -rb, 0};     Point(17) = {rbd, -rbd, 0};
Point(20) = {ri, 0, 0};      Point(21) = {0, ri, 0};
Point(22) = {-ri, 0, 0};     Point(23) = {0, -ri, 0};
Point(30) = {rq, rq, 0};     Point(31) = {-rq, rq, 0};
Point(32) = {-rq, -rq, 0};   Point(33) = {rq, -rq, 0};
Point(40) = {Rw, 0, 0};      Point(41) = {wo, wo, 0};
Point(42) = {0, Rw, 0};      Point(43) = {-wo, wo, 0};
Point(44) = {-Rw, 0, 0};     Point(45) = {-wo, -wo, 0};
Point(46) = {0, -Rw, 0};     Point(47) = {wo, -wo, 0};

// bore points duplicated at z = -dc for the nozzle interior (+100 offset)
Point(101) = {0, 0, -dc};
Point(110) = {rb, 0, -dc};   Point(111) = {rbd, rbd, -dc};
Point(112) = {0, rb, -dc};   Point(113) = {-rbd, rbd, -dc};
Point(114) = {-rb, 0, -dc};  Point(115) = {-rbd, -rbd, -dc};
Point(116) = {0, -rb, -dc};  Point(117) = {rbd, -rbd, -dc};
Point(120) = {ri, 0, -dc};   Point(121) = {0, ri, -dc};
Point(122) = {-ri, 0, -dc};  Point(123) = {0, -ri, -dc};
Point(130) = {rq, rq, -dc};  Point(131) = {-rq, rq, -dc};
Point(132) = {-rq, -rq, -dc};Point(133) = {rq, -rq, -dc};

// --- front (z = 0) bore: arcs / radials / octagon / spokes ---
For k In {0:7}
  Circle(200+k) = {10+k, 1, 10+((k+1)%8)};
EndFor
Line(210) = {10, 20};  Line(211) = {11, 30};  Line(212) = {12, 21};
Line(213) = {13, 31};  Line(214) = {14, 22};  Line(215) = {15, 32};
Line(216) = {16, 23};  Line(217) = {17, 33};
Line(220) = {20, 30};  Line(221) = {30, 21};  Line(222) = {21, 31};
Line(223) = {31, 22};  Line(224) = {22, 32};  Line(225) = {32, 23};
Line(226) = {23, 33};  Line(227) = {33, 20};
Line(230) = {1, 20};   Line(231) = {1, 21};
Line(232) = {1, 22};   Line(233) = {1, 23};

Line Loop(1) = {230, 220, 221, -231};   Plane Surface(1) = {1};
Line Loop(2) = {231, 222, 223, -232};   Plane Surface(2) = {2};
Line Loop(3) = {232, 224, 225, -233};   Plane Surface(3) = {3};
Line Loop(4) = {233, 226, 227, -230};   Plane Surface(4) = {4};
Line Loop(5) = {200, 211, -220, -210};  Plane Surface(5) = {5};
Line Loop(6) = {201, 212, -221, -211};  Plane Surface(6) = {6};
Line Loop(7) = {202, 213, -222, -212};  Plane Surface(7) = {7};
Line Loop(8) = {203, 214, -223, -213};  Plane Surface(8) = {8};
Line Loop(9) = {204, 215, -224, -214};  Plane Surface(9) = {9};
Line Loop(10) = {205, 216, -225, -215}; Plane Surface(10) = {10};
Line Loop(11) = {206, 217, -226, -216}; Plane Surface(11) = {11};
Line Loop(12) = {207, 210, -227, -217}; Plane Surface(12) = {12};

// --- nozzle-wall annulus (rb -> Rw), fluid only for z > 0 ---
For k In {0:7}
  Circle(240+k) = {40+k, 1, 40+((k+1)%8)};
  Line(250+k) = {10+k, 40+k};
EndFor
For k In {0:7}
  Line Loop(13+k) = {200+k, 250+((k+1)%8), -(240+k), -(250+k)};
  Plane Surface(13+k) = {13+k};
EndFor

// --- back (z = -dc) bore, extruded forward as the nozzle interior ---
For k In {0:7}
  Circle(300+k) = {110+k, 101, 110+((k+1)%8)};
EndFor
Line(310) = {110, 120}; Line(311) = {111, 130}; Line(312) = {112, 121};
Line(313) = {113, 131}; Line(314) = {114, 122}; Line(315) = {115, 132};
Line(316) = {116, 123}; Line(317) = {117, 133};
Line(320) = {120, 130}; Line(321) = {130, 121}; Line(322) = {121, 131};
Line(323) = {131, 122}; Line(324) = {122, 132}; Line(325) = {132, 123};
Line(326) = {123, 133}; Line(327) = {133, 120};
Line(330) = {101, 120}; Line(331) = {101, 121};
Line(332) = {101, 122}; Line(333) = {101, 123};

Line Loop(41) = {330, 320, 321, -331};  Plane Surface(41) = {41};
Line Loop(42) = {331, 322, 323, -332};  Plane Surface(42) = {42};
Line Loop(43) = {332, 324, 325, -333};  Plane Surface(43) = {43};
Line Loop(44) = {333, 326, 327, -330};  Plane Surface(44) = {44};
Line Loop(45) = {300, 311, -320, -310}; Plane Surface(45) = {45};
Line Loop(46) = {301, 312, -321, -311}; Plane Surface(46) = {46};
Line Loop(47) = {302, 313, -322, -312}; Plane Surface(47) = {47};
Line Loop(48) = {303, 314, -323, -313}; Plane Surface(48) = {48};
Line Loop(49) = {304, 315, -324, -314}; Plane Surface(49) = {49};
Line Loop(50) = {305, 316, -325, -315}; Plane Surface(50) = {50};
Line Loop(51) = {306, 317, -326, -316}; Plane Surface(51) = {51};
Line Loop(52) = {307, 310, -327, -317}; Plane Surface(52) = {52};

// --------------------------------------------- uniform annulus bands (xy)
// ring j of points/arcs: 1000+10*j+k / 1100+10*j+k.  Band b uses ring 2*b-1 as
// its inner ring (band 0 uses the Rw ring, points 40+k / arcs 240+k) and ring
// 2*b as its outer ring.
For j In {0:6}
  rr = (j % 2 == 0) ? bA1[j/2] : bA0[(j+1)/2];
  For k In {0:7}
    ang = k * Pi/4;
    Point(1000+10*j+k) = {rr*Cos(ang), rr*Sin(ang), 0};
  EndFor
  For k In {0:7}
    Circle(1100+10*j+k) = {1000+10*j+k, 1, 1000+10*j+((k+1)%8)};
  EndFor
EndFor

pIn[] = {40,  1010, 1030, 1050};   // inner ring point base per band
cIn[] = {240, 1110, 1130, 1150};   // inner ring arc base per band
pOut[] = {1000, 1020, 1040, 1060};
cOut[] = {1100, 1120, 1140, 1160};

For b In {0:3}
  For k In {0:7}
    Line(1200+10*b+k) = {pIn[b]+k, pOut[b]+k};
  EndFor
  For k In {0:7}
    Line Loop(1300+10*b+k) = {cIn[b]+k, 1200+10*b+((k+1)%8),
                              -(cOut[b]+k), -(1200+10*b+k)};
    Plane Surface(1300+10*b+k) = {1300+10*b+k};
  EndFor
EndFor

// ------------------------------------------- transition rings ((x,z) faces)
// One 2:1 template per coarse cell, alternating orientation so the stack
// tiles: T (extra node on its bottom radial edge) then T' (mirror, extra node
// on top). Global cell index even -> T, odd -> T'. Quad order per cell is
// (Q1,Q2,Q3), so cell i's quads are at list positions 3i, 3i+1, 3i+2.
tS0[] = {}; tS1[] = {}; tS2[] = {};   // quad lists, one per ring
tN0 = 0; tN1 = 0; tN2 = 0;            // number of coarse cells per ring

For t In {0:2}
  ra = tRi[t];  rmid = tRi[t] + tWi[t]/2;  rbo = tRi[t] + tWi[t];
  ncl = zc / tFc[t];    // coarse cells in the charging zone
  ncu = zp / tFc[t];    // coarse cells in the projection zone
  For i In {0:ncl+ncu-1}
    If (i < ncl)
      Z0 = -dc + i * (dc/ncl);       Z1 = Z0 + dc/ncl;
    Else
      Z0 = (i-ncl) * (dp/ncu);       Z1 = Z0 + dp/ncu;
    EndIf
    Zm = 0.5*(Z0+Z1);
    pC = newp; Point(pC) = {ra,   0, Z0};
    pM = newp; Point(pM) = {ra,   0, Zm};
    pD = newp; Point(pD) = {ra,   0, Z1};
    pA = newp; Point(pA) = {rbo,  0, Z0};
    pB = newp; Point(pB) = {rbo,  0, Z1};
    pP = newp; Point(pP) = {rmid, 0, Zm};
    If (i % 2 == 0)
      // T : extra node N on the bottom edge
      pN = newp; Point(pN) = {rmid, 0, Z0};
      lCN = newl; Line(lCN) = {pC, pN};   lNA = newl; Line(lNA) = {pN, pA};
      lNP = newl; Line(lNP) = {pN, pP};   lPM = newl; Line(lPM) = {pP, pM};
      lMC = newl; Line(lMC) = {pM, pC};   lMP = newl; Line(lMP) = {pM, pP};
      lPB = newl; Line(lPB) = {pP, pB};   lBD = newl; Line(lBD) = {pB, pD};
      lDM = newl; Line(lDM) = {pD, pM};   lAB = newl; Line(lAB) = {pA, pB};
      lBP = newl; Line(lBP) = {pB, pP};   lPN = newl; Line(lPN) = {pP, pN};
      q1 = news; Line Loop(q1) = {lCN, lNP, lPM, lMC}; Plane Surface(q1) = {q1};
      q2 = news; Line Loop(q2) = {lMP, lPB, lBD, lDM}; Plane Surface(q2) = {q2};
      q3 = news; Line Loop(q3) = {lNA, lAB, lBP, lPN}; Plane Surface(q3) = {q3};
      Transfinite Line{lCN,lNA,lNP,lPM,lMC,lMP,lPB,lBD,lDM,lAB,lBP,lPN} = 2;
    Else
      // T' : mirror, extra node N on the top edge
      pN = newp; Point(pN) = {rmid, 0, Z1};
      lDN = newl; Line(lDN) = {pD, pN};   lNB = newl; Line(lNB) = {pN, pB};
      lNP = newl; Line(lNP) = {pN, pP};   lPM = newl; Line(lPM) = {pP, pM};
      lMD = newl; Line(lMD) = {pM, pD};   lMP = newl; Line(lMP) = {pM, pP};
      lPA = newl; Line(lPA) = {pP, pA};   lAC = newl; Line(lAC) = {pA, pC};
      lCM = newl; Line(lCM) = {pC, pM};   lBA = newl; Line(lBA) = {pB, pA};
      lAP = newl; Line(lAP) = {pA, pP};   lPN = newl; Line(lPN) = {pP, pN};
      q1 = news; Line Loop(q1) = {lDN, lNP, lPM, lMD}; Plane Surface(q1) = {q1};
      q2 = news; Line Loop(q2) = {lMP, lPA, lAC, lCM}; Plane Surface(q2) = {q2};
      q3 = news; Line Loop(q3) = {lNB, lBA, lAP, lPN}; Plane Surface(q3) = {q3};
      Transfinite Line{lDN,lNB,lNP,lPM,lMD,lMP,lPA,lAC,lCM,lBA,lAP,lPN} = 2;
    EndIf
    Transfinite Surface{q1, q2, q3};
    Recombine Surface{q1, q2, q3};
    If (t == 0)
      tS0[] += q1; tS0[] += q2; tS0[] += q3;
    EndIf
    If (t == 1)
      tS1[] += q1; tS1[] += q2; tS1[] += q3;
    EndIf
    If (t == 2)
      tS2[] += q1; tS2[] += q2; tS2[] += q3;
    EndIf
  EndFor
  If (t == 0)
    tN0 = ncl + ncu;
  EndIf
  If (t == 1)
    tN1 = ncl + ncu;
  EndIf
  If (t == 2)
    tN2 = ncl + ncu;
  EndIf
EndFor

// ---------------------------------------------------------------- transfinite
Transfinite Surface {1:20, 41:52};
Recombine Surface  {1:20, 41:52};
For b In {0:3}
  Transfinite Surface {1300+10*b : 1300+10*b+7};
  Recombine Surface  {1300+10*b : 1300+10*b+7};
EndFor

// circumferential + inner-quad edges
Transfinite Line {200:207, 240:247, 300:307, 220:227, 320:327,
                  230:233, 330:333} = Ceil(nb) Using Progression 1;
For j In {0:6}
  Transfinite Line {1100+10*j : 1100+10*j+7} = Ceil(nb) Using Progression 1;
EndFor
// bore cap radial / nozzle wall thickness
Transfinite Line {210:217, 310:317} = Ceil(nbr) Using Progression 1;
Transfinite Line {250:257} = Ceil(ntc) Using Progression 1;
// annulus band radial, graded so dr tracks the circumferential chord
For b In {0:3}
  Transfinite Line {1200+10*b : 1200+10*b+7} =
      bNr[b]+1 Using Progression (bA1[b]/bA0[b])^(1/bNr[b]);
EndFor

// ---------------------------------------------------------------- extrusions
top2[] = {};   // z = +dp faces   -> Physical Surface(2)
top1[] = {};   // z = -dc faces   -> Physical Surface(1)
wall3[] = {};  // no-slip nozzle  -> Physical Surface(3)
lat4[] = {};   // r = Rc2         -> Physical Surface(4)

// bore + nozzle-wall annulus, forward (+dp), always at factor 1
pA0[] = Extrude {0, 0, dp} {
  Surface{1:20}; Layers{zp}; Recombine;
};
For i In {0:19}
  top2[] += pA0[6*i];
EndFor

// nozzle interior, forward (+dc) from z = -dc
pB0[] = Extrude {0, 0, dc} {
  Surface{41:52}; Layers{zc}; Recombine;
};
For i In {4:11}
  wall3[] += pB0[6*i+2];      // swept bore-cap arcs = inner nozzle cylinder
EndFor

// uniform annulus bands, forward and backward, each at its own layer count
For b In {0:3}
  fw[] = Extrude {0, 0, dp} {
    Surface{1300+10*b : 1300+10*b+7}; Layers{zp/bF[b]}; Recombine;
  };
  bw[] = Extrude {0, 0, -dc} {
    Surface{1300+10*b : 1300+10*b+7}; Layers{zc/bF[b]}; Recombine;
  };
  For k In {0:7}
    top2[] += fw[6*k];
    top1[] += bw[6*k];
    If (b == 0)
      wall3[] += bw[6*k+2];   // r = Rw cylinder for z < 0 = nozzle outer wall
    EndIf
    If (b == 3)
      lat4[] += fw[6*k+4];    // r = Rc2
      lat4[] += bw[6*k+4];
    EndIf
  EndFor
EndFor

// transition rings: revolve the (x,z) quad stack 8 x 45deg
For t In {0:2}
  If (t == 0)
    cur[] = tS0[]; nc = tN0;
  EndIf
  If (t == 1)
    cur[] = tS1[]; nc = tN1;
  EndIf
  If (t == 2)
    cur[] = tS2[]; nc = tN2;
  EndIf
  For s In {1:8}
    out[] = Extrude {{0,0,1}, {0,0,0}, Pi/4} {
      Surface{cur[]}; Layers{nb-1}; Recombine;
    };
    // bottom of the stack is always a T cell: its z=-dc faces are the first
    // edge of Q1 and of Q3.
    top1[] += out[2];              // cell 0, Q1, edge 0
    top1[] += out[6*2+2];          // cell 0, Q3, edge 0
    // top of the stack: T' -> first edge of Q1' and Q3'; T -> third edge of Q2
    If ((nc-1) % 2 == 1)
      top2[] += out[6*(3*(nc-1)  )+2];
      top2[] += out[6*(3*(nc-1)+2)+2];
    Else
      top2[] += out[6*(3*(nc-1)+1)+4];
    EndIf
    nxt[] = {};
    For i In {0:#cur[]-1}
      nxt[] += out[6*i];
    EndFor
    cur[] = nxt[];
  EndFor
EndFor

// One global pass to collapse the duplicates that ARE entity-identical (the
// 360deg seams and the r=Rw interface). Not enough on its own - see the build
// note at the top - but it takes the written mesh from 23 MB to 7.6 MB by
// dropping ~145k redundant geometric points, and it leaves the physical
// groups intact (verified: all five keep their exact face counts).
Coherence;

// The weld (removeDuplicateNodes) happens in build_v4.py, after meshing:
// band-to-ring interfaces, the 360deg seam of each revolved ring, and the
// r = Rw interface between the xy block and band 0.

// ---------------------------------------------------------------- physical groups
Physical Volume(0) = Volume{:};

// (0) Inlet: nozzle interior back face (z = -dc)
Physical Surface(0) = {41:52};
// (1) Anterior chamber face (z = -dc)
Physical Surface(1) = top1[];
// (2) Downstream wall (z = +dp)
Physical Surface(2) = top2[];
// (3) Nozzle wall (no-slip): inner cylinder, outer cylinder, and the rim
Physical Surface(3) = {wall3[], 13:20};
// (4) Lateral chamber wall (r = Rc2)
Physical Surface(4) = lat4[];
