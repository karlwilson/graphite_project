#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2025 The Lethe Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception OR LGPL-2.1-or-later
"""Build jet_on_wall_3d_lab_specs_cyl_v4.msh from the .geo.

The v4 mesh mixes z-extruded blocks with rotationally swept transition rings.
Every interface carries coincident nodes, but gmsh only merges geometry that is
entity-identical, so the CLI alone leaves the band-to-ring interfaces and the
360 deg seams unwelded. This driver meshes through the API and calls
removeDuplicateNodes(), then verifies that the result is actually conforming --
deal.II's GridIn does not check, and would read an unwelded mesh as a domain
with internal cracks.

    python3 build_v4.py [--check-only]
"""
import sys
import collections
import gmsh

HERE = __file__.rsplit("/", 1)[0]
GEO = f"{HERE}/jet_on_wall_3d_lab_specs_cyl_v4.geo"
MSH = f"{HERE}/jet_on_wall_3d_lab_specs_cyl_v4.msh"

HEX_FACES = [(0, 1, 2, 3), (4, 5, 6, 7), (0, 1, 5, 4),
             (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)]


def build():
    gmsh.initialize()
    gmsh.option.setNumber("General.Terminal", 1)
    gmsh.open(GEO)
    gmsh.model.mesh.generate(3)
    before = len(gmsh.model.mesh.getNodes()[0])
    gmsh.model.mesh.removeDuplicateNodes()
    after = len(gmsh.model.mesh.getNodes()[0])
    print(f"welded {before - after} duplicate nodes ({before} -> {after})")
    gmsh.option.setNumber("Mesh.MshFileVersion", 4.1)
    gmsh.write(MSH)
    gmsh.finalize()


def verify():
    """Conformity + aspect ratio. Fails loudly rather than shipping a crack."""
    import numpy as np
    gmsh.initialize()
    gmsh.option.setNumber("General.Terminal", 0)
    gmsh.open(MSH)
    tags, coords, _ = gmsh.model.mesh.getNodes()
    X = {int(t): np.array(coords[3 * i:3 * i + 3]) for i, t in enumerate(tags)}
    hexes = []
    for dim, tag in gmsh.model.getEntities(3):
        et, _, nod = gmsh.model.mesh.getElements(dim, tag)
        for t, nn in zip(et, nod):
            if t == 5:
                hexes += [list(map(int, nn[i:i + 8])) for i in range(0, len(nn), 8)]
    gmsh.finalize()

    seen = collections.defaultdict(int)
    for t, p in X.items():
        seen[tuple(np.round(p, 9))] += 1
    dup = sum(v - 1 for v in seen.values() if v > 1)

    faces = collections.Counter()
    for h in hexes:
        for f in HEX_FACES:
            faces[tuple(sorted(h[k] for k in f))] += 1
    over = sum(1 for v in faces.values() if v > 2)

    ed = [(0, 1), (1, 2), (2, 3), (3, 0), (4, 5), (5, 6), (6, 7), (7, 4),
          (0, 4), (1, 5), (2, 6), (3, 7)]
    ar = np.array([max(e) / min(e) for e in
                   ([np.linalg.norm(X[h[a]] - X[h[b]]) for a, b in ed] for h in hexes)])

    print(f"{len(X)} nodes, {len(hexes)} hexes")
    print(f"duplicate-coordinate nodes : {dup}")
    print(f"faces used more than twice : {over}")
    print(f"aspect ratio  median {np.median(ar):.2f}  "
          f"90th {np.percentile(ar, 90):.1f}  max {ar.max():.1f}")
    ok = dup == 0 and over == 0
    print("CONFORMING" if ok else "NOT CONFORMING -- do not use this mesh")
    return 0 if ok else 1


if __name__ == "__main__":
    if "--check-only" not in sys.argv:
        build()
    sys.exit(verify())
