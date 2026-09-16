#!/bin/bash
#SBATCH --time=0-12:00
#SBATCH --account=rrg-blaisbru
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=192
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=charles.wilson@etud.polymtl.ca
#SBATCH --mail-type=ALL
#SBATCH --job-name=fluid_warmup_jow_3d_particle_fluid_cyl_v5_noslip_nozzle_boxref_q2q2_Re_480

export OMP_NUM_THREADS=1
ulimit -s 8192

export OMPI_MCA_btl_openib_warn_no_device_params_found=0

export PLIJ_PATH=$SCRATCH/graphite_project/particle_laden_impinging_jet
source $HOME/.dealii

# prm paths are relative to this directory
cd $PLIJ_PATH/simulations/jow_3d_particle_fluid_cyl_v5_noslip_nozzle_boxref_q2q2_Re_480 || exit 1

PRM=jow_3d_particle_fluid_cyl_v5_noslip_nozzle_boxref_q2q2_Re_480.prm
MESH=$PLIJ_PATH/meshes/jet_on_wall_3d_lab_specs_cyl_v5.msh

# Stage the mesh onto each node's local disk. deal.II needs the coarse mesh on
# every rank, so every rank parses this same 89 MB file. Read off the shared
# filesystem that is 192*nodes concurrent readers on one file: "Read mesh,
# manifolds and particles" was 21 s on 2 nodes but 988 s on 4 (job 2318280).
# One copy per node turns that back into a local read. $SLURM_TMPDIR is the
# same path on every node, so the rewritten prm below is valid everywhere.
# Staged with mpirun rather than srun, which behaves poorly on VAST.
[ -n "$SLURM_TMPDIR" ] || { echo "SLURM_TMPDIR is not set; refusing to stage"; exit 1; }
[ -r "$MESH" ]         || { echo "mesh not readable: $MESH"; exit 1; }

mpirun --map-by ppr:1:node -x SLURM_TMPDIR bash -c '
  set -e
  mkdir -p "$SLURM_TMPDIR"
  cp "$0" "$SLURM_TMPDIR/mesh.msh"
  cmp -s "$0" "$SLURM_TMPDIR/mesh.msh"
  # point the prm at the node-local copy; every other path stays relative to CWD
  sed -E "s|^([[:space:]]*set file name[[:space:]]*=).*|\1 $SLURM_TMPDIR/mesh.msh|" \
      "$1" > "$SLURM_TMPDIR/$1"
  grep -q "^[[:space:]]*set file name[[:space:]]*= $SLURM_TMPDIR/mesh.msh$" "$SLURM_TMPDIR/$1"
  echo "staged mesh on $(hostname)"
' "$MESH" "$PRM" || { echo "mesh staging failed"; exit 1; }

# outputs/ and the restart files still resolve against the CWD above, on $SCRATCH
mpirun $HOME/lethe/inst/bin/lethe-fluid-particles $SLURM_TMPDIR/$PRM
